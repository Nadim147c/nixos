package main

import (
	"encoding/gob"
	"encoding/json"
	"fmt"
	"log/slog"
	"math"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strings"
	"time"

	"github.com/Nadim147c/go-chroma"
	"github.com/charmbracelet/log"
	"github.com/spf13/cobra"
)

type DirectoryEntry struct {
	LastAccess time.Time `json:"last_access"`
	Frequency  int64     `json:"frequency"`
}

type State struct {
	Dirs map[string]DirectoryEntry `json:"dirs"`
}

type DirCacheEntry struct {
	Mtime time.Time
	Repos []string
}

type DirCache map[string]DirCacheEntry

var (
	scoreFile string
	cacheFile string
	flagDepth = 5
)

func InitFiles() {
	home, err := os.UserHomeDir()
	if err != nil {
		return
	}
	dir := filepath.Join(home, ".local", "share", "tmux-list-repo")
	os.MkdirAll(dir, 0o755)
	scoreFile = filepath.Join(dir, "score.json")
	cacheFile = filepath.Join(dir, "repo.index")
}

func LoadState() (*State, error) {
	f, err := os.Open(scoreFile)
	if err != nil {
		if os.IsNotExist(err) {
			return &State{Dirs: make(map[string]DirectoryEntry)}, nil
		}
		return nil, err
	}
	defer f.Close()

	var state State
	if err := json.NewDecoder(f).Decode(&state); err != nil {
		return &State{Dirs: make(map[string]DirectoryEntry)}, nil
	}

	if state.Dirs == nil {
		state.Dirs = make(map[string]DirectoryEntry)
	}
	return &state, nil
}

func SaveState(state *State) error {
	f, err := os.Create(scoreFile)
	if err != nil {
		return fmt.Errorf("SaveState: %w", err)
	}
	defer f.Close()
	return json.NewEncoder(f).Encode(state)
}

func UpdateScore(repoPath string) error {
	absPath, err := filepath.Abs(repoPath)
	if err != nil {
		return fmt.Errorf("UpdateScore: %w", err)
	}

	state, err := LoadState()
	if err != nil {
		return err
	}

	entry := state.Dirs[absPath]
	entry.Frequency++
	entry.LastAccess = time.Now()
	state.Dirs[absPath] = entry
	return SaveState(state)
}

func LoadDirCache() (DirCache, error) {
	f, err := os.Open(cacheFile)
	if err != nil {
		if os.IsNotExist(err) {
			return DirCache{}, nil
		}
		return nil, err
	}
	defer f.Close()

	cache := DirCache{}
	err = gob.NewDecoder(f).Decode(&cache)
	if err != nil {
		return nil, err
	}

	return cache, nil
}

func SaveDirCache(cache DirCache) error {
	f, err := os.Create(cacheFile)
	if err != nil {
		return err
	}
	defer f.Close()
	return gob.NewEncoder(f).Encode(cache)
}

func GetMtime(path string) (time.Time, error) {
	info, err := os.Stat(path)
	if err != nil {
		return time.Time{}, err
	}
	return info.ModTime(), nil
}

func isRepoIndex(f os.DirEntry) bool {
	return f.IsDir() &&
		(f.Name() == ".git" || f.Name() == ".jj")
}

func GetReposCached(path string, dirCache DirCache, depth int) []string {
	absPath, err := filepath.Abs(path)
	if err != nil {
		return nil
	}
	currentMtime, err := GetMtime(absPath)
	if err != nil {
		return nil
	}
	slog.Info("mtime", "dir", absPath, "time", currentMtime)
	if entry, ok := dirCache[absPath]; ok && entry.Mtime.Sub(currentMtime).Abs() < time.Minute {
		slog.Debug("cache found", "dir", absPath, "result", entry.Repos)
		return entry.Repos
	}

	var repos []string
	entries, err := os.ReadDir(absPath)
	if err != nil {
		return nil
	}

	if slices.ContainsFunc(entries, isRepoIndex) {
		return append(repos, absPath)
	}

	if depth > 0 {
		for _, e := range entries {
			subPath := filepath.Join(absPath, e.Name())
			subRepos := GetReposCached(subPath, dirCache, depth-1)
			repos = append(repos, subRepos...)
		}
	}
	dirCache[absPath] = DirCacheEntry{Mtime: currentMtime, Repos: repos}
	return repos
}

func GetRepos(root string, maxDepth int) ([]string, error) {
	slog.Info("mtime", "dir", root)
	dirCache, err := LoadDirCache()
	if err != nil {
		return nil, err
	}

	repos := GetReposCached(root, dirCache, maxDepth)

	err = SaveDirCache(dirCache)
	if err != nil {
		return nil, err
	}
	return repos, nil
}

func EffectiveScore(entry DirectoryEntry, now time.Time) float64 {
	if entry.Frequency <= 0 || entry.LastAccess.IsZero() {
		return 0
	}
	hours := now.Sub(entry.LastAccess).Hours()
	if hours <= 5 {
		return float64(entry.Frequency)
	}
	const maxHours = 336.0
	if hours >= maxHours {
		return 0
	}
	recency := 1.0 - (math.Log(hours/5.0) / math.Log(67.2))
	return float64(entry.Frequency) * recency
}

const sep = string(os.PathSeparator)

func SortReposByScore(repos []string, dirs map[string]DirectoryEntry, root string) {
	now := time.Now()
	sort.SliceStable(repos, func(i, j int) bool {
		si := EffectiveScore(dirs[repos[i]], now)
		sj := EffectiveScore(dirs[repos[j]], now)
		if si != sj {
			return si > sj
		}
		relI, _ := filepath.Rel(root, repos[i])
		relJ, _ := filepath.Rel(root, repos[j])
		depthI := strings.Count(relI, sep)
		depthJ := strings.Count(relJ, sep)
		if depthI != depthJ {
			return depthI < depthJ
		}
		return strings.ToLower(relI) < strings.ToLower(relJ)
	})
}

var addCmd = &cobra.Command{
	Use:   "add <repo-path>",
	Short: "Record usage of a repository",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return UpdateScore(args[0])
	},
}

var rootCmd = &cobra.Command{
	Use:   "tmux-list-repos [flags] <root>",
	Short: "List Git repositories under a directory, sorted by usage score",
	Args:  cobra.ExactArgs(1),
	PreRun: func(cmd *cobra.Command, args []string) {
		if debug {
			handler := log.NewWithOptions(os.Stderr, log.Options{
				Level:      log.Level(slog.LevelDebug),
				TimeFormat: "",
			})
			slog.SetDefault(slog.New(handler))
		} else {
			slog.SetDefault(slog.New(slog.DiscardHandler))
		}
	},
	RunE: func(cmd *cobra.Command, args []string) error {
		root := args[0]
		repos, err := GetRepos(root, flagDepth)
		if err != nil {
			return fmt.Errorf("failed to list repos: %w", err)
		}

		state, err := LoadState()
		if err != nil {
			return fmt.Errorf("failed to load state: %w", err)
		}
		SortReposByScore(repos, state.Dirs, root)

		from := chroma.ARGBFromHexMust("#4fd6be").ToOkLab()
		to := chroma.ARGBFromHexMust("#c8d3f5").ToOkLab()
		total := float64(len(repos))
		for i, absRepo := range repos {
			if rel, err := filepath.Rel(root, absRepo); err == nil {
				col := blend(from, to, float64(i)/total)
				res := col.ToARGB().AnsiFg(rel)
				fmt.Println(res)
			}
		}
		return nil
	},
}

func blend(from, to chroma.OkLab, ratio float64) chroma.OkLab {
	return chroma.OkLab{
		L: from.L + (to.L-from.L)*ratio,
		A: from.A + (to.A-from.A)*ratio,
		B: from.B + (to.B-from.B)*ratio,
	}
}

var debug bool

func init() {
	rootCmd.Flags().IntVarP(&flagDepth, "max-depth", "d", flagDepth, "Maximum directory recursion depth")
	rootCmd.Flags().BoolVarP(&debug, "debug", "v", debug, "Enable debug loggin")
	rootCmd.AddCommand(addCmd)
	InitFiles()
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
