---
name: constitution
description: Author or refresh a project's CONSTITUTION.md — the mission, audience, principles, non-goals, and success criteria. Auto-detects bootstrap mode (no file) vs refresh mode (file exists). In refresh mode, compares the existing constitution against current repo state and produces a drift report before updating. Required input for the planned `panel-product` skill; useful on its own to make implicit project intent explicit.
argument-hint: "[--mode=bootstrap|refresh] [--no-interview]"
allowed-tools: Read, Write, Edit, Bash(git:*), Bash(gh:*), Bash(glab:*), Bash(date:*), Bash(test:*), Bash(command:*), Bash(mkdir:*), Bash(head:*), Bash(ls:*), Bash(find:*)
effort: medium
---

<objective>
Make a project's mission, audience, principles, non-goals, and success criteria explicit by writing or refreshing `CONSTITUTION.md` at the repo root.

`SECURITY.md`, `README.md`, `CONTRIBUTING.md`, and `CODE_OF_CONDUCT.md` are existing conventions and not in scope. The gap this fills is the project-level *intent* doc that nobody quite writes — the one that lets reviewers ask "is what we're doing still what we said we'd do?"

This skill is also the input bootloader for the planned `panel-product` skill, which measures strategic alignment against the constitution.
</objective>

<quick_start>
```bash
# Auto-detect mode: drafts if CONSTITUTION.md is absent, refreshes if present
/panels:constitution

# Force bootstrap (overwrites existing CONSTITUTION.md after confirmation)
/panels:constitution --mode=bootstrap

# Bootstrap without the section-by-section interview (just auto-draft + confirm)
/panels:constitution --no-interview
```
</quick_start>

<arguments>
| Flag | Effect |
|------|--------|
| (none) | Auto-detect mode by presence of `CONSTITUTION.md` |
| `--mode=bootstrap` | Force bootstrap mode; warn if file exists and require confirmation before overwriting |
| `--mode=refresh` | Force refresh mode; abort if file doesn't exist |
| `--no-interview` | In bootstrap, skip section-by-section confirmation; present the full draft once for accept/edit/discard |
| `--allow-principle-changes` | In refresh, skip the extra confirmation gate when proposed updates touch the Principles section. Use after you've deliberately weighed the principle change |
</arguments>

<workflow>
0. **Probe the environment.**
   - `git rev-parse --show-toplevel 2>/dev/null` — repo root. If empty, stop.
   - `test -f CONSTITUTION.md && echo present` — mode detection
   - `command -v gh >/dev/null 2>&1 && echo gh` — issue/milestone tooling
   - `command -v glab >/dev/null 2>&1 && echo glab`
   - `date +%Y-%m-%d` — for drift-report folder
   - Parse `$ARGUMENTS` for `--mode`, `--no-interview`

1. **Determine mode.**
   - `--mode=bootstrap` explicit → bootstrap (confirm overwrite if file exists)
   - `--mode=refresh` explicit → refresh (abort if file missing: "No CONSTITUTION.md found; run without --mode=refresh to bootstrap")
   - No flag and file absent → bootstrap
   - No flag and file present → refresh

2. **Gather context.** Same data for both modes:
   - `README.md` (first ~200 lines)
   - Project metadata: search common locations for `plugin.json`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `setup.cfg`, `manifest.json`. Check **both root and common subdirs** (`plugins/*/`, `plugins/*/.claude-plugin/`, `packages/*/`, `apps/*/`, `services/*/`, `crates/*/`). Read what exists at the most-specific location — many real repos nest the manifest several levels deep.
   - Recent activity: `git log --since='6 months ago' -50 --pretty=format:'%h %s'`
   - Tags/releases: `git tag --sort=-creatordate | head -5`
   - Open milestones (if `gh` available: `gh api repos/{owner}/{repo}/milestones --jq '.[] | {title, description, state}'`; if `glab` available: `glab api projects/:id/milestones`)
   - Top-level docs presence flags
   - In **refresh** mode also read the existing `CONSTITUTION.md` in full

3. **Mode: bootstrap.**

   3a. **Auto-draft.** Compose a CONSTITUTION.md proposal using the template in `<constitution_template>`. Infer each section from gathered context:
   - **Mission:** synthesize from README's first paragraph + project description + observed scope. One paragraph.
   - **Audience:** infer "for whom" from README + commit subjects (who solves what here). Include a "not for" line — if you can't infer one confidently, mark it `<TODO: confirm with user>`.
   - **Principles:** 3–7 tradeoff choices. Try to surface tradeoffs the project has *actually* made (e.g., "simplicity over completeness", "compatibility over modernity"). If you can't ground a principle in observed evidence, mark it `<TODO>`.
   - **Non-Goals:** 2–5 things the project is explicitly *not* doing. Often inferable from README ("does not", "won't", "out of scope"). If you can't infer any, leave `<TODO>` placeholders and rely on the interview.
   - **Success Criteria:** 2–5 concrete signals, each with a stable id (`C1`, `C2`, …) and a `Check:` line — the template note in `<constitution_template>` is the single definition of what counts as checked. Ground them in signals the project already measures. Where the repo already has the check — a Make target, a CI job, a script — draft `Check:` with that command. Otherwise draft `Check: <TODO>`. Never invent a command that does not exist.

   3b. **Present to user.** Show the full draft with `<TODO>` markers visible.

   3c. **Interview (skip if `--no-interview`).** For each section that contains `<TODO>` markers or that you flagged as low-confidence in step 3a, ask the user via AskUserQuestion. Limit to **at most 4 questions per pass** (AskUserQuestion's max). If more sections need input, run multiple passes — but bias toward fewer, better questions.
      - **Every success criterion whose `Check:` is `<TODO>` gets a question:** *what command or observation would settle this?* Offer: **name a command** (one that credits a result to this criterion — see the template note) · **it's a judgement call** (say what a human looks at, and why no command can settle it; a judgement call with no stated reason is not accepted) · **reword or drop the criterion**. Record the answer on the criterion's `Check:` line. This is the principles rule applied to criteria: reject the platitude, ask for the tradeoff — reject the impression, ask for the check. A judgement call is a legitimate answer; never force a false metric to avoid one. Under `--no-interview`, `Check: <TODO>` lines stay in the written file on purpose — the next refresh flags them.

   3d. **Confirm and write.** Show the final draft. Ask:
      - **Write** — write `CONSTITUTION.md` to repo root
      - **Edit** — let user describe changes; apply via Edit; re-confirm
      - **Discard** — stop without writing

   3e. If file already exists (forced `--mode=bootstrap`), the confirm step explicitly notes "this will overwrite the existing CONSTITUTION.md".

4. **Mode: refresh.**

   4a. **Compare.** For each section in the existing `CONSTITUTION.md`, evaluate against gathered context. Look for:
   - **Mission drift:** does the README or recent activity suggest a scope or audience the mission doesn't cover, or commit to scope the mission claims but evidence contradicts?
   - **Audience drift:** has the actual user/contributor profile shifted (e.g., constitution says "for solo devs", commits show enterprise integrations)?
   - **Principle drift:** are there principles that the codebase no longer follows, or new tradeoff choices not reflected?
   - **Non-goal drift:** is the project doing things it said it wouldn't (or vice versa)?
   - **Success criteria drift:** are the metrics or signals still relevant? Are there new ones the project actually cares about now?
   - **Unchecked criteria:** apply the template note's definition of *checked* to every criterion. That includes a named command whose output does not credit a result to this criterion — `panel-product`'s scorecard counts that as a constitution defect (`not attributed`) just as it does a missing check (`no named check`), so refresh must flag both or the scorecard's remedy never lands. Flag each as a `[MINOR]` finding titled `Unchecked criterion: <id>`. Its **Proposed update** is a question, not replacement text: "Name the command that settles this — one that credits a result to this criterion — or declare it a judgement call and say why." Never draft a check on the author's behalf here.
   - **Criterion ids:** ids are stable — never renumber, never reuse a retired id; the scorecard matches rows across runs by id. A constitution written before ids existed (plain bullets) is cited by position and quoted text (`criterion 2, "releases ship monthly"`), and refresh adds one ordinary `[MINOR]` finding proposing `C<n>` ids in their current order. That one carries real replacement text and applies normally.

   4b. **Write drift report.** Path: `docs/reviews/constitution/<YYYY-MM-DD>-drift.md` (create folder if needed; append `-2`, `-3` if same-day collision). Template in `<drift_report_template>`. Each finding cites concrete evidence from the gathered context.

   4c. **Show drift summary inline.** Print a short summary of the drift report (top 3–5 items, severity). Point to the full report on disk.

   4d. **Ask user how to proceed.** Via AskUserQuestion:
      - **Apply all proposed updates** — apply the drift-report's suggested edits to CONSTITUTION.md
      - **Pick a subset** — show numbered list of proposed updates; user selects indices
      - **Skip** — leave CONSTITUTION.md unchanged; drift report persists

      `Unchecked criterion` findings carry a question, not replacement text, so neither apply path ever offers or applies them — not "Apply all", and not as an index in "Pick a subset". Answer them with the author afterwards, the same way bootstrap step 3c does, and write only what the author gives.

   4e. **Principle-change gate.** Before applying, check whether any selected update has `**Section:** Principles`.
      - If no principle changes are in the selection → proceed directly to 4f.
      - If principle changes are selected AND `--allow-principle-changes` was supplied → proceed directly to 4f.
      - Otherwise, prompt via AskUserQuestion:
        - **Apply all selected updates** — including the principle change(s); proceed
        - **Skip just the principle change(s)** — drop the Principles items, apply the rest
        - **Cancel** — apply nothing

      Rationale: principles are the project's foundational tradeoff choices and should change rarely. Mission/Audience/Non-Goals/Success Criteria can reasonably evolve as context shifts and don't need this gate.

   4f. **Apply updates.** Use `Edit` to make the (possibly-filtered) selected changes section by section. Update the `*Last refreshed*` footer to today's date. If applying any updates, show the user a diff summary at the end.

5. **Final summary.** Print:
   - Mode used (bootstrap or refresh)
   - Path to CONSTITUTION.md
   - Path to drift report (refresh only)
   - Summary of what was written/changed
</workflow>

<constitution_template>
```markdown
# Constitution

> The mission, principles, and non-goals of <project name>. When in conflict with this document, future decisions should align here or explicitly update it.

## Mission

<one paragraph: what the project does, for whom, and why it exists>

## Audience

**This is for:** <who benefits — be specific>
**This is not for:** <who should look elsewhere — also specific>

## Principles

When in doubt, prefer:

1. **<principle name>** — <one-sentence elaboration framing it as a tradeoff choice>
2. **<principle name>** — <...>
3. **<principle name>** — <...>

(3–7 principles. Order by priority. Frame each as a tradeoff, not a platitude: "simplicity over completeness" is useful; "be excellent" is not.)

## Non-Goals

This project is explicitly **not** trying to:

- <non-goal — specific, not "everything else">
- <non-goal>
- <non-goal>

(Equally important as goals. What we won't chase, even if asked.)

## Success Criteria

We'll know this is working if:

<Optional, when one command settles several criteria and reports per criterion:> Run them all: `<command>`

**C1 — <concrete, observable signal>.**
Check: `<command that settles it>` — e.g. `make test` exits 0 on the default branch

**C2 — <concrete, observable signal>.**
Check: judgement call — <what a human looks at, and why no command can settle it>

**C3 — <concrete, observable signal>.**
Check: <TODO> — the form bootstrap drafts when no check is known yet; the interview or the next refresh resolves it

(Every criterion carries a stable id and a `Check:` line. **Checked** means exactly one of: (a) a command whose result is credited to this criterion — its own exit code, or output that labels a result for this criterion by id; (b) the section's umbrella command, when its output labels a result per criterion by id; (c) `judgement call — <reason>`, stating what a human looks at and why no command can settle it. Anything else — no check, `<TODO>`, a command whose output does not credit this criterion, or a bare `judgement call` — is unchecked. This definition mirrors `panel-product`'s scorecard rules (step 2); keep the two in step. Avoid vibes-based metrics like "users are happy".)

---

*Last refreshed: <YYYY-MM-DD>*
```
</constitution_template>

<drift_report_template>
```markdown
# CONSTITUTION.md Drift Report — <YYYY-MM-DD>

Existing constitution last refreshed: <date from footer, or "unknown">

## Summary

<one or two sentences: overall alignment between constitution and current repo state>

## Drift findings

### [MAJOR] <short title>
- **Section:** <Mission | Audience | Principles | Non-Goals | Success Criteria>
- **Current text:** <quote>
- **Evidence of drift:** <concrete pointer to README/commits/issues>
- **Proposed update:** <specific replacement text — or, for an `Unchecked criterion` finding, the question to put to the author>

### [MINOR] <short title>
- ...

## Sections still accurate
- <list of sections that match current state>

## Suggested additions
- <new principles, non-goals, or criteria that current activity suggests but constitution doesn't capture>
```
</drift_report_template>

<success_criteria>
- Aborts cleanly when not in a git repo
- Mode auto-detected correctly; explicit `--mode` overrides honored; refresh aborts if file missing
- Bootstrap auto-draft makes a real attempt at each section using observed context; marks unknowns `<TODO>` rather than inventing
- Bootstrap interview asks at most 4 questions per AskUserQuestion call; only re-runs if necessary
- Refresh drift report cites concrete evidence (file paths, commit messages, issue titles), not impressions
- Refresh never modifies CONSTITUTION.md without explicit user choice
- Every bootstrap success criterion carries a stable id and a `Check:` line; *checked* is defined once, in the template note, to match the scorecard
- Refresh flags each unchecked criterion — including a command that does not credit the criterion — as a finding that asks for a check; neither apply path ever writes one unasked
- Criterion ids are never renumbered; legacy un-numbered criteria are cited by position and quoted text, with one ordinary proposal to assign ids
- Bootstrap with `--mode=bootstrap` warns before overwriting an existing file
- `*Last refreshed*` footer updated on any successful write
- Drift report persisted to `docs/reviews/constitution/<date>-drift.md` regardless of whether updates were applied
- Refresh-mode updates that touch the Principles section trigger an extra confirmation gate unless `--allow-principle-changes` was supplied; users can also choose "skip principle changes only" to apply other selected updates without the principle edit
</success_criteria>

<examples>
```bash
# First time on a project — produces a draft via interview
/panels:constitution

# Quarterly refresh — produces drift report, prompts for updates
/panels:constitution

# Force re-bootstrap a stale constitution (will prompt before overwrite)
/panels:constitution --mode=bootstrap

# Auto-draft without the interview (fast first pass to iterate on)
/panels:constitution --no-interview

# Refresh and pre-authorize principle updates (skip the extra gate)
/panels:constitution --allow-principle-changes
```
</examples>

<notes>
- The constitution is intentionally small (one screen). If it grows beyond that, the additions probably belong in ARCHITECTURE.md, ROADMAP.md, or a design doc — not here.
- Principles framed as platitudes ("be excellent", "users first") are noise. Framed as tradeoffs ("simplicity over completeness") they constrain decisions. The bootstrap interview should push toward the tradeoff framing.
- **Principles are gated, other sections aren't.** Mission, Audience, Non-Goals, and Success Criteria reasonably evolve as context shifts and update under normal confirmation. Principles capture foundational tradeoff choices and trigger an extra confirmation in refresh mode (override with `--allow-principle-changes`). This is convention enforced by the tool, not by file structure — direct `Edit` on `CONSTITUTION.md` bypasses the gate, as does any approach. The friction lives at the most common edit path (the refresh skill).
- The drift report is more valuable than the update itself in many cases — it surfaces the gap between stated and actual intent. Skipping the update but reading the drift report is a legitimate use mode.
- The `Check:` line is what `panel-product`'s scorecard reads. A checked command lets it score the criterion `met` or `unmet`; a declared judgement call is scored `unmeasurable` with reason `judgement call` (deliberate, no remedy); an unchecked criterion is scored `unmeasurable` with reason `no named check` or `not attributed`, both of which it counts as constitution defects and sends back here to fix. A scorecard that mostly reports "unmeasurable" trains its reader to skip it — the interview's check question is what keeps it worth reading.
- `panel-product` reads `CONSTITUTION.md` as its scoring rubric. A weak constitution will produce a weak product review; a clear, opinionated constitution will produce a sharp one.
</notes>
