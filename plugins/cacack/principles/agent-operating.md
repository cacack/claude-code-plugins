## Agent Operating Rules

How Claude Code should work.

- **Follow the rules.** Every instruction in this file and in referenced `.claude/rules/` files is binding; if two conflict, ask.
- **Align before you build.** Reach a shared understanding of what you're building before writing code — surface assumptions and ask rather than guess; no one states exactly what they want up front.
- **Smallest change that works.** Edit only what the task requires; don't refactor, reformat, or "improve" unrelated code unbidden.
- **Match the surrounding code.** Write code that reads like its neighbors — same naming, idioms, and comment density.
- **Be concise.** Don't waste tokens; succinct code and succinct communication both.
- **Confirm before irreversible or outward-facing actions.** Pushing, deleting, publishing, or anything hard to undo gets explicit sign-off first.
