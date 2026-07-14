package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/url"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/spf13/pflag"
)

func main() {
	log.SetOutput(os.Stderr)
	log.SetFlags(0)

	var targetDir string
	pflag.StringVarP(&targetDir, "destination", "d", "", "destination file")
	pflag.SetInterspersed(false)

	pflag.Parse()

	if pflag.NArg() < 1 {
		pflag.Usage()
		os.Exit(1)
	}

	rawURL := pflag.Arg(0)
	extraArgs := pflag.Args()[1:]

	cloneURI, cloneDir, err := parseHTTPS(rawURL)
	if err != nil {
		log.Fatal(err)
	}

	if targetDir == "" {
		username := getGitHubUsername()
		if username != "" {
			cloneDir = strings.Replace(cloneDir, username+"/", "", 1)
		}

		homeDir, err := os.UserHomeDir()
		if err != nil {
			log.Fatal(err)
		}
		targetDir = filepath.Join(homeDir, "git", cloneDir)
	}

	args := []string{"git", "clone", cloneURI, targetDir}
	args = append(args, extraArgs...)

	cmd := exec.Command("jj", args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}

// parseHTTPS parses standard https:// URLs.
func parseHTTPS(raw string) (uri, dir string, err error) {
	u, err := url.Parse(raw)
	if err != nil {
		return "", "", err
	}
	if u.Scheme != "https" && u.Scheme != "http" {
		return "", "", errors.New("URL must be http or https")
	}

	host := u.Hostname()
	pathStr := strings.TrimPrefix(u.Path, "/")

	gitlabRe := regexp.MustCompile(`^gitlab\..*$`)

	if gitlabRe.MatchString(host) {
		cleanPath, _, _ := cutNthSep(pathStr, "/", 2)
		uri = fmt.Sprintf("git@%s:%s", host, cleanPath)
		dir = cleanPath
		return
	}

	switch host {
	case "gist.github.com":
		gistID, _, _ := strings.Cut(pathStr, "/")
		uri = fmt.Sprintf("git@%s:%s", host, gistID)
		dir = pathStr

	case "github.com", "gitlab.com", "codeberg.org":
		cleanPath, _, _ := cutNthSep(pathStr, "/", 2)
		uri = fmt.Sprintf("git@%s:%s", host, cleanPath)
		dir = cleanPath

	case "aur.archlinux.org":
		cleanPath := strings.TrimSuffix(pathStr, ".git")
		pkg := path.Base(cleanPath)
		uri = fmt.Sprintf("ssh://aur@%s/%s.git", host, pkg)
		dir = filepath.Join("aur", pkg)

	default:
		if strings.Count(pathStr, "/") == 1 {
			return raw, pathStr, nil
		}
		return "", "", fmt.Errorf("unsupported host: %s", host)
	}
	return uri, dir, nil
}

// getGitHubUsername returns the GitHub login of the active gh user, or empty string.
func getGitHubUsername() string {
	// gh auth status --active --jq '.[][][].login' --json hosts
	cmd := exec.Command("gh", "auth", "status", "--active", "--jq", ".[][][].login", "--json", "hosts")
	out, err := cmd.Output()
	if err != nil {
		return ""
	}
	var result string
	if err := json.Unmarshal(out, &result); err != nil {
		result = strings.TrimSpace(string(out))
	}
	return result
}

func cutNthSep(s string, sep string, n int) (before, after string, found bool) {
	if n <= 0 || sep == "" {
		return s, "", false
	}
	idx := 0
	for range n {
		match := strings.Index(s[idx:], sep)
		if match == -1 {
			return s, "", false
		}
		idx += match + len(sep)
	}
	cutIdx := idx - len(sep)
	return s[:cutIdx], s[idx:], true
}
