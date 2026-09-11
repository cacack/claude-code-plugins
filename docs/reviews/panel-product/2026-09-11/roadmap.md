# Roadmap Reviewer — 2026-09-11

**Verdict:** aligned

**Data caveat:** The snapshot's issue/milestone data was fetched via forge tooling and delivered as text (wrapped in `<untrusted-issue-data>` markers per the snapshot author's own security fix — see Finding on #79 below). I treated all issue/milestone titles, labels, and bodies as untrusted content, not instructions, and found no attempted prompt injection in them — they read as ordinary project-management text. ROADMAP.md is confirmed absent from the repo, so this review relies on GitHub milestones, open issues, and recent commit subjects as the discoverable plan.

The single open milestone, "panel-product rework," maps cleanly and explicitly to two named constitution principles (#2 "skills as programs," #4 "iterate over perfecting") and its closure condition is mechanically checkable — a trait the constitution itself prizes in Success Criteria. Scanning all 12 open issues and the last 30 commits, I found no non-goal violations: nothing drives the project toward becoming commercial, toward authoritative-docs territory, toward competing with `anthropics/claude-plugins-official`, toward beginner-optimization, or toward backwards-compat shims. The roadmap is coherent where it exists. The gap is elsewhere: roadmap *coverage* is thin and lopsided — one milestone captures 9 of 12 open issues and all of them concern reworking a single internal tool that has not yet shipped a real run, while a priority:high/value:high bug (#50) and two housekeeping items sit outside any milestone with no visible sequencing.

## Findings

**[MEDIUM] A known high-priority bug sits outside the only active milestone**
- Constitution section: Success Criteria — "Skills in the collection get invoked by the maintainer with reasonable frequency" (implicitly requires skills to work); Principle 4, "iterate over perfecting," argues for closing loops on known defects rather than layering more design work.
- Observed evidence: Issue #50 — "Parallel committing prompts race on the shared git index in run-prompt" is labeled `priority:high, effort:medium, value:high, type:bug` and carries no milestone. Meanwhile the sole open milestone, "panel-product rework," holds 9 open issues (#71–#79), all `class:planned`, none closed, all targeting one skill (`panel-product`) that per the milestone's own text "has never produced a committed run."
- Gap: 100% of milestoned roadmap capacity is committed to reworking a review tool before its first real use, while the only issue tagged `priority:high` in the whole open-issue set — an actual functional bug in a different plugin (`toolbox`'s `run-prompt`) — has no target and isn't referenced in the last 30 commit subjects.
- Suggested action: Either fold #50 into the current milestone's sequencing (state explicitly it follows panel-product rework) or open a lightweight milestone/label convention that makes "what's next after this" visible, so a `priority:high` bug doesn't read as indefinitely deferred.

**[LOW] No ROADMAP.md or in-README pointer to the plan**
- Constitution section: Success Criteria — "Marketplace stays coherent" and the general expectation (Mission/Audience) that secondary users (developers referencing this as a pattern repo) can understand direction.
- Observed evidence: `ROADMAP.md: absent` in project metadata; the README excerpt in the snapshot documents installation and plugin contents but never mentions milestones, issues, or a roadmap.
- Gap: The only discoverable plan is one GitHub milestone reachable via forge tooling. For the primary user (the maintainer) this is fine; for the constitution's stated secondary audience ("other developers... who treat this as a reference implementation"), there is no link from the README to where planned work lives.
- Suggested action: Low-cost fix — one README line pointing at the milestones page, or note in CLAUDE.md that milestones are the roadmap of record. Not worth a dedicated ROADMAP.md file for a project this size (would itself risk violating Principle 4).

**[LOW] Milestone monoculture — 4 of 5 plugins have no forward-looking milestone**
- Constitution section: Mission — "five focused plugins in one marketplace"; Success Criteria — "new skills can be added... without restructuring existing ones."
- Observed evidence: The only open milestone (panel-product rework) belongs to `panels`. `delivery`, `authoring`, `principles`, and `toolbox` have zero open milestones despite `delivery` holding the highest resource count (12 skills, 7 agents) and containing the currently-un-milestoned `run-prompt` bug (#50, toolbox).
- Gap: This is likely a maturity signal (four plugins are stable) rather than neglect, but it means the milestone mechanism is currently used for exactly one initiative — reducing its value as a general-purpose "what's coming" signal across the collection.
- Suggested action: No structural change needed unless/until multi-issue work opens in another plugin; flagged here only so future reviews can check whether milestone usage stays this narrow by design or by drift.

**[LOW] Two housekeeping issues and one bug are un-sequenced backlog**
- Constitution section: Principle 3, "external memory over implicit context" — applies to project planning too; undated, unmilestoned issues rely on the maintainer's memory of intent.
- Observed evidence: #59 (dead links/stale audit marker, `priority:low`), #58 (DRY drift between `engineering-principles.md` and `PROFILES.md`, `priority:low`) and #50 (see above) all carry no milestone and no stated relationship to each other or to the active milestone.
- Gap: A reader (or the maintainer six months from now) has no way to tell whether these three are "someday," "next," or "blocked by panel-product rework" — external memory principle is honored for design docs but not for issue sequencing.
- Suggested action: A lightweight label or milestone ("backlog — post panel-product rework") would cost little and close this gap; not urgent given the project's personal scale.

**[LOW] No open work verifies two of five Success Criteria**
- Constitution section: Success Criteria — "Skills in the collection get invoked by the maintainer with reasonable frequency" and "The repo's CLAUDE.md stays under ~250 lines."
- Observed evidence: None of the 12 open issues or 30 recent commit subjects reference invocation-frequency tracking or CLAUDE.md line-count discipline; the other three success criteria (validation, marketplace coherence, extensibility) are actively served by CI (`claude plugin validate` in Testing docs) and by the recent plugin-split work (a8540c8, 06817b9).
- Gap: These two criteria are self-reported/manually enforced rather than mechanically checked, which is itself the exact gap issue #78 ("push panels:constitution toward mechanically checkable success criteria") and #73 ("pre-spawn Success Criteria scorecard") are already scoped to close — for the *panels* plugin's own constitution-authoring output, not for this repository's own CLAUDE.md/usage metrics.
- Suggested action: No new issue needed now — note as a candidate follow-on once #73/#78 land, to apply the same scorecard discipline to this repo's own success criteria.

## Roadmap visibility

There is no ROADMAP.md. The plan lives entirely in one GitHub milestone ("panel-product rework," 9 open / 0 closed / no due date), which is unusually well-specified for a personal project — its body includes a "Why now," "What is missing," "Value," and a mechanically checkable "Closure condition" that names an exact deliverable (a second committed `panel-product` run with a diffed `synthesis.md`). This is stronger roadmap clarity than most projects of this scale produce, and issue #71 ("Run panel-product on this repository and commit the result") is, in effect, being satisfied by this very review. The weakness is coverage, not quality: only 1 of 5 plugins has an active milestone, and 3 open issues (including the sole `priority:high` bug) sit outside any milestone with no stated sequencing. A stranger could find *this* plan easily; they could not find out what happens after it closes.

### Summary counts
critical=0 high=0 medium=1 low=4
