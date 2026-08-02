# Engineering Principles — the canon

Durable principles and operating rules — the canon the `instill-principles` skill installs into a repo's (or your user profile's) always-on Claude Code context.

The canon ships as **profiles**: self-contained payload files, one per audience, copied verbatim into a managed block. [`principles/PROFILES.md`](../principles/PROFILES.md) is the contract that binds them — the registry of payload and target paths, the marker format, the migration rule, and the map that keeps the two wordings of one idea from drifting apart.

- [`principles/profiles/engineering.md`](../principles/profiles/engineering.md) — for someone writing and shipping code: 9 durable, language-agnostic engineering principles, 6 agent operating rules, a privacy floor, and the issue-delivery line.
- [`principles/profiles/universal.md`](../principles/profiles/universal.md) — for someone doing non-code work with Claude: the same ideas where they survive generalization, in wording that names no code.

The framing, owed to Matt Pocock's "Claude Code for real engineers": **AI is the tactical programmer on the ground; you are the strategic one above it.** Good codebases are easy to change, and AI thrives in them — so software fundamentals matter *more* in the AI age, not less.

## Two audiences, one canon — and why you only get one

The canon started as an engineering artifact and reads like one: it names refactors, modules, APIs, schema fields. That wording is precise for the reader who works in those things and inert for the reader who doesn't. But the underlying ideas — work in small verifiable steps, verify before assuming, don't say the same thing in two places — are not about software. Someone writing, researching, planning, or running a household project with Claude needs them just as much, and needs them in their own vocabulary.

So the universal profile is a **re-voicing, not a subset**. Most ideas carry across with generalized examples. Two do not: *Explicit over implicit* and *One obvious way* were **dropped** rather than generalized, because every general wording of them lands as a platitude, and the behavior they'd buy is already covered by rules that survive intact. A weakened principle is worse than an absent one.

That leaves the real design problem: two files now say the same thing in two voices. Loading both would put two wordings of one idea into a single context — wasted tokens at best, and two different answers the moment the wordings drift. So profiles are an **override** model, not an additive one. **You get one profile per scope, never both.** Switching is a removal plus a write, not an addition.

The installer enforces that **per scope, not per file** — a distinction worth stating because the obvious reading is wrong. The two profiles normally have different target files, so a per-file check passes trivially while both files load in the same session; and in a repo with no `.claude/` they share one file, so a per-file check is all there is. The installer therefore searches every registry location for the scope, matching block IDs, and refuses to write a second profile if one is already there. Across *different* scopes — say `universal` for you personally and `engineering` checked into a repo — it surfaces the overlap and proceeds, because your personal setup should not be able to veto the team's.

`PROFILES.md` holds the last piece: an idea→variant map recording which line in one payload is the same idea as which line in the other. Nothing else in the repo can record that — the payloads are self-contained by design and the installer only copies. A `tuned variant` row is a promise that editing one wording means editing both.

## How delivery works — a skill plus a file, not magic

Principles need to be **ambient**: in context every session, not waiting to be invoked. A Claude Code plugin cannot ship ambient context — skills are loaded on demand, and there is no mechanism for a plugin to inject always-on instructions. The only surfaces always in context are `CLAUDE.md` (and its `@imports`) and `.claude/rules/` — files that live in the repo or your home directory.

So the kit splits the job:

- **The file keeps the principles active.** [`instill-principles`](../skills/instill-principles/SKILL.md) writes one profile payload to that profile's target: `.claude/rules/engineering-kit.md` for engineering, `.claude/rules/working-with-claude.md` for universal — at repo scope, or under `~/.claude/rules/` to cover every repo you work in. That file auto-loads thereafter. A repo with no `.claude/` directory can take a managed section in the root `CLAUDE.md` instead.
- **The skill gets the file there, correctly.** It resolves profile × scope against the registry, audits the target for overlap with what's already written there, refuses to install a second profile beside an existing one, and writes a managed block you can re-sync as the canon evolves.

The two dimensions are independent: which wording you get (profile) and who it applies to (scope). Repo scope ships to the team through version control; user scope is yours alone.

## What happens to an existing install

Installs made before profiles existed carry the block ID `engineering-kit:instill-principles`, in `.claude/rules/engineering-kit.md` — or, in a repo that had no `.claude/` directory at the time, in the repo-root `CLAUDE.md`, which the old installer offered as a fallback. Detection checks both, whichever profile you are installing, because a legacy block is an engineering block wherever it landed.

Re-running the skill **migrates in place**: it detects the old block by its ID — never by its version stamp, since a stale stamp is the normal case — and replaces both markers and their content with a `canon:engineering` block in the same file, at the same position. Nothing is moved, renamed, or appended, and content you wrote outside the markers is never touched. The engineering target path is unchanged from the pre-profile installer precisely so this stays a one-file edit.

Expect a **real diff, not a stamp refresh** — and one that both adds and edits, so read it rather than skimming for new sections.

It **adds** the precedence line, a five-bullet privacy floor, and the issue-delivery line; the procedural detail behind the latter two moved out of always-on context into the `privacy-redaction` and `issue-delivery` skills, which load on their own triggers.

It also **rewords two existing rules**, which is the part a diff-skimmer misses. *Follow the rules* dropped a clause that restated default behavior and now names user- and project-level rules explicitly; *Align before you build* absorbed the verifiable-goal instruction that previously lived in a separate file. The other 13 ideas are carried across unchanged, and the 9 engineering principles are byte-identical to the pre-profile canon.

The skill shows you the block before it writes anything.

We deliberately did **not** use a hook to inject the principles each turn. A hook would be per-turn overhead, invisible to the team, and would not travel with the repo — and hidden instructions Claude obeys for unseen reasons are exactly what **Explicit over implicit** argues against. The same argument settled it a second time during the profile split: a `SessionStart` hook that injected the privacy floor was considered and declined, because a floor nobody can see in a file is a floor nobody can review, and per-session injection is hidden instruction by another name. `hooks/hooks.json` remains empty by choice. The delivery mechanism obeys the canon it delivers.

## Standards Traceability

| Standard | Drawn from it |
|----------|---------------|
| Tim Peters — "[The Zen of Python](https://peps.python.org/pep-0020/)" (PEP 20), 2004 | Explicit over implicit; simple over complex; one obvious way; hard-to-explain = bad design |
| Hunt & Thomas — *The Pragmatic Programmer* (20th Anniv. ed.), 2019 | Verify before assuming; DRY; design for change (ETC, orthogonality); don't outrun your headlights; software entropy (tend the whole) |
| John Ousterhout — *A Philosophy of Software Design*, 2018 | Complexity is incremental; ease of change = measure of design; deep modules with simple interfaces |
| Frederick P. Brooks — *The Design of Design*, 2010 | Align before you build (the shared "design concept") |
| Kent Beck | "Invest in the design of the system every day" (tend the whole, fight entropy) |
| Saltzer & Schroeder — "The Protection of Information in Computer Systems", 1975 | The privacy floor: fail-safe defaults (visibility undeterminable ⇒ treat the destination as public), and least privilege (secrets stay out of tracked files whatever the repo's visibility) |
