# Proposed Issues — 2026-09-11

Drafted from `synthesis.md` and `foil.md`. **Not filed** — issue #71 scopes this run to
producing evidence, not acting on it. Labels are drawn only from the repository's own
vocabulary as captured in `snapshot.md`; none are invented.

Drafting rule applied: every CRITICAL/HIGH finding, every cross-flagged MEDIUM, and every
unanswered foil Hostile-Q&A item or pre-mortem cause-of-death not already covered.

---

## 1. Make the constitution's five success criteria executable

**Severity:** high  **Persona(s):** mission, trust, roadmap + rude-qa (foil)  **Labels:** documentation, type:task, class:planned, value:high, effort:low
**Constitution section:** Success Criteria (all five); Principle 2, "skills as programs — verifiable output"
**Possibly already tracked:** #78 — Push panels:constitution toward mechanically checkable success criteria. *Related but distinct:* #78 changes how the **skill** emits criteria for any repo; this draft fixes **this repository's own** five criteria. #78 is the general fix, this is the worked example that proves it.

Two of the five success criteria are false right now, and the git history shows why: the
"~250 line" criterion was already false on the day the constitution was authored
(`CLAUDE.md` hit 264 lines on 2026-03-29 in `e16515d`; `CONSTITUTION.md` was written
2026-05-16 in `a793e19`), and the file has exactly one commit in its history. Nothing was
ever verified because nothing was mechanically verifiable.

Rewrite each criterion as a command that exits 0 or 1 — a `make constitution-check`
target or a script. Any criterion that cannot be expressed as a command gets rewritten
until it can, or deleted. Surfaced by: rude-qa (foil), as the single highest-leverage
next move. Do this **before** any `/panels:constitution --refresh`, or the refresh
regenerates unverified prose in better wording.

---

## 2. Bring CLAUDE.md under its stated ceiling, or revise the ceiling

**Severity:** high  **Persona(s):** mission, trust, roadmap  **Labels:** documentation, type:task, class:planned, value:medium, effort:low
**Constitution section:** Success Criteria — "The repo's CLAUDE.md stays under ~250 lines (context-scarcity discipline)"
**Possibly already tracked:** none

`CLAUDE.md` is 297 lines, ~19% over. Verified independently by two personas and the
orchestrator. Either trim toward 250 — the Hooks event-type enumeration and the
frontmatter reference tables are the obvious candidates to move into
`plugins/authoring/docs/` — or revise the number and record why it moved. A stale failing
number on the books costs more than an honest larger one. Cross-flagged by three
personas, the widest reach in this run.

---

## 3. State the relationship to `anthropics/claude-plugins-official` in the README

**Severity:** high  **Persona(s):** market, audience  **Labels:** documentation, type:task, class:planned, value:medium, effort:low
**Constitution section:** Audience ("not for anyone who needs Anthropic-blessed canonical patterns"); Non-Goals ("Compete with or replace `anthropics/claude-plugins-official`")
**Possibly already tracked:** none

The constitution treats this boundary as defining. The README never mentions the official
marketplace and never links to `CONSTITUTION.md`, so the stated secondary audience —
developers reading this as a reference implementation — has no path to the most
position-defining content in the repo. One short section plus a link to the constitution
closes it.

---

## 4. Flag `panel-product`'s status in the README until the rework milestone closes

**Severity:** high  **Persona(s):** trust, mission, audience  **Labels:** documentation, type:task, class:planned, value:medium, effort:low
**Constitution section:** Success Criteria ("skills get invoked by the maintainer with reasonable frequency"); Audience (secondary)
**Possibly already tracked:** milestone 1 documents the gap but no issue fixes the README

The README lists `panel-product` identically to every skill that works. Until PR #80
landed, a run would have died at the issue-filing step, and anyone who installed `panels`
1.0.0 had no way to distinguish a broken release from their own mistake. Add a one-line
status note next to the entry, removable when milestone 1 closes.

---

## 5. Add a CHANGELOG so version bumps carry a release trail

**Severity:** medium (cross-flagged)  **Persona(s):** trust, audience  **Labels:** documentation, type:story, class:planned, value:medium, effort:medium
**Constitution section:** Principle 5, "match official conventions where they exist"; Audience (secondary)
**Possibly already tracked:** none

CLAUDE.md documents per-plugin semver, per-plugin tags, and CI that enforces version
bumps. There is no `CHANGELOG.md`. A consumer moving `panels` 1.0.0 → 1.0.1 has no
artifact saying what changed — which is precisely what made draft 4's gap invisible from
outside. Per-plugin sections in one root file would fit the existing tagging discipline.

---

## 6. Decide the capacity split between the panel-product milestone and open bugs

**Severity:** medium  **Persona(s):** roadmap + rude-qa (foil)  **Labels:** type:task, class:unplanned, value:high, effort:low
**Constitution section:** Success Criteria ("skills get invoked with reasonable frequency"); Principle 4
**Possibly already tracked:** #50 — Parallel committing prompts race on the shared git index in run-prompt. *This draft is the triage decision about #50, not a duplicate of it.*

All nine milestoned issues rework a tool with zero invocations to date, quarterly at best.
`#50` is a silent commit-corruption bug in `run-prompt` — the execution engine behind
`/play`, `/do`, and `deliver-milestone`, the path CLAUDE.md mandates for all work. It is
labelled `priority:high`/`value:high`, has sat since 2026-07-19 with no comments, and
carries no milestone. Capacity is currently allocated in inverse proportion to invocation
frequency. Either milestone #50 into the next slot or record why it waits.
Surfaced by: rude-qa (foil), Hostile Q&A 2 — which it marked as having no defense.

---

## 7. Run a via-negativa pass over the collection

**Severity:** medium  **Persona(s):** rude-qa (foil) only — pre-mortem cause-of-death 3  **Labels:** type:spike, class:planned, value:medium, effort:low
**Constitution section:** Principle 1 (specialization); Principle 4 (iterate over perfecting)
**Possibly already tracked:** none

46 skills, 26 agents, one maintainer. The foil's third pre-mortem is that carrying cost
overtakes the evenings available, and its Hostile Q&A 6 — "what did you delete last
quarter?" — went unanswered. `toolbox:consider` ships a via-negativa frame; point it at
the collection and answer the question before the next panel. Timebox it; the artifact is
a list of what goes.

---

## Triage actions arising from this run (not new issues)

The foil argued that a run which settles none of the milestone's pre-written issues was
ceremony rather than evidence. Against that test, this run says:

| Issue | This run's verdict |
|---|---|
| #71 (run it once) | **Not yet satisfied.** The run was produced by a 1.0.0 cache with 1.0.1 behavior applied by hand, so it did not exercise the shipped artifact. Re-run on a clean installed 1.0.1 before closing. |
| #72 (drop `product-market`) | **Refuted, or at least not confirmed.** Market returned a HIGH that no other persona raised — the official-marketplace boundary, draft 3 above. The persona earned its slot on this repo. Reconsider before acting. |
| #73 (scorecard) | **Confirmed and promoted.** Both false criteria are exactly what a pre-spawn scorecard catches mechanically. |
| #78 (checkable criteria upstream) | **Confirmed and promoted to root cause.** Currently `value:medium`/`effort:low`; the evidence says it is the milestone's most important issue. |
| #74, #76, #77 | **Untouched.** The run produced no evidence for or against. #76 (one verdict vocabulary) is mildly supported: the synthesis table carries four different scales. |

## Below the drafting threshold

Recorded so nothing is silently dropped. Single-persona MEDIUMs and LOWs that did not
meet the drafting rule, but that are mechanically verified:

- **Install command disagrees** between `README.md:9` (`claude plugin marketplace add cacack/claude-code-plugins`) and `CLAUDE.md:268` (`/plugin marketplace add https://github.com/...`) — audience (MEDIUM). Folds naturally into draft 3's README pass.
- **Mission claims the marketplace houses hooks; zero exist** (`find plugins -type d -iname hooks` returns nothing) — mission (MEDIUM). Folds into draft 1's constitution work.
- **No stated differentiation from upstream `taches-cc-resources`** — market (MEDIUM). Folds into draft 3.
- **No SECURITY.md** while shipping security-review tooling — trust (LOW).
- **No ROADMAP.md or README pointer to milestones** — roadmap (LOW).
- **"Reference implementation" claim thin on worked examples** (25 of 58 SKILL.md files mention an example; none uses an `## Example` heading) — audience (LOW).
- **Process infrastructure trending toward "supported project" shape** — mission (LOW), flagged to re-affirm at the next constitution refresh.
