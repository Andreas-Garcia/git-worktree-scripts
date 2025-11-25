# Git Worktree Management Scripts

A collection of bash scripts for managing git worktrees across multiple repositories. Automate the creation, opening, and removal of git worktrees with support for multiple editors (Cursor, VS Code) and repository-specific setup hooks.

## Description

This repository provides a set of reusable bash scripts that simplify git worktree management. Instead of manually creating worktrees, switching branches, and managing multiple working directories, these scripts automate the entire workflow:

- **Create worktrees** from the main branch with automatic editor opening
- **Open existing worktrees** interactively from a list
- **Remove worktrees** safely with merge detection and branch cleanup
- **Cross-platform support** for macOS, Linux, and Windows
- **Repository-specific setup** hooks for custom environment configuration

Perfect for developers who work on multiple features simultaneously or need separate editor windows for different branches. Install once, use across all your repositories.

## Features

- **Create worktrees** with automatic editor opening (Cursor/VS Code)
- **Open existing worktrees** interactively
- **Remove worktrees** safely with merge detection
- **Cross-platform support** (macOS, Linux, Windows)

## Installation

See [QUICKSTART.md](QUICKSTART.md) for detailed installation instructions.

### Quick Install

```bash
# Clone this repository once
git clone <your-repo-url>/git-worktree-scripts.git ~/git-worktree-scripts

# In any repository, run the installer
~/git-worktree-scripts/install.sh

# Optionally create git aliases for convenience
~/git-worktree-scripts/install.sh scripts --create-aliases
```

## Usage

### Create a Worktree

```bash
./scripts/create-worktree.sh feature/my-feature
```

This will:

- Create a new worktree from the `main` branch
- Set up the development environment (if `scripts/setup-worktree.sh` exists)
- Open the worktree in your editor (Cursor or VS Code)

### Open an Existing Worktree

```bash
./scripts/open-worktree.sh
```

Lists all worktrees and opens the selected one in your editor.

### Remove a Worktree

```bash
# Interactive removal
./scripts/remove-worktree-interactive.sh

# Direct removal
./scripts/remove-worktree-branch.sh feature/my-feature
```

## Repository-Specific Setup

If your repository needs custom setup when creating worktrees (e.g., Python virtual environment), create a `scripts/setup-worktree.sh` file:

```bash
#!/bin/bash
# Repository-specific worktree setup

# Example: Python virtual environment
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e ".[dev]"
fi
```

The `create-worktree.sh` script will automatically detect and run this file if it exists.

## Git Aliases (Optional)

After installation with `--create-aliases`, you can use:

```bash
git worktree feature/my-feature        # Create worktree
git worktree-open                      # Open existing worktree
git worktree-remove                    # Remove worktree interactively
```

## Scripts

- **create-worktree.sh** - Create a new worktree and open in editor
- **open-worktree.sh** - List and open existing worktrees
- **remove-worktree-branch.sh** - Remove a specific worktree and branch
- **remove-worktree-interactive.sh** - Interactive worktree removal with merge detection
- **editor-common.sh** - Shared utilities for editor detection

## Requirements

- Git 2.5+ (for worktree support)
- Bash 4+
- Cursor or VS Code (for editor integration)

## Platform Support

- **macOS**: Fully tested
- **Linux**: Experimental (not fully tested)
- **Windows**: Experimental (via Git Bash/Cygwin, not fully tested)

## License

[Your License Here]
