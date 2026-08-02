---
name: pressure-test
description: Pressure-test a strategy, pitch, proposal, roadmap, or idea against the adversarial questioning of the rude-qa agent BEFORE you bring it to decision-makers. Channels a gentle-but-relentless probing style — 5 Whys, As-Is/To-Be/gap, Voice of the Customer, speed/cost/risk, the Complexity-vs-Value 4-box, "skate to where the puck is going", and a hostile-question rehearsal — and hands back a sharpened ask plus a Monday action. Triggers include "pressure-test this", "rude Q&A this", "foil my pitch", "poke holes in this before I present it", "stress-test this strategy/idea/proposal".
argument-hint: "[<file-path> | <free-text idea> | (nothing — I'll ask)]"
allowed-tools: Task, Read, Glob, Grep, Bash(git:*)
---

<objective>
Run a single adversarial strategy pass over an initiative the user is about to take to decision-makers, so they walk in with the hard questions already answered. This skill is a thin front door: it gathers the initiative, dispatches it to the `rude-qa` subagent in an isolated context, and relays the report. All the substance — the frameworks, the persona, the constructive close — lives in the agent.
</objective>

<quick_start>
```
/panels:pressure-test                              # I'll ask you to paste or point me at the idea
/panels:pressure-test docs/strategy/foo.md         # pressure-test a file (plan, CONSTITUTION.md, one-pager)
/panels:pressure-test We should consolidate the three services into one
```
Also fires on natural phrasing: "rude Q&A this", "foil my pitch", "poke holes in this before I present it".
</quick_start>

<workflow>
1. **Resolve the initiative** from `$ARGUMENTS`:
   - **A readable file path** → note the path; the agent will read it (it has `Read`).
   - **Free text** → that *is* the initiative; pass it through verbatim.
   - **Empty** → ask the user one question: "What are you bringing, and who's the audience? Paste it, point me at a file, or describe it." Do not proceed without an initiative.
   - If the idea clearly references the current repo's work, optionally capture light context (`git log --oneline -5`, the relevant doc) to hand the agent — but keep it minimal; the agent pulls what it needs.

2. **Dispatch to the agent.** Launch the `panels:rude-qa` subagent via the Task tool with a prompt containing:
   - The initiative (the file path and/or the verbatim text).
   - The audience and the ask, if the user stated them ("this is going to the VP next Tuesday; I want headcount").
   - Any light context you gathered.
   Let the agent do the probing — do not pre-answer or soften. Missing context is the agent's job to surface as Hostile Q&A, not yours to fill.

3. **Relay the report.** Return the agent's output as-is — it is already structured (What I think you're bringing → frame check → probes → pre-mortem → Hostile Q&A → The Close). Do not summarize away the Hostile Q&A or The Close; those are the payload.

4. **Offer the follow-up.** After relaying, offer one of: (a) draft answers to the Hostile Q&A questions the user couldn't answer, (b) tighten the ask into the three-bullet close, or (c) run a second pass once they've revised. Don't do these unprompted.
</workflow>

<constraints>
- This skill writes nothing and decides nothing — it gathers, dispatches, and relays.
- One agent, one pass. This is not the multi-persona panel (`panel-review` / `panel-product`); it's a single sharp foil.
- Keep your own commentary minimal — let the agent's voice carry.
- If the initiative is trivial or operational (not strategic), say so and suggest it may not need a Rude Q&A, rather than manufacturing one.
</constraints>
