# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Changelog Best Practices

### General Principles

- Changelogs are for humans, not machines.
- Include an entry for every version, with the latest first.
- Group similar changes under: Added, Changed, Improved, Deprecated, Removed, Fixed, Documentation, Performance, CI.
- **"Test" is NOT a valid changelog category** - tests should be mentioned within the related feature or fix entry, not as standalone entries.
- Use an "Unreleased" section for upcoming changes.
- Follow Semantic Versioning where possible.
- Use ISO 8601 date format: YYYY-MM-DD.
- Avoid dumping raw git logs; summarize notable changes clearly.

### Guidelines for Contributors

All contributors (including maintainers) should update `CHANGELOG.md` when creating PRs:

1. **Add entries to the `[Unreleased]` section** - Add your changes under the appropriate category (Added, Changed, Improved, Deprecated, Removed, Fixed, Documentation, Performance, CI)

2. **Follow the changelog format** - See examples below for detailed guidelines

3. **Group related changes** - Similar changes should be grouped together

4. **Be descriptive** - Write clear, user-focused descriptions of what changed

5. **Mention tests when relevant** - Tests should be mentioned within the related feature or fix entry, not as standalone entries

**Example:**

```markdown
## [Unreleased]

### Added

- **New Feature**: Added support for custom worktree directory names
  - Includes bash syntax validation

### Fixed

- **Editor Detection**: Fixed issue with detecting Cursor on Linux systems
  - Includes improved error handling for missing editors
```

**Note:** During releases, maintainers will move entries from `[Unreleased]` to a versioned section (e.g., `## [1.0.1] - 2025-11-XX`).

## [Unreleased]

## [1.2.1] - 2025-11-27

### Fixed

- **Script Execution Error**: Fixed "local: can only be used in a function" error
  - Removed `local` keyword from main script body in removal scripts
  - `local` can only be used inside functions, not in main script scope
  - Fixes error when removing worktrees in strict Git Flow repositories

## [1.2.0] - 2025-11-27

### Added

- **Interactive Branch Creation**: Added interactive mode for creating worktrees
  - Always prompts for branch type and name (no direct mode)
  - Strict Git Flow: offers feature/_, release/_, and hotfix/\* options
  - Light Git Flow: offers feature/_, chore/_, and hotfix/\* options
  - Automatically branches from correct base (develop/dev for features/releases, main for hotfixes/chores)
  - Optional custom worktree directory name can still be provided as argument

### Changed

- **Strict Git Flow Validation**: Enforced strict Git Flow branch naming
  - Prevents creation of non-Git Flow branch types (chore/_, bugfix/_, etc.) in strict Git Flow repos
  - Prevents removal of non-Git Flow branch types in strict Git Flow repos
  - Shows error with suggestion to rename branch to feature/\* before removal
  - Only official Git Flow branch types (feature/_, release/_, hotfix/\*) are allowed in strict Git Flow repos

## [1.1.1] - 2025-01-27

### Improved

- **Git Flow Support**: Added support for `dev` branch as alternative to `develop`
  - Scripts now check for `develop` (standard) first, then `dev` (alternative shorthand)
  - `dev` branch is now protected from deletion alongside `main`, `master`, and `develop`
  - Maintains backward compatibility with repositories using either naming convention

## [1.1.0] - 2025-01-27

### Added

- **Strict Git Flow Support**: Added automatic detection and support for strict git flow workflows
  - Feature branches (`feature/*`) and release branches (`release/*`) now branch from `develop` when it exists (strict git flow)
  - Falls back to `main` if `develop` doesn't exist (light git flow) for backward compatibility
  - Hotfix branches (`hotfix/*`) always branch from `main` or `master`
  - Merge detection in removal scripts now uses the appropriate base branch based on git flow conventions
  - Protected branches now include `main`, `master`, and `develop` to prevent accidental deletion

## [1.0.3] - 2025-11-26

### Fixed

- **Path Resolution**: Fixed path resolution issue when running via npm/npx symlinks
  - Scripts now correctly resolve symlinks to find package root
  - Fixes "No such file or directory" error when running `npx git-worktree` commands
  - Works correctly both in development and when installed via npm

### Removed

- **CONTRIBUTING.md**: Removed contributing guidelines document
- **PUBLISHING.md**: Removed publishing guide document

## [1.0.1] - 2025-11-26

### Fixed

- **Release Script**: Fixed release script to handle missing `package-lock.json` file
  - Release script now conditionally adds `package-lock.json` only if it exists
  - Prevents release failures when package-lock.json is not present

### Documentation

- **PUBLISHING.md**: Added comprehensive explanation of GitHub Environments in Trusted Publishing
  - Explains what GitHub Environments are and when to use them
  - Provides setup instructions for environments with protection rules
  - Clarifies that environments are optional for solo maintainers

### CI

- **Package Lock File**: Added `package-lock.json` for npm CI compatibility
  - Required for `npm ci` command in GitHub Actions workflow
  - Ensures consistent dependency resolution in CI/CD pipeline

## [1.0.0] - 2025-11-26

### Added

- **npm Package Support**: Published as npm package for easy installation via `npx`

  - Package name: `git-worktree-scripts`
  - Can be used without installation: `npx git-worktree create feature/my-feature`
  - Can be installed as dev dependency: `npm install --save-dev git-worktree-scripts`

- **Main Command Interface**: Added unified `git-worktree` command with subcommands

  - `git-worktree create <branch-name>` - Create a new worktree
  - `git-worktree open` - Open an existing worktree interactively
  - `git-worktree remove [branch-name]` - Remove a worktree (interactive or direct)
  - `git-worktree --help` - Show usage information

- **Automated Publishing**: Set up GitHub Actions workflow for automated npm publishing

  - Uses npm Trusted Publishing (OIDC) for secure authentication
  - Automatically publishes when version tags are pushed
  - Includes bash syntax checking before publishing
  - Creates GitHub releases automatically

- **Release Script**: Added `scripts/release.sh` for easy version management

  - Automates version bumping, committing, and tagging
  - Validates bash syntax before release
  - Supports patch, minor, and major version increments

- **Pre-commit Hook**: Added bash syntax checking hook

  - Automatically validates all `.sh` files before commit
  - Prevents commits with syntax errors
  - Runs `bash -n` on staged shell scripts

- **Comprehensive Documentation**:

  - **README.md**: Complete project overview with usage examples
  - **QUICKSTART.md**: Quick start guide for users
  - **PUBLISHING.md**: Publishing guide for maintainers
  - **CONTRIBUTING.md**: Contribution guidelines for developers

- **Git Worktree Management Scripts**: Core functionality for managing git worktrees

  - `create-worktree.sh`: Creates worktrees from main branch with automatic editor opening
  - `open-worktree.sh`: Lists and opens existing worktrees interactively
  - `remove-worktree-interactive.sh`: Safely removes worktrees with merge detection
  - `remove-worktree-branch.sh`: Directly removes worktrees by branch name
  - `editor-common.sh`: Shared utilities for editor detection (Cursor, VS Code)

- **Editor Integration**: Support for multiple code editors

  - Cursor editor support (macOS, Linux, Windows)
  - VS Code support (macOS, Linux, Windows)
  - Automatic editor detection and selection
  - Cross-platform compatibility

- **Repository-Specific Setup**: Support for custom worktree setup scripts

  - Automatically runs `scripts/setup-worktree.sh` if present
  - Allows per-repository customization (e.g., Python venv, npm install)
  - Example script provided: `setup-worktree.sh.example`

- **Safety Features**: Built-in protections for worktree operations
  - Prevents deletion of `main` branch worktrees
  - Prevents deletion of current worktree
  - Handles missing worktree directories gracefully
  - Merge status detection before removal

### Documentation

- **README.md**: Comprehensive documentation including:

  - Installation instructions (npm/npx)
  - Usage examples for all commands
  - Working with multiple branches guide
  - Repository-specific setup instructions
  - Platform support information

- **QUICKSTART.md**: User-focused quick start guide:

  - Installation steps
  - Basic usage examples
  - Common scenarios
  - Repository-specific setup

- **PUBLISHING.md**: Maintainer guide covering:

  - Initial npm setup
  - First publication process
  - Trusted Publishing configuration
  - Automated publishing workflow
  - Version management
  - Troubleshooting

- **CONTRIBUTING.md**: Contribution guidelines including:
  - Development workflow
  - Branching strategy
  - Testing procedures
  - Commit message conventions
  - Pull request process

### CI

- **GitHub Actions Workflow**: Automated publishing pipeline

  - Triggers on version tags (`v*`)
  - Validates package contents
  - Checks bash syntax
  - Publishes to npm using Trusted Publishing
  - Creates GitHub releases

- **Pre-commit Hooks**: Local development checks
  - Bash syntax validation
  - Prevents committing broken scripts
