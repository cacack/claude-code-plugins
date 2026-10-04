---
name: panel-engineering
description: Multi-persona engineering-health review of the whole repository. Spawns 5 senior-level reviewer subagents (Architect, Security Posture, Operations/SRE, Developer Experience, Maintainability) in parallel against a captured repo snapshot, produces per-persona reports plus a synthesis and draft proposed issues, then optionally files the issues. Use quarterly or after major milestones to assess the state of the project holistically. Complements `panel-review` (per-change) and `panel-product` (strategic alignment).
argument-hint: "[--personas <list>] [--skip-issues]"
allowed-tools: Task, SendMessage, Read, Write, AskUserQuestion, Bash(git:*), Bash(gh:*), Bash(glab:*), Bash(find:*), Bash(ls:*), Bash(wc:*), Bash(date:*), Bash(mkdir:*), Bash(test:*), Bash(command:*), Bash(head:*), Bash(mktemp:*)
effort: high
---

<objective>
Run a holistic, senior-persona review of the engineering health of the current repository. Five persona subagents — Architect, Security Posture, Operations/SRE, Developer Experience, Maintainability — examine a captured snapshot of the repo from distinct angles **in parallel**, produce structured findings, a synthesis pass extracts cross-cutting themes, and a final step drafts actionable issues with deduplication against open issues.

Where `panel-review` asks "is *this change* safe to merge?", this skill asks "is *this project* in good shape?" Designed to run quarterly. Output is persisted under `docs/reviews/panel-engineering/<YYYY-MM-DD>/` so reports can be committed, referenced, and compared across runs.
</objective>

<protocol>
**Read `${CLAUDE_SKILL_DIR}/../../docs/panel-protocol.md` before step 0.** It is the single home of the run protocol this skill shares with `panel-product`: argument rules, environment probe, output folder, shared snapshot sections, persona-prompt preamble, truncation retry, synthesis rules, issue drafting, filing prompt, and final summary. Steps below that name a protocol section follow it exactly; this file carries only what is specific to the engineering panel.

Protocol parameters: `<panel>` = `panel-engineering`; `<personas>` as in step 3; `<flags>` = none beyond the shared `--personas` and `--skip-issues`.
</protocol>

<quick_start>
```bash
/panels:panel-engineering
```

Captures a repo snapshot, spawns five persona reviewers in parallel, writes outputs to `docs/reviews/panel-engineering/<YYYY-MM-DD>/`, drafts proposed issues, and ends by offering to file them.
</quick_start>

<arguments>
| Flag | Effect |
|------|--------|
| (none) | Run all five personas; prompt to file drafted issues at end |
| `--personas <list>` | Any of `architect,security,ops-sre,dx,maintainability`. Default: all five |
| `--skip-issues` | Skip the issue-drafting step and the end-of-run prompt entirely |

Parsing and unrecognized-flag handling: protocol **Arguments**.
</arguments>

<workflow>
0. **Probe the environment** — protocol **Probe the environment**, plus `test -f CONSTITUTION.md && echo present` (grounding-only context flag).

1. **Resolve the output folder** — protocol **Resolve the output folder**.

2. **Capture the snapshot.** Write `<output_folder>/snapshot.md` from the sections below; sections marked *(protocol)* use the protocol's **Snapshot sections** form. Use the actual repo state; keep each section short and bounded so the snapshot stays small enough for personas to consume.

   ```markdown
   # Project Snapshot — <YYYY-MM-DD>

   ## Repo metadata  (protocol)

   ## Top-level tree (depth 3, with container dirs expanded)
   <output of: find . -maxdepth 3 -not -path '*/\.*' -not -path '*/node_modules/*' -not -path '*/vendor/*' -not -path '*/.git/*' | sort | head -300>

   <if any of these container dirs appear at top level — `plugins/`, `packages/`, `apps/`, `services/`, `crates/`, `modules/`, `workspaces/` — descend one level deeper for them so the real subsystem layout is visible. Example: `find plugins -maxdepth 3 -type d | sort` appended below the tree.>

   ## Resource counts (where applicable)
   <if directories like skills/, agents/, packages/, apps/, components/, hooks/ exist anywhere in the tree, count their immediate children. Example:
   - `plugins/delivery/skills/` — 12 subdirectories
   - `plugins/delivery/agents/` — 7 .md files
   This signals scale that a tree listing alone underreports.>

   ## Language footprint
   <small table of file counts by extension for top ~10 extensions>

   ## README excerpt  (protocol)

   ## CONSTITUTION.md
   <full content if present; otherwise "(not present — engineering panel proceeds without project-mission grounding)">

   ## Other top-level docs
   - SECURITY.md: <present | absent>
   - CONTRIBUTING.md: <present | absent>
   - CODE_OF_CONDUCT.md: <present | absent>
   - CHANGELOG.md: <present | absent>
   - CLAUDE.md: <present | absent>

   ## Build/CI/config files (top level)
   <list of files like Makefile, package.json, pyproject.toml, go.mod, Dockerfile, .github/workflows/*.yml, etc.>

   ## Recent activity (last 6 months)
   - Commits: <git log --since='6 months ago' --oneline | wc -l>
   - Last 20 commit subjects:
     <git log -20 --pretty=format:'%h %s'>

   ## Repository label vocabulary  (protocol)

   ## Open issues  (protocol; gh fields: number,title,labels)
   ```

   CONSTITUTION.md is included for **grounding only** — personas should understand what the project is trying to be, but not score against it. That role belongs to `panel-product`.

3. **Filter the persona list.** Default = all five. Validate per protocol **Arguments**. Persona key → `subagent_type`:

   | Key | `subagent_type` |
   |-----|-----------------|
   | `architect` | `panels:engineering-architect` |
   | `security` | `panels:engineering-security` |
   | `ops-sre` | `panels:engineering-ops-sre` |
   | `dx` | `panels:engineering-dx` |
   | `maintainability` | `panels:engineering-maintainability` |

4. **Spawn the selected personas** — protocol **Spawn personas**, with:
   - Opening task line: `You are reviewing the engineering health of a repository in your assigned persona.`
   - Reading instructions: `Read the snapshot first. Then optionally read source files via the Read tool for context the snapshot does not cover.`
   - Evidence kinds to cite: `files, paths, or snapshot sections`.

5. **Detect truncation** — protocol **Detect truncation**.

6. **Synthesis pass** — protocol **Synthesis rules**, writing:

   ```markdown
   # Engineering Panel Synthesis — <YYYY-MM-DD>

   <partial-run header note, if any>

   ## Per-persona verdicts
   | Persona | Verdict | Findings (C/H/M/L) |
   |---------|---------|--------------------|
   | Architect | healthy/needs-attention/at-risk | ... |
   | ... | ... | ... |

   ## Cross-cutting themes
   Themes flagged by 2+ personas. Each theme cites the personas and points to the relevant findings.

   ## Prioritized findings
   Top 5–10 findings across all personas, ordered by severity then cross-persona reach.

   ## Overall assessment
   One paragraph: what's healthy, what's at risk, what to focus on first.

   ## Truncated personas
   (only if any)
   ```

   Theme detection is judgment-based: if Architect and Maintainability both flag "test coverage gaps in auth/", that's a cross-cutting theme regardless of exact wording.

7. **Draft proposed issues** — protocol **Draft proposed issues**. No extra sources or fields.

8. **End-of-run prompt** — protocol **Offer filing**.

9. **Final summary** — protocol **Final summary**, plus the verdict table and top themes (see `<output_format>`).
</workflow>

<output_layout>
```
docs/reviews/panel-engineering/2026-05-16/
├── snapshot.md            # shared evidence base
├── architect.md           # persona reports (one per persona run)
├── security.md
├── ops-sre.md
├── dx.md
├── maintainability.md
├── synthesis.md           # cross-persona themes + prioritization
└── proposed-issues.md     # draft issue list with dedup annotations
```

If the date folder already exists, the new run lands in `2026-05-16-2/`, `2026-05-16-3/`, etc.
</output_layout>

<output_format>
The persisted files are the canonical output. At the end of the run, print a short summary like:

```markdown
# Panel Engineering Review — 2026-05-16

Reports written to: `docs/reviews/panel-engineering/2026-05-16/`
- snapshot.md
- architect.md, security.md, ops-sre.md, dx.md, maintainability.md
- synthesis.md
- proposed-issues.md

## Verdicts
| Persona | Verdict | C/H/M/L |
|---------|---------|---------|
| Architect | needs-attention | 0/3/4/2 |
| ... | ... | ... |

## Top themes
1. <theme> (flagged by: architect, maintainability)
2. <theme> (flagged by: security, ops-sre)
3. ...

## Issues
- Drafted: 7
- Created: 4 (links below)
- <list of URLs>

See `synthesis.md` for the full prioritized view.
```
</output_format>

<success_criteria>
- Every protocol **Invariant** holds
- Selected personas default to all five
- CONSTITUTION.md (when present) included in `snapshot.md` as grounding context only, never scored against
- Verdicts use the `healthy` / `needs-attention` / `at-risk` scale
</success_criteria>

<examples>
```bash
# Full quarterly run — all five personas, drafted issues, end-of-run prompt
/panels:panel-engineering

# Reports only; skip the issue drafting and prompt
/panels:panel-engineering --skip-issues

# Run a focused subset
/panels:panel-engineering --personas architect,security

# Combine flags
/panels:panel-engineering --personas dx,maintainability --skip-issues
```
</examples>

<notes>
- Prompt-injection and shared-bias caveats: protocol **Caveats**.
- Scope intentionally **excludes** strategic dimensions (mission alignment, market position, roadmap coherence). Those belong in `panel-product`, which requires `CONSTITUTION.md` as input.
- The Security Posture persona is **whole-repo posture** (dependency hygiene, secrets handling, threat surface, SECURITY.md adequacy) — not diff-level vulnerability hunting (that's `reviewer-security` under `panel-review`) and not deep security analysis (that's `delivery:security-review`).
</notes>
