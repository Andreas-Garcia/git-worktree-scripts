#!/bin/bash

# Script to remove a git worktree and its associated branch
#
# This script removes both the worktree directory and the branch it was tracking.
# It can remove local branches and optionally remote branches.
#
# Usage: ./scripts/remove-worktree-branch.sh <branch-name> [worktree-path] [--remove-remote]
#
# Arguments:
#   branch-name: The name of the branch to remove
#   worktree-path: (Optional) Path to the worktree. If not provided, will be inferred from branch name
#   --remove-remote: (Optional) Also remove the remote branch if it exists
#
# Examples:
#   ./scripts/remove-worktree-branch.sh feature/my-feature
#   ./scripts/remove-worktree-branch.sh feature/my-feature ../audiometa-python-my-feature
#   ./scripts/remove-worktree-branch.sh feature/my-feature --remove-remote

set -e

# Get the repository root (where .git directory is)
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")

# Parse arguments
BRANCH_NAME=""
WORKTREE_PATH=""
REMOVE_REMOTE=false

for arg in "$@"; do
    case $arg in
        --remove-remote)
            REMOVE_REMOTE=true
            shift
            ;;
        *)
            if [ -z "$BRANCH_NAME" ]; then
                BRANCH_NAME="$arg"
            elif [ -z "$WORKTREE_PATH" ]; then
                WORKTREE_PATH="$arg"
            fi
            ;;
    esac
done

if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: $0 <branch-name> [worktree-path] [--remove-remote]"
    echo ""
    echo "Examples:"
    echo "  $0 feature/my-feature"
    echo "  $0 feature/my-feature ../audiometa-python-my-feature"
    echo "  $0 feature/my-feature --remove-remote"
    exit 1
fi

# Check if repository uses strict git flow and validate branch name
local has_develop=false
if git show-ref --verify --quiet "refs/heads/develop" || git show-ref --verify --quiet "refs/remotes/origin/develop"; then
    has_develop=true
elif git show-ref --verify --quiet "refs/heads/dev" || git show-ref --verify --quiet "refs/remotes/origin/dev"; then
    has_develop=true
fi

# In strict Git Flow, prevent removal of non-Git Flow branch types
if [ "$has_develop" = true ]; then
    if [[ ! "$BRANCH_NAME" =~ ^(feature|release|hotfix)/ ]] && [[ ! "$BRANCH_NAME" =~ ^(main|master|develop|dev)$ ]]; then
        local branch_type="${BRANCH_NAME%%/*}"
        local branch_suffix="${BRANCH_NAME#*/}"
        echo "❌ Error: '$branch_type/*' is not a valid Git Flow branch type." >&2
        echo "   Git Flow only supports: feature/*, release/*, and hotfix/*" >&2
        echo "" >&2
        echo "   This branch should be renamed to 'feature/$branch_suffix' before removal." >&2
        echo "   To rename: git branch -m $BRANCH_NAME feature/$branch_suffix" >&2
        exit 1
    fi
fi

# Infer worktree path if not provided
if [ -z "$WORKTREE_PATH" ]; then
    WORKTREE_NAME="${BRANCH_NAME#feature/}"
    WORKTREE_NAME="${WORKTREE_NAME#chore/}"
    WORKTREE_NAME="${WORKTREE_NAME#hotfix/}"
    if [ -z "$WORKTREE_NAME" ]; then
        WORKTREE_NAME="$BRANCH_NAME"
    fi
    WORKTREE_PATH="../${REPO_NAME}-${WORKTREE_NAME}"
fi

# Convert to absolute path
if [[ ! "$WORKTREE_PATH" = /* ]]; then
    WORKTREE_ABS_PATH=$(cd "$REPO_ROOT" && cd "$(dirname "$WORKTREE_PATH")" && pwd)/$(basename "$WORKTREE_PATH")
else
    WORKTREE_ABS_PATH="$WORKTREE_PATH"
fi

echo "Removing worktree and branch: $BRANCH_NAME"
echo ""

# Remove worktree if it exists
if [ -d "$WORKTREE_ABS_PATH" ]; then
    echo "Removing worktree at: $WORKTREE_ABS_PATH"
    git worktree remove "$WORKTREE_ABS_PATH" --force 2>/dev/null || {
        echo "Warning: Could not remove worktree via git (may not be registered)"
        echo "Removing directory manually..."
        rm -rf "$WORKTREE_ABS_PATH"
    }
    echo "✓ Worktree removed"
else
    # Directory doesn't exist - check if git has a stale worktree entry
    if git worktree list | grep -q "$WORKTREE_ABS_PATH"; then
        echo "Worktree directory not found but git has stale entry"
        echo "Pruning stale worktree entries..."
        git worktree prune
        echo "✓ Stale worktree entry removed"
    else
        echo "Worktree not found at: $WORKTREE_ABS_PATH (already removed)"
    fi
fi

echo ""

# Remove local branch if it exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "Removing local branch: $BRANCH_NAME"
    git branch -D "$BRANCH_NAME" 2>/dev/null || git branch -d "$BRANCH_NAME"
    echo "✓ Local branch removed"
else
    echo "Local branch '$BRANCH_NAME' not found (skipping)"
fi

echo ""

# Remove remote branch if requested and exists
if [ "$REMOVE_REMOTE" = true ]; then
    REMOTE_NAME="origin"
    if git show-ref --verify --quiet "refs/remotes/${REMOTE_NAME}/$BRANCH_NAME"; then
        echo "Removing remote branch: ${REMOTE_NAME}/$BRANCH_NAME"
        git push "${REMOTE_NAME}" --delete "$BRANCH_NAME" 2>/dev/null || {
            echo "Warning: Could not remove remote branch (may not have permission or branch doesn't exist)"
        }
        echo "✓ Remote branch removed"
    else
        echo "Remote branch '${REMOTE_NAME}/$BRANCH_NAME' not found (skipping)"
    fi
else
    # Use ls-remote to check if branch actually exists on remote (not just local tracking ref)
    if git ls-remote --heads origin "$BRANCH_NAME" 2>/dev/null | grep -q "refs/heads/$BRANCH_NAME"; then
        echo "Note: Remote branch 'origin/$BRANCH_NAME' exists but was not removed"
        echo "      To remove it, run: git push origin --delete $BRANCH_NAME"
    fi
fi

echo ""
echo "✓ Cleanup complete"
