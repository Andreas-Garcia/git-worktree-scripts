# Quick Start Guide

## For Repository Maintainers

### Step 1: Create the Shared Repository

```bash
# Create a new repository (e.g., on GitHub)
# Then clone it locally
git clone <your-repo-url>/git-worktree-scripts.git ~/git-worktree-scripts
cd ~/git-worktree-scripts

# Copy the shared-worktree-scripts directory contents to the repo root
# (Assuming you're in the audiometa-python repo)
cp -r shared-worktree-scripts/* ~/git-worktree-scripts/
cd ~/git-worktree-scripts

# Commit and push
git add .
git commit -m "Initial commit: git worktree management scripts"
git push origin main
```

## For Users (Installing in Any Repository)

### Option 1: Standalone Installation (Recommended)

```bash
# Clone the shared scripts repository once
git clone <your-repo-url>/git-worktree-scripts.git ~/git-worktree-scripts

# In any repository where you want to use the scripts:
cd /path/to/your/repo
~/git-worktree-scripts/install.sh

# Optionally create git aliases for convenience
~/git-worktree-scripts/install.sh scripts --create-aliases
```

After installation, you can use:

```bash
./scripts/create-worktree.sh feature/my-feature
./scripts/open-worktree.sh
./scripts/remove-worktree-interactive.sh
```

Or with git aliases:

```bash
git worktree feature/my-feature
git worktree-open
git worktree-remove
```

### Option 2: Git Submodule

```bash
# In your repository
cd /path/to/your/repo
git submodule add <your-repo-url>/git-worktree-scripts.git scripts/worktree-scripts
git submodule update --init --recursive

# Install scripts
./scripts/worktree-scripts/install.sh

# Commit the submodule
git add .gitmodules scripts/worktree-scripts
git commit -m "chore: add git worktree scripts as submodule"
```

### Option 3: Copy Scripts Directly

```bash
# Clone the repository
git clone <your-repo-url>/git-worktree-scripts.git /tmp/git-worktree-scripts

# Copy scripts to your repository
cp -r /tmp/git-worktree-scripts/scripts/* /path/to/your/repo/scripts/
chmod +x /path/to/your/repo/scripts/*.sh
```

## Repository-Specific Setup (Optional)

If your repository needs custom setup when creating worktrees (e.g., Python virtual environment, npm install, etc.), create a `scripts/setup-worktree.sh` file:

```bash
# Copy the example
cp shared-worktree-scripts/scripts/setup-worktree.sh.example scripts/setup-worktree.sh

# Or create your own
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

The `create-worktree.sh` script will automatically detect and run this file when creating new worktrees.

## Updating Scripts

### Standalone Installation

```bash
cd ~/git-worktree-scripts
git pull origin main

# Re-run installer in each repository
cd /path/to/your/repo
~/git-worktree-scripts/install.sh
```

### Git Submodule

```bash
cd /path/to/your/repo
git submodule update --remote scripts/worktree-scripts
./scripts/worktree-scripts/install.sh
git add scripts/worktree-scripts
git commit -m "chore: update git worktree scripts"
```

