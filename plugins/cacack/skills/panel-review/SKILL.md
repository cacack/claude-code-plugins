---
name: panel-review
description: Multi-persona code review of a diff. Spawns 5 reviewer subagents (Skeptic, Maintainer, Performance Engineer, Caller, Security Reviewer) in parallel against the current branch diff (default), a GitHub PR, or a commit range. Use whenever the user asks for a code review, panel review, or PR review and you want a structured multi-angle pass without depending on external tools like CodeRabbit.
argument-hint: [<pr-number> | <commit-range>]
allowed-tools: Task, Read, Write, Bash(git:*), Bash(gh:*), Bash(glab:*), Bash(mktemp:*)
effort: high
---

<objective>
Run a multi-persona code review of a code change. Five reviewer subagents — Skeptic, Maintainer, Performance Engineer, Caller, Security Reviewer — each examine the same diff from a distinct adversarial angle in **parallel** subagent contexts, then findings are aggregated into a single consolidated report.

This exists because rate-limited or budget-constrained third-party review tools (CodeRabbit, etc.) leave gaps. Five disposable critics with narrow focus areas, run in isolated contexts with no knowledge of who authored the change, give you back something useful without an external dependency.
</objective>

<quick_start>
With no arguments, reviews the current branch's diff vs the default remote branch:

```bash
/cacack:panel-review
```

Other supported scopes: PR number (`/cacack:panel-review 274`), GitHub PR URL, or a commit range (`/cacack:panel-review HEAD~3..HEAD`). See `<scope_resolution>` for details.
</quick_start>

<scope_resolution>
Resolve scope from `$ARGUMENTS`:

| Input | Scope |
|-------|-------|
| (empty) | Current branch vs its merge-base with the default remote branch (`origin/main` or `origin/master`) |
| Integer (e.g., `274`) or `#274` | GitHub PR #274 — fetch via `gh pr diff 274` |
| URL like `https://github.com/owner/repo/pull/N` | That PR — extract N and `gh pr diff N` |
| Git range like `abc..def` or `HEAD~3..HEAD` | `git diff <range>` |
| Anything else | Ask the user to clarify |

After resolving:
1. Write the unified diff to a temp file: `DIFF_FILE=$(mktemp -t panel-review.XXXXXX.diff)`
2. Capture metadata: number of files changed, number of lines added/removed (`git diff --stat <range>` or `gh pr view <n> --json additions,deletions,changedFiles`)
3. If the diff is empty: stop and tell the user.
4. If the diff exceeds 5000 changed lines: warn the user and ask whether to proceed (reviewers may produce less focused output on very large diffs).
</scope_resolution>

<workflow>
0. **Probe the environment.** Run these to set up scope resolution:
   - `git branch --show-current` — current branch
   - `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@'` (fall back to `main` if it fails) — default remote base branch
   - `gh pr view --json number,title,url 2>/dev/null` — open PR for the current branch, if any
   These run at invocation time, not skill-load time — keep them in the workflow, not in a static context block.

1. **Resolve scope** as above. Print a one-line summary: "Reviewing: <description> (<N files>, +<adds>/-<dels>)".

2. **Capture context for subagents.** In addition to the diff, prepare a short context block:
   - Scope description (branch, PR title, or range)
   - Repository root
   - The diff file path
   - The base branch (so subagents can run `git show` or read source files at their previous state if needed)

3. **Spawn all 5 reviewer subagents in parallel** via a single message with 5 Task tool calls. Each call uses the matching `subagent_type` (`cacack:reviewer-skeptic`, etc.) and the same prompt template:

   ```
   You are reviewing the following diff in your assigned persona.

   Scope: <one-line scope description>
   Diff file: <DIFF_FILE path>
   Repository root: <pwd>
   Base reference: <e.g., origin/main>

   Read the diff, optionally read source files via the Read tool for context that
   isn't in the diff, and produce findings in the output format defined in your
   persona's role definition. Do NOT exceed your focus area. Be specific and
   evidence-based.
   ```

4. **Aggregate** the five returned reports. Apply this aggregation procedure:
   - **Group by location.** For each `file:line` cited across reviewers, list all personas that flagged it. If 2+ personas independently flag the same location, mark that finding "🎯 cross-flagged".
   - **Highest-severity wins.** When the same location appears in multiple reports, the consolidated severity is the highest reported.
   - **Verdict aggregation.** Final verdict is the most conservative of the five individual verdicts: any `block` → block; else any `proceed-with-caution` → proceed-with-caution; else `ship-it`.

5. **Print the consolidated report** using the output format below.

6. **Cleanup.** Remove the temp diff file.

7. **Offer follow-up actions.** If the scope was a PR, offer (in order):
   - Post the consolidated report as a PR review comment (provide gh command)
   - Show full per-persona reports (when the aggregated view collapses things you want to see in full)
   - Skip — no follow-up
</workflow>

<output_format>
```markdown
# Panel Review

**Scope:** <description>
**Files changed:** <N> · **Lines:** +<adds>/-<dels>
**Final verdict:** <block | proceed-with-caution | ship-it>

## Cross-flagged findings 🎯
Locations flagged by two or more reviewers — high-signal items to address first.

**[SEVERITY] <title>** — flagged by: Skeptic, Maintainer
- Location: `file:line`
- Skeptic: <their finding>
- Maintainer: <their finding>
- Suggested action: <consolidated>

(Omit this section if there are no cross-flagged findings.)

## Findings by reviewer

### 🔍 The Skeptic — verdict: <theirs>
critical=N high=N medium=N low=N

**[CRITICAL] <title>** — `file:line`
<concise summary; one to two sentences>

**[HIGH] <title>** — `file:line`
<...>

(Continue for all findings in severity order. If none: "No defects found.")

### 🧰 The Maintainer — verdict: <theirs>
high=N medium=N low=N

<findings...>

### ⚡ The Performance Engineer — verdict: <theirs>
high=N medium=N low=N

<findings...>

### 📞 The Caller — verdict: <theirs>
high=N medium=N low=N

<findings...>

### 🔒 The Security Reviewer — verdict: <theirs>
critical=N high=N medium=N low=N

<findings...>

## Totals
- Critical: N
- High: N
- Medium: N
- Low: N

## Recommendation
<one-paragraph synthesis, naming the 1-3 most important things to address before merging>
```
</output_format>

<success_criteria>
- Scope correctly resolved from `$ARGUMENTS` (or defaulted)
- Diff captured to a real file accessible to subagents
- All 5 reviewer subagents invoked **in parallel** (single message, 5 Task calls)
- Cross-flagged findings explicitly highlighted
- Final verdict applies the conservative-OR rule
- Temp diff file cleaned up
- Follow-up action options offered when scope was a PR
</success_criteria>

<examples>
```bash
# Review the current branch's diff vs origin/main
/cacack:panel-review

# Review a specific PR
/cacack:panel-review 274

# Review a commit range
/cacack:panel-review HEAD~3..HEAD
/cacack:panel-review abc123..def456
```
</examples>

<notes>
- Bias caveat: all five personas run on the same LLM family, so they share some failure modes. The mitigation is the **adversarial framing** and **isolated context** — each subagent sees only the diff, not the author's intent or the rest of this conversation. This won't eliminate bias but it breaks the "I just wrote this code, of course it's good" loop.
- Panel review **complements** existing skills, doesn't replace them. For deep security work prefer `cacack:security-review`. For simplification prefer `cacack:simplify`. Panel review is the broad-survey first pass.
- The Security Reviewer here is the diff-focused variant; for broader security analysis (full repo, threat modeling) use the standalone `cacack:security-review`.
</notes>
