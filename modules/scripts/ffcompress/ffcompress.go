package main

import (
	"bufio"
	"bytes"
	"context"
	"errors"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"

	"charm.land/bubbles/v2/progress"
	tea "charm.land/bubbletea/v2"
	"charm.land/huh/v2"
	"charm.land/lipgloss/v2"
)

const (
	padding  = 2
	maxWidth = 80
	randSize = 35
)

const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/~!@#$%^&*_-=.\\"

type preset struct {
	Name     string
	CRF      string
	Speed    string
	RatioEst float64 // Estimated percentage remaining (e.g., 0.40 = ~60% reduction)
}

var presets = []preset{
	{"High Quality (Lower compression)", "22", "medium", 0.70},
	{"Balanced (Recommended)", "26", "slow", 0.45},
	{"Aggressive (Smaller file size)", "32", "slower", 0.25},
}

// Model holds the application state.
type model struct {
	program    *tea.Program
	inputPath  string
	outputPath string
	duration   time.Duration
	elapsed    time.Duration
	percent    float64
	phase      string
	err        error
	rand       [randSize]byte
	ctx        context.Context
	cancel     context.CancelFunc
	progress   progress.Model
	preset     preset
	fileSize   int64
	done       bool
}

type progressMsg struct {
	elapsed time.Duration
	percent float64
}

type ffmpegDoneMsg struct{ err error }

type errMsg struct{ err error }

// Update initialModel constructor signature
func initialModel(inputPath, outputPath string, dur time.Duration, fileSize int64, preset preset) *model {
	var rand [randSize]byte
	copy(rand[:], charset)
	return &model{
		inputPath:  inputPath,
		outputPath: outputPath,
		duration:   dur,
		fileSize:   fileSize,
		preset:     preset,
		phase:      "encoding", // Skip probing phase in UI
		progress:   progress.New(progress.WithDefaultBlend()),
		rand:       rand,
	}
}

type tickMsg time.Time

func tick() tea.Cmd {
	return tea.Tick(time.Second/24, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

// Init runs the ffprobe command and returns a Cmd that will send the duration.
func (m *model) Init() tea.Cmd {
	return tea.Batch(m.startFFmpegCmd(), tick())
}

// startFFmpegCmd returns a Cmd that runs ffmpeg and sends progress updates.
func (m *model) startFFmpegCmd() tea.Cmd {
	return func() tea.Msg {
		cmd := exec.CommandContext(
			m.ctx, "ffmpeg",
			"-y", "-i", m.inputPath,
			"-c:v", "libx264",
			"-pix_fmt", "yuv420p",
			"-crf", m.preset.CRF,
			"-preset", m.preset.Speed,
			"-nostats",
			"-progress", "pipe:1",
			m.outputPath,
		)

		stdout, err := cmd.StdoutPipe()
		if err != nil {
			return errMsg{err: fmt.Errorf("stdout pipe: %w", err)}
		}

		if err := cmd.Start(); err != nil {
			return errMsg{err: fmt.Errorf("start ffmpeg: %w", err)}
		}

		go func() {
			scanner := bufio.NewScanner(stdout)
			for scanner.Scan() {
				line := scanner.Text()
				val, ok := strings.CutPrefix(line, "out_time_us=")
				if !ok {
					continue
				}
				us, err := strconv.Atoi(val)
				if err != nil {
					continue
				}

				elapsed := time.Duration(us) * time.Microsecond

				percent := min(elapsed.Seconds()/m.duration.Seconds(), 1)
				m.program.Send(progressMsg{elapsed: elapsed, percent: percent})
			}
			err1 := scanner.Err()
			err2 := cmd.Wait()

			m.program.Send(ffmpegDoneMsg{err: errors.Join(err1, err2)})
		}()

		return nil
	}
}

// Update handles incoming messages.
func (m *model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyPressMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			if m.cancel != nil {
				m.cancel() // kill ffmpeg
			}
			return m, tea.Quit
		}
		return m, nil

	case tea.WindowSizeMsg:
		// Set progress bar width.
		width := min(msg.Width-padding*2-4, maxWidth)
		m.progress.SetWidth(width)
		return m, nil

	case errMsg:
		m.phase = "error"
		m.err = msg.err
		m.done = true
		return m, tea.Quit

	case progressMsg:
		m.elapsed = msg.elapsed
		m.percent = msg.percent
		// Update the progress component.
		cmd := m.progress.SetPercent(m.percent)
		return m, cmd

	case ffmpegDoneMsg:
		m.done = true
		if msg.err != nil {
			m.phase = "error"
			m.err = msg.err
		} else {
			m.phase = "done"
			m.percent = 1.0
			// Set progress bar to 100%.
			cmd := m.progress.SetPercent(1.0)
			return m, tea.Batch(cmd, tea.Quit)
		}
		return m, tea.Quit

	case progress.FrameMsg:
		var cmd tea.Cmd
		m.progress, cmd = m.progress.Update(msg)
		return m, cmd

	case tickMsg:
		var newRand [randSize]byte
		copy(newRand[:], m.rand[1:])
		newRand[randSize-1] = charset[rand.Intn(len(charset))]
		m.rand = newRand
		return m, tick()

	default:
		return m, nil
	}
}

var (
	helpStyle = lipgloss.NewStyle().Foreground(lipgloss.BrightBlack)
	randStyle = lipgloss.NewStyle().Foreground(lipgloss.Green).Bold(true)
)

// View renders the UI.
func (m *model) View() tea.View {
	buf := bytes.NewBuffer(nil)
	switch m.phase {
	case "ffprobe":
		buf.WriteString("Probing video duration...")
	case "encoding":
		fmt.Fprintf(buf, "Encoding: %s → %s\n\n", m.inputPath, m.outputPath)
		for range padding {
			buf.WriteByte(' ')
		}
		fmt.Fprintf(buf, "Duration: %.1fs | Elapsed: %.1fs | %.1f%%\n", m.duration.Seconds(), m.elapsed.Seconds(), m.percent*100)
		for range padding {
			buf.WriteByte(' ')
		}
		fmt.Fprintf(buf, "Compressing: [%s]\n\n", randStyle.Render(fmt.Sprintf("%s", m.rand)))
		fmt.Fprintln(buf, m.progress.View())
	case "done":
		fmt.Fprintf(buf, "Encoding complete: %s", m.outputPath)
	case "error":
		fmt.Fprintf(buf, "Error: %v", m.err)
	default:
		buf.WriteString("Unknown state")
	}
	buf.WriteByte('\n')
	buf.WriteString(helpStyle.Render("Press q or Ctrl+C to quit"))
	return tea.NewView(buf.String())
}

func probeVideo(path string) (time.Duration, int64, error) {
	info, err := os.Stat(path)
	if err != nil {
		return 0, 0, fmt.Errorf("stat file: %w", err)
	}

	cmd := exec.Command(
		"ffprobe",
		"-v", "error",
		"-show_entries", "format=duration",
		"-of", "default=noprint_wrappers=1:nokey=1",
		path,
	)
	out, err := cmd.Output()
	if err != nil {
		return 0, 0, fmt.Errorf("ffprobe failed: %w", err)
	}

	var sec float64
	if _, err := fmt.Sscanf(string(out), "%f", &sec); err != nil {
		return 0, 0, fmt.Errorf("invalid duration format: %w", err)
	}

	return time.Duration(sec * float64(time.Second)), info.Size(), nil
}

func formatBytes(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(b)/float64(div), "KMGTPE"[exp])
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <input_video>\n", os.Args[0])
		os.Exit(1)
	}
	inputPath := os.Args[1]
	ext := filepath.Ext(inputPath)
	base := strings.TrimSuffix(inputPath, ext)
	outputPath := base + "_compressed" + ext

	// 1. Run ffprobe upfront
	fmt.Println("Analyzing video details...")
	dur, size, err := probeVideo(inputPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error probing video: %v\n", err)
		os.Exit(1)
	}

	// 2. Build options with estimated reduction and new size
	var options []huh.Option[preset]
	for _, p := range presets {
		estSize := int64(float64(size) * p.RatioEst)
		reduction := int((1.0 - p.RatioEst) * 100)

		label := fmt.Sprintf(
			"%-35s | ~%d%% reduction | Est. Size: %s",
			p.Name,
			reduction,
			formatBytes(estSize),
		)
		options = append(options, huh.NewOption(label, p))
	}

	var selectedPreset preset
	form := huh.NewForm(
		huh.NewGroup(
			huh.NewSelect[preset]().
				Title(fmt.Sprintf("Select Compression Preset (Original: %s)", formatBytes(size))).
				Options(options...).
				Value(&selectedPreset),
		),
	)

	if err := form.Run(); err != nil {
		if errors.Is(err, huh.ErrUserAborted) {
			os.Exit(0)
		}
		fmt.Fprintf(os.Stderr, "Prompt error: %v\n", err)
		os.Exit(1)
	}

	m := initialModel(inputPath, outputPath, dur, size, selectedPreset)

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT, syscall.SIGQUIT)
	defer cancel()
	m.ctx = ctx
	m.cancel = cancel

	p := tea.NewProgram(m)
	m.program = p

	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v\n", err)
		os.Exit(1)
	}
}
