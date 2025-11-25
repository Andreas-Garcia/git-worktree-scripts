# Setup Instructions for Shared Worktree Scripts

This directory contains everything you need to create a shared repository for your git worktree management scripts.

## What's Included

```
shared-worktree-scripts/
├── scripts/
│   ├── create-worktree.sh              # Create new worktrees
│   ├── open-worktree.sh                 # Open existing worktrees
│   ├── remove-worktree-branch.sh        # Remove specific worktree
│   ├── remove-worktree-interactive.sh   # Interactive removal
│   ├── editor-common.sh                 # Shared editor utilities
│   └── setup-worktree.sh.example        # Example repo-specific setup
├── install.sh                           # Installation script
├── README.md                            # Main documentation
├── QUICKSTART.md                        # Quick start guide
├── SETUP_INSTRUCTIONS.md                # This file
└── .gitignore                           # Git ignore rules
```

## Step-by-Step Setup

### 1. Create the Shared Repository

```bash
# Create a new repository on GitHub/GitLab/etc (e.g., "git-worktree-scripts")
# Then initialize it locally:

mkdir ~/git-worktree-scripts
cd ~/git-worktree-scripts
git init
git remote add origin <your-repo-url>

# Copy all files from shared-worktree-scripts/ to the repo root
cp -r /path/to/audiometa-python/shared-worktree-scripts/* .

# Commit and push
git add .
git commit -m "feat: initial commit - git worktree management scripts"
git branch -M main
git push -u origin main
```

### 2. Install in Your Current Repository

```bash
# In audiometa-python (or any other repo)
cd /path/to/audiometa-python

# Install the scripts
~/git-worktree-scripts/install.sh

# Optionally create git aliases
~/git-worktree-scripts/install.sh scripts --create-aliases
```

### 3. Create Repository-Specific Setup (Optional)

If your repository needs Python virtual environment setup (like audiometa-python), create:

```bash
cat > scripts/setup-worktree.sh << 'EOF'
#!/bin/bash
set -e
WORKTREE_PATH="${1:-$(pwd)}"
cd "$WORKTREE_PATH"

if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    
    PYTHON_CMD=""
    for version in 3.14 3.13 3.12; do
        if command -v "python${version}" >/dev/null 2>&1; then
            PYTHON_CMD="python${version}"
            break
        fi
    done

    if [ -z "$PYTHON_CMD" ]; then
        if command -v python3 >/dev/null 2>&1; then
            PYTHON_CMD="python3"
        else
            echo "Warning: No Python 3.12+ installation found"
            exit 0
        fi
    fi

    echo "Using $PYTHON_CMD for virtual environment"
    "$PYTHON_CMD" -m venv .venv
    source .venv/bin/activate
    echo "Installing dependencies..."
    pip install --upgrade pip
    pip install -e ".[dev]"
    echo "✓ Virtual environment created and dependencies installed"
else
    echo "Virtual environment already exists at .venv"
fi
EOF

chmod +x scripts/setup-worktree.sh
```

### 4. Install in Other Repositories

For each repository where you want to use these scripts:

```bash
cd /path/to/other/repo
~/git-worktree-scripts/install.sh

# Create repo-specific setup if needed
# (copy setup-worktree.sh.example and customize)
```

## Updating Scripts

When you update the shared scripts:

```bash
# Update the shared repository
cd ~/git-worktree-scripts
git pull origin main
# Make changes, commit, push

# Update in each repository
cd /path/to/your/repo
~/git-worktree-scripts/install.sh
```

## Benefits

1. **Single source of truth** - Scripts maintained in one place
2. **Easy updates** - Update once, install everywhere
3. **Repository-specific customization** - Each repo can have its own `setup-worktree.sh`
4. **No duplication** - Scripts aren't copied into each repo (unless you choose to)

## Alternative: Git Submodule Approach

If you prefer to track the scripts version in each repository:

```bash
# In each repository
git submodule add <your-repo-url>/git-worktree-scripts.git scripts/worktree-scripts
git submodule update --init --recursive
./scripts/worktree-scripts/install.sh
```

This approach:
- Tracks the exact version of scripts used in each repo
- Requires submodule updates when scripts change
- Better for teams where script versions need to be synchronized

## Next Steps

1. Create the shared repository
2. Install in your current repository (audiometa-python)
3. Test the scripts work correctly
4. Install in other repositories as needed
5. Update scripts as you improve them

See [QUICKSTART.md](QUICKSTART.md) for more details.

