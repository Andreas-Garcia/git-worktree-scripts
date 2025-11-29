# Quick Start Guide

## Why npm? (This isn't a Node.js project!)

**npm** (Node Package Manager) is being used here purely as a **distribution mechanism**, not because this project requires Node.js.

**Are the scripts wrapped in Node.js?**

No! The scripts are **pure bash** - they run directly without any Node.js involvement. Here's what's actually happening:

- `package.json` is just **metadata** - it tells npm where to find the bash scripts
- The `bin` entries point directly to bash scripts (e.g., `./bin/git-worktree` which starts with `#!/bin/bash`)
- When you run `npx git-worktree`, npm downloads the package, finds the bash script, and executes it directly
- There's no Node.js code, no `index.js`, no Node.js dependencies - just bash scripts packaged for npm distribution

Think of `package.json` as a "manifest" that tells npm "here are the bash scripts and how to run them" - similar to how a `Dockerfile` describes a container but isn't the container itself.

**Is this standard for bash projects?**

No, npm is not the traditional standard for distributing bash scripts. Common alternatives include:

- **Homebrew** (macOS) - Very popular for command-line tools
- **System package managers** (apt/yum/pacman on Linux)
- **GitHub releases** - Direct download and manual installation
- **Git clone** - Clone and use directly

**Why use npm for bash scripts?**

Despite not being standard, npm offers some advantages:

- ✅ **Easy installation**: `npx` works on macOS, Linux, and Windows
- ✅ **No installation needed**: Run commands directly with `npx` without installing
- ✅ **Version management**: Easy to use specific versions or always get the latest
- ✅ **Widely available**: npm comes pre-installed with Node.js (which many developers already have)
- ✅ **Cross-platform**: Works the same way everywhere
- ✅ **Developer-friendly**: Many developers already have npm installed

**Important**: You don't need Node.js installed to use these scripts! The scripts are pure bash. npm is just the delivery method. If you don't have npm, you can also:

- Clone the repository directly: `git clone https://github.com/Andreas-Garcia/git-worktree-scripts.git`
- Download scripts manually from GitHub releases

**npx** is a tool that comes with npm. When you run `npx git-worktree`, it:

1. Downloads the package temporarily (if not already cached)
2. Runs the bash scripts
3. Cleans up afterward

This means you can use `git-worktree-scripts` without any installation - just run `npx git-worktree` commands directly!

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

## Gitignored Files

The script automatically copies common gitignored files (like `.env`, `.env.local`, etc.) from your repo root to new worktrees. It also copies template files (like `.env.example` → `.env`) if the target doesn't exist. This ensures each worktree has the necessary environment configuration files.

## Repository-Specific Setup (Optional)

If your repository needs custom setup when creating worktrees (e.g., Python virtual environment, npm install, additional gitignored files, etc.), create a `scripts/setup-worktree.sh` file:

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
