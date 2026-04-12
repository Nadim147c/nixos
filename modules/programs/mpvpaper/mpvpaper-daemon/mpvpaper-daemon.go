package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"slices"
	"strings"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/adrg/xdg"
	"github.com/fsnotify/fsnotify"
)

// Workspace represents a Hyprland workspace
type Workspace struct {
	ID int `json:"id"`
}

// Client represents a Hyprland client/window
type Client struct {
	Workspace Workspace `json:"workspace"`
	Float     bool      `json:"floating"`
}

// Constants for mpvpaper commands
const (
	pauseCommand = "set pause yes"
	playCommand  = "set pause no"
)

var (
	// MpvSocket is the Unix socket path for mpvpaper IPC
	MpvSocket = "/tmp/mpvpaper.sock"
	// XdgRuntimeDir is the XDG runtime directory
	XdgRuntimeDir = os.Getenv("XDG_RUNTIME_DIR")
	// HIS is the Hyprland instance signature
	HIS = os.Getenv("HYPRLAND_INSTANCE_SIGNATURE")
	// HyprlandSocket is the path to Hyprland's request socket
	HyprlandSocket = fmt.Sprintf("%s/hypr/%s/.socket.sock", XdgRuntimeDir, HIS)
	// HyprlandSocket2 is the path to Hyprland's event socket
	HyprlandSocket2 = fmt.Sprintf("%s/hypr/%s/.socket2.sock", XdgRuntimeDir, HIS)
	// StateFile is the path to the wallpaper state file
	StateFile string
)

// main is the entry point of the application
func main() {
	StateFile = filepath.Join(xdg.StateHome, "wallpaper.state")

	// Set up context with signal handling
	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	// Attempt wallpaper restore
	wallpaperPath, err := getWallpaperPath()
	if err != nil {
		slog.Error("failed to read wallpaper path", "error", err)
		os.Exit(1)
	}

	// Start mpvpaper
	if err := startMpvPaper(ctx, wallpaperPath); err != nil {
		slog.Error("failed to start mpvpaper", "error", err)
	}

	// Connect to Hyprland socket
	conn, err := net.Dial("unix", HyprlandSocket2)
	if err != nil {
		slog.Error("failed to connect to Hyprland socket", "error", err)
		os.Exit(1)
	}

	var closed atomic.Bool
	context.AfterFunc(ctx, func() {
		closed.Store(true)
		conn.Close()
	})

	// Start watching wallpaper state file
	go watchWallpaper(ctx)

	// Subscribe to Hyprland events
	events := []string{
		"activewindowv2",
		"closewindow",
		"workspacev2",
		"changefloatingmode",
		"fullscreen",
	}

	var workspace int
	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		line := scanner.Text()
		event, data, found := strings.Cut(line, ">>")
		if !found {
			continue
		}

		// Update workspace on workspace change events
		if event == "workspacev2" {
			id := strings.Split(data, ",")[0]
			fmt.Sscanf(id, "%d", &workspace)
		} else if !slices.Contains(events, event) {
			continue
		}

		// Check if workspace has no clients
		hasNonFloat, err := getWorkspaceClients(workspace)
		if err != nil {
			slog.Error("error checking clients", "error", err)
			continue
		}

		if err = toggleMPVPaper(hasNonFloat); err != nil {
			slog.Error("failed to toggle mpv paper", "error", err)
		}
	}

	if closed.Load() {
		slog.Info("closing due to user cancellation")
		return
	}

	if err := scanner.Err(); err != nil {
		slog.Error("scanner failed", "error", err)
	}
}

// getWallpaperPath reads the wallpaper path from the state file
func getWallpaperPath() ([]byte, error) {
	data, err := os.ReadFile(StateFile)
	if err != nil {
		return nil, err
	}
	return bytes.TrimSpace(data), nil
}

// watchWallpaper monitors the wallpaper state file and updates wallpaper when changed
func watchWallpaper(ctx context.Context) error {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return fmt.Errorf("creating watcher: %w", err)
	}
	defer watcher.Close()

	if err := watcher.Add(StateFile); err != nil {
		return fmt.Errorf("add watcher: %w", err)
	}

	for {
		select {
		case <-ctx.Done():
			slog.Info("watcher context cancelled, stopping")
			return ctx.Err()
		case event, ok := <-watcher.Events:
			if !ok {
				slog.Error("watcher events channel closed")
				return errors.New("watcher failed unexpectedly")
			}
			if event.Has(fsnotify.Create) || event.Has(fsnotify.Write) {
				handleFileChange(event.Name)
			}
		case err, ok := <-watcher.Errors:
			if !ok {
				slog.Error("watcher errors channel closed")
				return errors.New("watcher failed unexpectedly")
			}
			slog.Error("watcher error", "error", err)
		}
	}
}

// handleFileChange reads and applies wallpaper updates from the state file
func handleFileChange(filename string) {
	var b []byte
	var err error

	time.Sleep(100 * time.Millisecond)

	// Retry a few times to avoid race condition with file writes
	for range 3 {
		b, err = os.ReadFile(filename)
		if err == nil {
			break
		}
		if errors.Is(err, fs.ErrNotExist) {
			time.Sleep(100 * time.Millisecond)
			continue
		}
		slog.Error("error reading file", "file", filename, "error", err)
		return
	}

	if err != nil {
		slog.Error("could not read wallpaper state after retries", "error", err)
		return
	}

	path := bytes.TrimSpace(b)
	if len(path) == 0 {
		slog.Info("wallpaper file is empty, ignoring")
		return
	}

	sendMpvPaperCommand(fmt.Sprintf("loadfile %q", path))
}

// startMpvPaper starts the mpvpaper process with the given wallpaper path
func startMpvPaper(ctx context.Context, path []byte) error {
	args := []string{
		"-o", "loop panscan=1.0 background-color='#222222' mute=yes config=no input-ipc-server=" + MpvSocket,
		"*", string(path),
	}
	cmd := exec.CommandContext(ctx, "mpvpaper", args...)
	return cmd.Start()
}

// getWorkspaceClients checks if the specified workspace has any non-floating clients
func getWorkspaceClients(workspace int) (bool, error) {
	conn, err := net.Dial("unix", HyprlandSocket)
	if err != nil {
		return false, err
	}
	defer conn.Close()

	if _, err := fmt.Fprint(conn, "j/clients"); err != nil {
		return false, err
	}

	var clients []Client
	if err := json.NewDecoder(conn).Decode(&clients); err != nil {
		return false, err
	}

	hasNonFloat := slices.ContainsFunc(clients, func(c Client) bool {
		return c.Workspace.ID == workspace && !c.Float
	})

	return hasNonFloat, nil
}

// toggleMPVPaper pauses or plays mpvpaper based on the pause parameter
func toggleMPVPaper(pause bool) error {
	cmd := playCommand
	if pause {
		cmd = pauseCommand
	}
	return sendMpvPaperCommand(cmd)
}

// sendMpvPaperCommand sends a command to mpvpaper via Unix socket
func sendMpvPaperCommand(cmd string) error {
	conn, err := net.Dial("unix", MpvSocket)
	if err != nil {
		return err
	}
	defer conn.Close()
	_, err = fmt.Fprintln(conn, cmd)
	return err
}
