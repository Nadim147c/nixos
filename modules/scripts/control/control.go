package main

import (
	"fmt"
	"math"
	"math/rand"
	"os"
	"os/exec"
	"strings"

	"github.com/spf13/pflag"
)

func main() {
	var cpu, mem string
	pflag.StringVarP(&cpu, "cpu", "c", "", "CPU limit (e.g., 50% or 2)")
	pflag.StringVarP(&mem, "memory", "m", "", "Memory limit (e.g., 512M or 1G)")

	var scope bool
	pflag.BoolVarP(&scope, "scope", "s", false, "Run in scope mode (foreground)")

	pflag.Parse()

	if pflag.NArg() < 1 {
		fmt.Fprintln(os.Stderr, "Usage: control-run [options] <program> [args...]")
		pflag.PrintDefaults()
		os.Exit(1)
	}

	programName := pflag.Arg(0)
	args := []string{"--user"}

	if cpu != "" {
		args = append(args, "--property", fmt.Sprintf("CPUQuota=%s", cpu))
	}
	if mem != "" {
		args = append(args, "--property", fmt.Sprintf("MemoryMax=%s", mem))
	}

	sliceName := fmt.Sprintf("--slice=%s-%d-controlled.slice", programName, rand.Uint32()%math.MaxUint16)
	args = append(args, sliceName)

	if scope {
		args = append(args, "--scope")
	}

	args = append(args, pflag.Args()...)

	cmd := exec.Command("systemd-run", args...)

	// Connect standard IO so interactive programs work correctly
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	fmt.Printf("Running: systemd-run %s\n", strings.Join(args, " "))

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Execution failed: %v\n", err)
		os.Exit(1)
	}
}
