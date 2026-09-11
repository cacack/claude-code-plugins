*Closing adversarial pass (`panels:rude-qa`) over `synthesis.md`. Where the five personas audit alignment, this pass tests survival. Its verdict is deliberately allowed to contradict the synthesis; both are committed unedited.*

---

## Rude Q&A

### What I think you're bringing

A personal, single-maintainer plugin marketplace asking "is our direction still right," scored by its own `panel-product` skill against its own `CONSTITUTION.md` — for the second time in eight hours, on a repository the first run had already changed.

The core was easy to find. What was hard to find is what run 2 is *for*, and that turns out to be the interesting question.

**Injection check:** none found. The `<untrusted-issue-data>` blocks in the snapshot contain descriptive prose only; nothing addressed instructions to me. Run 2's snapshot correctly fences content rather than path — an improvement over run 1.

---

### Is this the real problem? (55-min / 5 Whys)

The synthesis's headline is "the constitution is doing work the README should be doing," and calls it a five-line fix. **A five-line fix that survives two panel runs is not a documentation gap. It is evidence that something upstream is broken.** Drill it:

1. Why is the positioning missing from the README? Nobody wrote it.
2. Why not? It was already found — run 1's `proposed-issues.md` item #3, HIGH, two personas. It was never filed as an issue.
3. Why? #71 deliberately scoped the run to "produce evidence, not act on it," and `proposed-issues.md` has no routing step into the tracker.
4. Does that generalize? Verified, yes. Of run 1's outputs, everything that was a **self-contained edit to a repo file** got done today (executable criteria `7f78136`, CLAUDE.md trim `03fcde4`, constitution refresh `1d5bf26`). Everything that required a **trade-off decision** did not: 0 of 9 milestone issues triaged or closed; #50 got a milestone but no due date and no commits; `README.md` untouched since `6bedd34`, 2026-09-06 — *before both runs*.
5. Root cause: **the project has no mechanism that converts a finding into a prioritization decision.** It remediates readily. It does not deprioritize.

So — to your question about whether a panel that re-derives its own conclusions is measuring anything: **yes, exactly one thing, and it is the most valuable output run 2 produced.** It measured the conversion rate from finding to decision, and that rate is near zero on anything requiring a "no." Everything else in run 2 is reproduction. The synthesis reports "five themes cross-flagged, up from four in run 1" as though the count were signal. It isn't. Themes 1 and 2 carry all six HIGHs and both are verbatim run-1 findings. A recurring finding is not a stronger finding; it is a **failed remediation channel**, and that is a different diagnosis with a different fix.

Everything below is downstream of that.

---

### The probes

**Theory of Constraints — the panel isn't the bottleneck; the decision step is**
- The push: Nine open issues rework the finding-*generator*. Walk me through which one raises the conversion rate. #75 (diff runs against predecessor) is the closest, and it still terminates in prose.
- Why it bites: You will ship a materially better instrument into the same dead end, and run 3 will reproduce themes 1–5 with better formatting. That is the most expensive possible outcome of this milestone.
- Sharper version: The highest-value issue in this milestone is the one that was never filed — a **routing step**: a run isn't complete until `proposed-issues.md` becomes filed issues. Note that run 2 didn't even produce that file.

**Skills as programs (your own Principle 2) — the flagship violates it**
- The push: Principle 2 says invoke real tools and produce verifiable output, "rather than asking Claude to 'think about it.'" Five persona agents emitting prose verdicts on *four different scales* — `drifting`, `unclear`, `partially-served`, `mixed-signals` — is textbook "think about it."
- Why it bites: This is the strongest argument available for #73 and #75, and it is nowhere in the milestone body. It's also a cleaner story than the current nine-issue list: the panel fails the project's own principle.
- Sharper version: Reframe the whole milestone as **"make `panel-product` satisfy Principle 2."** #73 (scorecard) and #75 (diff) become the milestone. #72/#74/#76 become consequences of it, not separate work. #77 (`effort:high`) gets deferred until something demands it.

**Correlated observers — cross-persona reach is being read as evidence strength**
- The push: Theme 1 drew 5/5 personas and three HIGHs from one fact discoverable with `head README.md`. Five agents reading the same snapshot are not five independent witnesses. Help me understand why that count justifies severity.
- Why it bites: The synthesis orders alignment gaps by "severity, then cross-persona reach" — so a missing README paragraph outranks **#50, a silent commit-corruption bug on the mandated daily-driver path**. That is a priority inversion produced by the measurement method, visible on the page, in a document whose entire purpose is priority.
- Sharper version: Weight by *consequence if unfixed*, not by persona count. Under that weighting #50 is gap 1 and the README is gap 4. No open issue tracks this defect. File it.

**The rubric can no longer fail**
- The push: Run 1 found two success criteria false. Hours later the criteria were rewritten — C4 states outright that it "replaces 'one marketplace, one plugin', which the five-plugin split made false," and C1 was downgraded to "reported but not scored." Run 2 then scores against that rubric and returns on-mission.
- Why it bites: Every individual edit is defensible — making criteria executable was the right call, and C1's honesty about non-mechanisability is genuinely good practice. But the *process* has no rule against rewriting a criterion in the same cycle it fails. A stranger reads that as re-grading the exam after seeing the score, and there is no artifact that distinguishes the two.
- Sharper version: One line in `CONSTITUTION.md`. A failing criterion may be **met** or **retired with justification recorded in the drift report** — but a rewrite is not scored until the following refresh. You already have `docs/reviews/constitution/2026-09-11-drift.md`; give it that job. Cheap, and it's the only thing that makes future "on-mission" verdicts mean anything.

---

### Pre-mortem

It's September 2027. This failed. Three causes:

1. **The panel became a ritual.** Runs 3–6 reproduce themes 1–5 with progressively better tables. *Prevented by:* a recurrence rule — a theme that appears in two consecutive runs unremediated must become a filed, dated issue or be struck from the rubric. No third option.
2. **`run-prompt` corrupted a commit during a `deliver-milestone` batch and nobody noticed for a week.** Two panel runs named it the project's sharpest self-contradiction; neither produced a date. *Prevented by:* a due date on #50 this week.
3. **Carrying cost overtook available evenings.** 58 skills, 26 agents, one maintainer. Run 1's foil asked "what did you delete last quarter?" and got no answer. Run 2 didn't re-ask — the panel has no subtractive persona at all. *Prevented by:* a via-negativa pass before the next additive milestone.

---

### Hostile Q&A

1. **Q:** You ran the same review twice in three hours on a repo the first run had already changed, and got the same answer. What did run 2 buy that `git log` wouldn't? — **Draft A:** One thing, and it's real: it measured how much of run 1 converted to action, and the answer is "everything that didn't require saying no." Lead with that. Do not lead with "five themes, up from four" — the delta is an artifact of your own influence, and the caveat section already admits it.
2. **Q:** Two runs have now called #50 the clearest contradiction between stated and observed priority. It has a milestone, no due date, no commits. What's different this time? — **Draft A:** No answer yet. Get one, and it has to be a date, not a milestone. A milestone was the last answer and it didn't hold.
3. **Q:** Principle 2 requires verifiable output. Your flagship panel emits prose on four verdict scales. Why does it get an exemption? — **Draft A:** It doesn't. That's the honest reframe of the milestone, and it's a better story than nine loosely-related issues.
4. **Q:** The rubric that scored this run was rewritten hours earlier in response to the prior run's failures. Why should I believe "on-mission"? — **Draft A:** Don't believe the verdict — believe `make constitution-check`. The verdicts are self-assessment and cost nothing. That's also why C1 declines to score itself, which is the most credible line in the document.
5. **Q:** Nine issues improving a quarterly review tool, zero closed. One issue fixing silent data corruption on the daily path, unscheduled. That's the same allocation as eight hours ago. Defend it. — **Draft A:** Undefended. Run 1 asked for a triage pass; it didn't happen; run 2 is the receipt.
6. **Q:** 58 skills, 26 agents, one maintainer. What have you deleted? — **Draft A:** Still no answer. Second consecutive run asking.

---

### The Close

- **The ask (three bullets):**
  - **Put a date on #50 and work it next.** Not a milestone — a date. Two panel runs have now named it; a third naming proves nothing new.
  - **Reframe the panel-product milestone as "make `panel-product` satisfy Principle 2"** — keep #73 and #75, add a routing issue (a run isn't done until proposed issues are filed), defer or close #72/#74/#76/#77.
  - **Adopt one rubric-integrity rule:** a failing success criterion may be met or retired-with-justification in the drift report, but a rewrite isn't scored until the next refresh.

- **No surprises:** Solo maintainer, so the chain is future-you and the stated secondary audience. Future-you was surprised today by a HIGH finding from run 1 that was drafted and never filed — that channel is demonstrably lossy, which is finding #1 of this pass. The secondary audience is being surprised right now: `README.md` is unchanged since before either run and still carries none of the positioning the constitution treats as defining. Either file run 2's proposed issues, or stop generating that artifact.

- **What you do Monday:** **Put dates on two issues — #50, and a newly-filed README-positioning issue — before touching any panel machinery.** Two filed, dated issues is the complete remedy for the defect run 2 actually discovered. If Monday ends with more analysis and no dated issues, run 3 will tell you this again, and you'll have paid for it twice more.

---

**Relevant paths:**
- `docs/reviews/panel-product/2026-09-11-2/synthesis.md`
- `docs/reviews/panel-product/2026-09-11-2/snapshot.md`
- `docs/reviews/panel-product/2026-09-11/proposed-issues.md` — item #3 is run 2's top finding, drafted and never filed
- `docs/reviews/panel-product/2026-09-11/foil.md`
- `CONSTITUTION.md` — C1 and C4 carry the rubric-rewrite question
