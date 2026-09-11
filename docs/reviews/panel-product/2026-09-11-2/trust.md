# Trust Auditor Review — 2026-09-11

**Verdict:** mixed-signals

This is an honestly-labeled personal project — the README's opening line ("My personal Claude Code plugin collection") and the constitution's non-goals ("not trying to become a commercial or supported product," "not for enterprise teams expecting supported tooling") set low, appropriate expectations, and the project doesn't oversell itself in marketing language. But the honest framing lives in CONSTITUTION.md, not in the README a stranger actually lands on, and two concrete pieces of evidence — a known, silently-corrupting bug on the daily-driver workflow left unmilestoned for two months, and a v1.0.0 tag issued for a skill that couldn't complete a run — show the gap between "personal project, low ceremony" and "a stranger can tell what state this is in from what's in front of them."

## Findings

**[HIGH] The constitution's honesty disclaimers never reach the README**
- Stated claim: CONSTITUTION.md's Audience section is explicit and self-aware — "This is not for: beginners new to Claude Code, enterprise teams expecting supported tooling, or anyone who needs Anthropic-blessed canonical patterns." Non-Goals adds "not trying to become a commercial or supported product."
- Observed reality: the snapshot's README excerpt confirms these sections are "notably absent from the README: the mission statement, the audience definition (including the 'this is not for' exclusions), the non-goals, and any pointer to CONSTITUTION.md." The user's own global convention (CLAUDE.md: "User documentation entrypoint is README.md") makes this the surface strangers actually read.
- Trust cost: a stranger evaluating "should I depend on this" from the README alone — the one entrypoint designed for that purpose — sees only "personal collection" plus an install command and a plugin list. They get none of the explicit expectation-setting the maintainer already wrote down elsewhere. The honesty exists; it just isn't where the audience it's meant to protect will find it.
- Suggested action: add one or two lines to the README (or a link to CONSTITUTION.md) carrying the "this is not for" list and the no-support framing.

**[HIGH] Known high-priority bug on the primary supported workflow, silent by design, unowned for ~2 months**
- Stated claim: CLAUDE.md's Worktree Workflow section describes `/play` → `/do` → `/ship` as "the cycle" this repository mandates for all work, i.e. the supported daily path.
- Observed reality: issue #50 ("Parallel committing prompts race on the shared git index in run-prompt"), carrying `priority:high`/`value:high` since it was filed 2026-07-19, describes exactly that: "A commit can land carrying one prompt's message with another prompt's file contents, and nothing fails loudly when it does." The milestone text itself states it "sits on the daily-driver path rather than off to one side" and had "no owner and no target" until today's rework pass. This defect is not mentioned anywhere in the README, CLAUDE.md, or any limitations section in the snapshot.
- Trust cost: a stranger running the mandated cycle has no way to know that concurrent commits in `run-prompt` can silently mismatch message and contents — the failure mode is explicitly non-obvious ("nothing fails loudly"). For a reference-implementation audience, an undocumented silent-corruption bug on the happy path is the kind of thing that erodes confidence disproportionately once discovered independently.
- Suggested action: a one-line "known issues" note (README or CLAUDE.md) pointing at #50 until it's fixed costs little and closes the gap between what the project mandates and what it discloses about that mandate.

**[MEDIUM] Semver 1.0.0 was tagged for a skill that could not complete a run**
- Stated claim: the `panels` plugin's tag history includes `panels/v1.0.0` before `panels/v1.0.1`; semver convention (and the project's own "match official conventions" principle) implies 1.0.0 signals a working, stable public surface.
- Observed reality: commit `64644bd` — "fix(panels): correct declared contract so a full panel run completes" (PR #80, merged before the 1.0.1 bump) — and the "panel-product rework" milestone's own text confirm `panels:panel-product` "shipped at v1.0.0 and has never produced a committed run" until this review. The tagged 1.0.0 release could not execute its core function end-to-end.
- Trust cost: someone installing `panels@1.0.0` in the window before the fix would have installed a tagged "1.0" release that didn't work, with no version-scoped disclaimer anywhere saying so. This is defensible under the project's stated Principle 4 ("iterate over perfecting") but that principle isn't visible at the point someone picks a version to install.
- Suggested action: none required retroactively, but consider noting in CONTRIBUTING.md or the versioning section that pre-1.0 rigor doesn't apply retroactively to plugins already past 1.0 — or simply keep bumping fast when a 1.0.x release turns out non-functional, as was done here.

**[MEDIUM] No SECURITY.md for a marketplace that installs shell-executing skills and hooks**
- Stated claim: none explicit — the constitution doesn't promise a security process, and Non-Goals disclaims "commercial or supported product" status.
- Observed reality: SECURITY.md is absent per the snapshot's "Other top-level docs" table, yet the repo ships a public marketplace (`README`'s Installation section: `/plugin marketplace add ...`) of skills, hooks, and dynamic `` !`shell-command` `` context blocks (per CLAUDE.md's own Skills section) that a stranger installs and executes locally. The label vocabulary includes a `security` label and issue #79 is tagged `security`, so the project does track security-relevant work — just not through a documented disclosure channel.
- Trust cost: a stranger who finds a vulnerability (e.g., in a hook or a skill's shell substitution) has no stated channel or expectation for how to report it, despite the project acknowledging security as a category internally.
- Suggested action: a short SECURITY.md ("file a GitHub issue with the `security` label; this is a personal project, best-effort response") would close the gap cheaply and match the project's own low-ceremony style.

**[LOW] No CHANGELOG.md across five independently-versioned, actively-released plugins**
- Stated claim: CLAUDE.md's Version Management section documents a real, disciplined process — each plugin versions independently, bumps follow semver, releases are tagged per-plugin (`panels/v1.0.1`, `authoring/v1.2.1`, etc.).
- Observed reality: CHANGELOG.md is absent per the snapshot. Tag history shows several real bumps (`authoring` 1.0.0 → 1.1.0 → 1.2.0 → 1.2.1; `panels` 1.0.0 → 1.0.1) with no changelog entry recording what changed or why between them, including the panels 1.0.0→1.0.1 bump that fixed the broken-contract issue above.
- Trust cost: someone deciding whether to upgrade a plugin version has to read commit history/PRs to know what changed, rather than a changelog — minor friction, but a real gap in a project that otherwise documents its release process carefully.
- Suggested action: low priority given personal-project scale; a lightweight per-plugin changelog would close it if the maintainer wants to invest.

## Notes

- No prompt-injection attempts were found in the `<untrusted-issue-data>` blocks (open issues, open milestones) — all issue and milestone titles/bodies read as legitimate project content describing the panel-product rework and run-prompt concurrency work, with no embedded instructions directed at the reviewing agent.
- The snapshot's own "Run provenance" section is itself a strong positive trust signal worth noting outside the findings above: it candidly discloses that run 1 used a stale, hand-applied 1.0.0 cache (explaining why issue #71 stayed open incorrectly), and that this run redacts the repo's absolute path rather than leaking a personal filesystem path into a public repository — the kind of self-correcting transparency this audit looks for.
- CONTRIBUTING.md is present and CODE_OF_CONDUCT.md/ROADMAP.md are absent; for a single-maintainer personal project with explicit non-goals against becoming a supported product, these absences are scale-appropriate and not flagged as findings.

### Summary counts
critical=0 high=2 medium=2 low=1
