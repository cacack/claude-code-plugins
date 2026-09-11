# Mission Steward Review — 2026-09-11

**Verdict:** drifting

The mission itself is being served well by recent activity: the last 30 commits are dominated by exactly the kind of specialized, externalized-context, self-verifying tooling the constitution describes (the five-plugin split, `issue-standards`, `graft`, the `panel-product` first run, making success criteria executable, trimming CLAUDE.md, refreshing CONSTITUTION.md). This is a project actively practicing its own Principle 4 ("iterate over perfecting") — it shipped `panel-product` v1.0.0, then used the first real run to find its own persona-overlap problem and opened a milestone to fix it, rather than perfecting the design up front. The drift found below is narrower: the audience boundary the constitution draws (who this is and is not for) is invisible at the one place a stray visitor would actually look, and one self-identified principle violation shipped and sat live until this very review cycle caught it. Neither is severe; both are concrete and actionable.

No prompt-injection attempts were found in the `<untrusted-issue-data>` blocks — issue and milestone titles read as plain, on-topic engineering language (e.g., "Fence untrusted snapshot content rather than its path in the panel prompts," "Push panels:constitution toward mechanically checkable success criteria") with no embedded instructions directed at the reviewing agent.

## Findings

**[HIGH] README carries none of the constitution's audience boundary**
- Constitution section: Audience — "**This is not for:** beginners new to Claude Code, enterprise teams expecting supported tooling, or anyone who needs Anthropic-blessed canonical patterns."
- Observed evidence: The snapshot's README excerpt confirms the 164-line README has Installation, Plugins, Scripts, Attribution, and References sections, but "Notably absent from the README: the mission statement, the audience definition (including the 'this is not for' exclusions), the non-goals, and any pointer to `CONSTITUTION.md`."
- Gap: The constitution explicitly names three audiences this project is *not* built to serve, but the artifact every external visitor reads first gives no signal of that. Someone arriving expecting supported enterprise tooling or beginner-friendly onboarding has no way to self-select out before filing an issue or expectation the maintainer never intended to meet. This is exactly the audience-fit failure mode the constitution tries to preempt in writing, just not in practice.
- Suggested action: Add a one- or two-line "who this is for / not for" pointer near the top of the README, linking to `CONSTITUTION.md`. Smallest fix: a single sentence plus a link, not a restatement of the full section.

**[MEDIUM] panel-product shipped violating Principle 1 and stayed that way until this run**
- Constitution section: Principles #1 — "Specialization over generalization — small, focused skills/agents that do one thing well, over monolithic tools that try to handle everything."
- Observed evidence: The "panel-product rework" milestone text states the skill "shipped at v1.0.0 and has never produced a committed run," and that a review "found that the panel's persona set is anchored to a rubric that does not cover it… and that its five personas overlap enough to need explicit 'do not evaluate X' fencing" (visible in this very persona's own role definition, which lists four other personas it must not duplicate).
- Gap: A resource whose whole purpose is enforcing specialization/non-overlap on the rest of the repo itself shipped in a state that needed retrofitted overlap-fencing across five personas — the opposite of "do one thing well." This sat live from ship until the current rework milestone (9 open issues: #71–#79) surfaced it.
- Why it matters less than HIGH: remediation is already in motion and scoped correctly — the milestone's closure condition is this exact run producing a diffable `synthesis.md` against run 1, and issues #74 ("resharpen personas onto non-overlapping axes") and #77 ("extract the shared panel protocol") target the root cause directly.
- Suggested action: No new action needed beyond closing the existing milestone as scoped; flagging here so the constitution's Principle 1 has a named instance of enforcement lapsing and recovering.

**[LOW] DRY-drift issue open against the audience-serving `principles` plugin**
- Constitution section: Audience — "through the `principles` plugin's universal profile, people doing non-code work with Claude who receive the canon without ever installing this marketplace" — and Principle 3, external memory ("don't repeat knowledge" is the adjacent engineering principle this failure mode maps to).
- Observed evidence: Open issue #58, "engineering-principles.md restates facts owned by PROFILES.md (DRY drift)," labeled `documentation`, `priority:low`, `value:low`, `class:unplanned`, no milestone.
- Gap: The plugin that reaches the constitution's third, largest, and least-visible audience (non-code users who never install the marketplace) has an acknowledged duplicated-knowledge defect sitting unscheduled. Low severity because it's correctly labeled low priority/value and C1's "stable code needs no commits" reasoning applies — but it is the one open item that touches that audience segment at all.
- Suggested action: No urgency implied; leave triaged as-is, but don't let it silently age past the point where "unplanned" becomes "permanent."

**[LOW] Core workflow-scaffolding path carries an open correctness bug while the mission's meta-tooling gets a dedicated milestone**
- Constitution section: Mission — "scaffold the maintainer's development workflows."
- Observed evidence: Issue #50 ("Parallel committing prompts race on the shared git index in run-prompt"), `priority:high`, `value:high`, filed 2026-07-19, milestoned under "run-prompt concurrency safety" (1 open issue, no due date), versus the "panel-product rework" milestone's 9 open issues actively worked this same day.
- Gap: `run-prompt` sits on the `/play → /do → /ship` path the constitution's own CLAUDE.md marks as the mandated cycle for all work — i.e., it's the literal mechanism of "scaffolding the maintainer's workflow," the mission's core noun. A silent data-corruption bug there (wrong commit message paired with wrong file contents, "nothing fails loudly") has sat unscheduled for ~2 months. This is primarily a sequencing/roadmap-coherence question (out of this persona's scope, and already raised by the milestone's own text, which cites the Roadmap Reviewer and Rude Q&A findings from run 1), but it touches mission scope insofar as the thing left waiting is the workflow-scaffolding mechanism itself, not a peripheral feature.
- Suggested action: Defer sequencing judgment to `product-roadmap`; noting here only because it's the mission's own core mechanism that's exposed.

## Constitution health

- **Non-Goals closing paragraph is an assertion with no matching success criterion.** The text reads: "Process rigor here — issue templates, a label vocabulary, CI validation — serves the reference-implementation goal. It is not a support commitment, and should not be read as the project drifting toward one." This is a real and reasonable claim, but none of C1–C5 could ever falsify it — there is no check for "process investment relative to actual support behavior." Given the repo already carries a 29-label vocabulary, formal issue templates (`issue-standards`, shipped via #66/#67), and CI validation, this is precisely the area where the paragraph's reassurance could quietly stop being true without any mechanism noticing. Consider either (a) accepting it stays a judgement call like C1 and saying so explicitly, or (b) adding a lightweight check (e.g., "no SUPPORT.md, no SLA language, no assigned-response-time labels").
- No other section was too vague to test — Mission, Audience, Principles, and Non-Goals are all concrete enough to check activity against, and this refresh (1d5bf26, same day) already tightened Success Criteria into executable form after the first `panel-product` run found two of them false. That is itself good evidence the constitution is being actively maintained rather than left to rot.

### Summary counts
critical=0 high=1 medium=1 low=2
