# 🧭 Contributing Guidelines

Thank you for your interest in contributing!

This project is currently maintained by a solo developer, but contributions, suggestions, and improvements are welcome.

## Table of Contents

- [🧑‍🤝‍🧑 Contributors vs Maintainers](#-contributors-vs-maintainers)
  - [Roles Overview](#roles-overview)
  - [Infrastructure & Automation Permissions](#infrastructure--automation-permissions)
- [🧱 Development Workflow](#-development-workflow)
  - [0. Fork & Clone](#0-fork--clone)
  - [1. Environment Setup](#1-environment-setup)
  - [2. Branching](#2-branching)
  - [3. Developing](#3-developing)
  - [4. Testing](#4-testing)
  - [5. Committing](#5-committing)
  - [6. Pull Request Process](#6-pull-request-process)
    - [6.1. Pre-PR Checklist](#61-pre-pr-checklist)
    - [6.2. Opening a Pull Request](#62-opening-a-pull-request)
  - [7. Releasing _(For Maintainers)_](#7-releasing-for-maintainers)
- [🪪 License & Attribution](#-license--attribution)
- [📜 Code of Conduct](#-code-of-conduct)
- [🌍 Contact & Discussions](#-contact--discussions)

## 🧑‍🤝‍🧑 Contributors vs Maintainers

### Roles Overview

**Contributors**

Anyone can be a contributor by:

- Submitting bug reports or feature requests via GitHub Issues
- Proposing code changes through Pull Requests
- Improving documentation
- Participating in discussions
- Testing and providing feedback

**Maintainers**

The maintainer(s) are responsible for:

- Reviewing and merging Pull Requests
- Managing releases and versioning
- Ensuring code quality and project direction
- Responding to critical issues
- Maintaining the project's infrastructure
- Publishing to npm registry
- Managing repository automation

**Important:** Even maintainers must go through Pull Requests. No direct commits to `main` are allowed - all changes, including those from maintainers, must be submitted via Pull Requests and go through the standard review process.

### Infrastructure & Automation Permissions

**Repository automation policies (maintainer-only):**

- Publishing workflows (`.github/workflows/publish.yml`) - handles npm publishing via Trusted Publishing
- Other automation workflows that affect repository management

**Why most automation is maintainer-only:**

- These workflows implement repository policies and management decisions
- Changes can affect how issues/PRs are handled and how packages are published
- They require understanding of project management strategy

**What contributors can do:**

- Suggest improvements or report issues with automation via GitHub Issues
- Add/remove labels on their own issues and PRs (type labels like `bug`, `enhancement`, priority labels, etc.)
- Discuss automation behavior in discussions or issues

**What contributors cannot do:**

- Modify automation workflows (publishing, etc.) - these are policy decisions
- Create or delete repository labels (maintainer-only)
- Modify labels on issues/PRs they didn't create (unless they have write access)

Currently, this project has a solo maintainer, but the role may expand as the project grows.

## 🧱 Development Workflow

We follow a lightweight GitFlow model adapted for small teams and open-source projects:

**Workflow steps:** Fork & Clone → Environment Setup → Branching → Developing → Testing → Committing → Pull Request Process (including Pre-PR Checklist) → Releasing _(For Maintainers)_

### 0. Fork & Clone

**For contributors:**

1. Fork the repository on GitHub
2. Clone your fork:

   ```bash
   git clone https://github.com/YOUR-USERNAME/git-worktree-scripts.git
   cd git-worktree-scripts
   ```

**For maintainers:**

Clone the main repository directly:

```bash
git clone https://github.com/Andreas-Garcia/git-worktree-scripts.git
cd git-worktree-scripts
```

### 1. Environment Setup

Ensure you have:

- **Git 2.5+** (for worktree support)
- **Bash 4+**
- **Node.js 12+** (for npm package management)
- **npm** (comes with Node.js)

**Optional but recommended:**

- **Cursor** or **VS Code** (for editor integration features)

### 2. Branching

#### Main Branch (`main`)

- The stable, always-deployable branch
- All tests must pass before merging
- Releases are tagged from `main`
- **No direct commits allowed** - All changes must go through Pull Requests, including changes from maintainers

#### Feature Branches (`feature/<name>`)

- Create one for each new feature or bug fix
- Include issue numbers when applicable: `feature/123-add-new-command`

- Examples:

  ```bash
  git checkout -b feature/improve-editor-detection
  git checkout -b feature/123-add-new-command        # With issue number
  git checkout -b feature/456-fix-worktree-removal    # With issue number
  ```

- Merge into `main` via Pull Request when complete and tested

#### Hotfix Branches (`hotfix/<name>`) _(For Maintainers)_

- For urgent bug fixes on production versions
- Include issue numbers when applicable: `hotfix/789-critical-bug`

- Examples:

  ```bash
  git checkout -b hotfix/critical-syntax-error
  git checkout -b hotfix/789-critical-security-patch   # With issue number
  ```

- Contributors can submit fixes via feature branches that maintainers may promote to hotfixes if needed

#### Chore Branches (`chore/<name>`)

- For maintenance, infrastructure, and configuration work
- Include issue numbers when applicable: `chore/234-update-dependencies`

- Examples: repository setup, CI/CD changes, dependency updates, documentation infrastructure

- Examples:

  ```bash
  git checkout -b chore/github-setup
  git checkout -b chore/update-dependencies
  git checkout -b chore/234-update-dependencies        # With issue number
  ```

- Merge into `main` via Pull Request when complete

#### Working with Multiple Local Branches (Git Worktrees)

When working on multiple branches simultaneously or when you need separate editor windows for different branches, use **git worktrees**. This allows you to have multiple working directories for the same repository, each on a different branch.

**Using this project's scripts:**

```bash
# Create a worktree for a feature branch
npx git-worktree create feature/my-feature

# Open an existing worktree
npx git-worktree open

# Remove a worktree when done
npx git-worktree remove feature/my-feature
```

For detailed information, see [QUICKSTART.md](QUICKSTART.md) and [README.md](README.md).

### 3. Developing

**Code Style:**

- Use consistent bash style (4-space indentation)
- Follow existing script patterns
- Use meaningful variable names
- Add comments for complex logic
- Keep scripts focused and modular

**Script Structure:**

- All scripts should start with `#!/bin/bash`
- Use `set -e` for error handling
- Source shared utilities from `scripts/editor-common.sh` when needed
- Check prerequisites before executing main logic

**Best Practices:**

- Validate inputs before processing
- Provide clear error messages
- Handle edge cases gracefully
- Test scripts manually before committing

### 4. Testing

**Bash Syntax Checking:**

All bash scripts are automatically checked for syntax errors via pre-commit hooks. You can also test manually:

```bash
# Check syntax of a specific script
bash -n scripts/create-worktree.sh

# Check all scripts
for script in bin/*.sh scripts/*.sh; do
    if [ -f "$script" ]; then
        echo "Checking $script..."
        bash -n "$script" || exit 1
    fi
done
```

**Manual Testing:**

Before submitting a PR, manually test your changes:

```bash
# Test creating a worktree
./bin/git-worktree create test-branch

# Test opening a worktree
./bin/git-worktree open

# Test removing a worktree
./bin/git-worktree remove test-branch
```

**Package Testing:**

Test the npm package locally:

```bash
# Create a tarball
npm pack

# Install from tarball
npm install -g ./git-worktree-scripts-*.tgz

# Test commands
npx git-worktree --help
npx git-worktree create test-branch

# Clean up
rm git-worktree-scripts-*.tgz
```

### 5. Committing

We follow a structured commit format inspired by [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

**Format:** `<type>(<scope>): <summary>`

**Commit Types:**

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `refactor` - Code restructuring
- `chore` - Maintenance tasks
- `style` - Formatting changes
- `test` - Test additions/changes

**Examples:**

- `feat: add support for custom worktree directory names`
- `fix(editor): handle missing Cursor installation gracefully`
- `docs: update README with npm installation instructions`
- `chore: update package.json version`
- `refactor: extract editor detection to common script`

**Pre-commit Hooks:**

The repository includes a pre-commit hook that automatically checks bash syntax:

- Runs `bash -n` on all staged `.sh` files
- Blocks commit if syntax errors are found
- Shows which files have errors

**Commit Message Guidelines:**

- Use imperative mood ("Add...", "Fix...", "Update...")
- Keep summary under ~72 characters
- Be descriptive but concise
- Reference issues when applicable: `fix(#123): handle edge case`

### 6. Pull Request Process

#### 6.1. Pre-PR Checklist

Before submitting a Pull Request, ensure the following checks are completed:

**1. Code Quality**

- ✅ Follow existing code style and patterns
- ✅ Run bash syntax checks: `bash -n scripts/your-script.sh`
- ✅ Scripts are executable: `chmod +x scripts/your-script.sh`
- ✅ No hardcoded paths or user-specific configurations

**2. Testing**

- ✅ All scripts pass syntax checks
- ✅ Manual testing completed
- ✅ Tested on your platform (macOS/Linux/Windows)
- ✅ Edge cases handled appropriately

**3. Documentation**

- ✅ Update README.md if adding new features or changing behavior
- ✅ Update QUICKSTART.md if workflow changes
- ✅ Add usage examples if introducing new commands
- ✅ Update inline comments for complex logic

**4. Git Hygiene**

- ✅ Commit messages follow the [commit message convention](#5-committing)
- ✅ Branch is up to date with target branch
- ✅ No accidental commits (secrets, personal configs, large files)

#### For Maintainers (Before Opening/Merging a PR)

**All Contributor Checks Plus:**

**1. Code Review**

- ✅ Code follows project conventions and style
- ✅ Logic is sound and well-structured
- ✅ Error handling is appropriate
- ✅ Scripts are portable across platforms

**2. Testing Verification**

- ✅ CI tests pass (bash syntax checks)
- ✅ Scripts work on target platforms
- ✅ Integration with existing features works correctly
- ✅ No breaking changes (unless intentional)

**3. Documentation Review**

- ✅ Public API changes are documented
- ✅ Breaking changes are clearly marked
- ✅ Examples and usage are updated
- ✅ README reflects current functionality

**4. Compatibility Verification**

- ✅ Scripts work with supported Git versions (2.5+)
- ✅ Editor detection works correctly
- ✅ No breaking changes (unless intentional and versioned)

**5. Final Checks**

- ✅ PR description is clear and complete
- ✅ All review comments are addressed
- ✅ No unresolved discussions
- ✅ Ready for release (if applicable)

**Quick Pre-PR Command:**

```bash
# Check all bash scripts for syntax errors
for script in bin/*.sh scripts/*.sh; do
    if [ -f "$script" ]; then
        bash -n "$script" || exit 1
    fi
done
```

#### 6.2. Opening a Pull Request

**Before opening a Pull Request, ensure you have completed the [Pre-PR Checklist](#61-pre-pr-checklist) above.**

##### PR Title Naming Convention

Pull Request titles must follow the same format as commit messages for consistency:

**Format:**

```
<type>(<optional-scope>): <short imperative description>
```

**Allowed Types:**

- `feat` — new feature
- `fix` — bug fix
- `refactor` — code restructuring
- `docs` — documentation update
- `chore` — maintenance / infrastructure
- `style` — formatting / lint-only changes
- `ci` — CI/CD pipeline changes

**Rules:**

- Use imperative mood ("Add…", "Fix…", "Update…")
- Keep it under ~70 characters
- Include issue/ticket IDs when applicable (e.g., `fix(#123): handle null values`)
- Avoid "WIP" in titles — use draft PRs instead
- Use lowercase for type and scope

**Note on Branch Prefixes vs PR Title Types:**

Branch prefixes (`feature/`, `chore/`, `hotfix/`) are for branch organization and differ from PR title types:

- Branch `feature/add-new-command` → PR title: `feat: add new command` (use `feat`, not `feature`)
- Branch `chore/update-dependencies` → PR title: `chore: update dependencies`
- Branch `hotfix/critical-bug` → PR title: `fix: critical bug` (use `fix`, not `hotfix`)

**Examples:**

- `feat: add support for custom worktree names`
- `fix(editor): handle missing VS Code installation`
- `docs: update installation instructions`
- `chore: update package.json dependencies`
- `refactor: extract common editor detection logic`
- `fix(#123): handle edge case in worktree removal`

##### PR Description

When opening a Pull Request, ensure your PR description includes:

- ✅ Clear description of changes
- ✅ Reference related issues (e.g., "Fixes #123")
- ✅ Note any breaking changes
- ✅ Include testing instructions if applicable
- ✅ Screenshots or examples if UI/UX changes

##### Breaking Changes

If your PR includes breaking changes:

- ✅ Breaking changes are clearly documented in the PR description
- ✅ Migration path is provided (if applicable)
- ✅ Breaking changes include proper versioning notes (for maintainers to handle)

##### PR Automations

When you open a Pull Request, several automations will run automatically:

- **CI/CD checks**: Automated bash syntax checking runs on your PR
- **Welcome message**: First-time contributors receive a welcome message with helpful links

These automations help streamline the review process and ensure consistency across the project.

### 7. Releasing _(For Maintainers)_

Releases are created from the `main` branch and published to npm automatically via GitHub Actions.

**Quick release process:**

1. **Ensure you're on the `main` branch**:

   ```bash
   git checkout main
   git pull origin main
   ```

2. **Use the release script**:

   ```bash
   # For bug fixes
   ./scripts/release.sh patch   # 1.0.0 -> 1.0.1

   # For new features (non-breaking)
   ./scripts/release.sh minor   # 1.0.0 -> 1.1.0

   # For breaking changes
   ./scripts/release.sh major   # 1.0.0 -> 2.0.0
   ```

   The script will:
   - Check that working directory is clean
   - Run bash syntax checks
   - Bump the version in `package.json`
   - Commit the version change
   - Create and push a git tag (e.g., `v1.0.1`)
   - Push to GitHub

3. **GitHub Actions automatically**:
   - Detects the new tag
   - Runs the workflow
   - Verifies package contents
   - Checks bash syntax
   - Publishes to npm using Trusted Publishing
   - Creates a GitHub release

**Manual Release Process** (Alternative):

If you prefer to bump versions manually:

```bash
# Bump version
npm version patch  # or minor/major

# Push tags and changes
git push --tags
git push
```

**Note:** Ensure Trusted Publishing is configured in npm package settings before tagging. See [PUBLISHING.md](PUBLISHING.md) for setup instructions.

## 🪪 License & Attribution

All contributions are made under the project's open-source license.

You retain authorship of your code; the project retains redistribution rights under the same license.

## 📜 Code of Conduct

This project adheres to a Code of Conduct to ensure a welcoming and inclusive environment for all contributors. Please be respectful and constructive when participating in this project.

## 🌍 Contact & Discussions

You can open:

- **Issues** → bug reports or new ideas
- **Discussions** → suggestions, architecture, or workflow improvements

For more detailed information, see:

- [README.md](README.md) - Project overview and usage
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide for users
- [PUBLISHING.md](PUBLISHING.md) - Publishing guide for maintainers

Let's make this tool better together 🌱

