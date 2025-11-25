#!/bin/bash

# Installation script for git worktree management scripts
# This script installs the worktree scripts into any git repository
#
# Usage: ./install.sh [target-dir] [--create-aliases]
#   target-dir: Directory to install scripts to (default: scripts)
#   --create-aliases: Create git aliases for convenience

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="scripts"
CREATE_ALIASES=""

# Parse arguments
for arg in "$@"; do
    case $arg in
        --create-aliases)
            CREATE_ALIASES="--create-aliases"
            shift
            ;;
        *)
            if [ -z "$CREATE_ALIASES" ] && [ "$TARGET_DIR" = "scripts" ]; then
                TARGET_DIR="$arg"
            fi
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    echo "Please run this script from within a git repository"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
TARGET_PATH="$REPO_ROOT/$TARGET_DIR"

echo "Installing git worktree scripts..."
echo "Repository: $REPO_ROOT"
echo "Target directory: $TARGET_PATH"
echo ""

# Create target directory if it doesn't exist
mkdir -p "$TARGET_PATH"

# Copy scripts
SCRIPTS=(
    "create-worktree.sh"
    "open-worktree.sh"
    "remove-worktree-branch.sh"
    "remove-worktree-interactive.sh"
    "editor-common.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT_DIR/scripts/$script" ]; then
        echo "Installing $script..."
        cp "$SCRIPT_DIR/scripts/$script" "$TARGET_PATH/$script"
        chmod +x "$TARGET_PATH/$script"
    else
        echo "Warning: $script not found, skipping..."
    fi
done

echo ""
echo "✓ Scripts installed successfully"
echo ""

# Optionally create git aliases
if [ "$CREATE_ALIASES" = "--create-aliases" ]; then
    echo "Creating git aliases..."
    git config alias.worktree '!f() { bash scripts/create-worktree.sh "$@"; }; f'
    git config alias.worktree-open '!bash scripts/open-worktree.sh'
    git config alias.worktree-remove '!f() { bash scripts/remove-worktree-interactive.sh "$@"; }; f'
    echo "✓ Git aliases created"
    echo ""
    echo "You can now use:"
    echo "  git worktree <branch-name>"
    echo "  git worktree-open"
    echo "  git worktree-remove"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage examples:"
echo "  ./scripts/create-worktree.sh feature/my-feature"
echo "  ./scripts/open-worktree.sh"
echo "  ./scripts/remove-worktree-interactive.sh"

