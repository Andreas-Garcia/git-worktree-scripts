#!/bin/bash

# Release script for git-worktree-scripts
# Usage: ./scripts/release.sh [patch|minor|major]

set -e

TYPE="${1:-patch}"

if [[ ! "$TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo "Error: Invalid version type. Use patch, minor, or major"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo "Error: Working directory has uncommitted changes"
    echo "Please commit or stash your changes first"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Warning: Not on main branch (currently on $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Run syntax checks
echo "Checking bash syntax..."
for script in bin/*.sh scripts/*.sh; do
    if [ -f "$script" ]; then
        echo "  Checking $script..."
        bash -n "$script" || exit 1
    fi
done
echo "✓ All syntax checks passed"

# Bump version
echo "Bumping $TYPE version..."
npm version "$TYPE" --no-git-tag-version

VERSION=$(node -p "require('./package.json').version")
echo "New version: $VERSION"

# Commit version change
git add package.json package-lock.json
git commit -m "chore: bump version to $VERSION"

# Create and push tag
echo "Creating tag v$VERSION..."
git tag "v$VERSION"
git push origin "$CURRENT_BRANCH"
git push --tags

echo ""
echo "✓ Version $VERSION released!"
echo "GitHub Actions will automatically publish to npm."
echo ""
echo "To verify:"
echo "  npm view git-worktree-scripts"
echo "  npx git-worktree --help"


