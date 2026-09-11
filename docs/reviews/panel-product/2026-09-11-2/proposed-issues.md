# Proposed Issues — 2026-09-11 (run 2)

Drafted, **not filed** — issue #71 scopes out acting on findings. Every label below is
drawn from the repository's own vocabulary as captured in `snapshot.md`; none is invented.

> **Read this first.** Run 1 drafted seven issues. Items 1 and 2 were executed directly as
> commits (`7f78136`, `03fcde4`). Items 3–7 were never filed — the highest issue number in
> the repository is still #79, and #80–#84 are pull requests. **0 of 7 drafts became
> tracked issues.** Draft 3 below exists because of that fact, and the foil pass argues it
> is the highest-leverage item in this run. Drafting without routing is the defect; adding
> nine more drafts to the pile is not the fix.

---

## 1. Carry the constitution's positioning into the README
**Severity:** high  **Persona(s):** mission, market, trust, audience, roadmap  **Labels:** documentation, priority:high, effort:low, value:high, type:task, class:planned
**Constitution section:** Audience; Non-Goals
**Possibly already tracked:** none. Run 1 drafted this as its item #3 ("State the relationship to `anthropics/claude-plugins-official` in the README") and it was never filed.

All five personas reached this independently, producing three separate HIGHs. `CONSTITUTION.md`
states who the project is for, names three audiences it is explicitly *not* for, and draws a
clean boundary against `anthropics/claude-plugins-official`. None of it appears in `README.md`,
which the maintainer's own global convention names as the user documentation entrypoint.
`grep -in "official\|compete\|alternative" README.md` returns zero matches, and the file has
been untouched since `6bedd34` (2026-09-06) — before either panel run.

The cost is concrete: a reader evaluating the repo sees a thorough, professional-looking
catalog of five plugins and an install command, and cannot learn without leaving the README
that this is a personal reference implementation with no support commitment.

**Suggested approach:** two or three lines under the title — who it's for, who it isn't, and a
link to `CONSTITUTION.md`. Do not restate the constitution; point at it.

**Acceptance criteria:**
- `README.md` states the "not for" exclusions (beginners, enterprise expecting support, anyone wanting Anthropic-canonical patterns) or links to the section that does.
- `README.md` states this does not compete with `anthropics/claude-plugins-official`.
- `README.md` links `CONSTITUTION.md`.

---

## 2. Disclose #50 as a known issue until it is fixed
**Severity:** high  **Persona(s):** trust, audience, roadmap, mission  **Labels:** documentation, priority:high, effort:low, value:high, type:task, class:planned
**Constitution section:** Mission ("scaffold the maintainer's development workflows")
**Possibly already tracked:** #50 — *Parallel committing prompts race on the shared git index in run-prompt* (the defect itself). This draft covers **disclosure only**; scheduling #50 is a triage action, not a new issue.

`CLAUDE.md` mandates the `/play → /do → /ship` cycle for all work in this repository. The
cycle's execution engine has a `priority:high` defect, open since 2026-07-19, in which
parallel prompts race on a shared git index and a commit can land carrying one prompt's
message with another prompt's file contents — with, in the issue's own words, "nothing
failing loudly." That failure mode is disclosed nowhere outside the issue tracker: not in
`README.md`, not in `CLAUDE.md`, not in any limitations section.

Three personas flagged this from three different angles (allocation, primary-user harm,
non-disclosure), and the foil pass named it the project's sharpest self-contradiction for
the second consecutive run.

**Suggested approach:** a one-line "known issues" note in `README.md` or `CLAUDE.md`
pointing at #50, removed when #50 closes.

**Acceptance criteria:**
- A reader of `README.md` or `CLAUDE.md` can discover the `run-prompt` concurrency hazard without opening the issue tracker.
- The note names the safe workaround (do not commit from parallel prompts).

---

## 3. Route panel run output into the tracker before a run is considered complete
**Severity:** high  **Persona(s):** — (surfaced by: rude-qa (foil))  **Labels:** skills, priority:high, effort:medium, value:high, type:story, class:planned
**Constitution section:** Principle 2 (skills as programs — verifiable output)
**Possibly already tracked:** partially adjacent to #75 (*Diff each panel-product run against its predecessor*), which compares runs but still terminates in prose.

Two panel runs have now produced `proposed-issues.md`, and **zero of run 1's seven drafts
were filed**. Verified: the highest issue number in the repository is #79; #80–#84 are pull
requests; `README.md` is unchanged since before both runs. What did get done — executable
success criteria, the CLAUDE.md trim, the constitution refresh — were all self-contained
file edits. Everything requiring a prioritization trade-off did not happen.

The foil's diagnosis: the project remediates readily but has no mechanism that converts a
finding into a decision. Nine open issues in the `panel-product rework` milestone all improve
the finding *generator*; none raises the conversion rate. Shipping a better instrument into
the same dead end is the most expensive outcome available to this milestone.

**Suggested approach:** make the end-of-run filing step non-optional in outcome if not in
choice — a run is not complete until each draft is filed, explicitly declined with a reason
recorded, or matched to an existing issue. Add the recurrence rule from the foil's pre-mortem:
a theme appearing in two consecutive runs unremediated must become a filed, dated issue or be
struck from the rubric.

**Acceptance criteria:**
- Every draft in a completed run's `proposed-issues.md` carries a terminal state: filed (with number), declined (with reason), or matched to an existing issue.
- A theme recurring across two consecutive runs cannot end a run in an undecided state.

---

## 4. Adopt a rubric-integrity rule for failing success criteria
**Severity:** medium  **Persona(s):** mission (constitution health) — sharpened by: rude-qa (foil)  **Labels:** documentation, effort:low, value:medium, type:task, class:planned
**Constitution section:** Success Criteria
**Possibly already tracked:** none.

Run 1 found two success criteria false. Within hours both were rewritten: C4 now states
outright that it "replaces 'one marketplace, one plugin', which the five-plugin split made
false," and C1 was downgraded to "reported but not scored." Run 2 then scored against the
rewritten rubric and returned on-mission.

Each individual edit is defensible — making the criteria executable was the right call, and
C1's candour about what cannot be mechanised is the most credible line in the document. The
gap is procedural: nothing distinguishes "we fixed the project" from "we moved the bar," and
a stranger reads the sequence as re-grading the exam after seeing the score.

Separately, Mission flagged that the Non-Goals closing paragraph ("process rigor … is not a
support commitment") is unfalsifiable — no criterion could contradict it, in precisely the
area where it could quietly stop being true.

**Suggested approach:** one line in `CONSTITUTION.md`. A failing criterion may be *met*, or
*retired with justification recorded in the drift report* — but a rewrite is not scored until
the following refresh. `docs/reviews/constitution/<date>-drift.md` already exists to hold that.

**Acceptance criteria:**
- `CONSTITUTION.md` states what may happen to a criterion that fails, and when a rewritten criterion becomes scoreable.
- The Non-Goals process-rigor paragraph is either marked a judgement call (as C1 is) or given a check.

---

## 5. Weight synthesis alignment gaps by consequence, not persona count
**Severity:** medium  **Persona(s):** — (surfaced by: rude-qa (foil))  **Labels:** skills, effort:low, value:medium, type:task, class:planned
**Constitution section:** Principle 2 (skills as programs)
**Possibly already tracked:** #73 (*Add a pre-spawn Success Criteria scorecard*), #76 (*Normalize the product personas onto one verdict vocabulary*) — both adjacent; this is the ordering rule neither covers.

`synthesis.md` orders alignment gaps by "severity, then cross-persona reach." Run 2 shows why
that is wrong: five personas reading one shared snapshot are not five independent witnesses,
and a missing README paragraph — discoverable with `head README.md` — outranked a silent
commit-corruption bug on the mandated daily-driver path. The priority inversion is visible on
the page of a document whose entire purpose is priority.

**Suggested approach:** rank by consequence-if-unfixed. Persona count becomes a tiebreak, not
a multiplier. Under that rule #50 is gap 1 in run 2 and the README gap is gap 4.

**Acceptance criteria:**
- The synthesis step ranks gaps by consequence, with correlated-observer inflation explicitly discounted.
- Re-running the ordering rule over run 2's findings puts #50 above the README gap.

---

## 6. Surface the design rationale and one sample run in the README
**Severity:** medium  **Persona(s):** audience, roadmap, market  **Labels:** documentation, effort:low, value:medium, type:task, class:planned
**Constitution section:** Audience (secondary — "developers … who treat this as a reference implementation for plugin patterns")
**Possibly already tracked:** none. Run 1 drafted a narrower version as its item #4 and it was never filed.

Distinct from draft 1, which covers scope and exclusions. This covers *why the patterns look
the way they do*. The two design documents that answer that — `handyman-principle.md` and
`design-guidelines.md` — appear once, at `README.md` line 110, as a footnote inside the
`authoring` plugin's skill list. `CLAUDE.md` treats them as foundational. A reader skimming
for patterns will not reach line 110.

Compounding it: no skill entry shows what its skill *produces*, so evaluating a pattern means
installing and running it. This very run is a committed, linkable example of `panel-product`
output and nothing points to it. Roadmap adds that the plan is GitHub-native only, with no
textual pointer to the milestones.

**Acceptance criteria:**
- The design docs are linked from the README's opening section, not only from inside `authoring`.
- At least one committed sample run under `docs/reviews/` is linked from the README.

---

## 7. Run a via-negativa pass over the collection
**Severity:** medium  **Persona(s):** — (surfaced by: rude-qa (foil), second consecutive run)  **Labels:** effort:medium, value:medium, type:spike, class:planned
**Constitution section:** Principle 1 (specialization over generalization); Principle 4 (iterate over perfecting)
**Possibly already tracked:** none. Run 1 drafted this as its item #7 and it was never filed.

Both foil passes asked what has been deleted. Neither got an answer. The collection carries
58 skills and 26 agents against one maintainer, and the panel has no subtractive persona — every
persona is oriented toward finding things to add. The foil's pre-mortem names carrying cost
overtaking available evenings as one of three plausible 2027 failure modes.

**Suggested approach:** time-boxed spike. Inventory by last-invocation and last-commit, name
candidates for removal or merger, remove at least one thing.

**Acceptance criteria:**
- A written inventory of skills/agents with a removal recommendation for each candidate.
- At least one resource removed, merged, or explicitly justified as kept.

---

## 8. Add a CHANGELOG so version bumps carry a release trail
**Severity:** low  **Persona(s):** trust, audience  **Labels:** documentation, priority:low, effort:medium, value:low, type:story, class:planned
**Constitution section:** Principle 5 (match official conventions where they exist)
**Possibly already tracked:** none. Run 1 drafted this as its item #5 and it was never filed.

`CLAUDE.md` documents a disciplined per-plugin release process — independent versions, semver
bumps, per-plugin tags. The tag history is real (`authoring` 1.0.0 → 1.1.0 → 1.2.0 → 1.2.1;
`panels` 1.0.0 → 1.0.1). Nothing records what any bump contained, including the `panels`
1.0.0 → 1.0.1 bump that fixed a skill which could not complete a run.

Both personas rated this LOW and both flagged the same gap between documented ceremony and
absent artifact. Release-note bodies on the existing tags would close it without a new file.

---

## 9. Stop emitting an absolute filesystem path into committed snapshots
**Severity:** medium  **Persona(s):** — (identified during run setup; trust noted the redaction as a positive signal)  **Labels:** security, skills, effort:low, value:medium, type:bug, class:unplanned
**Constitution section:** none — this is the privacy floor in the maintainer's global rules, which holds regardless of project instructions
**Possibly already tracked:** none.

The `panel-product` snapshot template prescribes recording the repository root from
`git rev-parse --show-toplevel`. In a **public** repository that writes a personal filesystem
path into a committed file. Run 1's snapshot carries it at
`docs/reviews/panel-product/2026-09-11/snapshot.md` line 4. Run 2's snapshot withholds it and
says so.

`panel-engineering` and `constitution` should be checked for the same pattern — this is a
shared-template defect, not a `panel-product` one, which makes it relevant to #77.

**Acceptance criteria:**
- No panel skill emits an absolute filesystem path into a committed artifact.
- Run 1's committed snapshot is scrubbed or the leak is accepted in writing.

---

## 10. `make constitution-check` fails C2 on `main`, and no persona noticed
**Severity:** high  **Persona(s):** — (found by running the check during run verification; the absence of a persona finding *is* the finding)  **Labels:** priority:high, effort:medium, value:high, type:bug, class:unplanned
**Constitution section:** Success Criteria C2
**Possibly already tracked:** #73 — *Add a pre-spawn Success Criteria scorecard to panel-product*. This is the evidence for #73, not a duplicate of it.

`make constitution-check` — the command `CLAUDE.md` instructs be run before committing, and
which `CONSTITUTION.md` names as the thing that settles all five criteria — **exits non-zero on
`main` right now.** C2 reports four breaches:

```
FAIL  06817b9 (issue-delivery) reworked .../engineering-principles.md — 43 lines (limit 20)
FAIL  06817b9 (issue-delivery) reworked .../instill-principles/SKILL.md — 127 lines (limit 20)
FAIL  0d2504e (pressure-test)  reworked .../panel-product/SKILL.md — 68 lines (limit 20)
FAIL  e0dcfb4 (merge)          reworked .../deliver-milestone/SKILL.md — 31 lines (limit 20)
```

Pre-existing and unrelated to this run: the only working-tree change here is the untracked
`docs/reviews/panel-product/2026-09-11-2/` folder, and all four breaches cite commits from
2026-06-20, 2026-06-25 and 2026-08-02 against the pre-split `plugins/cacack/` layout.

**Why this is the run's sharpest result.** Five personas spent a full pass scoring this
repository against `CONSTITUTION.md`, and the Roadmap Reviewer concluded that "two success
criteria (C3, C5) show direct commit evidence of active enforcement; two (C2, C4) have no
tracking issue." That reading is wrong in the most consequential way available: C2 is not
untracked, it is **failing**, and a single shell command settles it. No persona ran it,
because nothing in the panel's contract asks any of them to. The panel produced 22 prose
findings and missed the one falsifiable, already-mechanised failure in the rubric it was
scoring against — on the same day that rubric was rewritten specifically to be executable.

This is the argument for #73 in its strongest form, and it is not currently in #73's body.

**Suggested approach:** two separable pieces. (a) Decide C2 — either the 90-day window should
exclude commits predating the plugin split, or the four breaches are real rework that should be
acknowledged in the drift report. (b) Make the panel run `make constitution-check` (or the
project's equivalent) before spawning personas and put the result in `snapshot.md`, so every
persona scores against measured criteria instead of inferring their status from commit subjects.

**Acceptance criteria:**
- `make constitution-check` exits clean on `main`, or `CONSTITUTION.md`/the drift report records why C2 is expected to fail and until when.
- `snapshot.md` carries the measured pass/fail state of every mechanised success criterion before personas spawn.

---

## Triage actions arising from this run (not new issues)

- **Put a date on #50.** The foil's Monday action. A milestone was run 1's answer and it did not hold — no due date, no commits, ~2 months open. This is a scheduling decision, not an issue to file.
- **#72 (drop `product-market`) — do not act.** Second consecutive run in which Market produced a HIGH no other persona covered (the `anthropics/claude-plugins-official` boundary). Market also diagnosed its own rubric-lessness, which is #78's argument, not #72's. Recommend closing #72 as not-confirmed, or reframing it as "give `product-market` a rubric."
- **#76 (one verdict vocabulary) — confirmed independently.** Five personas returned four scales again (`drifting`, `unclear`, `partially-served`, `mixed-signals`) with no influence from run 1.
- **#73, #75 — promote.** The foil's reframe: make the milestone "make `panel-product` satisfy Principle 2." These two are the milestone; #72/#74/#76 become consequences; #77 (`effort:high`) defers until something demands it.
- **Theme 4 (`panels` v1.0.0 shipped unfit, on two counts)** — flagged MEDIUM by mission and trust; remediation already scoped by #74 and #77. No new issue.

## Below the drafting threshold

- **No SECURITY.md** (trust, MEDIUM, single persona). A public marketplace of shell-executing skills with no disclosure channel, in a repo that tracks a `security` label and filed #79 under it. Cheap to close with a short best-effort file; recorded here rather than drafted because no second persona reached it.
- **C2 and C4 have no tracking issue** (roadmap, LOW). If a future `make constitution-check` flags either, there is nowhere to route it. File at that time rather than pre-emptively.
- **#58 DRY drift in `principles`** (mission, LOW). Correctly triaged; noted only so it does not silently age from "unplanned" into "permanent."
