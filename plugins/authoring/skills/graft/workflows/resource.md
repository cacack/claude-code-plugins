# Workflow: Graft a Resource

One skill directory, agent `.md`, hooks entry, or rules block moves into a target plugin. The most common graft and the one with the most silent failure modes, all of them reference breakage.

Read `references/graft-contract.md` first. The closure rules and rewrite map below are not restated here.

## 1. Confirm the target plugin is the right home

The target repo's `CLAUDE.md` Plugin Boundaries table (if it has one) says what each plugin owns. A resource that does not fit any plugin's scope is not automatically a new plugin — say so and let the person decide between widening a boundary, renaming, and creating a plugin.

Check for a name collision in the target: a `skills/<name>/` or `agents/<name>.md` that already exists. A collision is either a rename or a re-graft, and those are opposite actions. Resolve it now, not during the copy.

## 2. Compute the closure

Walk the payload and list, with paths:

- Its own subdirectories — these are part of it.
- Every relative markdown link and `${CLAUDE_PLUGIN_ROOT}` path it contains, resolved against the source plugin root.
- Every `plugin:name` token, each classified invocational or descriptive per the contract.
- Every `subagent_type` value and `skills:` frontmatter entry.
- Every MCP tool and `allowed-tools` entry — the target may not have that server or permission.

```bash
SRC=<source-resource-path>
grep -rnoE '\]\((\.\.?/)[^)]+\)' "$SRC"
grep -rnoE '\$\{CLAUDE_PLUGIN_ROOT\}[^ )`"]*' "$SRC"
grep -rnoE '\b[a-z][a-z-]*:[a-z][a-z-]+' "$SRC"
grep -rnoE 'subagent_type[^,)]*' "$SRC"
```

Present the closure as a list of files that will be copied *in addition to* the payload, and a list of references that need a decision. Get agreement on that list before copying anything — an unnoticed dependency is the failure this step exists to prevent.

## 3. Copy

Same repo, `move` disposition: `git mv` so history follows the file.

Everything else: `cp -R`, then the source is left alone (`copy`) or removed with `git rm -r` after the target verifies (`move`). Never remove the source before the target passes verification.

For a rules or CLAUDE.md block, the payload is a span of text rather than a file. Insert it at the target under its own heading, and never inside another skill's managed markers.

## 4. Rewrite

Apply the rewrite map. Under `verbatim` fidelity, skip this and record each entry that *would* have changed as drift.

Order matters: rewrite the copied files' internal references before touching frontmatter names, so a rename does not have to be chased through links you have not fixed yet.

## 5. Register

- Bump the target plugin's version in `plugin.json` **and** its marketplace entry. Minor for a new resource, patch for a docs-only graft.
- Add the resource to the target `README.md`, and to the Plugin Boundaries table if the target repo keeps one.
- On a `move`, do the same subtraction at the source: bump the source plugin, drop the resource from its README and boundaries row.

## 6. Verify

```bash
bash <skill-dir>/scripts/check-graft.sh <target-plugin-dir>
```

Then run the target's own auditor for the payload kind — `audit-skill`, `audit-subagent`, `audit-hooks`, or `audit-claudemd`. A graft that passes reference integrity can still violate the target's authoring conventions, and the auditors are the thing that knows those.

On a `move`, run the checker against the **source** plugin too. Removing a resource can strand a reference in a sibling that pointed at it.

## 7. Commit

One commit for the graft, with the provenance trailers from the contract. On a cross-repo graft that is two commits in two repos — give both the same trailers so the pair is findable from either side.
