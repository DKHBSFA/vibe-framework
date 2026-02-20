# Releasing

How to create a new release of the VIBE Framework.

## Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- Push access to the repository

## Steps

1. **Update version:**
   ```bash
   echo "X.Y.Z" > VERSION
   ```

2. **Update CHANGELOG.md:**
   Add a new `## [X.Y.Z] - YYYY-MM-DD` section at the top with changes.

3. **Commit:**
   ```bash
   git add VERSION CHANGELOG.md
   git commit -m "Release vX.Y.Z"
   ```

4. **Tag and push:**
   ```bash
   git tag vX.Y.Z
   git push && git push origin vX.Y.Z
   ```

5. **Create GitHub release:**
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z" --notes-file - <<'EOF'
   Paste release notes here (copy from CHANGELOG.md).
   EOF
   ```

   Or with auto-generated notes from commits:
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z" --generate-notes
   ```

## Version numbering

- **MAJOR** (1.0.0): Breaking changes to framework.sh behavior or CLAUDE.md contract
- **MINOR** (0.X.0): New skills, new features, significant improvements
- **PATCH** (0.0.X): Bug fixes, documentation updates, minor tweaks
