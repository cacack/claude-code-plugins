# Workflow: Graft a Pattern

No bytes move. Something in the source does a thing well, and the target should do that thing too, in the target's own idiom. This is transcription rather than copying, and it is the one graft kind with no mechanical verification — so the discipline is in stating the pattern explicitly before implementing it.

Read `references/graft-contract.md` first. Closure and rewrite rules mostly do not apply here; the invariants still do, since you are writing new files into a plugin.

## 1. Name the pattern in prose, before writing any code

Read the source implementation and write down, in a few sentences:

- **What it does** — the behavior, not the mechanism.
- **Why it is shaped that way** — the constraint that produced it. A pattern lifted without its constraint becomes cargo cult.
- **What is essential and what is incidental** — which parts are the pattern and which are the source's local circumstances.

Show that statement and get agreement on it. Everything downstream is judged against it, and this is the cheapest point to discover that the person meant a different pattern than the one you read.

## 2. Check whether the target already has it

The target may solve the same problem differently, and a second solution is worse than either. Search the target for its existing answer before adding one.

If the target has a partial or divergent version, the honest options are to extend the target's version, replace it, or leave it — not to add a parallel mechanism. Name which one you are doing.

## 3. Implement in the target's idiom

Write it the way the target writes things: its file layout, its frontmatter conventions, its prose voice, its level of XML structure. The result should be indistinguishable from code the target's author wrote. A transcription that reads like an import has failed even when it works.

Do not copy the source's identifiers, comments, or file names unless they are genuinely the clearest choice in the new context.

## 4. Verify

There is no reference checker for this, because nothing was copied. Instead:

- Run the target's auditor for whatever resource kind you produced (`audit-skill`, `audit-subagent`, `audit-plugin`, `audit-hooks`).
- Run `bash <skill-dir>/scripts/check-graft.sh <target-plugin-dir>` anyway — you wrote new files into a plugin, and the closure invariants apply to new work as much as to copied work.
- Re-read the step 1 statement and check the implementation against it point by point. Say which points it satisfies and which it does not.

## 5. Commit

Provenance still matters, even with no bytes in common — the trailer is how someone later finds the original when the pattern turns out to be wrong. Use `Graft-Kind: pattern`, and point `Grafted-From` at the source implementation's path and sha.
