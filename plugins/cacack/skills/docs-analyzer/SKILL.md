---
name: docs-analyzer
description: Analyze code changes semantically to identify documentation that needs updating. Maps new features, API changes, and breaking changes to specific doc sections with draft update suggestions.
user-invocable: false
---

<objective>
Keep documentation synchronized with code changes. This skill goes beyond "did you update the README?" to semantically analyze what changed and identify specific documentation sections that need updates. It provides draft text suggestions, not just reminders.
</objective>

<quick_start>
Analyze documentation needs for staged changes:

```bash
# Get semantic summary of changes
git diff --cached --stat
git diff --cached

# Find documentation files
ls README.md FEATURES.md CHANGELOG.md IDEAS.md API.md USAGE.md 2>/dev/null

# Map changes to doc sections
```

Output:
```
Documentation Analysis
──────────────────────
README.md (line 45):
  Section: "Authentication"
  Action: Add OAuth subsection
  Draft: "## OAuth Login\nAuthenticate via Google OAuth..."

FEATURES.md:
  Action: New entry
  Draft: "- OAuth Login: Sign in with Google account"
```
</quick_start>

<workflow>
<step name="detect_docs">
Find documentation files in the project:

```bash
# Common documentation files
ls -la README.md FEATURES.md CHANGELOG.md IDEAS.md \
       API.md USAGE.md CONTRIBUTING.md docs/ 2>/dev/null
```

**Documentation inventory:**

| File | Purpose | Update triggers |
|------|---------|-----------------|
| `README.md` | Project overview, quick start | Major features, setup changes |
| `FEATURES.md` | Feature list | Any new feature |
| `CHANGELOG.md` | Version history | All significant changes |
| `IDEAS.md` | Backlog/roadmap | When implementing an idea |
| `API.md` | API reference | API changes |
| `USAGE.md` | Usage examples | New usage patterns |
| `docs/` | Extended docs | Deep feature changes |
</step>

<step name="analyze_changes">
Semantically categorize the staged changes:

```bash
# Get changed files
git diff --cached --name-only

# Get full diff for analysis
git diff --cached
```

**Change categories:**

| Category | Signals in diff | Doc impact |
|----------|-----------------|------------|
| New feature | New files, new exports, `feat:` commit | High - README, FEATURES |
| API change | Modified interfaces, new params | High - API docs |
| Breaking change | Removed/renamed exports | Critical - CHANGELOG, migration |
| Bug fix | Existing file changes, `fix:` commit | Low - maybe CHANGELOG |
| Refactor | Internal changes, same API | None usually |
| Config change | Config files modified | Medium - setup docs |
| New dependency | package.json, requirements.txt | Medium - installation docs |

**Semantic analysis:**
1. Parse diff for new exports/functions
2. Identify changed function signatures
3. Detect removed or renamed items
4. Find new configuration options
</step>

<step name="map_to_docs">
For each change category, identify specific doc updates:

**New feature mapping:**
```
Change: Added src/auth/oauth.ts with GoogleAuth class
  ↓
README.md:
  - Section: "Authentication" or "Features"
  - Line: After existing auth content
  - Content: New subsection explaining OAuth

FEATURES.md:
  - Location: Feature list
  - Content: "OAuth Login - [description]"
```

**API change mapping:**
```
Change: Added optional `timeout` param to fetchData()
  ↓
API.md:
  - Section: fetchData documentation
  - Content: Add timeout parameter docs
```

**Breaking change mapping:**
```
Change: Renamed getUserById to getUser
  ↓
CHANGELOG.md:
  - Section: Breaking Changes
  - Content: Migration note

README.md:
  - Any usage examples using old name
```
</step>

<step name="check_ideas">
If implementing from ideas backlog:

```bash
# Check if change matches an item in IDEAS.md
cat IDEAS.md 2>/dev/null
```

**Match indicators:**
- Commit message references idea
- New feature matches listed idea
- Branch name matches idea description

**If match found:**
- Suggest removing from IDEAS.md
- Or marking as completed
- Note: Don't remove if partially implemented
</step>

<step name="draft_updates">
Generate specific update suggestions:

**For each doc needing updates:**

1. **Locate insertion point**
   - Find relevant section heading
   - Identify line number
   - Note surrounding context

2. **Draft content**
   - Match existing style/tone
   - Include necessary details
   - Keep concise

3. **Prioritize**
   - REQUIRED: Breaking changes, critical features
   - RECOMMENDED: New features, API changes
   - OPTIONAL: Minor enhancements, internal changes
</step>
</workflow>

<output_format>
<template name="docs_analysis">
```
Documentation Analysis
══════════════════════

Change Summary
──────────────
Type: [feat/fix/refactor/breaking]
Scope: [affected area]
Files: [N files changed]

Documentation Files Found
─────────────────────────
✓ README.md
✓ FEATURES.md
- CHANGELOG.md (not found)
- IDEAS.md (not found)

Updates Needed
──────────────

[REQUIRED/RECOMMENDED/OPTIONAL]
📄 README.md
   Section: [section name] (line N)
   Action: [Add/Update/Remove]

   Current:
   ```
   [existing content if updating]
   ```

   Suggested:
   ```
   [draft update text]
   ```

[REQUIRED/RECOMMENDED/OPTIONAL]
📄 FEATURES.md
   Action: Add new entry

   Suggested:
   ```
   - [Feature name]: [Brief description]
   ```

[If implementing from IDEAS.md]
📄 IDEAS.md
   Action: Remove implemented item

   Item to remove:
   ```
   - [The idea that was implemented]
   ```

Summary
───────
Required updates: N
Recommended updates: N
Optional updates: N

[If no updates needed:]
No documentation updates required for this change.
```
</template>
</output_format>

<style_matching>
Match existing documentation style:

**Detect patterns:**
```bash
# Heading style
grep -E '^#+\s' README.md | head -5

# List style (- vs * vs numbers)
grep -E '^\s*[-*0-9]' README.md | head -5

# Code block style
grep -E '^```' README.md | head -2
```

**Apply detected style to drafts:**
- Same heading levels
- Same list markers
- Same code fence language tags
- Similar sentence structure
</style_matching>

<commit_type_rules>
Skip documentation analysis for certain commit types:

| Commit type | Skip docs? | Reason |
|-------------|------------|--------|
| `docs:` | Yes | Already documentation change |
| `test:` | Yes | Tests don't affect user docs |
| `ci:` | Yes | CI changes are internal |
| `style:` | Yes | Formatting only |
| `chore:` | Usually | Unless affects users |
| `refactor:` | Usually | Unless changes API |
| `feat:` | No | Always check |
| `fix:` | Maybe | Check if user-facing |
| `perf:` | Maybe | If significant |
</commit_type_rules>

<success_criteria>
Documentation analysis complete when:

- All relevant doc files discovered
- Changes semantically categorized
- Specific sections identified for updates
- Draft content provided (not just "update needed")
- Drafts match existing documentation style
- Priority assigned to each update
- IDEAS.md checked if implementing new feature
</success_criteria>

<integration>
Invoked by shipper agent during shipping workflow:

```
shipper agent → docs-analyzer skill → documentation report
                                    ↓
                    [No updates: continue]
                    [Updates found: include in shipping report]
```

The shipper agent decides whether to:
- Prompt user to make updates before shipping
- Include update suggestions in PR description
- Ship with a follow-up task for docs

Can analyze docs independently:
```
> What documentation needs updating for my staged changes?
```
</integration>

<edge_cases>
**No documentation files:**
- Report "No documentation files found"
- Suggest creating README.md if missing
- Don't block shipping

**Large changes:**
- Prioritize most impactful doc updates
- May not catch everything
- Note that manual review recommended

**Generated code:**
- Skip generated files in analysis
- Focus on source changes

**Documentation-only changes:**
- Skip analysis (nothing new to document)
- Validate documentation syntax if possible
</edge_cases>
