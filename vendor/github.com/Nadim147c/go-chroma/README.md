# Chroma

[![GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/Nadim147c/go-chroma?style=for-the-badge&logo=go&labelColor=11140F&color=BBE9AA)](https://pkg.go.dev/github.com/Nadim147c/go-chroma)
[![GitHub Repo stars](https://img.shields.io/github/stars/Nadim147c/go-chroma?style=for-the-badge&logo=github&labelColor=11140F&color=BBE9AA)](https://github.com/Nadim147c/go-chroma)
[![GitHub License](https://img.shields.io/github/license/Nadim147c/go-chroma?style=for-the-badge&logo=gplv3&labelColor=11140F&color=BBE9AA)](./LICENSE)
[![GitHub Tag](https://img.shields.io/github/v/tag/Nadim147c/go-chroma?include_prereleases&sort=semver&style=for-the-badge&logo=git&labelColor=11140F&color=BBE9AA)](https://github.com/Nadim147c/go-chroma/tags)

> [!IMPORTANT]
> 🔥 Found this useful? A quick star goes a long way.

An opinionated Go library for working with colors. These color types model color
spaces but do not implement `color.Color` or `color.Model`.

> This is a semi-read-only clone of `github.com/Nadim147c/material/v2`. This package
> only contains color models. Files prefixed with `zz_*` are generated using
> `go run ./generate`.

## Install

```bash
go get -u github.com/Nadim147c/go-chroma
```

## Usage

Generate 10 shade of a color from a random hue. These colors are perceptually linear.

```go
package main

import (
	"fmt"
	"math/rand"

	"github.com/Nadim147c/go-chroma"
	"github.com/Nadim147c/go-chroma/num"
)

func main() {
	const count = 10.0 // generate 10 colors
	const steps = 100 / (count - 1)
	hue := rand.Float64() * 360 // random hue

	palette := make([]chroma.ARGB, count)
	for i := range palette {
		tc := num.Clamp(5, 95, float64(i)*steps)
		palette[i] = chroma.Hct{Hue: hue, Chroma: tc, Tone: tc}.ToARGB()
		fmt.Println(palette[i].AnsiBg("       "))
	}
}
```

![Preview](./example/palette/preview.png)

## License

This code is licensed under the original [Apache 2.0](./LICENSE).
