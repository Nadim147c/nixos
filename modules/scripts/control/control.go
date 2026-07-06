package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/spf13/pflag"
)

func main() {
	var cpu, mem string
	pflag.StringVarP(&cpu, "cpu", "c", "", "CPU limit (e.g., 50% or 2)")
	pflag.StringVarP(&mem, "memory", "m", "", "Memory limit (e.g., 512M or 1G)")
	pflag.SetInterspersed(false)

	var scope bool
	pflag.BoolVarP(&scope, "scope", "s", false, "Run in scope mode (foreground)")

	var args []string

	args = append(args, "app")

	pflag.Parse()

	if pflag.NArg() < 1 {
		fmt.Fprintln(os.Stderr, "Usage: control-run [options] <program> [args...]")
		pflag.PrintDefaults()
		os.Exit(1)
	}

	if cpu != "" {
		args = append(args, "-p", fmt.Sprintf("CPUQuota=%s", cpu))
	}
	if mem != "" {
		args = append(args, "-p", fmt.Sprintf("MemoryMax=%s", mem))
	}

	if scope {
		args = append(args, "-t", "scope")
	} else {
		args = append(args, "-t", "service")
	}

	args = append(args, "--")

	args = append(args, pflag.Args()...)
	cmd := exec.Command("uwsm", args...)

	// Connect standard IO so interactive programs work correctly
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	fmt.Printf("Running: uwsm %s\n", strings.Join(args, " "))

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Execution failed: %v\n", err)
		os.Exit(1)
	}
}
