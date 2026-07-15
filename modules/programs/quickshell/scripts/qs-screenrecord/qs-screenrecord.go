package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"syscall"
	"time"
	"unicode"

	"github.com/adrg/xdg"
	"github.com/charmbracelet/log"
)

func must(name string, err error) {
	if err != nil {
		slog.Error(name, "error", err)
		exit()
	}
}

func runCommand(ctx context.Context, name string, args ...string) *exec.Cmd {
	printableArgs := make([]string, len(args))
	for i, arg := range args {
		printableArgs[i] = "'" + strings.ReplaceAll(arg, "'", "'''") + "'"
	}
	slog.Info("Exec", "command", name+" "+strings.Join(printableArgs, " "))
	return exec.CommandContext(ctx, name, args...)
}

func qsIPC(ctx context.Context, args ...string) error {
	out, err := runCommand(ctx, "quickshell", "list", "--all", "--json").Output()
	if err != nil {
		return fmt.Errorf("qs list failed: %w", err)
	}

	var items []struct {
		ID string `json:"id"`
	}
	if err := json.Unmarshal(out, &items); err != nil {
		return fmt.Errorf("unmarshal quickshell list: %w", err)
	}
	if len(items) == 0 {
		return fmt.Errorf("no quickshell instances found")
	}
	quickshellID := items[0].ID

	cmdArgs := append([]string{"ipc", "-i", quickshellID}, args...)
	return exec.Command("qs", cmdArgs...).Run()
}

func qsStatus(ctx context.Context, status string) {
	must("Quickshell Set Status", qsIPC(ctx, "call", "recording", "setStatus", status))
}

func qsPID(ctx context.Context, pid string) {
	must("Quickshell Set PID", qsIPC(ctx, "call", "recording", "setPID", pid))
}

func qsPerc(ctx context.Context, perc float64) {
	ps := fmt.Sprintf("%.5f", perc)
	must("Quickshell Set Compression Percent", qsIPC(ctx, "call", "recording", "setPerc", ps))
}

// cleanup resets the quickshell recording status, typically called via defer.
func cleanup() {
	ctx := context.Background()
	qsStatus(ctx, "disabled")
	qsPID(ctx, "do not kill me")
	qsPerc(ctx, 0)
}

// parseSlurpColors reads a custom bash file for slurp colour settings.
func parseSlurpColors() []string {
	colorsFile := filepath.Join(xdg.StateHome, "rong", "colors.json")

	data, err := os.ReadFile(colorsFile)
	if err != nil {
		return nil
	}
	res := struct {
		Material struct {
			Background struct {
				Hex string `json:"hex_rgb"`
			} `json:"background"`
			Outline struct {
				Hex string `json:"hex_rgb"`
			} `json:"outline"`
		} `json:"material"`
	}{}
	err = json.Unmarshal(data, &res)
	if err != nil {
		slog.Error("failed to parse rong json", "error", err)
		return nil
	}

	return []string{"-b", res.Material.Background.Hex + "88", "-c", res.Material.Outline.Hex}
}

// selectRegion runs slurp to let the user pick a screen region.
func selectRegion(ctx context.Context, slurpArgs []string) (string, error) {
	runCommand(ctx, "pkill", "slurp").Run()

	cmd := runCommand(ctx, "slurp", append([]string{"-d"}, slurpArgs...)...)
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("slurp failed: %w", err)
	}
	return strings.TrimSpace(string(out)), nil
}

// findAudioOutputDevice uses pactl to locate the first output source.
func findAudioOutputDevice(ctx context.Context) string {
	cmd := runCommand(ctx, "pactl", "list", "sources")
	out, err := cmd.Output()
	if err != nil {
		slog.Error("failed find pactl output", "error", err)
		return ""
	}

	lines := strings.SplitSeq(string(out), "\n")
	for line := range lines {
		trimmed := strings.TrimLeftFunc(line, unicode.IsSpace)
		if after, ok := strings.CutPrefix(trimmed, "Name: "); ok {
			if strings.Contains(after, "output") {
				return strings.TrimSpace(after)
			}
		}
	}
	return ""
}

// recordScreen starts wf-recorder and returns its PID.
func recordScreen(ctx context.Context, region, outputPath string) (*exec.Cmd, error) {
	args := []string{
		"-y", "-g", region,
		"-c", "libx264rgb",
		"-p", "crf=0",
		"-p", "preset=ultrafast",
		"-p", "pix_fmt=rgb24",
		"--file=" + outputPath,
	}
	ao := findAudioOutputDevice(ctx)
	if ao != "" {
		args = append(args, "--audio="+ao)
	}

	cmd := runCommand(ctx, "wf-recorder", args...)
	if err := cmd.Start(); err != nil {
		return nil, err
	}
	return cmd, nil
}

// compressVideo uses ffmpeg to produce a web-optimised version, forwarding progress to quickshell.
func compressVideo(ctx context.Context, input, output string) error {
	durOut, err := runCommand(
		ctx, "ffprobe",
		"-v", "error",
		"-show_entries", "format=duration",
		"-of", "default=noprint_wrappers=1:nokey=1",
		input,
	).Output()
	if err != nil {
		return fmt.Errorf("ffprobe duration: %w", err)
	}
	var duration float64

	_, err = fmt.Fscanf(bytes.NewReader(durOut), "%f", &duration)
	if err != nil {
		return fmt.Errorf("parse duration: %w", err)
	}

	args := []string{
		"-y", "-i", input,
		"-c:v", "libx264",
		"-pix_fmt", "yuv420p",
		"-crf", "28",
		"-preset", "slow",
		"-nostats",
		"-progress", "pipe:1",
		output,
	}
	cmd := runCommand(ctx, "ffmpeg", args...)

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	if err := cmd.Start(); err != nil {
		return err
	}

	scanner := bufio.NewScanner(stdout)
	reProgress := regexp.MustCompile(`out_time_us=(\d+)`)
	for scanner.Scan() {
		line := scanner.Text()
		if matches := reProgress.FindStringSubmatch(line); matches != nil {
			var us float64
			_, err := fmt.Sscanf(matches[1], "%f", &us)
			if err != nil {
				slog.Error("failed to convert parse progress", "error", err)
				continue
			}
			perc := float64(us / (1_000_000 * duration))
			perc = min(max(perc, 0), 1)
			qsPerc(ctx, perc)
		}
	}
	if err := scanner.Err(); err != nil {
		_ = cmd.Wait()
		return err
	}
	return cmd.Wait()
}

// notify sends a desktop notification with optional action.
func notify(ctx context.Context, title, body string, actions ...string) (string, error) {
	args := []string{"-u", "normal", "-a", "Recorder"}
	for _, a := range actions {
		args = append(args, "-A", a)
	}
	args = append(args, title, body)
	cmd := runCommand(ctx, "notify-send", args...)
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}

var exit = func() { os.Exit(1) }

func main() {
	logHandler := log.New(os.Stdout)
	slog.SetDefault(slog.New(logHandler))

	var ctx context.Context
	ctx, exit = signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer exit()
	defer cleanup()

	go func() {
		<-ctx.Done()
		cleanup()
		os.Exit(1)
	}()

	if _, err := exec.LookPath("qs"); err != nil {
		slog.Error("quickshell (qs) not found in PATH – exiting", "err", err)
		exit()
	}

	qsStatus(ctx, "selecting")

	slurpArgs := parseSlurpColors()
	region, err := selectRegion(ctx, slurpArgs)
	if err != nil {
		slog.Error("region selection failed", "err", err)
		exit()
	}

	videosDir := filepath.Join(xdg.UserDirs.Videos, "recordings")
	if err := os.MkdirAll(videosDir, 0o755); err != nil {
		slog.Error("cannot create output directory", "dir", videosDir, "err", err)
		exit()
	}

	name := time.Now().Format("2006-01-02_15:04:05")
	outputFile := filepath.Join(videosDir, name+".mp4")
	slog.Info("recording to", "file", outputFile)

	qsStatus(ctx, "recording")

	wfRecorderCmd, err := recordScreen(ctx, region, outputFile)
	if err != nil {
		slog.Error("could not start wf-recorder", "err", err)
		exit()
	}
	qsPID(ctx, strconv.Itoa(wfRecorderCmd.Process.Pid))

	state, err := wfRecorderCmd.Process.Wait()
	if err != nil {
		slog.Error("wf-recorder failed", "err", err)
	}
	qsStatus(ctx, "disabled")

	if state != nil && !state.Success() {
		slog.Warn("wf-recorder exited with error")
	}

	answer, err := notify(
		ctx,
		"Recording finished",
		"Do you want to compress the video?",
		"yes=Compress for web",
		"no=Keep original",
	)
	if err != nil {
		slog.Warn("notification failed", "err", err)
		answer = "no"
	}

	if answer == "yes" {
		qsStatus(ctx, "compressing")

		webOutput := strings.TrimSuffix(outputFile, ".mp4") + "_web.mp4"
		if err := compressVideo(ctx, outputFile, webOutput); err != nil {
			slog.Error("compression failed", "err", err)
			notify(ctx, "Compression failed", err.Error())
		} else {
			notify(ctx, "Compression done", webOutput)
		}
	} else {
		notify(ctx, "Recording saved", outputFile)
	}

	exit()
}
