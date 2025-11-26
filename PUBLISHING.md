# Publishing Guide

This guide explains how to publish `git-worktree-scripts` to npm and set up automated publishing via CI/CD.

## Table of Contents

- [Initial Setup](#initial-setup)
- [First Publication](#first-publication) ⚠️ **Required First** - Create package on npm
- [Set Up Trusted Publishing](#set-up-trusted-publishing) - Enable automated publishing
- [Automated Publishing](#automated-publishing) - All future releases
- [Version Management](#version-management)
- [Troubleshooting](#troubleshooting)

## Initial Setup

### 1. Create npm Account

1. Visit [npmjs.com](https://www.npmjs.com) and sign up for a free account
2. Verify your email address
3. Enable two-factor authentication (recommended)

### 2. Verify Package Name Availability

Check if the package name `git-worktree-scripts` is available:

```bash
npm view git-worktree-scripts
```

If you see `404`, the name is available. If you see package information, you'll need to:
- Use a different name (update `package.json`)
- Or contact the owner if it's your package

### 3. Configure package.json

Ensure your `package.json` has the required fields (already configured):

```json
{
  "name": "git-worktree-scripts",
  "version": "1.0.0",
  "author": "Andreas Garcia",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/Andreas-Garcia/git-worktree-scripts.git"
  }
}
```

### 4. Test Package Locally

Before publishing, test that the package builds correctly:

```bash
# Create a tarball to verify what will be published (dry run)
npm pack --dry-run

# Create the actual tarball
npm pack

# This creates: git-worktree-scripts-1.0.0.tgz
# Now test installing from the tarball
npm install -g ./git-worktree-scripts-1.0.0.tgz

# Test the commands work
npx git-worktree --help

# Clean up the tarball when done testing
rm git-worktree-scripts-*.tgz
```

## First Publication

⚠️ **Important**: You must publish the package **once manually** to create it on npm before you can set up Trusted Publishing. The package must exist on npm before you can access its settings.

### Step 1: Authenticate with npm

You'll need to authenticate once to create the package. Choose one method:

**Option A: Use npm login** (if security key works):
```bash
npm login
```
Enter your username, password, and 2FA code when prompted.

**Option B: Use a temporary token** (if login fails):
- Go to [npmjs.com](https://www.npmjs.com) → [Your Profile](https://www.npmjs.com/~andreas-garcia) → Access Tokens
- Generate a new token (type: "Publish" or "Automation")
- Configure npm to use it:
  ```bash
  npm config set //registry.npmjs.org/:_authToken YOUR_TOKEN_HERE
  ```

### Step 2: Publish the Package

1. **Ensure all changes are committed**:

   ```bash
   git status
   git add .
   git commit -m "chore: prepare for initial release"
   ```

2. **Publish to npm**:

   ```bash
   npm publish
   ```

3. **Verify publication**:

   ```bash
   npm view git-worktree-scripts
   ```

4. **Tag the release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

The package is now published! Visit `https://www.npmjs.com/package/git-worktree-scripts` to see it.

## Set Up Trusted Publishing

After the initial publish, set up Trusted Publishing to enable automated publishing for all future releases.

**Important**: 
- Trusted Publishing requires npm CLI version 11.5.1 or later. The workflow automatically updates npm to the latest version.
- **The package must already exist on npm** - publish it once manually first (see [First Publication](#first-publication) above).

### Step 1: Create GitHub Actions Workflow

Create `.github/workflows/publish.yml`:

> **Important**: The workflow filename (`publish.yml`) must match exactly what you configure in npm Trusted Publishing settings (case-sensitive, including `.yml` extension).

```yaml
name: Publish to npm

on:
  push:
    tags:
      - "v*" # Triggers on version tags like v1.0.0

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write # Required for Trusted Publishing (OIDC)
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          registry-url: "https://registry.npmjs.org"

      - name: Update npm
        run: npm install -g npm@latest

      - name: Install dependencies
        run: npm ci

      - name: Verify package contents
        run: npm pack --dry-run

      - name: Check bash syntax
        run: |
          for script in bin/*.sh scripts/*.sh; do
            if [ -f "$script" ]; then
              echo "Checking $script..."
              bash -n "$script" || exit 1
            fi
          done

      - name: Publish to npm
        run: npm publish
        # No NODE_AUTH_TOKEN needed - uses Trusted Publishing (OIDC)
        # Automatically generates provenance attestations for public packages

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          name: Release ${{ github.ref_name }}
          body: |
            ## Changes

            See [CHANGELOG.md](https://github.com/${{ github.repository }}/blob/${{ github.ref_name }}/CHANGELOG.md) for details.

            ## Installation

            ```bash
            npm install -g git-worktree-scripts
            # or
            npx git-worktree create feature/my-feature
            ```
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Step 2: Configure Trusted Publishing on npm

1. **Add a trusted publisher on npmjs.com**:

   - Go to [npmjs.com](https://www.npmjs.com) → Search for your package `git-worktree-scripts` or go to `https://www.npmjs.com/package/git-worktree-scripts`
   - Click **"Package Settings"** (or go to your profile → Packages → git-worktree-scripts → Settings)
   - Navigate to **"Trusted Publisher"** section
   - Under **"Select your publisher"**, click the **"GitHub Actions"** button
   - Configure the following fields:
     - **Organization or user** (required): `Andreas-Garcia`
     - **Repository** (required): `git-worktree-scripts`
     - **Workflow filename** (required): `publish.yml`
       - ⚠️ **Important**: Enter only the filename (`publish.yml`), not the full path
       - Must include the `.yml` extension
       - The filename is case-sensitive and must match exactly
     - **Environment name** (optional): Leave empty unless using GitHub environments
   - Click **"Save"** or **"Approve"**

2. **No GitHub Secrets needed**: Trusted Publishing uses GitHub OIDC, so you don't need to store any tokens.

**Benefits**:

- ✅ More secure (no long-lived tokens)
- ✅ Automatic token generation per workflow run
- ✅ Short-lived, cryptographically-signed tokens
- ✅ Cannot be extracted or reused
- ✅ Recommended by npm for CI/CD
- ✅ Automatically generates provenance attestations

## Automated Publishing

After Trusted Publishing is set up, all future releases are automated!

### Using the Release Script

Use the release script for easy version management:

```bash
./scripts/release.sh patch   # for bug fixes (1.0.0 -> 1.0.1)
./scripts/release.sh minor   # for new features (1.0.0 -> 1.1.0)
./scripts/release.sh major   # for breaking changes (1.0.0 -> 2.0.0)
```

The script will:
- Check that working directory is clean
- Run bash syntax checks
- Bump the version in `package.json`
- Commit the version change
- Create and push a git tag (e.g., `v1.0.1`)
- Push to GitHub

GitHub Actions will automatically:
- Detect the new tag
- Run the workflow
- Publish to npm using Trusted Publishing
- Create a GitHub release

### Manual Version Bump

If you prefer to bump versions manually:

```bash
# Bump version
npm version patch  # or minor/major

# Commit and push
git push --tags
git push
```

GitHub Actions will automatically publish when it detects the tag.

## Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (x.Y.0): New features (backward compatible)
- **PATCH** (x.y.Z): Bug fixes (backward compatible)

### Release Script

The `scripts/release.sh` script automates the release process:

```bash
./scripts/release.sh patch   # 1.0.0 -> 1.0.1
./scripts/release.sh minor   # 1.0.0 -> 1.1.0
./scripts/release.sh major   # 1.0.0 -> 2.0.0
```

## Troubleshooting

### Package Already Exists

If you get an error that the package already exists:

```bash
npm ERR! 403 You do not have permission to publish "git-worktree-scripts"
```

**Solutions**:

- Use a scoped package: `@andreas-garcia/git-worktree-scripts`
- Or choose a different name

### Security Key Button Not Working

If the "Use Security Key" button on npm's website doesn't respond:

**Solutions**:

1. Use **TOTP (Authenticator App)** instead:
   - Go to npm settings → Two-Factor Authentication
   - Use "Authenticator App" option instead of security key

2. Use **CLI authentication**:
   ```bash
   npm login
   ```
   This will prompt for username/password and 2FA code (TOTP), bypassing the web security key issue.

3. Generate a **temporary token**:
   - Go to npm → Access Tokens
   - Generate a new token (use "Publish" type)
   - Configure npm: `npm config set //registry.npmjs.org/:_authToken YOUR_TOKEN_HERE`

### CI/CD Not Publishing

If you encounter an "Unable to authenticate" error:

1. **Verify workflow filename matches exactly**:
   - Check npm package settings → Trusted Publisher
   - The workflow filename must match exactly (case-sensitive)
   - Must include `.yml` extension
   - Should be `publish.yml` (not `.github/workflows/publish.yml`)

2. **Check npm version**:
   - Trusted Publishing requires npm 11.5.1 or later
   - The workflow automatically updates npm, but verify it's running

3. **Verify GitHub Actions configuration**:
   - GitHub Actions workflow is enabled (Settings → Actions)
   - Workflow has `id-token: write` permission (required for OIDC)
   - Using GitHub-hosted runners (self-hosted runners not supported yet)

4. **Verify npm Trusted Publishing configuration**:
   - Organization/user: `Andreas-Garcia`
   - Repository: `git-worktree-scripts`
   - Workflow filename: `publish.yml`

5. **Check other issues**:
   - Workflow file syntax is correct (check Actions tab for errors)
   - Tag format matches trigger (e.g., `v1.0.0`)
   - Repository name matches what's configured in npm

**Note**: npm does not verify your trusted publisher configuration when you save it. Double-check that your repository, workflow filename, and other details are correct, as errors will only appear when you attempt to publish.

### Version Already Exists

If you try to publish the same version twice:

```bash
npm ERR! 403 You cannot publish over the previously published versions
```

**Solution**: Bump the version first:

```bash
npm version patch
git push --tags
git push
```

## Security Best Practices

- **Use Trusted Publishing**: Recommended by npm for CI/CD (uses OIDC, no tokens to manage)
- **Restrict token access**: After enabling Trusted Publishing, consider restricting traditional token-based publishing:
  - Go to Package Settings → Publishing access
  - Select "Require two-factor authentication and disallow tokens"
  - This only affects traditional tokens; Trusted Publishing continues to work
- **Enable 2FA**: Protect your npm account with two-factor authentication
- **Limit scope**: Trusted Publishing only grants access to the specific repository you configure
- **Review access**: Regularly review Trusted Publishing connections in npm settings
- **Automatic provenance**: Trusted Publishing automatically generates provenance attestations for public packages from public repositories

**Note**: Trusted Publishing uses short-lived, workflow-specific credentials that cannot be extracted or reused, eliminating the security risks of long-lived tokens.

## Next Steps

After publishing:

1. Verify on npm: Visit `https://www.npmjs.com/package/git-worktree-scripts`
2. View your profile: Visit `https://www.npmjs.com/~andreas-garcia`
3. Test installation: `npm install -g git-worktree-scripts`
4. Test npx: `npx git-worktree --help`
5. Share: Update README with npm package link
6. Monitor: Check download stats and issues


