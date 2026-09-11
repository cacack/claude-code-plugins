# Strategic Panel Synthesis — 2026-09-11 (run 2)

All five personas ran. This is the second `panel-product` run on this repository and the
first executed from the **shipped** `panels` 1.0.1 plugin rather than a hand-applied
workflow — see `snapshot.md` § Run provenance, including the comparability caveat that
forbids reading differences from run 1 as a clean A/B.

## Constitution under review

`CONSTITUTION.md` (87 lines, last refreshed 2026-09-11) declares a **personal** Claude
Code plugin marketplace whose mission is to scaffold the maintainer's development
workflows through small, specialized, file-externalizing skills. It names three
audiences — the maintainer (primary), developers treating the repo as a
reference implementation (secondary), and non-code Claude users reached through the
`principles` universal profile (tertiary) — and three explicit exclusions: beginners,
enterprise teams expecting support, and anyone wanting Anthropic-canonical patterns.
Five principles (specialization, skills-as-programs, external memory, iterate-over-
perfect, match-official-conventions), five non-goals, and five success criteria
(C1–C5) that became executable checks (`make constitution-check`) earlier the same day.

## Per-persona verdicts

| Persona | Verdict | Findings (C/H/M/L) |
|---------|---------|--------------------|
| Mission Steward | drifting | 0/1/1/2 |
| Market Strategist | unclear | 0/1/1/2 |
| Roadmap Reviewer | drifting | 0/1/1/2 |
| Audience Advocate | partially-served | 0/1/3/1 |
| Trust Auditor | mixed-signals | 0/2/2/1 |
| **Total** | — | **0/6/8/8** (22 findings) |

Four verdict scales across five personas, again — `drifting`/`aligned`, `unclear`,
`partially-served`, `mixed-signals`. Issue #76 is about exactly this, and run 2
reproduces the problem independently of run 1.

## Cross-cutting themes

Themes flagged by 2+ personas. **Five themes cross-flagged**, up from four in run 1.

### Theme 1 — The README is a catalog; the constitution's positioning never reaches it (5/5 personas)

Every persona arrived here independently, from five different angles:

| Persona | Finding | Severity |
|---|---|---|
| Mission | README carries none of the constitution's audience boundary | HIGH |
| Market | Stated differentiation vs `anthropics/claude-plugins-official` is invisible in README | HIGH |
| Trust | The constitution's honesty disclaimers never reach the README | HIGH |
| Market | Audience exclusions ("this is not for") not surfaced externally | MEDIUM |
| Audience | README gives the secondary audience no way to self-select before installing | MEDIUM |
| Roadmap | No ROADMAP.md and no README pointer to the constitution or milestones | MEDIUM |
| Market | No pointer from README to `CONSTITUTION.md` | LOW |

Three HIGHs from three personas on one root cause. The project has already done the
positioning work — it is simply filed in a document the README never links. The
maintainer's own global convention (`CLAUDE.md`: "User documentation entrypoint is
README.md") makes this the surface that matters.

### Theme 2 — #50 silently corrupts commits on the mandated daily-driver path (4/5 personas)

| Persona | Finding | Severity |
|---|---|---|
| Roadmap | The only `priority:high` issue is unscheduled while unprioritized work gets the commits | HIGH |
| Audience | The primary audience's daily-driver tool silently produces wrong commits | HIGH |
| Trust | Known high-priority bug, silent by design, unowned ~2 months, undisclosed anywhere | HIGH |
| Mission | Core workflow-scaffolding path carries an open correctness bug | LOW |

Three HIGHs again. Roadmap frames it as allocation, Audience as primary-user harm,
Trust as non-disclosure — three distinct failures from one defect. Run 1's foil made the
same argument and produced the "run-prompt concurrency safety" milestone; run 2 shows
the milestone alone did not settle it, because #50 still has no due date and no commits.

### Theme 3 — The README gives the reference-implementation audience no orientation beyond the skill list (3/5 personas)

| Persona | Finding | Severity |
|---|---|---|
| Audience | Design docs (`handyman-principle.md`, `design-guidelines.md`) buried at README line 110 | MEDIUM |
| Audience | No sample output — a reader must install and run a skill to see what it produces | MEDIUM |
| Roadmap | Roadmap is GitHub-native only; nothing in the repo text points to it | MEDIUM |
| Market | No statement of what this adds over the attributed upstream `taches-cc-resources` | LOW |

Distinct from Theme 1: that theme is about *scope and exclusions*, this one is about
*why the patterns look this way*. Audience notes the irony that this very run's output
is a committed, linkable example of `panel-product` and nothing references it.

### Theme 4 — `panels` v1.0.0 shipped unfit for purpose, on two independent counts (2/5 personas)

| Persona | Finding | Severity |
|---|---|---|
| Mission | `panel-product` shipped violating Principle 1 — five overlapping personas needing retrofitted "do not evaluate X" fencing | MEDIUM |
| Trust | Semver 1.0.0 was tagged for a skill that could not complete a run (fixed by `64644bd`, released as 1.0.1) | MEDIUM |

Two different defects in one release — a design-overlap problem and a broken declared
contract — converging on the same event. Mission tempers severity because remediation is
already scoped (#74, #77); Trust notes no version-scoped disclaimer existed for anyone
who installed in the window.

### Theme 5 — No CHANGELOG.md despite a disciplined per-plugin release process (2/5 personas)

| Persona | Finding | Severity |
|---|---|---|
| Trust | Five independently-versioned plugins, real tag history, no record of what changed | LOW |
| Audience | A reader who adopted an earlier pattern must reconstruct changes from `git log` | LOW |

Both LOW, both flagging the same gap between documented release ceremony (`CLAUDE.md`
§ Version Management) and the absence of any artifact recording what a bump contained.

## Alignment gaps

Ordered by severity, then cross-persona reach.

1. **The constitution's audience boundary and competitive position are absent from the README.** (HIGH ×3 — mission, market, trust; + medium/low from audience, roadmap, market.) Constitution: *Audience*, *Non-Goals*. The fix is one or two sentences plus a link, not a restatement.
2. **#50 — silent commit corruption on `/play → /do → /ship` — is the repo's only `priority:high` issue, is ~2 months old, has no due date, no recent commits, and is disclosed nowhere outside the issue tracker.** (HIGH ×3 — roadmap, audience, trust; LOW — mission.) Constitution: *Mission* ("scaffold the maintainer's development workflows").
3. **`panel-product` shipped at v1.0.0 violating the specialization principle it exists to enforce, and the tag implied a working surface it did not have.** (MEDIUM ×2 — mission, trust.) Constitution: *Principle 1*, *Principle 5*.
4. **Reference-implementation readers get a catalog with no design rationale, no sample output, and no roadmap pointer.** (MEDIUM ×3 — audience ×2, roadmap; LOW — market.) Constitution: *Audience* (secondary).
5. **No SECURITY.md for a public marketplace of shell-executing skills and dynamic `` !`command` `` context blocks.** (MEDIUM — trust.) Constitution: no section; the gap is that the repo tracks `security` as a label and filed #79 under it, but offers no disclosure channel.
6. **No CHANGELOG.md across five independently-versioned plugins.** (LOW ×2 — trust, audience.) Constitution: *Principle 5* (match official conventions).
7. **Two success criteria (C2, C4) have no tracking issue**, so a future `constitution-check` failure has nowhere to route. (LOW — roadmap.) Constitution: *Success Criteria*.
8. **#58 — DRY drift in the plugin serving the tertiary audience — sits unscheduled.** (LOW — mission.) Constitution: *Audience* (tertiary).

## Overall alignment

**The project is on-mission and drifting at its edges.** The last 30 commits are almost
entirely the kind of work the constitution describes, and the sequence that produced this
very review — ship `panel-product`, run it, find two success criteria false, make them
executable, refresh the constitution, re-run — is Principle 4 working exactly as written.
Non-goal discipline holds cleanly: Roadmap found no open work or commit driving toward any
of the five stated non-goals, and the refresh's new process-rigor disclaimer pre-empts the
one plausible drift reading.

The drift is concentrated in a single structural fact: **the constitution is doing work the
README should be doing.** Five of five personas found some version of it. Every honest thing
this project says about itself — who it is not for, that it does not compete with the
official marketplace, that it is not a supported product — is written down, well, in a file
no reader is pointed to. That is a five-line fix, and it is the highest-leverage item here.

The one place the project **contradicts itself** is #50. `CLAUDE.md` mandates the
`/play → /do → /ship` cycle for all work; the cycle's execution engine has a known,
silent, `priority:high` corruption bug that has been open since 2026-07-19 with no due
date and no commits — while nine unprioritized issues about a quarterly review tool
absorbed the day's entire commit output. Run 1's foil said this. The milestone created in
response documents it well but has not scheduled it. Saying a thing is the highest
priority and then not working it is the gap between stated and observed direction that
this panel exists to name.

## Constitution suggestions

Two, both surfaced by personas rather than invented here:

- **The Non-Goals closing paragraph is unfalsifiable.** "Process rigor here … is not a
  support commitment, and should not be read as the project drifting toward one" is a
  reasonable claim that no criterion in C1–C5 could ever contradict — and it sits in
  exactly the area (29-label vocabulary, formal issue templates, CI validation) where it
  could quietly stop being true. Either mark it a judgement call as C1 honestly does, or
  give it a cheap check (no SUPPORT.md, no SLA language, no response-time labels).
  *(Mission Steward, Constitution health.)*
- **The constitution has no section covering market positioning**, which is why the
  Market Strategist scores against *Non-Goals* and *Audience* rather than a rubric of its
  own. Market flagged this itself. It is the substance of #78 and the premise of #72 —
  see the note below, because run 2 bears on #72 directly.

Recommend `/panels:constitution` at the next refresh rather than now; the document was
refreshed hours ago and the suggestions above are additive, not corrective.

## Post-hoc addendum — what the panel missed

*Added after the personas and the foil completed, during run verification. Left here rather
than folded into the sections above, so the record shows what the panel produced on its own.*

`make constitution-check` **fails on `main`.** C2 reports four breaches (commits `06817b9`,
`0d2504e`, `e0dcfb4`, all predating both runs, all against the pre-split `plugins/cacack/`
layout). The failure is pre-existing and unrelated to this run.

No persona ran the command. The Roadmap Reviewer inferred from commit subjects that "two
success criteria (C3, C5) show direct commit evidence of active enforcement; two (C2, C4)
have no tracking issue" — and C2 was failing the whole time. Twenty-two prose findings, and
the one falsifiable failure in the rubric went unnoticed, on the day that rubric was rewritten
to be executable.

Read against the foil's central charge, this sharpens it. The foil argued the panel
re-derives its own prior conclusions and calls the recurrence signal. The stronger version:
the panel did not check the one thing that could have contradicted it. See
`proposed-issues.md` draft 10.

## Truncated personas

None. All five wrote complete reports terminating in `### Summary counts`; no
continuation was required.
