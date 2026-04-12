package main

import (
	"fmt"
	"os"
	"os/exec"
)

type command struct{ fmt, paneFlag, windowFlag string }

const (
	PaneSwitchRight = "-R"
	PaneSwitchLeft  = "-L"
	PaneSwitchUp    = "-U"
	PaneSwitchDown  = "-D"
)

const (
	PanePositionRight  = "#{pane_at_right}"
	PanePositionLeft   = "#{pane_at_left}"
	PanePositionTop    = "#{pane_at_top}"
	PanePositionBottom = "#{pane_at_bottom}"
)

const (
	WindowSwitchNext     = "-n"
	WindowSwitchPrevious = "-p"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Please provide a direction")
		os.Exit(1)
	}

	var cmd command
	switch os.Args[1] {
	case "left", "h":
		cmd = command{PanePositionLeft, PaneSwitchRight, WindowSwitchPrevious}
	case "right", "l":
		cmd = command{PanePositionRight, PaneSwitchLeft, WindowSwitchNext}
	case "up", "k":
		cmd = command{PanePositionTop, PaneSwitchDown, WindowSwitchPrevious}
	case "down", "j":
		cmd = command{PanePositionBottom, PaneSwitchUp, WindowSwitchNext}
	default:
		fmt.Fprintln(os.Stderr, "Invalid direction: ", os.Args[1])
		os.Exit(1)
	}

	out, err := exec.Command("tmux", "display-message", "-p", "-F", cmd.fmt).Output()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Error: ", err)
		os.Exit(1)
	}

	if len(out) == 0 {
		fmt.Fprintln(os.Stderr, "Error: No output from tmux")
		os.Exit(1)
	}

	if out[0] != '1' {
		err = exec.Command("tmux", "select-pane", cmd.paneFlag).Run()
	} else {
		err = exec.Command("tmux", "select-window", cmd.windowFlag).Run()
	}

	if err != nil {
		fmt.Fprintln(os.Stderr, "Error: ", err)
		os.Exit(1)
	}
}
