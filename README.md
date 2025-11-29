# Git Worktree Management Scripts

A collection of bash scripts for managing git worktrees across multiple repositories. Automate the creation, opening, and removal of git worktrees with support for multiple editors (Cursor, VS Code) and repository-specific setup hooks.

## Description

This repository provides a set of reusable bash scripts that simplify git worktree management. Instead of manually creating worktrees, switching branches, and managing multiple working directories, these scripts automate the entire workflow:

- **Create worktrees** with automatic base branch detection (supports both light and strict git flow)
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

### Option 1: NPM Package (Recommended)

Use via `npx` - no installation needed:

```bash
npx git-worktree create feature/my-feature
npx git-worktree open
npx git-worktree remove
npx git-worktree remove feature/my-feature
```

Or install as a dev dependency for convenience:

```bash
npm install --save-dev git-worktree-scripts
# or
yarn add -D git-worktree-scripts
# or
pnpm add -D git-worktree-scripts
```

After installation, use the same commands:

```bash
npx git-worktree create feature/my-feature
npx git-worktree open
npx git-worktree remove
```

**Alternative commands** (also available):

- `npx git-worktree-create` (alias for `git-worktree create`)
- `npx git-worktree-open` (alias for `git-worktree open`)
- `npx git-worktree-remove` (alias for `git-worktree remove`)

## Git Flow Support

This project supports both **light git flow** and **strict git flow** workflows:

### Light Git Flow

- All branches (features, hotfixes, etc.) branch from `main`
- Works out of the box for repositories using a simple `main` branch workflow

### Strict Git Flow

- **Feature branches** (`feature/*`), **release branches** (`release/*`), and **chore branches** (`chore/*`) branch from `develop` (standard) or `dev` (alternative shorthand)
- **Hotfix branches** (`hotfix/*`) branch from `main` (or `master`)
- **Other branches** (`bugfix/*`, etc.) branch from `main`/`master` (these are not part of the official Git Flow spec)
- The scripts automatically detect which workflow your repository uses based on which branches exist

**How it works:**

- When creating `feature/*`, `release/*`, or `chore/*` branches, the script checks for `develop` first (standard), then `dev` (alternative), then falls back to `main` (light git flow).
- When creating `hotfix/*` branches, the script always uses `main` or `master` as the base.
- **Strict validation**: In repositories with `develop`/`dev` branches (strict Git Flow), the script will:
  - **Prevent creation** of non-Git Flow branch types (`bugfix/*`, etc.) with an error message
  - **Warn about removal** of non-Git Flow branch types and prompt for base branch selection
  - Valid Git Flow branch types are: `feature/*`, `release/*`, `hotfix/*`, and `chore/*`
- Merge detection in removal scripts uses the same logic to check merges against the appropriate base branch.
- Protected branches (`main`, `master`, `develop`, `dev`) cannot be deleted through the removal scripts.

## Working with Multiple Branches (Git Worktrees)

When working on multiple features simultaneously or when you need separate editor windows for different branches, use **git worktrees**. This allows you to have multiple working directories for the same repository, each on a different branch.

### Quick Setup

Use the provided command to create a worktree and open it in your preferred code editor (Cursor or VS Code):

```bash
# Interactive mode: prompts for branch type and name
npx git-worktree create
# Will prompt for:
# - Branch type (feature/release/hotfix in strict Git Flow, or feature/chore/hotfix in light Git Flow)
# - Branch name (without prefix)

# Optional: specify custom worktree directory name
npx git-worktree create my-custom-worktree-name

# If branch already exists with commits, script will offer options:
# - Create worktree for existing branch (default)
# - Checkout branch in current repo
# - Remove existing branch and create new one
```

**Editor Selection:**

- If both Cursor and VS Code are installed, you'll be prompted to choose
- If only one editor is installed, it opens automatically
- **macOS**: Fully tested. Editors must be in `/Applications`
- **Linux**: Experimental support (not tested). Uses `cursor` or `code` commands
- **Windows**: Experimental support (not tested). Uses `cursor` or `code` commands via Git Bash/Cygwin

⚠️ **Note**: Linux and Windows support has not been tested. If you encounter issues, please report them.

### What the Script Does

The `git-worktree create` command automates the following main steps:

1. **Validates prerequisites**: Checks if branch/worktree exists, ensures base branch exists, and worktree path is available

2. **Determines base branch**: Based on git flow conventions:

   - **Feature branches** (`feature/*`) and **release branches** (`release/*`): Use `develop` if it exists (strict git flow), otherwise fall back to `main` (light git flow)
   - **Hotfix branches** (`hotfix/*`): Use `main` or `master`
   - **Other branches**: Default to `main` or `master`

3. **Handles existing branches**: If branch already exists with commits, offers interactive options:

   - **Create worktree for existing branch** (default): Creates a worktree and checks out the existing branch
   - **Checkout in current repo**: Checks out the branch in your current repository
   - **Remove existing branch**: Removes the branch and creates a new one from the base branch
   - If a worktree already exists for the branch, offers to open it directly

4. **Updates base branch**: For new branches, pulls the latest changes from the base branch to ensure you have the most recent code

5. **Creates worktree**: Creates a new git worktree:

   - For new branches: Creates from the updated base branch with your specified branch name
   - For existing branches: Creates worktree and checks out the existing branch (fetches from remote if needed)

6. **Copies gitignored files**: Automatically copies common gitignored files (like `.env`, `.env.local`, etc.) from the repo root to the new worktree if they exist. Also copies template files (like `.env.example` → `.env`) if the target doesn't exist

7. **Sets up development environment**: Runs repository-specific setup script if `scripts/setup-worktree.sh` exists

8. **Opens in editor**: Automatically opens the worktree directory in Cursor or VS Code

**Important**:

- The script automatically detects whether your repository uses strict git flow (with `develop`) or light git flow (just `main`)
- For new branches, the script creates worktrees from the appropriate base branch (after pulling the latest changes) to ensure a consistent and up-to-date base
- For existing branches, the script creates a worktree for the existing branch, preserving any existing commits

### Opening Existing Worktrees

To quickly open an existing worktree in your editor:

```bash
# List all worktrees and open selected one in your editor
npx git-worktree open
```

The command will:

1. Display all available worktrees with their branch names
2. Prompt you to select a worktree by number
3. Prompt you to choose an editor (if both Cursor and VS Code are available)
4. Open the selected worktree in your chosen editor

This is useful when you have multiple worktrees and want to quickly switch between them without manually navigating to their directories.

### Manual Setup

If you prefer to create worktrees manually:

```bash
# Create worktree for existing branch
git worktree add ../repo-feature2 feature/my-feature

# Create worktree with new branch
git worktree add ../repo-feature2 -b feature/new-feature

# Open in Cursor (macOS)
open -a Cursor ../repo-feature2

# Or open in VS Code (macOS)
open -a "Visual Studio Code" ../repo-feature2

# Or use command line (Linux/macOS)
cursor ../repo-feature2  # for Cursor
code ../repo-feature2    # for VS Code
```

### Benefits

- Work on multiple branches simultaneously
- Each editor window operates independently
- No need to stash/commit when switching contexts
- Shared git history (same `.git` directory)

### Cleanup

#### Interactive Removal

To interactively list and remove worktrees:

```bash
# List all worktrees and remove selected one
npx git-worktree remove

# Also remove remote branch when removing worktree
# (use the direct removal method with --remove-remote flag)
```

The command will:

1. Display all available worktrees with their branch names
2. Protect base branches (`main`, `master`, `develop`) and current worktree from deletion (marked as `[PROTECTED]`)
3. Prompt you to select a worktree by number (only non-protected worktrees are selectable)
4. Check merge status against the appropriate base branch (develop for features/releases, main for hotfixes)
5. Show the selected worktree details and ask for confirmation
6. Remove the worktree and its associated branch

**Safety Features:**

- Cannot remove protected branch worktrees (`main`, `master`, `develop`)
- Cannot remove the worktree you're currently inside (prevents shell errors)
- Must switch to a different worktree before removing your current one
- Handles missing worktree directories gracefully (stale git entries are cleaned up automatically)
- Merge detection uses the correct base branch based on git flow conventions

**Note:** If a worktree directory was manually deleted, the command will detect this and clean up the stale git entries automatically.

#### Direct Removal

If you know the branch name, you can remove it directly:

```bash
# Remove worktree and local branch
npx git-worktree remove feature/my-feature

# Note: To remove remote branch, use git directly:
git push origin --delete feature/my-feature
```

#### Manual Removal

```bash
# Remove worktree when done
git worktree remove ../repo-feature2
```

### Example Workflow

```bash
# Main repository in ~/my-project (on main branch)
cd ~/my-project

# Create worktree for feature branch
npx git-worktree create feature/add-flac-support

# This command will:
# - Detect base branch (develop for features in strict git flow, main in light git flow)
# - Pull latest changes from origin/base
# - Create new directory: ~/my-project-feature-add-flac-support
# - Open new editor window (Cursor or VS Code) with that directory
# - Check out feature/add-flac-support branch from updated base branch

# Now you can work in both windows:
# - Main window: base branch (main or develop)
# - New window: feature/add-flac-support branch

# When done, remove the worktree
npx git-worktree remove feature/add-flac-support
```

### Listing Worktrees

```bash
# List all worktrees
git worktree list

# Output example:
# /path/to/my-project          abc1234 [main]
# /path/to/my-project-feature2  def5678 [feature/my-feature]

# Interactive command to list and open worktrees in your editor
npx git-worktree open
```

### Notes

- Each worktree shares the same `.git` directory, so commits, branches, and remotes are shared
- You cannot check out the same branch in multiple worktrees simultaneously
- Worktrees are useful for comparing branches side-by-side or working on multiple features without switching contexts

## Gitignored Files Handling

When creating a new worktree, the script can automatically copy gitignored files/directories to the new worktree. You configure which files to copy using a `.git-worktree-copy` file in your repository root.

### Configuration File

Create a `.git-worktree-copy` file in your repository root to specify which files/directories to copy:

```bash
# Copy specific files
.env
.env.local
.secrets

# Copy files matching a pattern
.env.*

# Copy entire directories
config/local/

# Copy template files (source:target)
.env.example:.env
.env.local.example:.env.local

# Copy files from subdirectories
config/*.local
*.local.json
```

**Configuration Format**:

- One pattern per line
- Lines starting with `#` are comments
- Empty lines are ignored
- Supports glob patterns (`*`, `?`, `[...]`) - works recursively for subdirectories
- Supports template syntax: `source:target` (e.g., `.env.example:.env`)
- Patterns can match files/directories in any subdirectory (e.g., `config/*.local`, `**/*.env`)

**Note**:

- Files are only copied if they don't already exist in the worktree, preventing overwriting of worktree-specific configurations
- Both files and directories can be copied (directories are copied recursively)

## Repository-Specific Setup

If your repository needs custom setup when creating worktrees (e.g., Python virtual environment, additional gitignored files), create a `scripts/setup-worktree.sh` file:

```bash
#!/bin/bash
# Repository-specific worktree setup

# Example: Python virtual environment
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e ".[dev]"
fi

# Example: Copy additional gitignored files
# The script already handles common .env files, but you can add more:
if [ -f "$REPO_ROOT/.custom-config" ] && [ ! -f "$WORKTREE_PATH/.custom-config" ]; then
    cp "$REPO_ROOT/.custom-config" "$WORKTREE_PATH/.custom-config"
fi
```

The `git-worktree create` command will automatically detect and run this file if it exists.

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
