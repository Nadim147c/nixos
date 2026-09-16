package main

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"hash/fnv"
	"image"
	"image/draw"
	"image/png"
	"io"
	"log"
	"math"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"sync"

	_ "image/jpeg"
	_ "image/png"

	"github.com/Nadim147c/material/v3/color"
	"github.com/Nadim147c/material/v3/num"
	"github.com/Nadim147c/material/v3/quantizer"
	"github.com/spf13/pflag"
	xdraw "golang.org/x/image/draw"
	_ "golang.org/x/image/webp"
)

type point struct{ a, b float64 }

var (
	sourceImage string
	colors      []string
	maxColors   uint
	quality     uint
)

const sourceColorCount = 32

func init() {
	log.SetFlags(0)
	pflag.StringVarP(&sourceImage, "source", "s", sourceImage, "Source image for color")
	pflag.StringSliceVarP(&colors, "colors", "c", colors, "Source colors")
	pflag.UintVarP(&maxColors, "max-colors", "n", maxColors, "Maximum colors to use (0 means no quantization of input image)")
	pflag.UintVarP(&quality, "quality", "q", quality, "Output image height in pixels (0 keeps original height)")
}

func main() {
	pflag.Parse()
	if pflag.NArg() != 1 {
		log.Fatalf("expected 1 input but got %d\n", pflag.NArg())
	}

	inputLocation := pflag.Arg(0)

	buf, err := readLocation(inputLocation)
	if err != nil {
		log.Fatal(err)
	}

	img, err := decodeImage(buf)
	if err != nil {
		log.Fatal(err)
	}

	if quality > 0 {
		img = resizeToHeight(img, int(quality))
	}

	srcColors, err := loadSourceColors(sourceImage, colors)
	if err != nil {
		log.Fatal(err)
	}
	if len(srcColors) == 0 {
		log.Fatal("no source colors: provide -c/--color or -s/--source")
	}

	targets := pointsFromColors(srcColors)
	if len(targets) == 0 {
		log.Fatal("no usable hues in source colors")
	}

	in := ensureNRGBA(img)

	palette, err := quantizeInput(in, maxColors)
	if err != nil {
		log.Fatal(err)
	}

	p1, err := quantizeInput(in, 6)
	if err != nil {
		log.Fatal(err)
	}
	p2, err := quantizer.QuantizeWuContext(context.Background(), srcColors, 6)
	if err != nil {
		log.Fatal(err)
	}
	count := min(len(p1), len(p2))
	var direction float64
	var total float64
	for i := range count {
		a, b := p1[i].ToOkLch(), p2[i].ToOkLch()
		total += num.DifferenceDegrees(a.Hue, b.Hue)
		direction += num.RotationDirection(a.Hue, b.Hue)
	}

	difference := total / float64(count)
	hueRotate := 0.0
	if difference > 45 {
		hueRotate = num.Sign(direction) * difference
	}

	box := in.Bounds()
	out := image.NewNRGBA(box)

	processImage(in, out, targets, palette, hueRotate, maxColors != 0)

	outfilePath := filepath.Join(os.TempDir(), "mpris-cover.png")
	outfile, err := os.Create(outfilePath)
	if err != nil {
		log.Fatal(err)
	}
	defer outfile.Close()

	hasher := fnv.New64a()
	w := io.MultiWriter(outfile, hasher)
	if err := png.Encode(w, out); err != nil {
		log.Fatal(err)
	}

	query := url.Values{}
	query.Add("hash", hex.EncodeToString(hasher.Sum(nil)))

	finalURL := url.URL{
		Scheme:   "file",
		Path:     outfilePath,
		RawQuery: query.Encode(),
	}

	fmt.Println(finalURL.String())
}

// resizeToHeight scales img so its height equals targetH, preserving
// aspect ratio. Small images are returned as-is.
func resizeToHeight(img image.Image, targetH int) image.Image {
	b := img.Bounds()
	srcH := b.Dy()
	if targetH <= 0 || srcH <= targetH {
		return img
	}

	ratio := float64(targetH) / float64(srcH)
	targetW := max(math.Round(float64(b.Dx())*ratio), 1)

	dst := image.NewNRGBA(image.Rect(0, 0, int(targetW), targetH))
	xdraw.CatmullRom.Scale(dst, dst.Bounds(), img, b, xdraw.Over, nil)
	return dst
}

// processImage recolors in -> out in parallel. Each worker owns a
// contiguous range of rows, so no two workers ever touch the same cache
// line (rows are at least 64 bytes apart for any width >= 16).
func processImage(in, out *image.NRGBA, targets []point, palette []color.OkLab, hueRotate float64, quantize bool) {
	width := in.Bounds().Dx()
	height := in.Bounds().Dy()
	if width == 0 || height == 0 {
		return
	}

	inPix := in.Pix
	outPix := out.Pix
	inStride := in.Stride
	outStride := out.Stride

	workers := min(runtime.NumCPU(), height)
	rowsPerWorker := (height + workers - 1) / workers

	var wg sync.WaitGroup
	for w := range workers {
		y0 := w * rowsPerWorker
		y1 := min(y0+rowsPerWorker, height)
		if y0 >= y1 {
			break
		}

		wg.Go(func() {
			for y := y0; y < y1; y++ {
				inStart := y * inStride
				outStart := y * outStride
				end := inStart + width*4
				for i, j := inStart, outStart; i < end; i, j = i+4, j+4 {
					pix := inPix[i : i+4 : i+4]
					argb := color.NewARGB(pix[3], pix[0], pix[1], pix[2])

					var lab color.OkLab
					if quantize {
						lab = closestOkLab(palette, argb.ToOkLab())
					} else {
						lab = argb.ToOkLab()
					}

					if hueRotate != 0 {
						lch := lab.ToOkLch()
						lch.Hue += hueRotate
						lab = lch.ToOkLab()
					}

					d1, d2 := math.MaxFloat64, math.MaxFloat64
					var p1, p2, finalPoint point
					for _, p := range targets {
						da := lab.A - p.a
						db := lab.B - p.b
						distance := da*da + db*db

						if distance < d1 {
							d2 = d1
							p2 = p1
							d1 = distance
							p1 = p
						} else if distance < d2 {
							d2 = distance
							p2 = p
						}
					}
					da := p2.a - p1.a
					db := p2.b - p1.b
					lengthSq := da*da + db*db

					if lengthSq == 0 {
						finalPoint = p1
					} else {
						t := ((lab.A-p1.a)*da + (lab.B-p1.b)*db) / lengthSq

						if t < 0 {
							t = 0
						} else if t > 1 {
							t = 1
						}

						finalPoint = point{
							a: p1.a + t*da,
							b: p1.b + t*db,
						}
					}

					lab.A = finalPoint.a
					lab.B = finalPoint.b

					a, r, g, b := lab.ToARGB().Components()
					outPix[j] = r
					outPix[j+1] = g
					outPix[j+2] = b
					outPix[j+3] = a
				}
			}
		})
	}
	wg.Wait()
}

func readLocation(location string) ([]byte, error) {
	u, err := url.Parse(location)
	if err != nil {
		return nil, err
	}

	switch u.Scheme {
	case "http", "https":
		resp, err := http.Get(u.String())
		if err != nil {
			return nil, err
		}
		defer resp.Body.Close()

		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			return nil, fmt.Errorf("http %s: %s", u.String(), resp.Status)
		}
		return io.ReadAll(resp.Body)

	case "file":
		return os.ReadFile(u.Path)

	default:
		return os.ReadFile(location)
	}
}

func decodeImage(buf []byte) (image.Image, error) {
	img, _, err := image.Decode(bytes.NewReader(buf))
	return img, err
}

func imagePixels(img image.Image) []color.ARGB {
	box := img.Bounds()
	size := (box.Max.Y - box.Min.Y) * (box.Max.X - box.Min.X)

	pixels := make([]color.ARGB, 0, size)
	for y := box.Min.Y; y < box.Max.Y; y++ {
		for x := box.Min.X; x < box.Max.X; x++ {
			pixels = append(pixels, color.ARGBFromInterface(img.At(x, y)))
		}
	}
	return pixels
}

func loadSourceColors(sourceImage string, hexColors []string) ([]color.ARGB, error) {
	var src []color.ARGB

	for _, h := range hexColors {
		c, err := color.ARGBFromHex(h)
		if err != nil {
			return nil, fmt.Errorf("invalid source color %q: %w", h, err)
		}
		src = append(src, c)
	}

	if sourceImage != "" {
		buf, err := readLocation(sourceImage)
		if err != nil {
			return nil, fmt.Errorf("read source image: %w", err)
		}

		img, err := decodeImage(buf)
		if err != nil {
			return nil, fmt.Errorf("decode source image: %w", err)
		}

		pixels := imagePixels(img)
		q, err := quantizer.QuantizeWuContext(context.Background(), pixels, sourceColorCount)
		if err != nil {
			return nil, fmt.Errorf("quantize source image: %w", err)
		}
		src = append(src, q...)
	}

	return src, nil
}

func pointsFromColors(src []color.ARGB) []point {
	targets := make([]point, len(src))
	for i, c := range src {
		lab := c.ToOkLab()
		targets[i] = point{a: lab.A, b: lab.B}
	}
	return targets
}

func quantizeInput(img image.Image, maxColors uint) ([]color.OkLab, error) {
	if maxColors == 0 {
		return nil, nil
	}

	pixels := imagePixels(img)
	res, err := quantizer.QuantizeWuContext(context.Background(), pixels, int(maxColors))
	if err != nil {
		return nil, err
	}

	okRes := make([]color.OkLab, len(res))
	for i, c := range res {
		okRes[i] = c.ToOkLab()
	}
	return okRes, nil
}

func closestOkLab(arr []color.OkLab, target color.OkLab) color.OkLab {
	minDist := math.MaxFloat64
	final := target
	for _, col := range arr {
		dist := col.DistanceSquared(target)
		if dist < minDist {
			final = col
			minDist = dist
		}
	}
	return final
}

func closestFloat64(arr []float64, target float64) float64 {
	n := len(arr)
	if n == 0 {
		return 0
	}

	i := sort.Search(n, func(i int) bool { return arr[i] >= target })
	if i == 0 {
		return arr[0]
	}
	if i == n {
		return arr[n-1]
	}
	if math.Abs(arr[i]-target) < math.Abs(arr[i-1]-target) {
		return arr[i]
	}
	return arr[i-1]
}

func ensureNRGBA(img image.Image) *image.NRGBA {
	if nrgba, ok := img.(*image.NRGBA); ok {
		return nrgba
	}
	box := img.Bounds()
	nrgba := image.NewNRGBA(box)
	draw.Draw(nrgba, box, img, box.Min, draw.Src)
	return nrgba
}
