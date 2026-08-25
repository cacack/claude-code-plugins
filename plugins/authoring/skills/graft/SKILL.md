---
name: graft
description: >-
  Graft a Claude Code resource, a whole plugin, or a pattern from one home into another — within this
  marketplace or across repos — carrying its full closure, rewriting every reference that must change,
  registering it in the target, and verifying that nothing is left dangling. Handles a clone (source keeps
  its copy), a migration (source deregisters), and a re-graft of something grafted before. Use when asked
  to "graft", "port", "clone", or "migrate" a skill, agent, hook, rules block, or plugin — "copy this skill
  into <plugin>", "move this agent to <plugin>", "migrate this plugin to <repo>", "steal that pattern",
  "same thing but in <repo>".
argument-hint: <what to graft> [into <target>]
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash(bash:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git remote:*), Bash(git add:*), Bash(git mv:*), Bash(git rm:*), Bash(git commit:*), Bash(claude plugin validate:*), Bash(cp:*), Bash(mkdir:*), Bash(ls:*), Bash(find:*), Bash(grep:*), Bash(sed:*), Bash(awk:*), Bash(diff:*), Bash(mktemp:*)
---

<objective>
Move a payload from one home to another so that it works in the new home — not merely so that its files exist there.

Copying files is the easy part and never the part that breaks. What breaks is the **closure**: an installed plugin ships only its own subtree, so a doc link, a dispatched agent, or a `skills:` entry that pointed across a boundary in the old home is dead in the new one. This skill computes the closure, rewrites what must change, registers the payload where the target expects it, and then proves the result with a checker rather than asserting it.
</objective>

<payload_kinds>
Classify first — the three kinds have different closures, different registration, and different verification.

**Read `references/graft-contract.md` before acting.** It *defines* the three kinds and owns the closure rules, the rewrite map, the provenance format, and the invariants. This section owns only the two things the contract deliberately leaves here: routing a kind to its workflow, and scoping a request into kinds.

| Kind | Route to |
|---|---|
| `resource` | `workflows/resource.md` |
| `plugin` | `workflows/plugin.md` |
| `pattern` | `workflows/pattern.md` |

Scoping: several named resources are several `resource` grafts under one ticket, not a `plugin` graft. A request that would drag most of a plugin across **is** a `plugin` graft — say so and re-scope rather than grafting resource by resource.
</payload_kinds>

<graft_ticket>
Six facts decide everything downstream. Establish them before touching a file, and write them to a scratch ticket so the graft survives a long session:

```bash
TICKET=$(mktemp "${TMPDIR:-/tmp}/graft-ticket.XXXXXX.md") && echo "$TICKET"
```

| Fact | How to settle it |
|---|---|
| **Kind** | From the payload. Infer it; state your inference. |
| **Source** | Repo identity, path, and `git rev-parse --short HEAD`. Record the sha even for a same-repo graft — it dates the copy. |
| **Target** | Repo **and** plugin. Never guess a repo path — if the target repo is not named or obvious from the session, ask for it. Do not assume any particular machine layout. |
| **Disposition** | `copy` or `move`. "Clone" means copy, "migrate" and "move this" mean move. Ask when the verb is ambiguous. |
| **Fidelity** | `adapt` or `verbatim`. Ask every time — a doc and a skill want different answers, and the person is the only one who knows whether the target will diverge. |
| **Reason** | One line. It resolves the judgment calls the rewrite map cannot. |

Ask for the unsettled facts in **one** `AskUserQuestion` call, not a series of them. Then echo the resolved ticket back in a few lines and proceed.
</graft_ticket>

<regraft_check>
Run this **before** copying anything. A payload grafted once is likely to be grafted again, and the target's copy may have been adapted since.

```bash
git -C <target-repo> log --all --grep='Grafted-From' --format='%h %s%n%b' -- <target-path>
```

If a prior graft of this payload exists, this is a **re-graft**, and overwriting blind destroys work. Show a three-way picture before proposing anything: the source as it is now, the target as it is now, and the graft point recorded in the trailer. Then name which target changes are local adaptations to preserve and which are stale copies of the source. Get agreement on that split before writing.

Absent any trailer, a payload that already exists at the target is a **collision**, not a re-graft. Collisions are resolved by renaming or by an explicit decision to overwrite — never silently.
</regraft_check>

<workflow>
1. **Classify and ticket.** Settle the six facts. Confirm the payload kind out loud.
2. **Re-graft check.** Search provenance at the target. Resolve any collision or divergence before proceeding.
3. **Confirm the target is a legal home.** For a resource, check the target repo's Plugin Boundaries table (if it keeps one) and check for a name collision. For a plugin, confirm the target repo actually has a marketplace catalog.
4. **Compute the closure** per the contract, and present it — the extra files that must travel, and the references that need a decision. Get agreement on that list. This is the step that manual grafts skip and the reason they break.
5. **Route** to the workflow file for the kind and follow it.
6. **Verify** (see below). Do not skip on the grounds that the copy "obviously worked" — a dangling reference looks identical to a working one from inside the file.
7. **Register and commit** with the provenance trailers from the contract. On a cross-repo graft that is two commits in two repos, both carrying the same trailers.
8. **Report** what landed, what was rewritten, what was deliberately left alone, and every decision still open. A graft with unresolved references is reported as unfinished, not as done.
</workflow>

<verification>
```bash
bash "${CLAUDE_SKILL_DIR}/scripts/check-graft.sh" <target-plugin-dir>
```

`${CLAUDE_SKILL_DIR}` is substituted **here**, in this file, before you read it — so the path above is already absolute. It is **not** an environment variable and is empty in a shell, so the `workflows/*.md` files write `<skill-dir>/scripts/check-graft.sh` instead: substitute the absolute path from the line above rather than pasting the variable into a command.

The checker resolves every relative link (bare-relative and dot-prefixed), every `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_SKILL_DIR}` path, and every namespaced `plugin:resource` reference and agent `skills:` entry; it rejects symlinks in the subtree, and runs `claude plugin validate` when the CLI is present. It reports facts and leaves judgment to you:

- **ERROR** — a reference that cannot resolve at runtime. Fix it. There is no acceptable-error case.
- **note** — a descriptive cross-plugin mention. Legal and usually correct, since prose may name another plugin's resources. Confirm each one reads as prose rather than as a dispatch.
- **skip** — a check that **did not run**, because an input it needed was absent (no sibling plugins to resolve namespaces against, or no `claude` on PATH). The trailer counts these separately, and exit 0 does not mean a skipped check passed. Resolve the missing input, or verify that ground by hand.

`scripts/selftest.sh` asserts each detection class against fixtures written in this repo's real idioms. Run it after changing the checker — a marker set tuned against convenient fixtures is how this checker first came to miss most real references while reporting a clean pass.

Then run the target's own auditor for the kind you produced — `audit-skill`, `audit-subagent`, `audit-hooks`, `audit-plugin`, or `audit-claudemd`. Reference integrity and authoring conventions are different questions, and the checker only answers the first.

On a `move`, run the checker against the **source** plugin too. Removing a resource can strand a sibling that dispatched it.
</verification>

<hard_rules>
- **Never remove the source before the target verifies.** A `move` is a copy, a verification, and then a removal — in that order, and the removal is its own commit. Nothing enforces this ordering mechanically, so state the checker's exit code before writing the removal commit.
- **Never leave an invocational reference crossing a plugin boundary.** There is no dependency mechanism between plugins. Resolve it by grafting the dependency too or by dropping the capability and saying so — never by renaming it and hoping.
- **Never "fix" a descriptive cross-plugin mention.** Prose that names another plugin's skill is legal and intentional.
- **Never overwrite a divergent target copy** without showing the divergence and getting a decision.
- **Never invent a target path**, and never encode a particular machine's directory layout into anything you write. Ask instead.
- **A graft the target's docs do not mention is half-landed.** README rows and boundary tables are part of the payload, not follow-up work.
</hard_rules>

<references>
- `references/graft-contract.md` — closure rules, rewrite map, provenance format, invariants. Read before acting.
- `workflows/resource.md`, `workflows/plugin.md`, `workflows/pattern.md` — the per-kind procedures.
- `scripts/check-graft.sh` — reference-integrity checker. Takes a plugin directory, exits nonzero on any ERROR, and counts skipped checks separately.
- `scripts/selftest.sh` — asserts every detection class of the checker. Run after changing it.

`Bash(bash:*)` is the one broad grant in `allowed-tools`, and it is there to run those two scripts. `git` and `claude` are scoped to the subcommands the workflows actually use, so this skill cannot force-push, rewrite git config, or install a marketplace.
</references>
