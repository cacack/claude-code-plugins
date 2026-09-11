# Strategic Panel Synthesis — 2026-09-11

All five personas ran. This is the first committed `panel-product` run in the project's
history (issue #71), so there is no prior run to diff against — every gap below is "new"
by definition, and this file is the baseline a future run compares itself to.

**Run caveat:** the session had `panels` 1.0.0 cached while the repository was at 1.0.1.
The 1.0.1 behaviors (step-0 label probe, label-constrained drafts, inline draft format)
were applied manually rather than loaded from the installed plugin. See `snapshot.md`
header and PR #80. The Trust Auditor independently flagged this as a LOW finding.

## Constitution under review

`CONSTITUTION.md` (last refreshed 2026-05-16) defines this as a personal Claude Code
plugin marketplace whose primary audience is the maintainer and whose secondary audience
is developers treating it as a reference implementation. Its five principles favour
specialization, skills-as-programs producing verifiable output, external memory over
implicit context, iterating over perfecting, and matching official conventions while
documenting divergence. Its non-goals rule out becoming a commercial or supported
product, competing with `anthropics/claude-plugins-official`, or optimizing for
first-time Claude Code users. Five success criteria close the document.

## Per-persona verdicts

| Persona | Verdict | Findings (C/H/M/L) |
|---------|---------|--------------------|
| Mission Steward | drifting | 0 / 2 / 3 / 1 |
| Market Strategist | unclear | 0 / 1 / 2 / 1 |
| Roadmap Reviewer | aligned | 0 / 0 / 1 / 4 |
| Audience Advocate | partially-served | 0 / 0 / 2 / 3 |
| Trust Auditor | mixed-signals | 0 / 2 / 1 / 2 |
| **Total** | — | **0 / 5 / 9 / 11** |

Four distinct verdict vocabularies appear in that column, which is exactly the
comparability problem issue #76 exists to fix. Read as a group they say: the work is
on-mission, but the document the work is scored against has never been verified against
it (see "Overall alignment" for the evidence that this is not mere drift).

## Cross-cutting themes

Themes flagged by two or more personas.

### Theme 1 — The constitution's own success criteria are measurably false (4 personas)
*Mission (HIGH ×2), Trust (HIGH), Roadmap (LOW), Market (LOW, in passing)*

Two of five success criteria fail a direct check:

- "Marketplace stays coherent: **one marketplace, one plugin**" — the repo ships five
  independently versioned plugins, and the README markets that as a feature. Commit
  `a8540c8` was the deliberate cause.
- "The repo's CLAUDE.md stays **under ~250 lines**" — it is 297 lines, ~19% over.

Both were verified mechanically by two personas independently, and again by the
orchestrator. This is the single strongest signal in the run: the failure is in the
rubric, not the project. The foil pass then sharpened it further — the line-count
criterion was already false when the constitution was authored, so this is an absence of
verification rather than drift. Nothing in the open backlog tracks either criterion.

### Theme 2 — `panel-product` is advertised as shipped but was never exercised (3 personas)
*Trust (HIGH), Mission (MEDIUM), Audience (MEDIUM)*

The README lists `panel-product` identically to every other skill. The project's own
milestone states it had never produced a committed run and carried defects that would
have killed a run at the filing step. Anyone who installed `panels` at 1.0.0 and ran it
would have hit that failure with no way to tell a broken release from their own mistake.
PR #80 fixed the defects the same day this review ran; the README still carries no
signal. Mission frames the deeper version: a five-persona architecture plus a foil pass
is a lot of design to ship before any verified need — in tension with Principle 4.

### Theme 3 — The project's stated boundaries are invisible where strangers look (2 personas)
*Market (HIGH + MEDIUM), Audience (LOW)*

`CONSTITUTION.md` names `anthropics/claude-plugins-official` as the thing this project
deliberately is not, and names the audience it is not for. The README mentions neither,
and never links to the constitution. The design docs that explain *why* the patterns look
the way they do sit at the bottom of one plugin's section. For the stated secondary
audience — developers reading this as a reference implementation — the most
position-defining content in the repo is unreachable from its front door.

### Theme 4 — Version ceremony without a release trail (2 personas)
*Trust (MEDIUM), Audience (MEDIUM)*

CLAUDE.md documents per-plugin semver, per-plugin tags, and CI that enforces version
bumps — real discipline, visible in the tag list. There is no CHANGELOG.md. A consumer
who updates `panels` 1.0.0 → 1.0.1 has no artifact telling them what changed, which is
what made Theme 2 undetectable from outside.

## Alignment gaps

Ordered by severity, then cross-persona reach.

1. **Success criterion "one marketplace, one plugin" contradicts the shipped architecture.**
   Constitution: Success Criteria. Flagged by mission (HIGH), market (LOW).
2. **CLAUDE.md is 297 lines against its own ~250 ceiling.**
   Constitution: Success Criteria. Flagged by mission (HIGH), trust (HIGH), roadmap (LOW).
3. **README advertises `panel-product` with no signal that it was unexercised and under rework.**
   Constitution: Success Criteria ("skills get invoked… with reasonable frequency").
   Flagged by trust (HIGH), audience (MEDIUM), mission (MEDIUM).
4. **The boundary with `anthropics/claude-plugins-official` exists only in CONSTITUTION.md.**
   Constitution: Audience, Non-Goals. Flagged by market (HIGH), audience (LOW).
5. **No CHANGELOG.md despite CI-enforced per-plugin versioning.**
   Constitution: Principle 5, Audience (secondary). Flagged by trust (MEDIUM), audience (MEDIUM).
6. **CONSTITUTION.md is not linked from README.**
   Constitution: Audience. Flagged by market (MEDIUM).
7. **Install command disagrees between README.md:9 and CLAUDE.md:268.**
   Constitution: Audience (secondary). Flagged by audience (MEDIUM).
8. **Mission claims the marketplace houses hooks; zero hooks exist.**
   Constitution: Mission. Flagged by mission (MEDIUM).
9. **`priority:high` bug #50 sits unmilestoned while all nine milestoned issues rework one unshipped tool.**
   Constitution: Principle 4. Flagged by roadmap (MEDIUM).
10. **No stated differentiation from the upstream `taches-cc-resources` most resources are adapted from.**
    Constitution: Principle 5. Flagged by market (MEDIUM).

## Overall alignment

The project is doing what it said it would do. Every recent architectural move — the
five-plugin split, the canon-profile split, the issue-standards work — is a direct
expression of Principle 1, and the Roadmap Reviewer found no non-goal violations in
either the open backlog or the last thirty commits. Two of its five success criteria are
false today, and its mission statement lists a resource type the marketplace does not
contain.

**Amended after the foil pass.** This section originally read "the constitution has
fallen behind the project." The closing Rude Q&A pass challenged that as the generous
reading, and the git history settles it against us:

- `CLAUDE.md` first crossed 250 lines on **2026-03-29** (commit `e16515d`, 264 lines).
  `CONSTITUTION.md` was authored on **2026-05-16** (commit `a793e19`), when CLAUDE.md was
  already 264 lines. `git show a793e19:CLAUDE.md | wc -l` confirms it. **That criterion
  was false on the day it was written** — it never had a true day.
- `CONSTITUTION.md` has **exactly one commit in its entire history** and has not been
  edited in the 96 commits since.

So only one criterion drifted: "one marketplace, one plugin," broken deliberately by the
five-plugin split (`a8540c8`). The other was never checked. The accurate headline is not
that the project outgrew its rubric — it is that **the rubric was never mechanically
verifiable, so it was never verified, at authoring or since.** That is a defect in how
`panels:constitution` emits success criteria (issue #78), which makes #78 the root-cause
issue of the milestone rather than a trailing nice-to-have.

The second pattern, visible across three personas, is that the project's outward surfaces
under-report what its internal documents know. The README presents a skill the milestone
describes as unexercised, omits the competitive boundary the constitution treats as
defining, and offers no changelog through which either gap could surface. None of it is
deceptive — everything is visible in the issue tracker — but the stated secondary
audience reads the README, not the tracker.

The one finding that lands on today's own work: 100% of milestoned capacity is committed
to reworking a review tool before its first real use, while the only `priority:high` bug
in the backlog carries no milestone. That is worth answering rather than dismissing.

## Constitution suggestions

**A refresh is recommended** — but *after* the criteria are made executable, not before.
The foil's warning is well founded: refreshing first regenerates the same unverified prose
in better wording. Make each criterion a command that exits 0 or 1, then refresh.

- Rewrite the "one marketplace, one plugin" criterion to describe coherence in a
  multi-plugin marketplace. CLAUDE.md's existing Plugin Boundaries rule 7
  ("cross-plugin references stay descriptive-only") is a ready-made replacement.
- Decide whether the ~250-line CLAUDE.md ceiling is load-bearing. Either trim toward it
  or revise the number and say why it moved. A stale failing number on the books costs
  more than an honest larger one.
- Scope the mission's "and hooks" clause to what exists, or file a small item to ship one
  first-party hook so the sentence becomes true.
- Re-verify all five success criteria as a checklist at every refresh. This run shows the
  check is cheap and catches real drift — which is what issues #73 and #78 already propose
  to automate.

## Truncated personas

None. All five wrote complete reports ending with the `### Summary counts` marker on the
first attempt; no continuation was needed.
