# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for macOS, Linux (Pop!OS), and WSL. Manages configuration for Neovim, Tmux, Zsh, Alacritty, and development tools (PHP, Node, Rust).

## Installation Commands

```bash
# Full installation (interactive)
./bin/update.sh

# Unattended installation (auto-yes)
./bin/update.sh -y

# Verbose output
./bin/update.sh -v

# Individual tool setup
./bin/setup_nvim.sh
./bin/setup_php.sh
./bin/setup_node.sh
./bin/setup_zsh.sh
```

## Architecture

### Directory Structure

- `bin/` - Setup scripts orchestrated by `update.sh`
  - `functions.sh` - Shared utilities (OS detection, package installation helpers)
  - `setup_*.sh` - Individual tool installers
- `nvim/` - Neovim configuration (Lua-based)
  - `init.lua` - Entry point
  - `lua/nusje2000/packer.lua` - Plugin definitions
  - `lua/nusje2000/remap.lua` - Key mappings
  - `after/plugin/lsp.lua` - LSP configuration
- `shell/` - Shell configuration (.zshrc, .aliases, ide.sh)
- `tmux/` - Tmux configuration with tmux2k theme
- `alacritty/` - Terminal emulator config
- `phpactor/` - PHP LSP with PHPCS, PHPStan, XDebug

### Configuration Pattern

All configuration files are symlinked from `~/.config/` to this repository using `link_file()` from `functions.sh`.

### IDE Command

The `ide.sh` script manages Tmux sessions per project:

```bash
ide <project-name>         # Open existing project in ~/projects/
ide new <project-name>     # Create new project from template
ide git@github.com/...     # Clone and open repository
```

### Neovim LSP Keybindings

- `gr` - Show references
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `F2` - Rename symbol
- `F3` - Format document
- `F4` - Code actions
- `g?` - Show diagnostics

### Platform Detection

Scripts use `is_wsl()`, `is_osx()` from `functions.sh` to apply platform-specific configuration. macOS uses Homebrew; Linux uses apt.
