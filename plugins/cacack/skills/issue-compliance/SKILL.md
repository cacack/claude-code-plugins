---
name: issue-compliance
description: Verify staged changes satisfy linked issue requirements. Extracts acceptance criteria from GitHub/GitLab issues, compares against diff, and scores coverage to determine if PR should close or reference the issue.
user-invocable: false
---

<objective>
Ensure shipped code actually addresses the linked issue. This skill fetches issue details, extracts explicit and implicit requirements, analyzes staged changes, and scores how well the changes satisfy each requirement. The output determines whether a PR/MR should close the issue or merely reference it.
</objective>

<quick_start>
Check compliance for issue #42:

```bash
# Fetch issue
gh issue view 42 --json title,body,labels,comments

# Get staged diff
git diff --cached

# Compare requirements to changes
# Score: COMPLETE, PARTIAL, MISSING for each
```

Output:
```
Issue Compliance: #42
─────────────────────
✓ COMPLETE: Add login button
⚠ PARTIAL:  Multiple providers (Google only)
✗ MISSING:  Logout functionality

Coverage: 1/3 complete
Recommendation: Reference only
```
</quick_start>

<workflow>
<step name="detect_issue">
Find issue references from multiple sources:

```bash
# From branch name
git branch --show-current | grep -oE '([0-9]+|[A-Z]+-[0-9]+)' | head -1

# From recent commits
git log --oneline $(git merge-base HEAD main 2>/dev/null || echo HEAD~10)..HEAD | grep -oE '#[0-9]+' | sort -u

# From PR description (if exists)
gh pr view --json body 2>/dev/null | jq -r '.body' | grep -oE '#[0-9]+'
```

**Pattern recognition:**

| Pattern | Example | Source |
|---------|---------|--------|
| `#N` | `#42` | Universal |
| `GH-N` | `GH-42` | GitHub |
| `issue-N` | `issue-42` | Branch naming |
| `PROJ-N` | `JIRA-123` | External tracker |

If no issue detected, report "No issue linked" and skip compliance check.
</step>

<step name="fetch_issue">
Retrieve full issue details:

**GitHub:**
```bash
gh issue view <number> --json title,body,labels,comments,state
```

**GitLab:**
```bash
glab issue view <number> --output json
```

Extract and structure:
- Title (often summarizes the main requirement)
- Body (detailed requirements, acceptance criteria)
- Labels (bug, feature, enhancement - affects expectations)
- Comments (may contain additional requirements or clarifications)
</step>

<step name="extract_requirements">
Parse issue content for requirements:

**Explicit requirements** (highest confidence):
- Checkbox items: `- [ ] requirement text`
- "Acceptance criteria" sections
- Numbered requirements
- "Must have" / "Should have" statements

**Implicit requirements** (infer from context):
- Problem statement → fix should address it
- Feature description → implementation should match
- Bug report → behavior should be corrected
- Labels: `bug` implies fix, `feature` implies new capability

**Requirement structure:**
```
{
  "id": "REQ-1",
  "text": "Add login button to header",
  "source": "body.checkbox",
  "confidence": "explicit"
}
```
</step>

<step name="analyze_changes">
Get the staged changes for comparison:

```bash
# Summary of files changed
git diff --cached --stat

# Full diff for semantic analysis
git diff --cached

# List of modified files
git diff --cached --name-only
```

For each requirement, search the diff for evidence:
- New functions/components that implement the feature
- Bug fixes that address the reported issue
- Test coverage for the requirement
- Documentation updates

**Mapping approach:**
1. Identify keywords from requirement
2. Search diff for those keywords
3. Read surrounding context
4. Determine if change addresses requirement
</step>

<step name="score_coverage">
Rate each requirement:

| Score | Meaning | Evidence |
|-------|---------|----------|
| **COMPLETE** | Fully addressed | Clear implementation in diff |
| **PARTIAL** | Partially addressed | Some aspects implemented, others missing |
| **MISSING** | Not addressed | No evidence in diff |

**Scoring guidelines:**

- Feature request → COMPLETE requires working implementation
- Bug fix → COMPLETE requires the bug to be fixed
- Multiple items in one requirement → all must be done for COMPLETE
- "Nice to have" items → can be PARTIAL without blocking

**Calculate overall coverage:**
```
complete_count / total_requirements * 100 = coverage %
```
</step>

<step name="recommend">
Based on coverage, recommend issue linking:

| Coverage | Recommendation |
|----------|----------------|
| 100% complete | `Closes #N` - PR will close issue |
| 80-99% complete | `Closes #N` with note about minor gaps |
| 50-79% complete | `Related to #N` - partial implementation |
| <50% complete | `See #N` - minimal progress, or wrong issue |

**Special cases:**

- Bug fix: Should be 100% or it's still broken
- Feature: Partial is acceptable if core functionality works
- Refactor: May not map cleanly to requirements
</step>
</workflow>

<output_format>
<template name="compliance_report">
```
Issue Compliance Report
═══════════════════════

Issue: #[number] - [title]
Labels: [label1, label2]
State: [open/closed]

Requirements Analysis
─────────────────────
[✓/⚠/✗] [REQ-1]: [requirement text]
         Source: [body.checkbox/body.implicit/comment]
         Evidence: [file:line or "not found"]
         [If PARTIAL: what's missing]

[✓/⚠/✗] [REQ-2]: [requirement text]
         ...

Coverage Summary
────────────────
Complete: N/N (X%)
Partial:  N/N
Missing:  N/N

Recommendation
──────────────
[Closes #N | Related to #N | See #N]

[Detailed reasoning for recommendation]

[If not 100%:]
Outstanding Items
─────────────────
- [Missing requirement 1]
- [Partial: what remains for requirement 2]

Options:
1. Proceed with partial (reference only)
2. Address missing items first
3. Split into multiple PRs
```
</template>
</output_format>

<requirement_extraction_patterns>
**Checkbox patterns:**
```markdown
- [ ] Implement feature X
- [x] Already done item (skip)
* [ ] Alternative bullet style
```

**Section patterns:**
```markdown
## Acceptance Criteria
## Requirements
## Definition of Done
## Tasks
```

**Inline patterns:**
```markdown
Must: implement X
Should: support Y
Could: add Z (lower priority)
```

**Bug report patterns:**
```markdown
Expected: [what should happen]
Actual: [what happens now]
→ Requirement: Make actual match expected
```
</requirement_extraction_patterns>

<confidence_levels>
**High confidence** (explicit):
- Checkboxes in issue body
- Numbered acceptance criteria
- "Must have" statements

**Medium confidence** (structured):
- Section content under "Requirements"
- Problem/solution descriptions
- Bug expected vs actual

**Low confidence** (implicit):
- General description text
- Comments without clear requirements
- Label-implied expectations

Weight high confidence requirements more heavily in scoring.
</confidence_levels>

<success_criteria>
Issue compliance check complete when:

- All issue references detected and fetched
- Requirements extracted from issue content
- Each requirement scored against staged changes
- Clear recommendation provided with reasoning
- If partial: outstanding items clearly listed
- Options presented for non-100% coverage
</success_criteria>

<integration>
Invoked by shipper agent during shipping workflow:

```
shipper agent → issue-compliance skill → compliance report
                                       ↓
                         [100%: proceed with Closes]
                         [<100%: escalate for decision]
```

Can verify compliance before committing:
```
> Check if my changes satisfy issue #42
```
</integration>

<edge_cases>
**No acceptance criteria in issue:**
- Extract implicit requirements from description
- Note lower confidence in report
- Suggest adding criteria to issue for future

**Issue already closed:**
- Report issue state
- Check if this is additional work or duplicate

**Multiple issues linked:**
- Analyze each separately
- Aggregate into single report
- May close some, reference others

**External tracker (Jira, etc.):**
- Note that full analysis requires manual review
- Extract what's available from branch/commit text
- Recommend verifying against external tracker
</edge_cases>
