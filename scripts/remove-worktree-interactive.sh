#!/bin/bash

# Script to list all git worktrees and remove the selected one
#
# This script displays all available git worktrees, allows you to select one,
# and removes the worktree and its branch (except protected branches: main, master, develop).
# Useful for cleaning up worktrees interactively.
#
# Behavior:
# 1. Lists all worktrees, marking protected branches (main, master, develop) as [PROTECTED] and non-selectable
# 2. User selects a worktree by number (only non-protected worktrees are numbered)
# 3. Checks and displays merge status of the reference branch (currently checked out branch) to detect safety
#    Safety means: reference branch is merged into its base branch (develop for features/releases, main for hotfixes)
#    Merge status is shown to the user before deletion confirmation
#
# If branch is merged (PR accepted):
# 4a. Requires simple 'y/N' confirmation for local branch deletion (safe - work is already in main)
# 5a. If remote branch exists: prompts with 'y/N' for remote branch deletion
#
# If branch is not merged (or merge status unclear):
# 4b. Requires typing 'DELETE' to confirm local branch deletion (destructive operation)
# 5b. If remote branch exists: requires typing 'DELETE' to confirm remote branch deletion
#     Shows merge status and safety information before prompting

# 6. Removes worktree directory and deletes the branch (local and optionally remote) if confirmed
#
# Merge detection (for the reference branch currently checked out in the worktree):
# - Determines base branch based on git flow conventions (develop for features/releases, main for hotfixes)
# - Detects if the reference branch is merged directly into origin/base
# - Detects transitive merges (A→B→base) when regular merge commits are used
# - Does NOT detect squash merges (commits are recreated, not preserved in history)
#   If a branch was merged via squash, it won't be detected as merged, but the
#   work is still in the base branch, so it's safe to delete (user decides based on context)
#
# Usage: ./scripts/remove-worktree-interactive.sh

set -e

# Source shared editor utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/editor-common.sh"

# Determine base branch based on git flow conventions
# Strict git flow: features/releases branch from develop, hotfixes branch from main
# Light git flow: everything branches from main
get_base_branch() {
    local branch="$1"
    
    # Check for hotfix branches (always branch from main/master in strict git flow)
    if [[ "$branch" == hotfix/* ]]; then
        # Try main first, then master
        if git show-ref --verify --quiet "refs/heads/main" || git show-ref --verify --quiet "refs/remotes/origin/main"; then
            echo "main"
        elif git show-ref --verify --quiet "refs/heads/master" || git show-ref --verify --quiet "refs/remotes/origin/master"; then
            echo "master"
        else
            echo "main"  # Default fallback
        fi
    # Check for feature or release branches (branch from develop in strict git flow)
    elif [[ "$branch" == feature/* ]] || [[ "$branch" == release/* ]]; then
        # Try develop first (strict git flow)
        if git show-ref --verify --quiet "refs/heads/develop" || git show-ref --verify --quiet "refs/remotes/origin/develop"; then
            echo "develop"
        # Fallback to main (light git flow)
        elif git show-ref --verify --quiet "refs/heads/main" || git show-ref --verify --quiet "refs/remotes/origin/main"; then
            echo "main"
        elif git show-ref --verify --quiet "refs/heads/master" || git show-ref --verify --quiet "refs/remotes/origin/master"; then
            echo "master"
        else
            echo "main"  # Default fallback
        fi
    # Default: use main/master (for other branch types like chore/, bugfix/, etc.)
    else
        if git show-ref --verify --quiet "refs/heads/main" || git show-ref --verify --quiet "refs/remotes/origin/main"; then
            echo "main"
        elif git show-ref --verify --quiet "refs/heads/master" || git show-ref --verify --quiet "refs/remotes/origin/master"; then
            echo "master"
        else
            echo "main"  # Default fallback
        fi
    fi
}

# Check if branch is protected (main, master, or develop)
is_protected_branch() {
    local branch="$1"
    if [ "$branch" = "main" ] || [ "$branch" = "master" ] || [ "$branch" = "develop" ]; then
        return 0
    fi
    return 1
}

# Check for unexpected arguments
if [ $# -gt 0 ]; then
    echo "Usage: $0"
    echo ""
    echo "This script takes no arguments. It will prompt for all confirmations interactively."
    exit 1
fi

# Get the repository root (where .git directory is)
REPO_ROOT=$(git rev-parse --show-toplevel)

# Get current worktree path
CURRENT_WORKTREE=$(pwd)

# Get all worktrees
WORKTREES=$(git worktree list --porcelain)

if [ -z "$WORKTREES" ]; then
    echo "No worktrees found."
    exit 1
fi

# Parse worktrees into arrays
declare -a PATHS
declare -a BRANCHES

CURRENT_PATH=""
CURRENT_BRANCH=""

while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    if [ -z "$line" ]; then
        # Empty line indicates end of current worktree entry
        if [ -n "$CURRENT_PATH" ]; then
            PATHS+=("$CURRENT_PATH")
            BRANCHES+=("$CURRENT_BRANCH")
            CURRENT_PATH=""
            CURRENT_BRANCH=""
        fi
        continue
    fi

    if [[ $line == worktree* ]]; then
        # Save previous worktree if exists
        if [ -n "$CURRENT_PATH" ]; then
            PATHS+=("$CURRENT_PATH")
            BRANCHES+=("$CURRENT_BRANCH")
        fi
        # Extract path (everything after "worktree ")
        CURRENT_PATH="${line#worktree }"
        CURRENT_BRANCH=""
    elif [[ $line == branch* ]]; then
        # Extract branch (everything after "branch refs/heads/")
        BRANCH_REF="${line#branch }"
        CURRENT_BRANCH="${BRANCH_REF#refs/heads/}"
    fi
done <<< "$WORKTREES"

# Save last worktree if exists
if [ -n "$CURRENT_PATH" ]; then
    PATHS+=("$CURRENT_PATH")
    BRANCHES+=("$CURRENT_BRANCH")
fi

# Separate worktrees into selectable (non-main, non-current) and non-selectable (main, current)
declare -a SELECTABLE_PATHS
declare -a SELECTABLE_BRANCHES
declare -a SELECTABLE_INDICES

for i in "${!PATHS[@]}"; do
    # Normalize paths for comparison
    WORKTREE_ABS_PATH=$(cd "${PATHS[$i]}" 2>/dev/null && pwd || echo "${PATHS[$i]}")
    CURRENT_ABS_PATH=$(cd "$CURRENT_WORKTREE" && pwd)

    # Skip protected branches (main, master, develop) and current worktree
    if ! is_protected_branch "${BRANCHES[$i]}" && [ "$WORKTREE_ABS_PATH" != "$CURRENT_ABS_PATH" ]; then
        SELECTABLE_PATHS+=("${PATHS[$i]}")
        SELECTABLE_BRANCHES+=("${BRANCHES[$i]}")
        SELECTABLE_INDICES+=("$i")
    fi
done

# Check if any selectable worktrees exist
if [ ${#SELECTABLE_PATHS[@]} -eq 0 ]; then
    echo "No removable worktrees found."
    echo "(All worktrees are either 'main' branch or the current worktree)"
    exit 0
fi

# Display worktrees: first selectable, then non-selectable (main/current)
echo "Available worktrees:"
echo ""

# First, display selectable worktrees (non-main, non-current) with numbers
SELECTABLE_NUM=1
for i in "${!PATHS[@]}"; do
    # Normalize path for comparison
    WORKTREE_ABS_PATH=$(cd "${PATHS[$i]}" 2>/dev/null && pwd || echo "${PATHS[$i]}")
    CURRENT_ABS_PATH=$(cd "$CURRENT_WORKTREE" && pwd)

    if ! is_protected_branch "${BRANCHES[$i]}" && [ "$WORKTREE_ABS_PATH" != "$CURRENT_ABS_PATH" ]; then
        BRANCH_INFO=""
        if [ -n "${BRANCHES[$i]}" ]; then
            BRANCH_INFO=" [${BRANCHES[$i]}]"
        else
            BRANCH_INFO=" (detached HEAD)"
        fi
        echo "  $SELECTABLE_NUM. ${PATHS[$i]}${BRANCH_INFO}"
        SELECTABLE_NUM=$((SELECTABLE_NUM + 1))
    fi
done

# Then, display non-selectable worktrees (main and current) with [PROTECTED] marker
for i in "${!PATHS[@]}"; do
    # Normalize path for comparison
    WORKTREE_ABS_PATH=$(cd "${PATHS[$i]}" 2>/dev/null && pwd || echo "${PATHS[$i]}")
    CURRENT_ABS_PATH=$(cd "$CURRENT_WORKTREE" && pwd)

    BRANCH_INFO=""
    if [ -n "${BRANCHES[$i]}" ]; then
        BRANCH_INFO=" [${BRANCHES[$i]}]"
    else
        BRANCH_INFO=" (detached HEAD)"
    fi

    if is_protected_branch "${BRANCHES[$i]}"; then
        echo "  [PROTECTED] ${PATHS[$i]}${BRANCH_INFO} (${BRANCHES[$i]} branch)"
    elif [ "$WORKTREE_ABS_PATH" = "$CURRENT_ABS_PATH" ]; then
        echo "  [PROTECTED] ${PATHS[$i]}${BRANCH_INFO} (current worktree)"
    fi
done
echo ""

# Get user selection (only selectable worktrees are numbered)
read -p "Select worktree to remove (1-${#SELECTABLE_PATHS[@]}): " SELECTION

# Handle empty input or Ctrl+C
if [ -z "$SELECTION" ]; then
    echo "Error: No selection made"
    exit 1
fi

# Validate selection
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "${#SELECTABLE_PATHS[@]}" ]; then
    echo "Error: Invalid selection. Please enter a number between 1 and ${#SELECTABLE_PATHS[@]}"
    exit 1
fi

# Get selected worktree path and currently checked out branch
# Note: Git doesn't track the "original" branch a worktree was created with.
# We only get the branch currently checked out in that worktree.
# If the user checked out different branches over time, we only see the current one.
SELECTED_INDEX=$((SELECTION - 1))
SELECTED_PATH="${SELECTABLE_PATHS[$SELECTED_INDEX]}"
SELECTED_BRANCH="${SELECTABLE_BRANCHES[$SELECTED_INDEX]}"

# Convert to absolute path if relative (only if directory exists)
if [[ ! "$SELECTED_PATH" = /* ]]; then
    # Relative path - convert to absolute
    if [ -d "$REPO_ROOT/$SELECTED_PATH" ]; then
        SELECTED_PATH=$(cd "$REPO_ROOT" && cd "$SELECTED_PATH" && pwd)
    else
        # Directory doesn't exist, construct absolute path manually
        SELECTED_PATH="$REPO_ROOT/$SELECTED_PATH"
    fi
else
    # Already absolute path
    if [ -d "$SELECTED_PATH" ]; then
        SELECTED_PATH=$(cd "$SELECTED_PATH" && pwd)
    fi
    # If directory doesn't exist, keep the path as-is for cleanup
fi

# Confirm removal
echo ""
echo "Selected worktree: $SELECTED_PATH"
if [ -n "$SELECTED_BRANCH" ]; then
    echo "Branch: $SELECTED_BRANCH"
else
    echo "Branch: (detached HEAD - no branch to remove)"
fi
echo ""

# Note: Worktrees with 'main' branch are filtered out and not selectable
# All remaining worktrees can have their branches deleted

if [ -z "$SELECTED_BRANCH" ]; then
    # Detached HEAD - only remove worktree
    read -p "Remove this worktree? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    echo ""
    echo "Removing worktree..."
    git worktree remove "$SELECTED_PATH" --force 2>/dev/null || {
        echo "Warning: Could not remove worktree via git (may not be registered)"
        echo "Removing directory manually..."
        rm -rf "$SELECTED_PATH"
    }
    echo "✓ Worktree removed"
else
    # Check merge status first to determine confirmation level
    # Determine the appropriate base branch for merge detection
    BASE_BRANCH=$(get_base_branch "$SELECTED_BRANCH")
    
    # Fetch latest origin/base to ensure accurate merge detection
    IS_MERGED=false
    COMMIT_COUNT=0
    if git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null; then
        # Check if branch has commits beyond base (if not, it's just a pointer to base, not merged)
        BRANCH_COMMIT=$(git rev-parse "$SELECTED_BRANCH" 2>/dev/null)
        BASE_COMMIT=$(git rev-parse "origin/$BASE_BRANCH" 2>/dev/null)

        if [ "$BRANCH_COMMIT" = "$BASE_COMMIT" ]; then
            # Branch points to same commit as base - freshly created, no work done
            IS_MERGED=false
            COMMIT_COUNT=0
        else
            # Count commits not in base
            COMMIT_COUNT=$(git rev-list --count "origin/$BASE_BRANCH..$SELECTED_BRANCH" 2>/dev/null || echo "0")

            if git merge-base --is-ancestor "$SELECTED_BRANCH" "origin/$BASE_BRANCH" 2>/dev/null; then
                # Branch is an ancestor of base - likely merged
                IS_MERGED=true
            fi
        fi
    fi

    # Show information about what will be deleted
    echo ""
    if [ "$IS_MERGED" = true ]; then
        echo "ℹ️  Branch '$SELECTED_BRANCH' is merged into origin/$BASE_BRANCH (PR accepted)"
        echo "   Safe to delete - the work is already in $BASE_BRANCH"
    elif [ "$COMMIT_COUNT" -eq 0 ]; then
        echo "ℹ️  Branch '$SELECTED_BRANCH' has 0 commits (freshly created or already merged)"
        echo "   Safe to delete - no uncommitted work"
    else
        echo "⚠️  WARNING: This operation is DESTRUCTIVE!"
        echo "   Branch '$SELECTED_BRANCH' has $COMMIT_COUNT commit(s) not in origin/$BASE_BRANCH"
        echo "   Removing it will DELETE this uncommitted work!"
    fi
    echo ""
    echo "The following will be deleted:"
    echo "  - Local branch: $SELECTED_BRANCH"
    if git show-ref --verify --quiet "refs/remotes/origin/$SELECTED_BRANCH" 2>/dev/null; then
        echo "  - Remote branch: origin/$SELECTED_BRANCH (you will be prompted separately)"
    fi
    echo "  - Worktree directory: $SELECTED_PATH"
    echo ""

    # Require different confirmation based on merge status and commit count
    if [ "$IS_MERGED" = true ] || [ "$COMMIT_COUNT" -eq 0 ]; then
        read -p "Delete branch? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    else
        read -p "Type 'DELETE' to confirm branch deletion (or 'N' to abort): " CONFIRMATION
        echo ""
        if [ "$CONFIRMATION" != "DELETE" ]; then
            echo "Aborted. Unmerged branch deletion requires typing 'DELETE'."
            exit 1
        fi
    fi

    # Check remote branch existence (merge status already checked above)
    # Use ls-remote to check if branch actually exists on remote (not just local tracking ref)
    REMOTE_EXISTS=false
    if git ls-remote --heads origin "$SELECTED_BRANCH" 2>/dev/null | grep -q "refs/heads/$SELECTED_BRANCH"; then
        REMOTE_EXISTS=true
    fi

    REMOTE_FLAG=""
    if [ "$REMOTE_EXISTS" = true ]; then
        echo ""
        if [ "$IS_MERGED" = true ]; then
            echo "ℹ️  Remote branch 'origin/$SELECTED_BRANCH' exists and is merged into origin/$BASE_BRANCH"
            echo "   (Includes direct merges and transitive merges via regular merge commits)"
            echo "   Safe to delete - the work is already in $BASE_BRANCH"
            echo ""
            echo "⚠️  Note: Deleting remote branch affects the shared repository"
            read -p "Delete remote branch? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                REMOTE_FLAG="--remove-remote"
            else
                echo "Remote branch deletion cancelled."
            fi
        else
            echo "⚠️  Remote branch 'origin/$SELECTED_BRANCH' exists but merge status is unclear"
            echo "   Possible reasons:"
            echo "   - Not merged into origin/$BASE_BRANCH"
            echo "   - Merged via squash/rebase (commits recreated, not detected)"
            echo "   - Part of an open or closed PR"
            echo ""
            echo "   ⚠️  Deleting it may break an open PR or remove unmerged work"
            echo "   (If it was merged via squash, the work is in $BASE_BRANCH but won't be detected)"
            echo ""
            echo "⚠️  WARNING: Deleting remote branch affects the shared repository and may affect others"
            read -p "Type 'DELETE' to confirm remote branch deletion anyway (or 'N' to abort): " REMOTE_CONFIRMATION
            echo ""
            if [ "$REMOTE_CONFIRMATION" = "DELETE" ]; then
                REMOTE_FLAG="--remove-remote"
            else
                echo "Remote branch deletion cancelled."
            fi
        fi
    fi

    echo ""
    "$SCRIPT_DIR/remove-worktree-branch.sh" "$SELECTED_BRANCH" "$SELECTED_PATH" $REMOTE_FLAG
fi

echo ""
echo "✓ Removal complete"
