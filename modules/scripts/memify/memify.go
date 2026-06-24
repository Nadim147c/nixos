package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"sync"
	"syscall"

	"github.com/Nadim147c/fang"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/spf13/cobra"
)

var (
	padding int     = 200
	ratio   float64 = 4
	font    string  = "Anton"
	gravity string  = "Center"
	top     string
	bottom  string
	left    string
	right   string
)

func init() {
	flag := cmd.Flags()
	flag.IntVarP(&padding, "padding", "p", padding, "Padding around the text")
	flag.Float64VarP(&ratio, "ratio", "a", ratio, "Aspect ratio of text image")
	flag.StringVarP(&gravity, "gravity", "g", gravity, "Text gravity")
	flag.StringVarP(&font, "font", "f", font, "Text font to use")
	flag.StringVarP(&top, "top", "t", "", "Add text to the top")
	flag.StringVarP(&bottom, "bottom", "b", "", "Add text to the bottom")
	flag.StringVarP(&left, "left", "l", "", "Add text to the left")
	flag.StringVarP(&right, "right", "r", "", "Add text to the right")
	cmd.MarkFlagsMutuallyExclusive("top", "bottom", "left", "right")
}

func main() {
	err := fang.Execute(
		context.Background(),
		cmd,
		fang.WithFlagTypes(),
		fang.WithNotifySignal(syscall.SIGINT, syscall.SIGTERM),
		fang.WithoutCompletions(),
		fang.WithoutManpage(),
		fang.WithShorthandPadding(),
		fang.WithoutCompletions(),
	)
	if err != nil {
		os.Exit(1)
	}
}

var nonAlnum = regexp.MustCompile(`[^a-z0-9-]+`)

func asciiFileName(s string) string {
	s = strings.ToLower(s)
	s = nonAlnum.ReplaceAllString(s, "-")
	s = strings.Trim(s, "-")
	return s
}

func first(texts ...string) (string, error) {
	for _, s := range texts {
		if s != "" {
			return s, nil
		}
	}
	return "", errors.New("Please provide a valid text")
}

var cmd = &cobra.Command{
	Use: "memify [--flags] <path/to/video>",
	Example: `
	# Create a meme with top text
	memify --top "My funny meme!" ~/funny-meme-clip.mp4
	`,
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		text, err := first(top, bottom, left, right)
		if err != nil {
			return nil
		}

		const size = 1000

		buf := bytes.NewBuffer(nil)

		err = RunSpinner(cmd.Context(), "Writing text...", func(ctx *SpinContext) error {
			magickCmd := exec.CommandContext(
				ctx,
				"magick",
				"-size", fmt.Sprintf("%.0fx%d", size*ratio, size),
				"xc:white",
				"-gravity", gravity,
				"-family", font,
				"-fill", "black",
				"caption:"+text,
				"-colorspace", "sRGB",
				"-composite",
				"png:-", // write output to stdout as PNG
			)
			magickCmd.Stdout = buf
			magickCmd.Stderr = os.Stderr
			return magickCmd.Run()
		})
		if err != nil {
			return err
		}

		output := asciiFileName(text) + "-meme.mp4"

		filterComplex := fmt.Sprintf("[1:v]pad=iw+%d:ih+%d:%d:%d:white[filterdText];\n", padding*2, padding*2, padding, padding)
		switch text {
		case top:
			filterComplex += `
			[0:v]scale=1000:-2[video];
			[filterdText]scale=1000:-2[text];
			[text][video]vstack=inputs=2[out];
			[out]format=yuv420p
			`
		case bottom:
			filterComplex += `
			[0:v]scale=1000:-2[video];
			[filterdText]scale=1000:-2[text];
			[video][text]vstack=inputs=2[out];
			[out]format=yuv420p
			`
		case left:
			filterComplex += `
			[0:v]scale=-2:1000[video];
			[filterdText]scale=-2:1000[text];
			[text][video]hstack=inputs=2[out];
			[out]format=yuv420p
			`
		case right:
			filterComplex += `
			[0:v]scale=-2:1000[video];
			[filterdText]scale=-2:1000[text];
			[video][text]hstack=inputs=2[out];
			[out]format=yuv420p
			`
		}

		return RunSpinner(cmd.Context(), "Generating meme...", func(ctx *SpinContext) error {
			ffmpegCmd := exec.CommandContext(
				cmd.Context(),
				"ffmpeg",
				"-i", args[0],
				"-i", "pipe:0",
				"-filter_complex", filterComplex,
				"-map", "0:a?",
				"-map_metadata", "-1",
				"-c:v", "libx264",
				"-crf", "23",
				"-preset", "veryfast",
				"-y", output,
			)

			ffmpegCmd.Stderr = ctx
			ffmpegCmd.Stdout = os.Stdout
			ffmpegCmd.Stdin = buf
			return ffmpegCmd.Run()
		})
	},
}

type (
	msgComplete   struct{}
	msgTitle      string
	msgOutputLine string
)

type SpinContext struct {
	context.Context
	buf bytes.Buffer
	p   *tea.Program
}

func (c *SpinContext) Write(p []byte) (n int, err error) {
	for i, b := range p {
		if b == '\n' || b == '\r' {
			c.p.Send(msgOutputLine(c.buf.Bytes()))
			c.buf.Reset()
			continue
		}

		if err := c.buf.WriteByte(b); err != nil {
			return i, err
		}
	}

	return len(p), nil
}

func (c *SpinContext) SetTitle(s string) {
	c.p.Send(msgTitle(s))
}

func RunSpinner(ctx context.Context, title string, f func(ctx *SpinContext) error) error {
	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = lipgloss.NewStyle().Foreground(lipgloss.Color("1"))
	m := spinnerModel{
		spinner: s,
		title:   title,
	}

	progCtx, cancel := context.WithCancel(ctx)
	defer cancel()

	program := tea.NewProgram(m)
	ictx := &SpinContext{Context: progCtx, p: program}

	var wg sync.WaitGroup
	wg.Go(func() {
		program.Run()
		cancel()
	})

	err := f(ictx)
	program.Send(msgComplete{})

	wg.Wait()
	return err
}

type spinnerModel struct {
	spinner spinner.Model
	title   string
	output  string
	done    bool
	err     error
}

// Init is the first function that will be called. It returns an optional
// initial command. To not perform an initial command return nil.
func (m spinnerModel) Init() tea.Cmd {
	return m.spinner.Tick
}

// Update is called when a message is received. Use it to inspect messages
// and, in response, update the model and/or send a command.
func (m spinnerModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c":
			m.err = errors.New("stopped by user")
			return m, tea.Quit
		}
	case msgComplete:
		m.done = true
		return m, tea.Quit
	case msgTitle:
		m.title = string(msg)
		return m, nil
	case msgOutputLine:
		m.output = string(msg)
		return m, nil
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	}
	return m, nil
}

var gray = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))

// View renders the program's UI, which can be a string or a [Layer]. The
// view is rendered after every Update.
func (m spinnerModel) View() string {
	if m.done {
		return ""
	}
	if m.output != "" {
		return fmt.Sprintf("%s%s\n   %s", m.spinner.View(), m.title, gray.Render(m.output))
	}
	return m.spinner.View() + m.title
}
