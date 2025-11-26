# Quick Start Guide

## Installation

### NPM Package

Use via `npx` - no installation needed:

```bash
npx git-worktree create feature/my-feature
npx git-worktree open
npx git-worktree remove
npx git-worktree remove feature/my-feature
```

Or install as a dev dependency for convenience (adds it to package.json):

```bash
cd /path/to/your/repo
npm install --save-dev git-worktree-scripts
# or
yarn add -D git-worktree-scripts
# or
pnpm add -D git-worktree-scripts
```

After installation, use the same `npx git-worktree` commands as above.

## Repository-Specific Setup (Optional)

If your repository needs custom setup when creating worktrees (e.g., Python virtual environment, npm install, etc.), create a `scripts/setup-worktree.sh` file:

```bash
# Create your own setup script
cat > scripts/setup-worktree.sh << 'EOF'
#!/bin/bash
set -e
WORKTREE_PATH="${1:-$(pwd)}"
cd "$WORKTREE_PATH"

# Your custom setup here
# Example: Python virtual environment
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e ".[dev]"
fi
EOF

chmod +x scripts/setup-worktree.sh
```

The `git-worktree create` command will automatically detect and run this file when creating new worktrees.

## Updating

When using `npx`, you always get the latest version. If you've installed as a dependency:

```bash
cd /path/to/your/repo
npm update git-worktree-scripts
# or
yarn upgrade git-worktree-scripts
# or
pnpm update git-worktree-scripts
```

