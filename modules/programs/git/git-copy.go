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
	"strings"
)

func main() {
	log.SetOutput(os.Stderr)
	log.SetFlags(0)

	if len(os.Args) < 2 || os.Args[1] == "--help" {
		log.Fatalf("Use: %s <url> ...<git-flags>\n", filepath.Base(os.Args[0]))
	}

	rawURL := os.Args[1]
	extraArgs := os.Args[2:]

	cloneURI, cloneDir, err := parseURL(rawURL)
	if err != nil {
		log.Fatal(err)
	}

	// Adjust clone directory using gh username if available
	if username := getGitHubUsername(); username != "" {
		cloneDir = strings.Replace(cloneDir, username+"/", "", 1)
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}
	targetDir := filepath.Join(homeDir, "git", cloneDir)

	args := []string{"clone", cloneURI, targetDir}
	args = append(args, extraArgs...)

	cmd := exec.Command("git", args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}

// parseURL takes a raw URL (HTTPS or SSH) and returns the git clone URI
// and the local directory path relative to ~/git.
func parseURL(raw string) (uri, dir string, err error) {
	// Detect SSH style: git@host:path
	if strings.HasPrefix(raw, "git@") {
		return parseSSH(raw)
	}
	// Fallback to HTTPS parsing
	return parseHTTPS(raw)
}

// parseSSH parses strings like "git@github.com:user/repo.git"
func parseSSH(raw string) (uri, dir string, err error) {
	// Split into user@host and path
	parts := strings.SplitN(raw, ":", 2)
	if len(parts) != 2 {
		return "", "", errors.New("invalid SSH URL format")
	}
	userHost := parts[0]
	pathPart := parts[1]

	// Extract host from user@host
	_, after, ok := strings.Cut(userHost, "@")
	if !ok {
		return "", "", errors.New("invalid SSH URL: missing @")
	}
	host := after
	cleanPath := strings.TrimSuffix(pathPart, ".git")
	uri = raw

	switch host {
	case "gist.github.com":
		dir = cleanPath
	case "github.com", "gitlab.com":
		dir = cleanPath
	case "aur.archlinux.org":
		pkg := path.Base(cleanPath)
		dir = filepath.Join("aur", pkg)
	default:
		return "", "", fmt.Errorf("unsupported host: %s", host)
	}
	return uri, dir, nil
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

	host := u.Host
	pathStr := strings.TrimPrefix(u.Path, "/")

	switch host {
	case "gist.github.com":
		gistID, _, _ := strings.Cut(pathStr, "/")
		uri = fmt.Sprintf("git@%s:%s", host, gistID)
		dir = pathStr

	case "github.com", "gitlab.com":
		cleanPath, _, _ := cutNthSep(pathStr, "/", 2)
		uri = fmt.Sprintf("git@%s:%s", host, cleanPath)
		dir = cleanPath

	case "aur.archlinux.org":
		cleanPath := strings.TrimSuffix(pathStr, ".git")
		pkg := path.Base(cleanPath)
		uri = fmt.Sprintf("ssh://aur@%s/%s.git", host, pkg)
		dir = filepath.Join("aur", pkg)

	default:
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
