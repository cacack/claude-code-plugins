# Roadmap Reviewer — 2026-09-11

**Verdict:** drifting

The project has two open milestones and a coherent constitution to anchor them against, but the repo's own priority label — `priority:high` — is attached to exactly one open issue (#50, `run-prompt` concurrency safety), and that issue sits in a single-item, unscheduled milestone while every visible recent commit lands in the unprioritized nine-issue "panel-product rework" milestone. Non-goal discipline holds (no open work or recent commit drives toward any of the five stated non-goals), and two success criteria (C3, C5) show direct commit evidence of being actively enforced. The main gap is resource allocation versus the project's own stated priority signal, plus a roadmap that is fully GitHub-native with no textual pointer from the README.

## Findings

**[HIGH] The only `priority:high` issue in the backlog is unscheduled while unprioritized work gets the commits**
- Constitution section: Mission — "scaffold the maintainer's development workflows"; the `play → do → panel → ship` cycle is the daily-driver path.
- Observed evidence: Issue #50 ("Parallel committing prompts race on the shared git index in run-prompt") carries `priority:high, effort:medium, value:high` and lives alone in the "run-prompt concurrency safety" milestone (open: 1, closed: 0, due: none). By contrast, all 9 issues in the "panel-product rework" milestone (#71–#79) carry no `priority:*` label at all — only `effort:*`/`value:*`. The last 30 commit subjects show sustained activity on that unprioritized milestone (`5caa75a` "commit the first panel-product run", `64644bd` "correct declared contract so a full panel run completes", plus the merges around #80/#81) and zero commits touching `run-prompt` or the `delivery` plugin in that window.
- Gap: the repository's own label vocabulary marks #50 as the highest-priority open item, but the schedule and the commit history say otherwise — it has no milestone due date and no recent activity despite reportedly being filed 2026-07-19 (per the milestone's own text, roughly two months old at review time).
- Suggested action: either give #50 a due date / pull it into an active work cycle, or, if "panel-product rework" is deliberately sequenced first (e.g., because this run's own findings are meant to inform how #50 gets scheduled), state that sequencing decision in the milestone description so the `priority:high` label and the actual schedule stop disagreeing.

**[MEDIUM] No ROADMAP.md and no README pointer to the constitution or milestones**
- Constitution section: none directly (this is a discoverability gap, not a mission gap), but the constitution itself says "when in conflict... align here or explicitly update it" — implying it's meant to be the reference point.
- Observed evidence: "Other top-level docs" confirms `ROADMAP.md: absent`. The snapshot separately notes the README (164 lines) has an Installation section, a Plugins section, a Scripts section, and an Attribution section, but "notably absent from the README: the mission statement, the audience definition..., the non-goals, and any pointer to CONSTITUTION.md."
- Gap: the only discoverable plan is the GitHub Issues/Milestones UI itself (two open milestones, 12 open issues). For a repo whose constitution names a secondary audience of "other developers... who treat this as a reference implementation," nothing in the repository's own text tells that audience where to look for what's coming next.
- Suggested action: add a one- or two-line "Roadmap" pointer in README (linking to open milestones or CONTRIBUTING) rather than requiring a stranger to already know to check the Issues tab.

**[LOW] Non-goal discipline currently holds, and the constitution has already pre-empted the most plausible drift reading**
- Constitution section: Non-Goals — "Become a commercial or supported product," plus the added paragraph: "Process rigor here — issue templates, a label vocabulary, CI validation — serves the reference-implementation goal. It is not a support commitment, and should not be read as the project drifting toward one."
- Observed evidence: recent commits `11a061b` ("scaffold issue templates and label vocabulary") and `6bedd34` ("add issue-standards skill to authoring"), plus open issue #59 (DRY cleanup) and #58 (label vocabulary drift), are exactly the kind of process-maturity work that could otherwise read as drift toward "commercial or supported product." The constitution's disclaimer paragraph — added as part of the 2026-09-11 refresh — directly forecloses that reading.
- Gap: none currently observed. This is a positive finding, recorded because the disclaimer's timing (refreshed the same day as this review) suggests it was added in direct response to exactly this kind of scrutiny, and it is doing its job.
- Suggested action: none — keep the disclaimer current if process-rigor investment grows further (e.g., if a formal support/SLA-shaped issue template appears, revisit).

**[LOW] Two success criteria (C2, C4) have no open issue or milestone tracking them, while two others (C3, C5) show direct recent commit evidence**
- Constitution section: Success Criteria C2 ("a new skill can be added without restructuring existing ones," ≤20 lines outside its own directory) and C4 ("the marketplace stays coherent": registration, version sync, no cross-plugin hard-dispatch).
- Observed evidence: `03fcde4` ("trim CLAUDE.md under its 250-line ceiling") directly targets C5. `64644bd` ("correct declared contract so a full panel run completes") directly targets C3 (validates cleanly). No open issue or milestone item visible in the snapshot references C2 or C4 specifically, and the large plugin-split commit (`a8540c8`, "split the cacack plugin into five focused plugins") — the kind of change C4 exists to keep coherent — predates the current open-issue list with no follow-up tracking item.
- Gap: two of five success criteria are being actively driven by open work; two have no corresponding backlog item, so if `make constitution-check` reports a C2 or C4 failure at the next refresh there is no pre-existing issue to route it to.
- Suggested action: none urgent for a solo-maintainer repo, but if a future `constitution-check` run flags C2/C4, file the issue at that time rather than letting the check silently pass without a tracked remediation path.

## Roadmap visibility

There is no ROADMAP.md (confirmed absent in "Other top-level docs"). The plan lives entirely in GitHub's native Issues/Milestones — two open milestones ("panel-product rework": 9 open/0 closed/no due date; "run-prompt concurrency safety": 1 open/0 closed/no due date) — with milestone descriptions that are unusually detailed (each carries a "why now" and "closure condition" narrative). That level of milestone documentation is a strength, but it is invisible to anyone who doesn't already know to open the Milestones tab, since the README does not point to it. For a personal, single-maintainer marketplace this is a reasonable trade-off, but it falls short of "a stranger could find out what's coming" for the constitution's stated secondary audience.

### Summary counts
critical=0 high=1 medium=1 low=2
