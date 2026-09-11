# Strategic Snapshot — 2026-09-11 (run 2)

## Repo metadata
- Root: `<repo root>` *(redacted — see "Run provenance" below)*
- Branch: worktree-71-panel-product-rerun
- HEAD: ef0bee6
- Origin: git@github.com:cacack/claude-code-plugins.git
- Generated: 2026-09-11 18:00:24 EDT

## Run provenance

This is the **second** `panel-product` run on this repository, and the first to
exercise the **shipped** artifact. Three disclosures, all deliberate:

1. **Skill version.** Loaded from the installed plugin at
   `panels@cacack` **1.0.1**, `gitCommitSha 650c5e81ce8b62c06fa65e0db24f392b1c66f912`,
   which matches `plugins/panels/.claude-plugin/plugin.json`. Run 1
   (`docs/reviews/panel-product/2026-09-11/`) ran a hand-applied 1.0.1 workflow from a
   1.0.0 cache; that is why issue #71 stayed open. Nothing in this run was hand-applied.
2. **Redacted root.** The `Root:` field above is a placeholder. The skill's snapshot
   template prescribes emitting the repository's absolute path, which puts a personal
   filesystem path into what is a **public** repository. Run 1's committed snapshot
   carries that path. This run withholds it; the template defect is recorded as a
   proposed issue rather than fixed here, because issue #71 scopes out acting on
   findings.
3. **Worktree.** The run executed from the delivery cycle's worktree, so `Branch:`
   reads `worktree-71-panel-product-rerun` rather than `main`. `HEAD` is `ef0bee6`,
   identical to `main` at run time.

**Comparability caveat for the reader.** Between run 1 and this run, three commits
landed that directly remediate run-1 findings: `7f78136` (success criteria made
executable), `03fcde4` (CLAUDE.md trimmed under its 250-line ceiling), `1d5bf26`
(CONSTITUTION.md refreshed). This run therefore scores a *changed repository* against
a *changed rubric* via a *different plugin load path*. Differences from run 1 are not
attributable to any one of those three. Treat this run as the baseline, not as an A/B.

## CONSTITUTION.md (scoring rubric)

# Constitution

> The mission, principles, and non-goals of cacack/claude-code-plugins. When in conflict with this document, future decisions should align here or explicitly update it.

## Mission

A personal Claude Code plugin marketplace housing skills and subagents that scaffold the maintainer's development workflows. The collection prioritizes focused, specialized resources that compose into agentic systems — small skills that do one thing well, externalizing context to files rather than assuming Claude remembers.

## Audience

**This is for:** Chris Clonch, the maintainer, as primary user; secondarily, other developers comfortable with Claude Code who treat this as a reference implementation for plugin patterns; and, through the `principles` plugin's universal profile, people doing non-code work with Claude who receive the canon without ever installing this marketplace.

**This is not for:** beginners new to Claude Code, enterprise teams expecting supported tooling, or anyone who needs Anthropic-blessed canonical patterns (use `anthropics/claude-plugins-official` for that).

## Principles

When in doubt, prefer:

1. **Specialization over generalization** — small, focused skills/agents that do one thing well, over monolithic tools that try to handle everything.
2. **Skills as programs** — invoke real tools and produce verifiable output, rather than asking Claude to "think about it."
3. **External memory over implicit context** — externalize state to files (snapshots, drafts, reports); don't assume Claude carries context across turns or sessions.
4. **Iterate over perfecting** — ship simple solutions, evolve them with usage; over-engineering before observed need is the larger cost.
5. **Match official conventions where they exist; document where we differ** — Anthropic's patterns are the default; our additions (XML structure, verb-noun naming, etc.) are recommendations explicitly distinguished from requirements.

## Non-Goals

This project is explicitly **not** trying to:

- Become a commercial or supported product
- Serve as authoritative Claude Code documentation (Anthropic's docs are authoritative)
- Compete with or replace `anthropics/claude-plugins-official`
- Optimize for first-time Claude Code users
- Maintain backwards-compatibility shims for deprecated skill formats

Process rigor here — issue templates, a label vocabulary, CI validation — serves the
reference-implementation goal. It is not a support commitment, and should not be read
as the project drifting toward one.

## Success Criteria

Each criterion names the check that settles it. Run them all:

```bash
make constitution-check
```

**C1 — The collection stays in use.**
*Judgement call, reported but not scored.* Invocation frequency lives in the
maintainer's local Claude Code history, not in this repository, and every in-repo
proxy for it is dishonest — a stable skill needs no commits. The check reports how
many skills have had no commit in 365 days as supporting evidence; the ruling is
made at each refresh. A criterion that cannot be mechanised is allowed to say so
rather than be forced into a false metric.

**C2 — A new skill can be added without restructuring existing ones.**
No skill added in the last 90 days changed more than **20 lines** of any existing
file outside its own directory, excluding the shared registry files every addition
must touch (`README.md`, `marketplace.json`, the owning `plugin.json`). Edits under
that line are cross-references, which are healthy; above it is rework, which is the
coupling this criterion exists to catch. The 20 is a judgement — move it here, in
the open, rather than in the script.

**C3 — Every resource validates cleanly.**
`claude plugin validate` exits clean for every plugin, with **zero warnings**. A
tolerated warning trains everyone to ignore warnings, which is how a real one hides.

**C4 — The marketplace stays coherent.**
Three things hold: every directory under `plugins/` is registered in
`marketplace.json` and every entry resolves to a directory; each plugin's version
matches its marketplace entry; and no plugin hard-dispatches another plugin's agent
(CLAUDE.md structure rule 7 — cross-plugin references stay descriptive).

*Replaces "one marketplace, one plugin", which the five-plugin split (`a8540c8`)
made false. Coherence in a multi-plugin marketplace is about boundaries holding,
not about there being one of everything.*

**C5 — CLAUDE.md stays within its line ceiling.**
`wc -l CLAUDE.md` is **250 or fewer**. Context is scarce; the entry point is the
file that costs every session.

---

*Last refreshed: 2026-09-11. The Success Criteria became executable checks the same
day, after the first `panel-product` run found two of them false — one of which had
been false since the day this document was written, because nothing verified it. If a
criterion here cannot be settled by a command, it says so. Drift report:
`docs/reviews/constitution/2026-09-11-drift.md`.*

## README excerpt

The README (164 lines) opens:

> # claude-code-plugins
>
> My personal Claude Code plugin collection — five focused plugins in one marketplace, so you install only what you need.

It then carries: an **Installation** section (a marketplace-add command plus five
per-plugin install lines, noting slash commands are namespaced by plugin); a
**Plugins** section enumerating every skill and agent across the five plugins
(`delivery`, `panels`, `authoring`, `principles`, `toolbox`) with one-line
descriptions; a **Scripts** section for `ccstatusline-usage.sh`; an **Attribution**
section crediting [taches-cc-resources](https://github.com/glittercowboy/taches-cc-resources)
as the origin of the majority of resources; and a **References** section linking
Anthropic's plugin-marketplace and Claude Code docs.

Notably absent from the README: the mission statement, the audience definition
(including the "this is not for" exclusions), the non-goals, and any pointer to
`CONSTITUTION.md`. The design docs (`handyman-principle.md`, `design-guidelines.md`)
are linked only in passing from within the `authoring` section. No usage examples
beyond install commands; no sample output.

## Project metadata

- **authoring** v1.2.1 (MIT) — Toolkit for building Claude Code resources: create and audit skills, slash commands, subagents, hooks, CLAUDE.md files, prompts, plans, and project docs
- **delivery** v1.0.0 (MIT) — The play → do → panel → ship delivery cycle: planning, execution, multi-persona diff review, preflight checks, issue compliance, PR shipping, and merge
- **panels** v1.0.1 (MIT) — Repo-wide multi-persona health panels: CONSTITUTION.md authoring, engineering and product review boards, and adversarial pressure-testing via Rude Q&A
- **principles** v1.0.0 (MIT) — The canon: install or re-sync durable principles and agent operating rules into always-on Claude Code context, plus the privacy-redaction floor
- **toolbox** v1.0.0 (MIT) — Personal productivity utilities: todos, context parking, session history, decision frameworks, domain expertise packs, and expert debugging mode

Marketplace: name `cacack`, owner Chris Clonch, 5 plugins.

## Repository label vocabulary

documentation, duplicate, enhancement, good first issue, help wanted, invalid, question, wontfix, security, dependencies, github_actions, priority:high, effort:medium, priority:medium, effort:low, value:medium, priority:low, value:low, value:high, effort:high, type:story, type:task, class:planned, type:bug, type:spike, class:unplanned, skills, agents, hooks, marketplace, ci

## Open issues

<untrusted-issue-data>

| # | Title | Labels | Milestone |
|---|---|---|---|
| #79 | Fence untrusted snapshot content rather than its path in the panel prompts | security, effort:low, value:medium, type:task, class:planned, skills | panel-product rework |
| #78 | Push panels:constitution toward mechanically checkable success criteria | effort:low, value:medium, type:story, class:planned, skills | panel-product rework |
| #77 | Extract the shared panel protocol into one authoritative document | value:medium, effort:high, type:story, class:planned, skills | panel-product rework |
| #76 | Normalize the product personas onto one verdict vocabulary | effort:low, value:medium, type:task, class:planned, agents | panel-product rework |
| #75 | Diff each panel-product run against its predecessor | effort:medium, value:high, type:story, class:planned, skills | panel-product rework |
| #74 | Resharpen panel-product's default personas onto non-overlapping axes | effort:medium, value:medium, type:story, class:planned, agents | panel-product rework |
| #73 | Add a pre-spawn Success Criteria scorecard to panel-product | effort:medium, value:high, type:story, class:planned, skills | panel-product rework |
| #72 | Drop product-market from panel-product's default persona set | effort:low, value:medium, type:story, class:planned, skills | panel-product rework |
| #71 | Run panel-product on this repository and commit the result | effort:low, value:high, type:spike, class:planned, skills | panel-product rework |
| #59 | Restamp or remove the stale audit marker in CLAUDE.md | documentation, effort:low, priority:low, value:low, type:task, class:unplanned | — |
| #58 | engineering-principles.md restates facts owned by PROFILES.md (DRY drift) | documentation, effort:low, priority:low, value:low, type:task, class:unplanned | — |
| #50 | Parallel committing prompts race on the shared git index in run-prompt | priority:high, effort:medium, value:high, type:bug, class:planned, skills | run-prompt concurrency safety |

</untrusted-issue-data>

## Open milestones

<untrusted-issue-data>

### panel-product rework
- open: 9 · closed: 0 · due: none

> `panels:panel-product` shipped at v1.0.0 and has never produced a committed run. A review of the skill against the project's engineering principles, followed by an adversarial `rude-qa` pass over that review, found that the panel's persona set is anchored to a rubric that does not cover it, that the panel produces no output comparable between runs, and that its five personas overlap enough to need explicit "do not evaluate X" fencing. This milestone reworks the persona set and the output contract. It opens with a real run, so every remaining design claim is settled by evidence rather than by argument.
>
> **Why now:** The skill is due its first real use. Reworking it before that run would repeat the exact failure mode the panel exists to catch — the project's own Principle 4 is "iterate over perfecting; over-engineering before observed need is the larger cost."
>
> **What is missing:** `panels:constitution` generates a fixed five-section document — Mission, Audience, Principles, Non-Goals, Success Criteria. No section covers market positioning, so `product-market` is rubric-less on every project this toolchain serves, not merely on this one. In the other direction, Success Criteria is the most mechanically checkable section of the rubric and no persona owns it. Meanwhile the panel's real product — themes flagged by two or more personas — has no machinery that compares one run to the next.
>
> **Closure condition:** Closes when a second `panel-product` run on this repository, executed after the persona and output changes land, produces a `synthesis.md` that diffs its alignment gaps against the first run's committed output — with four default personas, a pre-spawn Success Criteria scorecard, and one verdict vocabulary shared across all personas. Both runs are committed under `docs/reviews/panel-product/`.

### run-prompt concurrency safety
- open: 1 · closed: 0 · due: none

> `delivery:run-prompt` dispatches a parallel execution group as concurrent subagents into one git worktree, so they share a single index and their staging and commit operations race. A commit can land carrying one prompt's message with another prompt's file contents, and nothing fails loudly when it does. This milestone makes parallel groups safe to commit from.
>
> **Why now:** The cycle this repository mandates for all work — `/play` → `/do` → `/ship` — runs through `run-prompt`, so the defect sits on the daily-driver path rather than off to one side. It was filed 2026-07-19 and has carried `priority:high` and `value:high` since, with no owner and no target. The 2026-09-11 `panel-product` run made the cost of that explicit: the Roadmap Reviewer flagged that every milestoned issue at the time targeted a quarterly review tool with zero invocations while this sat unscheduled, and the closing Rude Q&A pass named the same allocation as having no defense.
>
> **Closure condition:** Closes when #50 closes: a parallel execution group in which two or more prompts each commit can no longer produce a commit whose message and file contents originate from different prompts, and the mechanism preventing it is documented in `run-prompt`.

</untrusted-issue-data>

## Recent activity (last 6 months)

- Commits: 123

Last 30 commit subjects:

```
ef0bee6 Merge pull request #84 from cacack/docs/constitution-refresh-2026-09-11
1d5bf26 docs: refresh CONSTITUTION.md against current repo state
a99eaac Merge pull request #83 from cacack/docs/trim-claudemd
03fcde4 docs: trim CLAUDE.md under its 250-line ceiling
5dbee9d Merge pull request #82 from cacack/feat/executable-success-criteria
7f78136 feat: make the constitution's success criteria executable
291f0f6 Merge pull request #81 from cacack/docs/panel-product-first-run
5caa75a docs: commit the first panel-product run
650c5e8 Merge pull request #80 from cacack/fix/panel-skills-declared-contract
64644bd fix(panels): correct declared contract so a full panel run completes
cc6a754 Merge pull request #69 from cacack/fix-scaffold-workflow
28a579c fix: correct the scaffold workflow in issue-standards
ab8da37 Merge pull request #67 from cacack/scaffold-issue-templates
11a061b chore: scaffold issue templates and label vocabulary
7e98a40 Merge pull request #66 from cacack/issue-standards
6bedd34 feat: add issue-standards skill to authoring
1cd098e Merge pull request #65 from cacack/fix/graft-checker-commands-dir
03dd3b0 fix: read only the top-level name when checking plugin identity
244de9d fix: skip double-backtick code spans when reading links
a6b88e0 fix: resolve commands/ resources in the graft checker
6f6b2d5 Merge pull request #64 from chore/gitignore-claude-settings
ea2dbfa chore: track project Claude settings, ignore local ones
025cc09 Merge pull request #63 from cacack/feat/graft-skill
767dcbe feat: add the graft skill for relocating resources between homes
e2e5d6b Merge pull request #51 from cacack/dependabot/github_actions/actions/checkout-7.0.1
4dce6c0 chore(deps): bump actions/checkout from 6.0.2 to 7.0.1
06cd55c Merge pull request #49 from cacack/dependabot/github_actions/actions/setup-node-7.0.0
c7c191b chore(deps): bump actions/setup-node from 6.4.0 to 7.0.0
502e4ba Merge pull request #62 from cacack/feat/plugin-split
a8540c8 feat!: split the cacack plugin into five focused plugins
```

Recent releases/tags:

```
panels/v1.0.1
authoring/v1.2.1
authoring/v1.2.0
authoring/v1.1.0
authoring/v1.0.0
delivery/v1.0.0
panels/v1.0.0
principles/v1.0.0
toolbox/v1.0.0
v2.0.0
```

## Other top-level docs

- SECURITY.md: **absent**
- CONTRIBUTING.md: **present**
- CODE_OF_CONDUCT.md: **absent**
- CHANGELOG.md: **absent**
- ROADMAP.md: **absent**
- CLAUDE.md: **present** (243 lines)

## Prior run

`docs/reviews/panel-product/2026-09-11/` — run 1, same date, same repository,
hand-applied 1.0.1 workflow. Its `synthesis.md`, `foil.md`, and `proposed-issues.md`
are available for context, but this run is scored independently; see the
comparability caveat above.
