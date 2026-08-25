# Workflow: Graft a Whole Plugin

A plugin directory moves into another marketplace. Fewer reference problems than a resource graft, because the subtree arrives intact, and more registration problems, because the plugin now has to exist in a catalog that has never heard of it.

Read `references/graft-contract.md` first.

## 1. Establish that the target is a marketplace

It needs `.claude-plugin/marketplace.json` at its root. A repo with `.claude/` but no marketplace file is not a marketplace, and grafting a plugin into it produces something nothing will install. Say so rather than improvising a layout.

Check the plugin's name against every existing entry in the target catalog. Plugin names are the install identity, so a collision is fatal and has to be resolved by renaming before anything is copied — which means renaming the directory, `plugin.json` `name`, and every `plugin:name` reference inside the plugin that points at itself.

## 2. Inventory what crosses the boundary

The subtree comes intact, so its internal references survive. What needs attention is the plugin's references **outward**:

```bash
SRC=<source-plugin-dir>
grep -rnoE '\b[a-z][a-z-]*:[a-z][a-z-]+' "$SRC" | grep -v "$(basename "$SRC"):"
```

Every hit names another plugin. For each, decide: does that plugin also exist in the target marketplace, is the reference descriptive (leave it), or is it invocational and now broken (resolve it — usually by grafting that resource in too, or by dropping the capability and saying so).

## 3. Copy and re-root

`cp -R` the plugin to `<target-repo>/plugins/<name>/`. Then in its `plugin.json`, adopt the target marketplace's identity fields — `author`, `homepage`, `repository` — and keep `name`, `description`, and `version`.

**Version decision.** Ask. Carrying the version preserves the plugin's history and is right for a move. Resetting to `1.0.0` is right when the graft is a fork that will diverge, and it makes the two lineages independently versionable. There is no safe default, and a wrong choice here is awkward to undo once tags exist.

## 4. Register in the catalog

Add an entry to the target `.claude-plugin/marketplace.json` with every field the target's sibling entries carry — typically `name`, `version`, `description`, `author`, `source: "./plugins/<name>"`, `strict: true`. Copy the *shape* from an existing entry in that file rather than from this contract, since marketplaces differ.

Then update the target repo's `README.md` and, if it keeps one, the Plugin Boundaries table in `CLAUDE.md`. A plugin absent from those is undiscoverable even though it installs.

## 5. Verify

```bash
bash <skill-dir>/scripts/check-graft.sh <target-repo>/plugins/<name>
claude plugin validate <target-repo>/plugins/<name>
```

Then install it in an isolated HOME, which is the only check that proves the catalog entry and the subtree agree:

```bash
HOME=$(mktemp -d) bash -c 'cd <target-repo> && claude plugin marketplace add ./ && claude plugin install <name>@<marketplace-name>'
```

## 6. Land it, and deal with the source

Commit with the provenance trailers. Tag per the target repo's scheme — this repo uses `<name>/vX.Y.Z`, others differ, so read the target's own convention rather than assuming.

On a `move`, remove the plugin from the source repo in its own commit: delete the subtree, delete its marketplace entry, and update the source README and boundaries table. Do this only after the target verifies. Existing tags in the source stay — tags are immutable, and a retired plugin's history is still its history.
