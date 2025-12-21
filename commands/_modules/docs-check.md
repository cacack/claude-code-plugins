# Documentation Check Module

Reusable logic for checking if documentation needs updates based on code changes.

## Detection

Check for these documentation files in the repository:
- `README.md` - Project overview and highlights
- `FEATURES.md` - Feature documentation
- `CHANGELOG.md` - Change history
- `IDEAS.md` - Ideas backlog (check if implementing from here)

## Analysis

When source files are being committed:

1. **Detect documentation files**: `ls README.md FEATURES.md CHANGELOG.md IDEAS.md 2>/dev/null`

2. **Analyze changes**: Look at `git diff --cached --name-only` or staged changes

3. **Determine impact**:
   - New feature (`feat:` commit) → likely needs README/FEATURES update
   - New capability → check if FEATURES.md should document it
   - Implementing an idea → check if it should be removed from IDEAS.md

## Prompt Format

If documentation updates may be needed, present:

```
Documentation check:
- [ ] README.md - [update highlights if major feature]
- [ ] FEATURES.md - [document new capability]
- [ ] IDEAS.md - [remove if implementing from ideas]

Would you like to update any documentation before committing? (y/n/skip)
```

## Skip Conditions

Skip documentation check when:
- Changes are only to documentation files themselves
- Changes are only to test files
- Commit type is `docs:`, `test:`, `ci:`, `style:`
- User passes `--no-docs-check` flag
