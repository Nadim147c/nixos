package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/adrg/xdg"
	"github.com/spf13/pflag"
)

func join(s []string) string {
	return strings.Join(s, ":")
}

func main() {
	dirs := map[string]string{
		"home":           xdg.Home,
		"config-home":    xdg.ConfigHome,
		"data-home":      xdg.ConfigHome,
		"state-home":     xdg.StateHome,
		"cache-home":     xdg.CacheHome,
		"bin-home":       xdg.BinHome,
		"runtime-dir":    xdg.RuntimeDir,
		"data-dirs":      join(xdg.DataDirs),
		"config-dirs":    join(xdg.ConfigDirs),
		"font-dirs":      join(xdg.FontDirs),
		"user-picture":   xdg.UserDirs.Pictures,
		"user-videos":    xdg.UserDirs.Videos,
		"user-music":     xdg.UserDirs.Music,
		"user-documents": xdg.UserDirs.Documents,
		"user-download":  xdg.UserDirs.Download,
		"user-templates": xdg.UserDirs.Templates,
		"user-public":    xdg.UserDirs.PublicShare,
	}

	log.SetFlags(0)
	log.SetOutput(os.Stderr)
	pflag.Parse()
	if pflag.NArg() < 1 {
		log.Fatal("usage: xdg-base-dir <directory|command> [subpath...]")
	}
	if v, ok := dirs[pflag.Arg(0)]; ok {
		fmt.Println(v)
		return
	}

	if pflag.NArg() < 2 {
		log.Fatal("usage: xdg-base-dir <command> [subpath...]")
	}

	next := filepath.Join(pflag.Args()[1:]...)

	var out string
	var err error
	switch pflag.Arg(0) {
	case "search-config":
		out, err = xdg.SearchConfigFile(next)
	case "search-data":
		out, err = xdg.SearchDataFile(next)
	case "search-state":
		out, err = xdg.SearchStateFile(next)
	case "search-cache":
		out, err = xdg.SearchCacheFile(next)
	case "search-runtime":
		out, err = xdg.SearchRuntimeFile(next)
	case "search-data-dirs":
		out, err = xdg.SearchDataFile(next)
	case "search-config-dirs":
		out, err = xdg.SearchConfigFile(next)
	case "config-file":
		out, err = xdg.ConfigFile(next)
	case "data-file":
		out, err = xdg.DataFile(next)
	case "state-file":
		out, err = xdg.StateFile(next)
	case "cache-file":
		out, err = xdg.CacheFile(next)
	case "runtime-file":
		out, err = xdg.RuntimeFile(next)
	}
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(out)
}
