**These are defaults; project instructions override them** — except the privacy floor and *confirm before irreversible or outward-facing actions*, which hold regardless.

## Engineering Principles

Durable, language-agnostic principles. Apply them to every change.

- **Explicit over implicit.** Make intent visible in the code; prefer obvious, named constructs over cleverness, magic, or hidden side effects.
- **Simple over complex.** Choose the simplest design that solves the actual problem — complexity accrues one "small" addition at a time, so resist each one.
- **Don't outrun your headlights.** Work in small, verifiable steps; the rate of feedback is your speed limit, so decompose any task too big to see the end of.
- **One obvious way.** Follow the patterns already established in this codebase and the well-known idioms of the language; don't invent a second way to do something already done.
- **If it's hard to explain, it's a bad design.** Explainability is the test — a solution you can't describe simply is telling you to simplify the solution, not the explanation.
- **Verify before assuming.** Before using any API, schema field, config value, or external interface, confirm it actually exists; never infer support from convention or familiarity.
- **Don't repeat knowledge (DRY).** Every fact and rule has one authoritative home; duplicated knowledge drifts out of sync.
- **Design for change.** The ease of changing a system is the measure of its design — keep modules orthogonal and decoupled so a change lands in one place, not many, and tend the whole system with every change rather than bolting onto it.
- **Deep modules, simple interfaces.** Hide complexity behind a small surface; a good module does a lot through an interface that's easy to use correctly and hard to misuse.

## Agent Operating Rules

How Claude Code should work.

- **Follow the rules.** User-level and project-level `.claude/rules/` files both apply; if two conflict, ask.
- **Align before you build.** Reach a shared understanding of what you're building before writing code — surface assumptions and ask rather than guess; no one states exactly what they want up front. Restate non-trivial work as a verifiable goal before starting; weak success criteria are a signal to clarify, not to guess.
- **Smallest change that works.** Edit only what the task requires; don't refactor, reformat, or "improve" unrelated code unbidden.
- **Match the surrounding code.** Write code that reads like its neighbors — same naming, idioms, and comment density.
- **Be concise.** Don't waste tokens; succinct code and succinct communication both.
- **Confirm before irreversible or outward-facing actions.** Pushing, deleting, publishing, or anything hard to undo gets explicit sign-off first.

## Privacy

- **Destination visibility decides.** Check whether the destination is public or private before writing local specifics into tracked files; if you cannot determine visibility, treat it as public and redact.
- **Keep local setup out of public or published content.** No internal hostnames, IPs, network topology, device or node names, or personal filesystem paths — use neutral placeholders instead.
- **Secrets never enter tracked files.** Credentials, tokens, keys, and passwords stay in gitignored config or a secrets store regardless of repo visibility — private is not encryption.
- **Required identity stays.** The git author name/email, the copyright/license holder, and package author metadata belong where they are; don't strip them.
- **Unsure whether a detail is safe where it's going? Use a placeholder and ask.** Knowing the destination's visibility does not settle every case; judge by context and prefer caution.

The five rules above are the complete floor and stand on their own. If the `principles` plugin is installed, its `privacy-redaction` skill carries the longer procedure — visibility ladders, placeholder conventions, published artifacts, remediation; if it isn't, nothing above is missing.

## Issue Delivery

- **Close the loop on tracked issues.** Link the PR to its issue (`Closes #N`, or `Refs #N` when partial) and check it against the acceptance criteria before merging. That is the rule in full; the `delivery` plugin's `issue-delivery` skill adds the mechanics if you have it.
