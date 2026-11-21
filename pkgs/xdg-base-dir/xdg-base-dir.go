package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/adrg/xdg"
	"github.com/carapace-sh/carapace"
	"github.com/spf13/cobra"
)

func joinDirs(s []string) string {
	return strings.Join(s, ":")
}

func runFileFunc(fn func(string) (string, error), args []string) error {
	target := filepath.Join(args...)
	out, err := fn(target)
	if err != nil {
		return err
	}
	fmt.Println(out)
	return nil
}

func newDirCmd(name, short, val string) *cobra.Command {
	return &cobra.Command{
		Use:     name,
		Short:   short,
		Args:    cobra.NoArgs,
		GroupID: "dirs",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println(val)
		},
	}
}

func newFileCmd(use, short string, fn func(string) (string, error)) *cobra.Command {
	return &cobra.Command{
		Use:     use,
		Short:   short,
		Args:    cobra.MinimumNArgs(1),
		GroupID: "files",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runFileFunc(fn, args)
		},
	}
}

func newRootCmd() *cobra.Command {
	rootCmd := &cobra.Command{
		Use:           "xdg-base-dir",
		Short:         "Query XDG base directories and search or resolve files",
		SilenceUsage:  true,
		SilenceErrors: true,
	}

	dirCmds := []*cobra.Command{
		newDirCmd("home", "Print home directory", xdg.Home),
		newDirCmd("config-home", "Print XDG config home directory", xdg.ConfigHome),
		newDirCmd("data-home", "Print XDG data home directory", xdg.DataHome),
		newDirCmd("state-home", "Print XDG state home directory", xdg.StateHome),
		newDirCmd("cache-home", "Print XDG cache home directory", xdg.CacheHome),
		newDirCmd("bin-home", "Print XDG bin home directory", xdg.BinHome),
		newDirCmd("runtime-dir", "Print XDG runtime directory", xdg.RuntimeDir),
		newDirCmd("data-dirs", "Print colon-separated XDG data directories", joinDirs(xdg.DataDirs)),
		newDirCmd("config-dirs", "Print colon-separated XDG config directories", joinDirs(xdg.ConfigDirs)),
		newDirCmd("font-dirs", "Print colon-separated font directories", joinDirs(xdg.FontDirs)),
		newDirCmd("user-document", "Print user documents directory", xdg.UserDirs.Documents),
		newDirCmd("user-documents", "Print user documents directory", xdg.UserDirs.Documents),
		newDirCmd("user-download", "Print user downloads directory", xdg.UserDirs.Download),
		newDirCmd("user-downloads", "Print user downloads directory", xdg.UserDirs.Download),
		newDirCmd("user-music", "Print user music directory", xdg.UserDirs.Music),
		newDirCmd("user-musics", "Print user music directory", xdg.UserDirs.Music),
		newDirCmd("user-picture", "Print user pictures directory", xdg.UserDirs.Pictures),
		newDirCmd("user-pictures", "Print user pictures directory", xdg.UserDirs.Pictures),
		newDirCmd("user-public", "Print user public share directory", xdg.UserDirs.PublicShare),
		newDirCmd("user-templates", "Print user templates directory", xdg.UserDirs.Templates),
		newDirCmd("user-video", "Print user videos directory", xdg.UserDirs.Videos),
		newDirCmd("user-videos", "Print user videos directory", xdg.UserDirs.Videos),
	}

	fileCmds := []*cobra.Command{
		newFileCmd("search-config <subpath...>", "Search for an existing config file", xdg.SearchConfigFile),
		newFileCmd("search-data <subpath...>", "Search for an existing data file", xdg.SearchDataFile),
		newFileCmd("search-state <subpath...>", "Search for an existing state file", xdg.SearchStateFile),
		newFileCmd("search-cache <subpath...>", "Search for an existing cache file", xdg.SearchCacheFile),
		newFileCmd("search-runtime <subpath...>", "Search for an existing runtime file", xdg.SearchRuntimeFile),
		newFileCmd("search-data-dirs <subpath...>", "Search data directories for an existing file", xdg.SearchDataFile),
		newFileCmd("search-config-dirs <subpath...>", "Search config directories for an existing file", xdg.SearchConfigFile),
		newFileCmd("config-file <subpath...>", "Resolve path to a config file", xdg.ConfigFile),
		newFileCmd("data-file <subpath...>", "Resolve path to a data file", xdg.DataFile),
		newFileCmd("state-file <subpath...>", "Resolve path to a state file", xdg.StateFile),
		newFileCmd("cache-file <subpath...>", "Resolve path to a cache file", xdg.CacheFile),
		newFileCmd("runtime-file <subpath...>", "Resolve path to a runtime file", xdg.RuntimeFile),
	}

	rootCmd.AddGroup(
		&cobra.Group{
			ID:    "files",
			Title: "Files",
		},
		&cobra.Group{
			ID:    "dirs",
			Title: "Directories",
		},
	)

	for _, c := range dirCmds {
		rootCmd.AddCommand(c)
	}
	for _, c := range fileCmds {
		rootCmd.AddCommand(c)
	}

	carapace.Gen(rootCmd)

	return rootCmd
}

func main() {
	if err := newRootCmd().Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
