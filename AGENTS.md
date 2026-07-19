# AI Developer Guidelines

> **System Note:** This file defines explicit project rules for version control,
> Nix development paradigms, and codebase styling. Strict adherence is required.

---

## Version Control (Jujutsu)

Never use `git`. This repository exclusively uses **Jujutsu (`jj`)**.

- **Inspection:** Always use `jj log` to look up commit stats and grab the
  required revision ID (`rev`).
- **Staging:** Track files using `jj file track` instead of adding them.
- **Committing:** Describe and create new revisions sequentially:

```bash
jj desc -m "your commit message" <rev>
jj new
```

- **Resetting:** Do not reset, create new change set from the parent revision:
  `jj new @-`.
- **Constraint:** Stick strictly to these core commands; avoid other `jj`
  utilities unless absolutely necessary.

---

## Development Rules

### Nix Search & Commands

- **No Store Scans:** Never search `/nix/store` directly. Use
  `nix flake archive --json` exactly once, then reference its output literally
  in subsequent commands without using variables.
  - _Bad:_ `NIXPKGS=/nix/store/... rg $NIXPKGS`
  - _Good:_ `rg /nix/store/abc-specific-path...`

- **Nix CLI Version:** Always use modern Nix3 CLI commands (e.g., `nix build`),
  never legacy ones (e.g., `nix-build`).

### Scripting & JSON

- **JSON Parsing:** Always use `jq` to parse JSON. Do not use Python (prevents
  unexpected permission prompts).
- **Long-Running Tasks:** Prefer **Go** over Bash for complex or long tasks.
  Write Go scripts using the provided `pkgs.writeGo` or `pkgs.writeGoBin`
  patterns:

```nix
pkgs.writeGo "hello" { runtimeInputs = [pkgs.ffmpeg]; } /* bash */ ''
  exec.Command("ffmpeg", "")...
''
```

- **Script Registration:** Register system scripts alongside their completions
  via the `flake-parts` module:

```nix
{
  scripts.<name> = {
    inherit name;
    completion = "carapace completion spec as nix attrset";
    script = pkgs: pkgs...;
  };
}
```

---

## ❄️ Nix Architecture & Module Styles

- **Structure:** Follow the **Dendritic Pattern** (auto-discovery via
  `flake-parts`).
- **Imports:** Handled recursively via `vic/import-tree`. Prefix ignored files
  with an underscore (e.g., `_settings.nix`).
- **Home Directory:** Managed via `hjem`. Modules are aliased to `home.*`.
- **Persistence:** Ephemeral data persistence is handled via
  `nix-community/preservation`. Module aliases are structured as `preserve.*`
  and `preserveHome.*`.
- **Utilities:** Custom project utility functions are isolated under `lib.x`.

- **Configuration Priority:**
  1. Prefer package wrappers over system configurations when modifying apps.
     Wrap packages using
     `perSystem.packages.x = inputs.wrappers.wrappers.x.wrap { ... };`.
  2. When a wrapper is impossible, fallback to `home.config.files.<name>.*`.

---

## Nix Code Style & Syntax

### Scope & Inherits

- **No Global Inherits:** Never use `inherit (lib) foo` unless `foo` is a
  root-level function. (except `lib.types` and `lib.x.opt`). Always pull from
  the exact submodule path (e.g., `inherit (lib.lists) head;`).
- **Top-Level Scope:** Extract `lib` functions via `let inherit ... in` at the
  very top of the topmost module, never inside nested attribute sets:

```nix
{ lib, ... }:
let
  inherit (lib.lists) head;
in {
  flake.modules.nixos.base = { ... }: { /* Do not use lib here */ };
}
```

- **Package List**:
  - **Single Package**: `singleton package` instead of `[package]`
  - **Multiple Packages from single source**: `with <src>; [ pkg1 pkg2]`.
  ```nix
  packages = with pkgs; [
      ffmpeg
      jq
  ];
  ```
  - **Multiple packages from multiple sources**: use `inherit (src) ...pkg` with
    attrValues.
  ```nix
  packages = attrValues {
    inherit (pkgs) ffmpeg jq;
    inherit (self.packages.${system}) myScript;
  };
  ```

### Expressions & Formatting

- **Anti-Rec:** **Never** use the `rec` keyword. For self-referencing attribute
  sets, use a custom fixed point function: `fix (final: { ... })`.
- **Lists:** Prefer `lib.lists.singleton x` over single-item list literals
  `[ x ]`.
- **Executables:** Always use `${getExe pkgs.x}` in shell aliases. If used
  multiple times, bind it to a variable: `package = getExe pkgs.x;`.
- **Conditionals:** Apply `mkIf` to individual child attributes rather than
  wrapping entire structural blocks:
  - _Bad:_ `foo = mkIf cond { bar = value; };`
  - _Good:_ `foo.bar = mkIf cond value;`

- **Piping:** Use the pipe-last operator (`<|`) instead of parentheses when
  passing an expression as the final argument to a function:
  - _Bad:_ `foo = mkIf cond (myfunction value);`
  - _Good:_ `foo = mkIf cond <|myfunction value;`

- **Piping:** For data that need to passed throught multiline functions. Use
  `|>`. E.g.
  ```nix
  # recusivily find *.plugin.zsh file to source theme!
  pluginFiles =
    [
      pkgs.zsh-fzf-tab
      pkgs.zsh-fast-syntax-highlighting
      pkgs.zsh-autosuggestions
    ]
    |> map listFilesRecursive
    |> flatten
    |> builtins.filter isPluginZSH
    |> map (p: "source ${p}")
    |> join "\n";
  ```

- **Paths:** Never use `toString` on paths requiring derivation context
  retention. Use string interpolation: `"${path}"`.

### Layout & Inline Strings

- **Key Order:** Group module configs exactly as follows: Environment Variables
  → Aliases → Packages → XDG Configs → Program-Specific Configs.
- **Separation:** Maintain a single empty line between unrelated option
  definitions.
- **Arguments:** Destructure attribute sets in arguments (`{ home, ... }:\n`)
  instead of using explicit member access (`value: value.home`).
- **Inline Code:** Specify the syntax language explicitly before multiline
  strings (e.g., `/* bash */ ''...''`).
- **Inline Derivations:** Declare scripts inline directly inside structural
  attributes (like `src` or `Exec`) rather than creating separate `let`
  bindings:

```nix
serviceConfig.Exec = pkgs.writeShellScript <name> /* bash */ ''<script>'';
```

- **Comments:** Format section headers as **Title Case** with no trailing
  punctuation (e.g., `# System Dock`).

### CLI Constraints

- **No Short Flags:** Always use long-form CLI arguments in scripts and source
  configurations. Short flags are strictly for interactive shell use.
