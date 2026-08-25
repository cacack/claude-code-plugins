# Graft Contract

Single source of truth for **what travels**, **what changes**, and **what must be true afterward** when a Claude Code resource, plugin, or pattern is grafted from one home to another. `SKILL.md` and the `workflows/` files defer to this file — they do not restate it.

## Terms

| Term | Meaning |
|---|---|
| **Payload** | The thing being grafted. One of three kinds — see below. |
| **Closure** | The payload *plus* everything it needs to work in the new home. Computing this wrong is the standard way a graft fails. |
| **Source** / **Target** | Where it comes from / where it lands. Either may be another plugin in this repo or another repo entirely. |
| **Disposition** | `copy` (source keeps its own live copy) or `move` (source deregisters). "Clone" is a copy; "migration" is a move. |
| **Fidelity** | `adapt` (rewrite to the target's conventions and voice) or `verbatim` (copy as-is, then report every resulting violation). |

## Payload kinds

| Kind | Is |
|---|---|
| `resource` | One skill directory, agent `.md`, `hooks.json` entry, or rules/CLAUDE.md block. |
| `plugin` | A whole plugin directory, including its marketplace registration. |
| `pattern` | A convention, not bytes. Read how the source does something, reimplement it idiomatically in the target. |

This file defines the kinds. Routing a kind to its workflow, and scoping a request into kinds, belong to `SKILL.md`.

## Closure rules

An installed plugin ships only its own subtree. Anything the payload reaches for at runtime must therefore live inside the **target plugin root** after the graft, or the reference is dead.

| Payload reaches for | Travels with it? |
|---|---|
| Its own subdirectories (`workflows/`, `references/`, `scripts/`, `templates/`) | Always. They are part of the payload, not dependencies. |
| A plugin-owned doc (`../../docs/x.md`) | Yes — copy the doc into the target plugin, or inline the content. Never leave the link pointing across a plugin boundary. |
| An agent it dispatches by `subagent_type` | Yes, if the dispatch is real. A namespaced agent in another plugin cannot be invoked. |
| A skill named in an agent's `skills:` frontmatter | Yes. Same reason. |
| A skill it only *mentions* in prose | No. Descriptive cross-plugin references are legal and should survive untouched. |
| A built-in agent type (`general-purpose`, `Explore`, `Plan`) | No. Available everywhere. |
| An MCP tool | No, but record the dependency — the target may not have that server configured. |

The distinction between a real dispatch and a prose mention is the judgment call in every graft. Treat a `plugin:name` token as **invocational** when its line also carries `subagent_type`, a `Task` call, a `Skill(` call, or an imperative to invoke it. Otherwise treat it as **descriptive**. When it is genuinely ambiguous, ask rather than guess — a wrongly-rewritten prose mention is cosmetic, a wrongly-kept dispatch is a runtime failure.

## Rewrite map

Every string class that changes on a graft. `verbatim` fidelity skips the rewrites and reports each one as drift instead.

| What | Where | Rule |
|---|---|---|
| Invocational `plugin:name` | dispatch instructions, `subagent_type` | Retarget to the resource's new home. If the resource did not come along, the dispatch is broken — resolve it, do not rename it. |
| Descriptive `plugin:name` | prose | Leave alone unless the named plugin does not exist in the target's world, in which case rephrase or drop the mention. |
| Relative link `](../../docs/x.md)` | markdown body | Must resolve inside the target plugin root. Re-point it at the copied doc. |
| `${CLAUDE_PLUGIN_ROOT}/...` | markdown, scripts | Plugin-relative, so the literal string usually survives — but only if the file it names came along in the closure. |
| `${CLAUDE_SKILL_DIR}/...` | markdown, scripts | Resolves against the *skill* directory, not the plugin root. Survives a whole-skill graft; breaks whenever the skill is renamed or its `scripts/`/`references/` payload does not travel. |
| `name:` frontmatter | skill, agent | For a skill, must equal its directory name. Rename on collision with an existing target resource. |
| `skills:` frontmatter | agent | Must name skills that exist in the target plugin. |
| Plugin identity (`author`, `homepage`, `repository`) | `plugin.json` | Adopt the target marketplace's values. Keep `description`. |
| Marketplace entry | `.claude-plugin/marketplace.json` | Whole-plugin grafts only. `source` is `./plugins/<name>`, plus `name`, `version`, `description`, `author`, `strict: true`. |
| Version | `plugin.json` **and** the marketplace entry | Bump the target plugin — minor for a new resource, patch for a docs-only graft. Both files, kept in sync. |
| Resource tables | target `README.md`, `CLAUDE.md` Plugin Boundaries | Add the new resource or plugin. A graft the docs do not mention is half-landed. |
| Terminology and voice | prose | `adapt` fidelity only. Match the target's terms for the same concepts. |

## Provenance

Every graft commit carries trailers. They are the durable record — the working ticket is scratch, this is what survives.

```
Grafted-From: <repo-identity>@<sha> <source-path>
Graft-Kind: resource|plugin|pattern
Graft-Disposition: copy|move
Graft-Fidelity: adapt|verbatim
```

`<repo-identity>` is the source's `origin` URL when it has one, otherwise its absolute path. `<sha>` is the source `HEAD` at graft time — record it even for a same-repo graft, since it dates the copy.

Find prior grafts of the same payload before overwriting anything:

```bash
git log --all --grep='Grafted-From' --format='%H %s%n%b' -- <target-path>
```

## Invariants

Check all of these after every graft. `scripts/check-graft.sh` covers 1 and 2 mechanically, plus 3 **only when the `claude` CLI is on PATH** — it prints a `skip` line and a skipped-check count when it is not. A skipped check is not a passed check, and the script's exit code cannot tell you the difference.

1. **No reference escapes the plugin root.** Every relative link (bare-relative and dot-prefixed alike), `${CLAUDE_PLUGIN_ROOT}` path, and `${CLAUDE_SKILL_DIR}` path in the grafted files resolves to a file inside the target plugin. **No symlink survives anywhere in the subtree** — `cp -R` preserves symlinks, and one inside the payload defeats every containment check by routing through a path that is lexically inside the plugin and physically outside it.
2. **Every invocational reference resolves.** Each dispatched agent and each `skills:` entry names a resource that exists in the target plugin.
3. **`claude plugin validate` passes** for the target plugin — and for the source plugin too, if the disposition was `move`.
4. **Versions are bumped and in sync** between the target's `plugin.json` and its marketplace entry.
5. **One live copy per repo.** A `move` that leaves the source resource in place is an unfinished graft, not a fork. Nothing enforces the copy-verify-remove ordering mechanically — it is a discipline of this skill, not a property of the tooling, so on a `move` state the checker's exit code before writing the removal commit.
6. **The commit carries the trailers above.**
