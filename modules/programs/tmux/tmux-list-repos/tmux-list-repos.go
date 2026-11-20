// tmux-list-repos lists Git/jj repositories below a root directory, ordered by
// how recently and how often they were used. Standard library only.
package main

import (
	"bufio"
	"cmp"
	"encoding/gob"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"log/slog"
	"math"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"time"
)

const (
	sep            = string(os.PathSeparator)
	indexVersion   = 2
	racyWindow     = 2 * time.Second
	fullScoreHours = 5.0
	maxScoreHours  = 336.0
)

const usage = `Usage:
  tmux-list-repos [flags] <root>   list repositories under <root>, best first
  tmux-list-repos add <repo-path>  record usage of a repository

Flags:
`

type DirectoryEntry struct {
	LastAccess time.Time `json:"last_access"`
	Frequency  int64     `json:"frequency"`
}

type State struct {
	Dirs map[string]DirectoryEntry `json:"dirs"`
}

func LoadState(path string) (*State, error) {
	empty := func() *State { return &State{Dirs: make(map[string]DirectoryEntry)} }

	f, err := os.Open(path)
	if errors.Is(err, fs.ErrNotExist) {
		return empty(), nil
	}
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var state State
	if err := json.NewDecoder(f).Decode(&state); err != nil {
		slog.Warn("ignoring unreadable score file", "path", path, "err", err)
		return empty(), nil
	}
	if state.Dirs == nil {
		state.Dirs = make(map[string]DirectoryEntry)
	}
	return &state, nil
}

func SaveState(path string, state *State) error {
	return writeFileAtomic(path, func(w io.Writer) error {
		return json.NewEncoder(w).Encode(state)
	})
}

func UpdateScore(scorePath, repoPath string) error {
	absPath, err := filepath.Abs(repoPath)
	if err != nil {
		return fmt.Errorf("resolve %q: %w", repoPath, err)
	}

	state, err := LoadState(scorePath)
	if err != nil {
		return err
	}

	entry := state.Dirs[absPath]
	entry.Frequency++
	entry.LastAccess = time.Now()
	state.Dirs[absPath] = entry
	return SaveState(scorePath, state)
}

func EffectiveScore(entry DirectoryEntry, now time.Time) float64 {
	if entry.Frequency <= 0 || entry.LastAccess.IsZero() {
		return 0
	}
	hours := now.Sub(entry.LastAccess).Hours()
	if hours <= fullScoreHours {
		return float64(entry.Frequency)
	}
	if hours >= maxScoreHours {
		return 0
	}
	recency := 1.0 - math.Log(hours/fullScoreHours)/math.Log(maxScoreHours/fullScoreHours)
	return float64(entry.Frequency) * recency
}

type dirEntry struct {
	Mtime   int64
	Scanned int64
	IsRepo  bool
	Subdirs []string
}

func (e dirEntry) fresh(mtime int64) bool {
	return e.Mtime == mtime && e.Scanned-e.Mtime > int64(racyWindow)
}

type indexData struct {
	Version int
	Dirs    map[string]dirEntry
}

type Index struct {
	path  string
	dirs  map[string]dirEntry
	seen  map[string]struct{}
	dirty bool
}

func LoadIndex(path string) *Index {
	ix := &Index{
		path: path,
		dirs: make(map[string]dirEntry),
		seen: make(map[string]struct{}),
	}

	f, err := os.Open(path)
	if err != nil {
		if !errors.Is(err, fs.ErrNotExist) {
			slog.Warn("cannot open index", "path", path, "err", err)
		}
		return ix
	}
	defer f.Close()

	var data indexData
	if err := gob.NewDecoder(f).Decode(&data); err != nil {
		slog.Debug("discarding unreadable index", "path", path, "err", err)
		return ix
	}
	if data.Version != indexVersion || data.Dirs == nil {
		slog.Debug("discarding index with different version", "version", data.Version)
		return ix
	}
	ix.dirs = data.Dirs
	return ix
}

func (ix *Index) Save() error {
	if !ix.dirty {
		return nil
	}
	return writeFileAtomic(ix.path, func(w io.Writer) error {
		return gob.NewEncoder(w).Encode(indexData{Version: indexVersion, Dirs: ix.dirs})
	})
}

// Find returns the absolute paths of all repositories at most maxDepth levels
// below root (root itself included). root must be absolute.
func (ix *Index) Find(root string, maxDepth int) []string {
	repos := ix.walk(root, maxDepth, nil)
	ix.prune(root)
	return repos
}

func (ix *Index) walk(dir string, depth int, out []string) []string {
	info, err := os.Stat(dir)
	if err != nil || !info.IsDir() {
		return out
	}
	ix.seen[dir] = struct{}{}
	mtime := info.ModTime().UnixNano()

	e, ok := ix.dirs[dir]
	if ok && e.fresh(mtime) {
		slog.Debug("index hit", "dir", dir)
	} else {
		slog.Debug("index miss, scanning", "dir", dir)
		if e, err = scanDir(dir, mtime); err != nil {
			slog.Debug("cannot read directory", "dir", dir, "err", err)
			return out
		}
		ix.dirs[dir] = e
		ix.dirty = true
	}

	if e.IsRepo {
		return append(out, dir)
	}
	if depth <= 0 {
		return out
	}
	for _, name := range e.Subdirs {
		out = ix.walk(filepath.Join(dir, name), depth-1, out)
	}
	return out
}

func (ix *Index) prune(root string) {
	for dir := range ix.dirs {
		if _, ok := ix.seen[dir]; !ok && isWithin(root, dir) {
			delete(ix.dirs, dir)
			ix.dirty = true
		}
	}
}

func scanDir(dir string, mtime int64) (dirEntry, error) {
	scanned := time.Now().UnixNano()
	entries, err := os.ReadDir(dir)
	if err != nil {
		return dirEntry{}, err
	}

	e := dirEntry{Mtime: mtime, Scanned: scanned}
	for _, d := range entries {
		if isRepoMarker(d) {
			return dirEntry{Mtime: mtime, Scanned: scanned, IsRepo: true}, nil
		}
		if d.IsDir() || d.Type()&fs.ModeSymlink != 0 {
			e.Subdirs = append(e.Subdirs, d.Name())
		}
	}
	return e, nil
}

func isRepoMarker(d fs.DirEntry) bool {
	return d.IsDir() && (d.Name() == ".git" || d.Name() == ".jj")
}

func isWithin(root, p string) bool {
	rel, err := filepath.Rel(root, p)
	return err == nil && rel != ".." && !strings.HasPrefix(rel, ".."+sep)
}

type dataFiles struct {
	score string
	index string
}

func locateData() (dataFiles, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return dataFiles{}, err
	}
	dir := filepath.Join(home, ".local", "share", "tmux-list-repo")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return dataFiles{}, err
	}
	return dataFiles{
		score: filepath.Join(dir, "score.json"),
		index: filepath.Join(dir, "repo.index"),
	}, nil
}

func writeFileAtomic(path string, write func(io.Writer) error) error {
	tmp, err := os.CreateTemp(filepath.Dir(path), filepath.Base(path)+".*.tmp")
	if err != nil {
		return err
	}
	defer os.Remove(tmp.Name())

	if err := write(tmp); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	return os.Rename(tmp.Name(), path)
}

type rgb struct{ r, g, b uint8 }

type oklab struct{ L, A, B float64 }

func srgbToLinear(c uint8) float64 {
	v := float64(c) / 255
	if v <= 0.04045 {
		return v / 12.92
	}
	return math.Pow((v+0.055)/1.055, 2.4)
}

func linearToSRGB(v float64) uint8 {
	v = min(max(v, 0), 1)
	if v <= 0.0031308 {
		v *= 12.92
	} else {
		v = 1.055*math.Pow(v, 1/2.4) - 0.055
	}
	return uint8(math.Round(v * 255))
}

func (c rgb) toOkLab() oklab {
	r, g, b := srgbToLinear(c.r), srgbToLinear(c.g), srgbToLinear(c.b)
	l := math.Cbrt(0.4122214708*r + 0.5363325363*g + 0.0514459929*b)
	m := math.Cbrt(0.2119034982*r + 0.6806995451*g + 0.1073969566*b)
	s := math.Cbrt(0.0883024619*r + 0.2817188376*g + 0.6299787005*b)
	return oklab{
		L: 0.2104542553*l + 0.7936177850*m - 0.0040720468*s,
		A: 1.9779984951*l - 2.4285922050*m + 0.4505937099*s,
		B: 0.0259040371*l + 0.7827717662*m - 0.8086757660*s,
	}
}

func (c oklab) toRGB() rgb {
	l := c.L + 0.3963377774*c.A + 0.2158037573*c.B
	m := c.L - 0.1055613458*c.A - 0.0638541728*c.B
	s := c.L - 0.0894841775*c.A - 1.2914855480*c.B
	l, m, s = l*l*l, m*m*m, s*s*s
	return rgb{
		linearToSRGB(+4.0767416621*l - 3.3077115913*m + 0.2309699292*s),
		linearToSRGB(-1.2684380046*l + 2.6097574011*m - 0.3413193965*s),
		linearToSRGB(-0.0041960863*l - 0.7034186147*m + 1.7076147010*s),
	}
}

func blend(from, to oklab, t float64) oklab {
	return oklab{
		L: from.L + (to.L-from.L)*t,
		A: from.A + (to.A-from.A)*t,
		B: from.B + (to.B-from.B)*t,
	}
}

func ansiFg(c rgb, s string) string {
	return fmt.Sprintf("\x1b[38;2;%d;%d;%dm%s\x1b[0m", c.r, c.g, c.b, s)
}

func setupLogging(debug bool) {
	if debug {
		h := slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelDebug})
		slog.SetDefault(slog.New(h))
		return
	}
	slog.SetDefault(slog.New(slog.DiscardHandler))
}

func newFlagSet(name string) (*flag.FlagSet, *bool) {
	flags := flag.NewFlagSet(name, flag.ExitOnError)
	flags.Usage = func() {
		fmt.Fprint(flags.Output(), usage)
		flags.PrintDefaults()
	}
	var debug bool
	flags.BoolVar(&debug, "debug", false, "enable debug logging")
	flags.BoolVar(&debug, "v", false, "shorthand for -debug")
	return flags, &debug
}

func runAdd(args []string) error {
	flags, debug := newFlagSet("add")
	flags.Parse(args)
	setupLogging(*debug)

	if flags.NArg() != 1 {
		flags.Usage()
		os.Exit(2)
	}
	files, err := locateData()
	if err != nil {
		return err
	}
	return UpdateScore(files.score, flags.Arg(0))
}

type repoItem struct {
	rel   string
	score float64
	depth int
}

func runList(args []string) error {
	flags, debug := newFlagSet("tmux-list-repos")
	var maxDepth int
	flags.IntVar(&maxDepth, "max-depth", 5, "maximum directory recursion depth")
	flags.IntVar(&maxDepth, "d", 5, "shorthand for -max-depth")
	flags.Parse(args)
	setupLogging(*debug)

	if flags.NArg() != 1 {
		flags.Usage()
		os.Exit(2)
	}

	root, err := filepath.Abs(flags.Arg(0))
	if err != nil {
		return err
	}
	if info, err := os.Stat(root); err != nil {
		return err
	} else if !info.IsDir() {
		return fmt.Errorf("%s is not a directory", root)
	}

	files, err := locateData()
	if err != nil {
		return err
	}

	ix := LoadIndex(files.index)
	found := ix.Find(root, maxDepth)
	if err := ix.Save(); err != nil {
		slog.Warn("cannot save index", "err", err)
	}

	state, err := LoadState(files.score)
	if err != nil {
		return fmt.Errorf("load state: %w", err)
	}

	now := time.Now()
	repos := make([]repoItem, 0, len(found))
	for _, p := range found {
		rel, err := filepath.Rel(root, p)
		if err != nil {
			continue
		}
		repos = append(repos, repoItem{
			rel:   rel,
			score: EffectiveScore(state.Dirs[p], now),
			depth: strings.Count(rel, sep),
		})
	}
	slices.SortStableFunc(repos, func(a, b repoItem) int {
		return cmp.Or(
			cmp.Compare(b.score, a.score),
			cmp.Compare(a.depth, b.depth),
			cmp.Compare(strings.ToLower(a.rel), strings.ToLower(b.rel)),
		)
	})

	from := rgb{0x4f, 0xd6, 0xbe}.toOkLab()
	to := rgb{0xc8, 0xd3, 0xf5}.toOkLab()
	total := float64(len(repos))

	out := bufio.NewWriter(os.Stdout)
	defer out.Flush()
	for i, r := range repos {
		c := blend(from, to, float64(i)/total).toRGB()
		fmt.Fprintln(out, ansiFg(c, r.rel))
	}
	return nil
}

func run(args []string) error {
	if len(args) > 0 && args[0] == "add" {
		return runAdd(args[1:])
	}
	return runList(args)
}

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "tmux-list-repos:", err)
		os.Exit(1)
	}
}
