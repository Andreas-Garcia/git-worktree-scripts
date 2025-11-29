# Release Checklist

When releasing a new version of git-worktree-scripts, follow these steps:

## Pre-Release Checklist

1. **Ensure working directory is clean**
   ```bash
   git status
   ```
   - Commit or stash any uncommitted changes

2. **Verify you're on main branch**
   ```bash
   git checkout main
   git pull origin main
   ```

3. **Review CHANGELOG.md**
   - Check that all changes in `[Unreleased]` section are documented
   - Ensure entries follow the changelog format (Added, Changed, Improved, Deprecated, Removed, Fixed, Documentation, Performance, CI)
   - Verify entries are user-focused and descriptive

4. **Run bash syntax checks manually** (release script does this, but good to verify)
   ```bash
   for script in bin/*.sh scripts/*.sh; do
       if [ -f "$script" ]; then
           bash -n "$script" || exit 1
       fi
   done
   ```

## Release Process

1. **Update CHANGELOG.md**
   - Move entries from `[Unreleased]` to a new versioned section
   - Format: `## [X.Y.Z] - YYYY-MM-DD`
   - Use today's date in ISO 8601 format (YYYY-MM-DD)
   - Keep `[Unreleased]` section empty (or with a placeholder) for future PRs

2. **Commit CHANGELOG.md update**
   ```bash
   git add CHANGELOG.md
   git commit -m "docs: update CHANGELOG for vX.Y.Z"
   ```

3. **Run the release script**
   ```bash
   ./scripts/release.sh patch   # for bug fixes (1.0.0 -> 1.0.1)
   ./scripts/release.sh minor   # for new features (1.0.0 -> 1.1.0)
   ./scripts/release.sh major   # for breaking changes (1.0.0 -> 2.0.0)
   ```

   The release script will:
   - Check bash syntax on all scripts
   - Bump version in `package.json`
   - Commit version change
   - Create and push git tag (e.g., `v1.0.1`)
   - Push to GitHub

4. **Push CHANGELOG commit** (if not already pushed by release script)
   ```bash
   git push origin main
   ```

## Post-Release Verification

1. **Verify GitHub Actions workflow**
   - Check Actions tab in GitHub repository
   - Ensure publish workflow runs successfully
   - Verify npm publishing completes

2. **Verify npm publication**
   ```bash
   npm view git-worktree-scripts
   ```
   - Check that new version appears on npm

3. **Test the published package**
   ```bash
   npx git-worktree --help
   npx git-worktree create test-branch
   ```
   - Verify commands work correctly
   - Test in a different repository to ensure path resolution works

4. **Verify GitHub Release**
   - Check that GitHub release was created automatically
   - Review release notes

## Version Number Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **PATCH** (1.0.0 -> 1.0.1): Bug fixes, small improvements
- **MINOR** (1.0.0 -> 1.1.0): New features, non-breaking changes
- **MAJOR** (1.0.0 -> 2.0.0): Breaking changes

## Important Notes

- **Never commit directly to main** - All changes must go through Pull Requests
- **CHANGELOG.md must be updated** before running release script
- **Release script handles version bumping** - Don't manually edit `package.json` version
- **GitHub Actions automatically publishes** - No manual npm publish needed
- **Tags trigger CI/CD** - Pushing a tag automatically starts the publish workflow

## Troubleshooting

If the release script fails:
- Check that working directory is clean
- Verify you're on main branch
- Ensure bash syntax checks pass
- Check that `package.json` is valid JSON

If GitHub Actions fails:
- Check Actions tab for error details
- Verify Trusted Publishing is configured in npm
- Ensure `package-lock.json` exists and is committed
- Check that tag format matches `v*` pattern





