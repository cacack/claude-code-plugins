# Engineering Principles — the canon

Durable engineering principles and agent operating rules — the software-fundamentals canon the `instill-principles` skill installs into a repo's (or your user profile's) always-on Claude Code context.

The canon is two files, the single source of truth:

- [`principles/engineering.md`](../principles/engineering.md) — 9 durable, language-agnostic engineering principles.
- [`principles/agent-operating.md`](../principles/agent-operating.md) — 6 rules for how Claude Code should work in a repo.

The framing, owed to Matt Pocock's "Claude Code for real engineers": **AI is the tactical programmer on the ground; you are the strategic one above it.** Good codebases are easy to change, and AI thrives in them — so software fundamentals matter *more* in the AI age, not less.

## How delivery works — a skill plus a file, not magic

Principles need to be **ambient**: in context every session, not waiting to be invoked. A Claude Code plugin cannot ship ambient context — skills are loaded on demand, and there is no mechanism for a plugin to inject always-on instructions. The only surfaces always in context are `CLAUDE.md` (and its `@imports`) and `.claude/rules/` — files that live in the repo or your home directory.

So the kit splits the job:

- **The file keeps the principles active.** [`instill-principles`](../skills/instill-principles/SKILL.md) writes the canon to `.claude/rules/engineering-kit.md` (repo scope) or `~/.claude/rules/engineering-kit.md` (every repo, for you). That file auto-loads thereafter.
- **The skill gets the file there, correctly.** It audits the target for overlap, merges without duplicating, and writes a managed block you can re-sync as the canon evolves.

We deliberately did **not** use a hook to inject the principles each turn. A hook would be per-turn overhead, invisible to the team, and would not travel with the repo — and hidden instructions Claude obeys for unseen reasons are exactly what **Explicit over implicit** argues against. The delivery mechanism obeys the canon it delivers.

## Standards Traceability

| Standard | Drawn from it |
|----------|---------------|
| Tim Peters — "[The Zen of Python](https://peps.python.org/pep-0020/)" (PEP 20), 2004 | Explicit over implicit; simple over complex; one obvious way; hard-to-explain = bad design |
| Hunt & Thomas — *The Pragmatic Programmer* (20th Anniv. ed.), 2019 | Verify before assuming; DRY; design for change (ETC, orthogonality); don't outrun your headlights; software entropy (tend the whole) |
| John Ousterhout — *A Philosophy of Software Design*, 2018 | Complexity is incremental; ease of change = measure of design; deep modules with simple interfaces |
| Frederick P. Brooks — *The Design of Design*, 2010 | Align before you build (the shared "design concept") |
| Kent Beck | "Invest in the design of the system every day" (tend the whole, fight entropy) |
