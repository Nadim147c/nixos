package color

import (
	"math"

	"github.com/Nadim147c/material/v3/num"
)

// OkLabMatrix1 defines the linear transformation from CIE XYZ to LMS
// cone responses used in the OkLab color model.
//
// This corresponds to the matrix M1 in Ottosson’s paper:
//
//	[L, M, S]^T = M1 * [X, Y, Z]^T
var OkLabMatrix1 = num.NewMatrix3(
	0.8189330101, 0.3618667424, -0.1288597137,
	0.0329845436, 0.9293118715, 0.0361456387,
	0.0482003018, 0.2643662691, 0.6338517070,
)

// OkLabMatrix2 defines the transformation from nonlinearly transformed LMS
// (after cube-root compression) to OkLab coordinates (L, a, b).
//
// This corresponds to matrix M2 in Ottosson’s formulation:
//
//	[L, a, b]^T = M2 * [L', M', S']^T
var OkLabMatrix2 = num.NewMatrix3(
	0.2104542553, 0.7936177850, -0.0040720468,
	1.9779984951, -2.4285922050, 0.4505937099,
	0.0259040371, 0.7827717662, -0.8086757660,
)

// OkLabMatrix1Inv is the inverse of M1, used to convert from LMS back to XYZ.
var OkLabMatrix1Inv = num.NewMatrix3(
	1.2270138511, -0.5577999807, 0.2812561490,
	-0.0405801784, 1.1122568696, -0.0716766787,
	-0.0763812845, -0.4214819784, 1.5861632204,
)

// OkLabMatrix2Inv is the inverse of M2, used to convert from OkLab (L,a,b)
// back to cube-rooted LMS values.
var OkLabMatrix2Inv = num.NewMatrix3(
	0.9999999985, 0.3963377922, 0.2158037581,
	1.0000000089, -0.1055613423, -0.0638541748,
	1.0000000547, -0.0894841821, -1.2914855379,
)

// OkLabMatrix3 transforms Linear sRGB coordinates directly to LMS cone responses.
//
// This is the combined transformation matrix (M1 * RGB_to_XYZ) optimized for
// direct Linear sRGB to LMS conversion:
//
//	[L, M, S]^T = M3 * [R, G, B]^T
var OkLabMatrix3 = num.NewMatrix3(
	0.4122214708, 0.5363325363, 0.0514459929,
	0.2119034982, 0.6806995451, 0.1073969566,
	0.0883024619, 0.2817188376, 0.6299787005,
)

// OkLabMatrix4 defines the transformation from nonlinearly transformed LMS
// (after cube-root compression) to OkLab coordinates (L, a, b).
//
// This corresponds to matrix M2 in the direct Linear sRGB pipeline:
//
//	[L, a, b]^T = M4 * [L', M', S']^T
var OkLabMatrix4 = num.NewMatrix3(
	0.2104542553, 0.7936177850, -0.0040720468,
	1.9779984951, -2.4285922050, 0.4505937099,
	0.0259040371, 0.7827717662, -0.8086757660,
)

// OkLabMatrix3Inv is the inverse of M3, used to convert from Linear LMS
// values back to Linear sRGB coordinates (R, G, B).
var OkLabMatrix3Inv = num.NewMatrix3(
	4.0767416621, -3.3077115913, 0.2309699292,
	-1.2684380046, 2.6097574011, -0.3413193965,
	-0.0041960863, -0.7034186147, 1.7076147010,
)

// OkLabMatrix4Inv is the inverse of M4, used to convert from OkLab (L, a, b)
// back to cube-rooted LMS values in the Linear sRGB pipeline.
var OkLabMatrix4Inv = num.NewMatrix3(
	1.0, 0.3963377774, 0.2158037573,
	1.0, -0.1055613458, -0.0638541728,
	1.0, -0.0894841775, -1.2914855480,
)

// OkLab color space is a uniform color space for device-independent color
// designed to improve perceptual uniformity, hue and lightness prediction,
// color blending, and usability while ensuring numerical stability and ease of
// implementation. Introduced by Björn Ottosson in December 2020.
type OkLab struct {
	// L for perceptual lightness, ranging from 0 (pure black) to 100 (reference
	// white), often denoted as a percentage.
	L float64 `json:"l"`
	// A for green (negative) to red (positive) in range [-100, 100].
	A float64 `json:"a"`
	// B for blue (negative) to yellow (positive) in range [-100, 100].
	B float64 `json:"b"`
}

var _ Model = (*OkLab)(nil)

// NewOkLab create a OkLab model from l,a,b values
func NewOkLab(l, a, b float64) OkLab {
	return OkLab{l, a, b}
}

// HACK: This implementation of XYZ is 0-100 scaled. But the
// https://bottosson.github.io/posts/oklab/ uses 0-1 scaled XYZ. Thus, we
// multiply all values of ZYX with 1/100 (0.01). After matrix multiplication we
// again transform the vector OkLab by multiplying with 100. Because, all of our
// other models 0-100 scaled. The best option will to find the matrices which
// directly works with 0-100 scaled XYZ model to get 0-100 scaled OkLab.

// OkLabFromXYZ create a OkLab model from x,y,z value of XYZ color space
func OkLabFromXYZ(c XYZ) OkLab {
	xyz := num.NewVector3(c.Values())

	// Scalar transformation
	xyz = xyz.Scaled(0.01)

	lsm := OkLabMatrix1.Mul(xyz).Map(math.Cbrt)
	lab := OkLabMatrix2.Mul(lsm)

	// Scalar transformation
	lab = lab.Scaled(100)

	return NewOkLab(lab.Values())
}

// OkLabFromARGB create an OkLab model from ARGB color space.
func OkLabFromARGB(c ARGB) OkLab {
	r, g, b := c.Red(), c.Green(), c.Blue()
	linrgb := num.NewVector3(
		LinearizedNormal(r),
		LinearizedNormal(g),
		LinearizedNormal(b),
	)

	lsm := OkLabMatrix3.Mul(linrgb).Map(math.Cbrt)
	lab := OkLabMatrix4.Mul(lsm)

	// Scalar transformation
	lab = lab.Scaled(100)

	return NewOkLab(lab.Values())
}

func cube(f float64) float64 { return f * f * f }

// ToXYZ convert OkLab model to XYZ color model.
func (ok OkLab) ToXYZ() XYZ {
	lab := num.NewVector(ok)

	// Scalar transformation
	lab = lab.Scaled(0.01)

	lms := OkLabMatrix2Inv.Mul(lab).Map(cube)

	xyz := OkLabMatrix1Inv.Mul(lms)

	// Scalar transformation
	xyz = xyz.Scaled(100)

	return NewXYZ(xyz.Values())
}

// ToOkLch convert OkLab to OkLch color model.
func (ok OkLab) ToOkLch() OkLch {
	return OkLchFromOkLab(ok)
}

// ToARGB convert OkLab to ARGB color model.
func (ok OkLab) ToARGB() ARGB {
	lab := num.NewVector(ok)

	lms := OkLabMatrix4Inv.Mul(lab.Scaled(0.01)).Map(cube)
	linrgb := OkLabMatrix3Inv.Mul(lms)

	r, g, b := linrgb.Values()

	return NewARGB(
		0xFF,
		DelinearizedNormal(r),
		DelinearizedNormal(g),
		DelinearizedNormal(b),
	)
}

// Hash returns the hash of the OkLab color
func (ok OkLab) Hash() Hash {
	return getHash(ok.L, ok.A, ok.B)
}

// DistanceSquared returns square of distance between two color.
func (ok OkLab) DistanceSquared(b OkLab) float64 {
	dl := ok.L - b.L
	da := ok.A - b.A
	db := ok.B - b.B
	return dl*dl + da*da + db*db
}

// Distance returns distance between two color.
func (ok OkLab) Distance(b OkLab) float64 {
	return math.Sqrt(ok.DistanceSquared(b))
}

// String returns a formatted string representation of OkLab color.
func (ok OkLab) String() string {
	return modelString("OKLAB", ok)
}

// Values returns L, a, b values of OkLab Model
func (ok OkLab) Values() (float64, float64, float64) {
	return ok.L, ok.A, ok.B
}
