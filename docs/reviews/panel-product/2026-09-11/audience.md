# Audience Advocate Review — 2026-09-11

**Verdict:** partially-served

**Stated audience (from CONSTITUTION.md):** "Chris Clonch, the maintainer, as primary user; secondarily, other developers comfortable with Claude Code who treat this as a reference implementation for plugin patterns." Explicitly **not for**: beginners new to Claude Code, enterprise teams expecting supported tooling, or anyone wanting Anthropic-blessed canonical patterns.

Read as the stated audience — an experienced Claude Code user who either wants to install a plugin and use it, or wants to study the repo as a pattern reference — the project's density and lack of hand-holding are appropriate, not a defect (Non-Goal: "not optimize for first-time Claude Code users"). The catalog-style README, terse one-line skill descriptions, and absence of a beginner quick-start all match a reader who already knows what a skill/agent/hook is. Where the experience breaks down is not "too advanced" but *inconsistent*: install instructions disagree between two tracked docs, the flagship `panel-product` skill was non-functional until a same-day fix with no audience-visible trail of that, and the "reference implementation" promise is only partially backed by worked examples across the 58 skills in the collection.

## Findings

**[MEDIUM] Install command disagrees between README.md and CLAUDE.md**
- Constitution audience: secondary audience "treat this as a reference implementation for plugin patterns" — implying they read the repo's top-level docs, not just README, to understand conventions.
- Observed evidence: `README.md:9` documents `claude plugin marketplace add cacack/claude-code-plugins` (CLI form, owner/repo shorthand); `CLAUDE.md:268` (Distribution section) documents `/plugin marketplace add https://github.com/cacack/claude-code-plugins` (slash-command form, full URL). Both are public, tracked, top-level files with an install command, and they don't match in form or argument shape.
- Audience cost: a developer comfortable with Claude Code but new to this specific repo, cross-checking the two files (a natural move when studying a repo "as reference"), hits an unexplained discrepancy right at the value moment — before they've installed anything.
- Suggested action: keep one authoritative install command (README per the user's own doc-entrypoint convention) and either drop the duplicate in CLAUDE.md's References section or make it a link to the README section instead of restating the command.

**[MEDIUM] Flagship `panel-product` skill was broken until a same-day fix, invisible to the audience**
- Constitution audience: the secondary audience installs plugins to use them ("treat this as reference implementation for plugin patterns," which presumes the patterns actually run).
- Observed evidence: milestone context in the snapshot states `panels:panel-product` "shipped at v1.0.0 and has never produced a committed run," and commit `64644bd fix(panels): correct declared contract so a full panel run completes` landed the same day as this review (`650c5e8`, PR #80). No `CHANGELOG.md` exists (confirmed absent in "Other top-level docs"), and `panels` version is 1.0.1 with no per-version release notes visible from the README or plugin.json description.
- Audience cost: anyone who installed `panels@cacack` at 1.0.0 and ran `/panels:panel-product` got a skill that could not complete — with no way to discover, short of reading git history, whether the failure was their mistake or a known-broken release.
- Suggested action: a lightweight per-plugin changelog or "known issues" note (even a few lines) so the audience can tell a stale install from a config error without spelunking commit logs.

**[LOW] "Reference implementation" claim is unevenly backed by examples**
- Constitution audience: secondary audience explicitly "treat this as a reference implementation for plugin patterns" — implying they read skills to learn conventions, not just to invoke them.
- Observed evidence: of 58 `SKILL.md` files, only 25 mention "example" at all (`grep -il example plugins/*/skills/*/SKILL.md`), and none use an `## Example` heading. Only one skill (`create-hooks`) ships a dedicated `references/examples.md`. There's no root-level worked walkthrough (e.g., a narrated `/delivery:play` → `/delivery:ship` transcript) that a pattern-studying reader could follow end to end.
- Audience cost: a developer trying to learn "how does this plugin pattern work" from the repo itself, rather than just invoking a skill, has to reverse-engineer intent from prose descriptions in roughly half the skills, with no canonical example to anchor on.
- Suggested action: no wholesale rewrite needed — a single annotated example under `plugins/authoring/docs/` (already the home of the Handyman Principle and design guidelines) showing one skill end-to-end would serve this audience segment disproportionately well for a small cost.

**[LOW] No triage signal for "which skill to look at first" in a 40+ skill catalog**
- Constitution audience: secondary audience studying "plugin patterns," who need an entry point, not necessarily hand-holding.
- Observed evidence: the README's Plugins section lists every skill in every plugin as a flat bulleted list (e.g., `authoring` alone lists 21 skills across 4 categories) with no "start here" pointer beyond the design-docs links buried at the end of the `authoring` section (`plugins/authoring/docs/handyman-principle.md`, `design-guidelines.md`).
- Audience cost: minor for an audience this experienced, but the two design docs that actually explain *why* the patterns look the way they do are one sentence at the bottom of one plugin's blurb, not surfaced anywhere near the top of the README where a pattern-studying reader would look first.
- Suggested action: consider a one-line pointer near the top of the README ("see `plugins/authoring/docs/` for the design rationale behind these patterns") — very small change, addressed to the audience's actual goal (understanding patterns) rather than installing skills.

## Notes

- `CONTRIBUTING.md` still describes the pre-split root-level `agents/`, `commands/`, `skills/` layout rather than the current `plugins/<name>/` structure — this is squarely a contributor-onboarding gap (engineering-dx's lane), but it's worth flagging here too since the secondary "reference implementation" audience would also read CONTRIBUTING.md and be misled about the canonical structure. Not scored as a finding to avoid duplicating engineering-dx.
- The Attribution section (crediting `taches-cc-resources`) is a genuine positive for the reference-implementation audience: it tells them plainly which parts are original design vs. adapted, so they know what to attribute if they borrow patterns themselves.
- Given the stated audience is narrow and self-selecting (a personal project plus comfortable-with-Claude-Code developers), the absence of a FAQ, CODE_OF_CONDUCT, or discussion forum is appropriately unremarkable — GitHub issue templates (`bug.yml`, `story.yml`, `task.yml`, `spike.yml`) already exist and are proportionate to this audience's needs.

### Summary counts
critical=0 high=0 medium=2 low=3
