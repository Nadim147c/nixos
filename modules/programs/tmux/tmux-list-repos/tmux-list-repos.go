package main

import (
	"encoding/json"
	"fmt"
	"hash/fnv"
	"io"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strings"
	"time"

	"github.com/spf13/cobra"
)

type repoScore struct {
	Score      int       `json:"score"`
	LastAccess time.Time `json:"last_access"`
}

var scoreFile string

func initScoreFile() {
	home, err := os.UserHomeDir()
	if err != nil {
		return
	}
	dir := filepath.Join(home, ".local", "share")
	os.MkdirAll(dir, 0o755)
	scoreFile = filepath.Join(dir, "tmux-list-repo.json")
}

func loadScores() map[string]repoScore {
	f, err := os.Open(scoreFile)
	if err != nil {
		return make(map[string]repoScore)
	}
	defer f.Close()

	var scores map[string]repoScore
	dec := json.NewDecoder(f)
	if err := dec.Decode(&scores); err != nil {
		return make(map[string]repoScore)
	}
	return scores
}

func saveScores(scores map[string]repoScore) error {
	f, err := os.Create(scoreFile)
	if err != nil {
		return err
	}
	defer f.Close()
	enc := json.NewEncoder(f)
	enc.SetIndent("", "  ")
	return enc.Encode(scores)
}

func updateScore(repoPath string) error {
	absPath, err := filepath.Abs(repoPath)
	if err != nil {
		return fmt.Errorf("failed to resolve path: %w", err)
	}
	// optional: check if it's a git repo
	info, err := os.Stat(filepath.Join(absPath, ".git"))
	if err != nil || !info.IsDir() {
		return fmt.Errorf("not a git repository (missing .git directory)")
	}

	scores := loadScores()
	sc := scores[absPath]
	sc.Score++
	sc.LastAccess = time.Now()
	scores[absPath] = sc
	return saveScores(scores)
}

// ---------- git repository discovery ----------
func safeAbsolute(v, fallback string) (string, error) {
	if v == "" {
		return fallback, nil
	}
	return filepath.Abs(v)
}

func isDotGit(f os.DirEntry) bool {
	return f.IsDir() && f.Name() == ".git"
}

func findGitRepos(root, current string, depth int) []string {
	if depth < 0 {
		return []string{root}
	}

	root, err := filepath.Abs(root)
	if err != nil {
		return nil
	}

	current, err = safeAbsolute(current, root)
	if err != nil {
		return nil
	}

	dir, err := os.ReadDir(current)
	if err != nil {
		return nil
	}

	if slices.ContainsFunc(dir, isDotGit) {
		return []string{current}
	}

	var res []string
	for _, entry := range dir {
		if !entry.IsDir() {
			continue
		}
		repos := findGitRepos(root, filepath.Join(current, entry.Name()), depth-1)
		if repos != nil {
			res = append(res, repos...)
		}
	}
	return res
}

func findRepos(root string, maxDepth int) []string {
	rootAbs, err := filepath.Abs(root)
	if err != nil {
		return nil
	}
	dir, err := os.ReadDir(rootAbs)
	if err != nil {
		return nil
	}
	var repos []string
	for _, entry := range dir {
		if !entry.IsDir() {
			continue
		}
		path := filepath.Join(rootAbs, entry.Name())
		repos = append(repos, findGitRepos(path, path, maxDepth)...)
	}
	return repos
}

const baseAnsiIndex = 31

func colorizePart(part string, bold bool) string {
	h := fnv.New64a()
	io.WriteString(h, part)
	idx := h.Sum64() % 6
	colored := fmt.Sprintf("\x1b[%dm%s\x1b[0m", baseAnsiIndex+idx, part)
	if bold {
		colored = "\x1b[1m" + colored
	}
	return colored
}

const sep = string(os.PathSeparator)

func colorizePath(path string) string {
	parts := strings.Split(path, sep)
	last := len(parts) - 1
	for i, part := range parts {
		parts[i] = colorizePart(part, i == last)
	}
	return strings.Join(parts, sep)
}

func effectiveScore(sc repoScore, now time.Time) int {
	if now.Sub(sc.LastAccess) > 14*24*time.Hour {
		return 0
	}
	return sc.Score
}

func sortReposByScore(repos []string, scores map[string]repoScore, root string) {
	now := time.Now()
	sort.SliceStable(repos, func(i, j int) bool {
		si := effectiveScore(scores[repos[i]], now)
		sj := effectiveScore(scores[repos[j]], now)
		if si != sj {
			return si > sj // higher score first
		}
		// fallback: depth (fewer separators first), then name
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

var flagDepth int = 5

var addCmd = &cobra.Command{
	Use:   "add <repo-path>",
	Short: "Record usage of a repository (increases its score)",
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return updateScore(args[0])
	},
}

var rootCmd = &cobra.Command{
	Use:   "tmux-list-repos [flags] <root>",
	Short: "List Git repositories under a directory, sorted by usage score",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		root := args[0]
		repos := findRepos(root, flagDepth)
		if len(repos) == 0 {
			return
		}
		scores := loadScores()
		sortReposByScore(repos, scores, root)

		for _, absRepo := range repos {
			rel, err := filepath.Rel(root, absRepo)
			if err != nil {
				continue
			}
			fmt.Println(colorizePath(rel))
		}
	},
}

func init() {
	rootCmd.Flags().IntVarP(&flagDepth, "max-depth", "d", flagDepth, "Maximum directory recursion depth")
	rootCmd.AddCommand(addCmd)
	initScoreFile()
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
