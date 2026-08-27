#!/usr/bin/env bash
# selftest.sh — assert check-graft.sh detects each class of graft breakage.
#
# Every fixture below is written in the idiom this repo ACTUALLY uses, not a convenient
# one: bare-relative links (4:1 more common here than dot-prefixed), ${CLAUDE_PLUGIN_ROOT}
# inside backticks, and dispatches phrased "Launch the `x` subagent via the Task tool"
# rather than with a literal subagent_type. An earlier fixture used the convenient forms
# and passed while the checker was blind to roughly 80% of real references.
#
# Usage: selftest.sh   (exits 0 if every assertion holds)

set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
CHECKER="$HERE/check-graft.sh"
FIX=$(mktemp -d "${TMPDIR:-/tmp}/graft-selftest.XXXXXX") || exit 2
trap 'rm -rf "$FIX"' EXIT

pass=0; fail=0
ok()  { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL %s\n' "$1"; }

# expect <label> <output> <pattern>
expect()     { case "$2" in *"$3"*) ok "$1" ;; *) bad "$1 (missing: $3)" ;; esac; }
expect_not() { case "$2" in *"$3"*) bad "$1 (unexpected: $3)" ;; *) ok "$1" ;; esac; }

mk_plugin() {  # mk_plugin <name> [json-name]
  mkdir -p "$FIX/plugins/$1/.claude-plugin" "$FIX/plugins/$1/skills" "$FIX/plugins/$1/agents"
  printf '{"name":"%s","version":"1.0.0","description":"fixture"}\n' "${2:-$1}" \
    > "$FIX/plugins/$1/.claude-plugin/plugin.json"
}

# ---------------------------------------------------------------- broken fixture -----
mk_plugin tgt
mk_plugin sibling
mkdir -p "$FIX/plugins/tgt/skills/good" "$FIX/plugins/sibling/agents" "$FIX/outside"
echo "leak" > "$FIX/outside/leak.md"
touch "$FIX/plugins/sibling/agents/some-agent.md"
mkdir -p "$FIX/plugins/tgt/commands"
touch "$FIX/plugins/tgt/commands/a-command.md"

cat > "$FIX/plugins/tgt/skills/good/SKILL.md" <<'M'
---
name: good
description: fixture skill
---
Bare-relative dangling (this repo's dominant style): [refs](references/missing.md)
Dot-prefixed dangling: [refs](./references/also-missing.md)
Escaping: [leak](../../../../outside/leak.md)
Real and fine: [self](SKILL.md)
A URL is not a path: [docs](https://example.com/x.md)
Backticked plugin-root escape: `${CLAUDE_PLUGIN_ROOT}/../../outside/leak.md`
Backticked plugin-root missing: `${CLAUDE_PLUGIN_ROOT}/references/absent.md`

Dispatch, repo idiom with no subagent_type on the line:
2. **Dispatch to the agent.** Launch the `sibling:some-agent` subagent via the Task tool.

Explicit form: each call uses the matching `subagent_type` (`sibling:some-agent`).
Self-reference that does not exist: tgt:ghost-skill
Self-reference that does exist: tgt:good
Self-reference to a command, the third resource kind: tgt:a-command
Descriptive prose only: the sibling:some-agent agent does something similar.
A glob names nothing: sibling:reviewer-*
M

cat > "$FIX/plugins/tgt/skills/good/fenced.md" <<'M'
# Fenced references are real

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/absent-helper.sh" --flag
```
M

cat > "$FIX/plugins/tgt/agents/helper.md" <<'M'
---
name: helper
description: fixture agent
skills: [good, vanished]
---
Body.
M
cat > "$FIX/plugins/tgt/agents/scalar.md" <<'M'
---
name: scalar
description: fixture agent
skills: sibling:good
---
Body.
M
ln -s /etc "$FIX/plugins/tgt/skills/good/etclink"

out=$(bash "$CHECKER" "$FIX/plugins/tgt" 2>&1); rc=$?
printf '\n--- broken fixture (exit %s) ---\n' "$rc"

expect "bare-relative dangling link"        "$out" "references/missing.md (dangling)"
expect "dot-prefixed dangling link"         "$out" "./references/also-missing.md (dangling)"
expect "escaping relative link"             "$out" "outside/leak.md (escapes plugin root)"
expect "backticked plugin-root escape"      "$out" 'CLAUDE_PLUGIN_ROOT}/../../outside/leak.md (escapes plugin root)'
expect "backticked plugin-root missing"     "$out" 'CLAUDE_PLUGIN_ROOT}/references/absent.md (missing from this plugin)'
expect "fenced CLAUDE_SKILL_DIR missing"    "$out" 'CLAUDE_SKILL_DIR}/scripts/absent-helper.sh (missing from this plugin)'
expect "Task-tool dispatch idiom caught"    "$out" "sibling:some-agent (invocational reference across a plugin boundary)"
expect "self-reference to missing resource" "$out" "tgt:ghost-skill (no such resource in this plugin)"
expect "symlink in tree"                    "$out" "etclink is a symlink"
expect "flow-style skills: entry"           "$out" "skills: vanished (no such skill in this plugin)"
expect "cross-plugin skills: entry"         "$out" "skills: sibling:good (cross-plugin reference"
expect "descriptive mention is a note"      "$out" "descriptive, verify"
expect_not "URL not treated as a path"      "$out" "example.com"
expect_not "existing self-link not flagged" "$out" "SKILL.md (dangling)"
expect_not "command resolves as a resource"  "$out" "tgt:a-command"
expect_not "glob placeholder not flagged"   "$out" "reviewer-"
[ "$rc" -eq 1 ] && ok "exit 1 on errors" || bad "exit 1 on errors (got $rc)"

# ------------------------------------------------- plugin.json name mismatch ---------
mk_plugin renamed wrong-name
out=$(bash "$CHECKER" "$FIX/plugins/renamed" 2>&1)
printf '\n--- plugin.json name mismatch ---\n'
expect "dir/plugin.json name mismatch" "$out" 'declares no "name" matching the directory'

# ------------------------------------------------------- no sibling plugins ----------
SOLO=$(mktemp -d "${TMPDIR:-/tmp}/graft-solo.XXXXXX")
mkdir -p "$SOLO/plugins/lonely/.claude-plugin" "$SOLO/plugins/lonely/skills"
printf '{"name":"lonely","version":"1.0.0"}\n' > "$SOLO/plugins/lonely/.claude-plugin/plugin.json"
printf -- '---\nname: x\n---\nSelf-ref that is missing: lonely:nope\n' \
  > "$SOLO/plugins/lonely/skills/x.md"
out=$(bash "$CHECKER" "$SOLO/plugins/lonely" 2>&1)
printf '\n--- solo plugin (no siblings) ---\n'
expect "narrowing is announced"          "$out" "cross-plugin reference checks are narrowed"
expect "self-check still runs"           "$out" "lonely:nope (no such resource in this plugin)"
expect "skip is surfaced in the trailer" "$out" "does not mean it passed"
rm -rf "$SOLO"

# ---------------------------------------------------------- hostile filenames --------
# A space must still be scanned; a newline cannot be passed through `awk -v` and must be
# reported rather than silently half-scanned.
mk_plugin odd
mkdir -p "$FIX/plugins/odd/skills"
printf 'Dangling: [x](nope.md)\n'     > "$FIX/plugins/odd/skills/we ird.md"
printf 'Dangling: [y](alsonope.md)\n' > "$FIX/plugins/odd/skills/$(printf 'new\nline').md"
out=$(bash "$CHECKER" "$FIX/plugins/odd" 2>&1)
printf '\n--- hostile filenames ---\n'
expect "space in filename still scanned" "$out" "we ird.md:1 -> nope.md (dangling)"
expect "newline in filename rejected"    "$out" "has a newline in its name"

# ------------------------------------------------------------- clean fixture ---------
mk_plugin clean
mkdir -p "$FIX/plugins/clean/skills/fine"
printf -- '---\nname: fine\n---\nA real link: [self](SKILL.md)\nProse about tgt:good elsewhere.\n' \
  > "$FIX/plugins/clean/skills/fine/SKILL.md"
out=$(bash "$CHECKER" "$FIX/plugins/clean" 2>&1); rc=$?
printf '\n--- clean fixture (exit %s) ---\n' "$rc"
expect_not "no errors on a clean plugin" "$out" "ERROR"
[ "$rc" -eq 0 ] && ok "exit 0 when clean" || bad "exit 0 when clean (got $rc)"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
