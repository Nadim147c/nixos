# Fang

<p>
    <a href="https://github.com/charmbracelet/fang/releases"><img src="https://img.shields.io/github/release/charmbracelet/fang.svg" alt="Latest Release"></a>
    <a href="https://pkg.go.dev/github.com/charmbracelet/fang?tab=doc"><img src="https://godoc.org/github.com/charmbracelet/fang?status.svg" alt="GoDoc"></a>
    <a href="https://github.com/charmbracelet/fang/actions"><img src="https://github.com/charmbracelet/fang/workflows/build/badge.svg" alt="Build Status"></a>
</p>

The CLI starter kit. A small, experimental library for batteries-included
[Cobra][cobra] applications.

[info]: https://pkg.go.dev/runtime/debug#BuildInfo
[cobra]: https://github.com/spf13/cobra
[mango]: https://github.com/muesli/mango
[upstream]: https://github.com/charmbracelet/fang

## Features

- **Fancy output**: fully styled help and usage pages
- **Fancy errors**: fully styled errors
- **Automatic `--version`**: set it to the [build info][info], or a version of
  your choice
- **Manpages**: Adds a hidden `man` command to generate _manpages_ using
  [mango][mango][^1]
- **Completions**: Adds a `completion` command to generate shell completions
- **Themeable**: use the built-in theme, or make your own
- **UX**: Silent `usage` output (help is not shown after a user error)

## Usage

To use it, invoke `fang.Execute` passing your root `*cobra.Command`:

```go
package main

import (
	"context"
	"os"

	"github.com/Nadim147c/fang"
	"github.com/spf13/cobra"
)

func main() {
	cmd := &cobra.Command{
		Use:   "example",
		Short: "A simple example program!",
	}
	if err := fang.Execute(context.Background(), cmd); err != nil {
		os.Exit(1)
	}
}
```

## License

This is a fork of [charmbracelet/fang](upstream).
[MIT](https://github.com/charmbracelet/fang/raw/main/LICENSE).
