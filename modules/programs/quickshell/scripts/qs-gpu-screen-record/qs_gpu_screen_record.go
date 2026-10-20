package main

import (
	"bufio"
	"errors"
	"flag"
	"fmt"
	"io"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"
)

type (
	event   string
	command string
)

const (
	EvtIdle      event = "idle"
	EvtStart     event = "start"
	EvtRecording event = "recording"
	EvtStop      event = "stop"
)

const (
	CmdRecord    command = "record"
	CmdStop      command = "stop"
	CmdTimelapse command = "timelapse"
)

const maxRetry = 3

var (
	debug       = "false"
	clients     = make(map[net.Conn]bool)
	clientsMu   sync.Mutex
	recording   bool
	started     bool
	recMu       sync.Mutex
	currentFile string
	startTime   time.Time
	cmd         *exec.Cmd
)

func initLogger() {
	level := slog.LevelInfo
	if debug == "true" {
		level = slog.LevelDebug
	}
	handler := slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: level,
	})
	slog.SetDefault(slog.New(handler))
}

func broadcast(evt event, msg any) {
	clientsMu.Lock()
	defer clientsMu.Unlock()
	if msg == nil {
		msg = "null"
	}
	slog.Debug("broadcasting event", "event", evt, "message", msg, "client_count", len(clients))
	for conn := range clients {
		_, err := fmt.Fprintf(conn, "%s:%v\n", evt, msg)
		if err != nil {
			slog.Warn("failed to send message to client", "remote_addr", conn.RemoteAddr(), "error", err)
		}
	}
}

func getUserVideoDir() (string, error) {
	config, err := os.UserConfigDir()
	if err != nil {
		slog.Debug("failed to get user config dir", "error", err)
		return "", err
	}
	file, err := os.Open(filepath.Join(config, "user-dirs.dirs"))
	if err != nil {
		slog.Debug("failed to open user-dirs.dirs", "error", err)
		return "", err
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		quoted, ok := strings.CutPrefix(line, "XDG_VIDEOS_DIR=")
		if ok {
			dir, unquoteErr := strconv.Unquote(quoted)
			if unquoteErr != nil {
				slog.Warn("failed to unquote XDG_VIDEOS_DIR", "value", quoted, "error", unquoteErr)
				return "", unquoteErr
			}
			slog.Debug("resolved XDG videos directory", "path", dir)
			return dir, nil
		}
	}
	if err := scanner.Err(); err != nil {
		slog.Error("error scanning user-dirs.dirs", "error", err)
		return "", err
	}
	return "", os.ErrNotExist
}

func getUserVideoDirSafe() string {
	dir, err := getUserVideoDir()
	if err == nil {
		return dir
	}
	home := os.Getenv("HOME")
	if home == "" {
		slog.Error("HOME environment variable is missing")
		panic("HOME env is missing")
	}
	fallback := filepath.Join(home, "Videos")
	slog.Warn("falling back to default videos directory", "path", fallback)
	return fallback
}

func startRecording(tryNum int) error {
	return startRecordingInternal(tryNum, false)
}

func startTimelapse(tryNum int) error {
	return startRecordingInternal(tryNum, true)
}

func startRecordingInternal(tryNum int, isTimelapse bool) error {
	if tryNum > maxRetry {
		slog.Error("max retry limit reached for starting recording")
		return errors.New("max retry reached")
	}

	recMu.Lock()
	defer recMu.Unlock()
	if recording {
		slog.Warn("recording requested but already in progress")
		return errors.New("already recording")
	}

	videosDir := filepath.Join(getUserVideoDirSafe(), "recordings")
	err := os.MkdirAll(videosDir, 0o755)
	if err != nil {
		slog.Error("failed to create recordings directory", "path", videosDir, "error", err)
		return err
	}

	currentFile = fmt.Sprintf("%s/%d.mp4", videosDir, time.Now().Unix())
	started = false

	if isTimelapse {
		slog.Info("starting gpu-screen-recorder in timelapse mode", "attempt", tryNum, "output_file", currentFile)
		cmd = exec.Command("gpu-screen-recorder", "-w", "portal", "-f", "3", "-o", currentFile)
	} else {
		slog.Info("starting gpu-screen-recorder", "attempt", tryNum, "output_file", currentFile)
		cmd = exec.Command("gpu-screen-recorder", "-w", "portal", "-f", "30", "-a", "default_output", "-o", currentFile)
	}

	stderr, err := cmd.StderrPipe()
	if err != nil {
		slog.Error("failed to create stderr pipe for recorder", "error", err)
		return err
	}

	initFailed := make(chan error, 1)
	var r io.Reader
	if debug == "true" {
		r = io.TeeReader(stderr, os.Stderr)
	} else {
		r = stderr
	}

	go func() {
		scanner := bufio.NewScanner(r)
		failed := false
		for scanner.Scan() {
			text := scanner.Text()
			slog.Debug("gpu-screen-recorder stderr", "output", text)
			if started {
				continue
			}
			if strings.HasPrefix(text, "gsr error: pipewire: the desktop portal failed to provide dmabuf") {
				if !failed {
					failed = true
					initFailed <- errors.New(text)
				}
			}
			if strings.HasPrefix(text, "gsr info: update fps:") {
				recMu.Lock()
				startTime = time.Now().Add(-time.Second)
				started = true
				recMu.Unlock()
				slog.Info("recording stream successfully initialized")
			}
		}
		_ = scanner.Err() // nobody cares about error lil bro
		close(initFailed)
	}()

	err = cmd.Start()
	if err != nil {
		slog.Error("failed to start recorder command", "error", err)
		return err
	}

	select {
	case initErr := <-initFailed:
		if initErr != nil {
			slog.Warn("recorder failed during initialization, attempting retry", "attempt", tryNum, "error", initErr)
			if cmd.Process != nil {
				cmd.Process.Kill()
			}
			time.Sleep(time.Second)
			return startRecordingInternal(tryNum+1, isTimelapse)
		}
	case <-time.After(1500 * time.Millisecond):
	}

	recording = true
	startTime = time.Now()
	broadcast(EvtStart, currentFile)

	go func() {
		stop := func() {
			broadcast(EvtStop, currentFile)
			recMu.Lock()
			recording = false
			recMu.Unlock()
			cmd = nil
			broadcast(EvtIdle, nil)
		}
		defer stop()

		err := cmd.Wait()
		if err == nil {
			slog.Error("recorder process exited with unexpected exit code 0")
			return
		}
		if strings.Contains(err.Error(), "signal: killed") {
			slog.Info("recorder process was killed")
		} else {
			slog.Warn("recorder process exited with error", "error", err)
			return
		}

		stop()

		if isTimelapse {
			slog.Info("processing timelapse with ffmpeg", "file", currentFile)
			fast := strings.TrimSuffix(currentFile, ".mp4") + "_fast.mp4"
			ffmpegCmd := exec.Command("ffmpeg", "-y", "-i", currentFile, "-vf", "setpts=0.05*PTS,fps=30", fast)
			ffmpegCmd.Stderr = os.Stderr
			ffmpegErr := ffmpegCmd.Run()
			if ffmpegErr != nil {
				slog.Error("failed to process timelapse with ffmpeg", "error", ffmpegErr)
			} else {
				slog.Info("timelapse processing completed successfully")
			}
		}
	}()

	go func() {
		ticker := time.NewTicker(time.Second)
		for range ticker.C {
			recMu.Lock()
			if !recording {
				ticker.Stop()
				recMu.Unlock()
				break
			}
			ms := time.Since(startTime).Milliseconds()
			if started {
				broadcast(EvtRecording, ms)
			}
			recMu.Unlock()
		}
	}()

	return nil
}

func handleClient(conn net.Conn) {
	clientsMu.Lock()
	clients[conn] = true
	clientsMu.Unlock()

	slog.Info("client connected", "remote_addr", conn.RemoteAddr())

	defer func() {
		clientsMu.Lock()
		delete(clients, conn)
		clientsMu.Unlock()
		conn.Close()
		slog.Info("client disconnected", "remote_addr", conn.RemoteAddr())
	}()

	recMu.Lock()
	if recording {
		ms := time.Since(startTime).Milliseconds()
		fmt.Fprintf(conn, "%s:%s\n", EvtStart, currentFile)
		fmt.Fprintf(conn, "%s:%d\n", EvtRecording, ms)
		slog.Debug("sent current recording state to new client", "file", currentFile, "duration_ms", ms)
	} else {
		fmt.Fprintf(conn, "%s:null\n", EvtIdle)
		slog.Debug("sent idle state to new client")
	}
	recMu.Unlock()

	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		line := scanner.Text()
		slog.Debug("received command from client", "remote_addr", conn.RemoteAddr(), "command", line)
		switch command(line) {
		case CmdRecord:
			err := startRecording(1)
			if err != nil {
				slog.Error("failed to start recording via client command", "error", err)
			}
		case CmdTimelapse:
			err := startTimelapse(1)
			if err != nil {
				slog.Error("failed to start timelapse via client command", "error", err)
			}
		case CmdStop:
			if cmd != nil {
				slog.Info("stopping recording via client command")
				cmd.Process.Kill()
			} else {
				slog.Warn("stop command received but no active recording process found")
			}
		default:
			slog.Warn("received unknown command from client", "command", line)
		}
	}

	if err := scanner.Err(); err != nil {
		slog.Error("client scanner failed unexpectedly", "remote_addr", conn.RemoteAddr(), "error", err)
	}
}

func main() {
	initLogger()

	socketPath := flag.String("socket", "", "Path to custom unix socket for testing")
	flag.Parse()

	var listener net.Listener
	var err error

	if *socketPath != "" {
		_ = os.Remove(*socketPath)
		listener, err = net.Listen("unix", *socketPath)
		if err != nil {
			slog.Error("failed to listen on custom socket", "path", *socketPath, "error", err)
			os.Exit(1)
		}
		slog.Info("listening on custom socket", "path", *socketPath)
	} else {
		file := os.NewFile(3, "activation")
		listener, err = net.FileListener(file)
		if err != nil {
			slog.Error("failed to inherit systemd socket", "error", err)
			os.Exit(1)
		}
		slog.Info("listening on inherited systemd socket")
	}
	defer listener.Close()

	for {
		conn, err := listener.Accept()
		if err != nil {
			slog.Error("failed to accept incoming connection", "error", err)
			continue
		}
		go handleClient(conn)
	}
}
