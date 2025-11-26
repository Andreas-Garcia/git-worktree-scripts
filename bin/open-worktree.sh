#!/bin/bash
# Wrapper script for open-worktree.sh
# This allows the script to be executed via npm bin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

exec "$REPO_ROOT/scripts/open-worktree.sh" "$@"

