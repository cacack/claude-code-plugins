#!/usr/bin/env bash
# check-graft.sh — verify that a plugin's internal references still resolve after a graft.
#
# Reports facts, not verdicts. Every ERROR is a reference that cannot resolve at runtime
# in an installed plugin, because an installed plugin ships only its own subtree.
#
# Fails CLOSED. When an input it depends on is missing (the sibling-plugin listing, the
# `claude` CLI), it says so on a `skip` line and counts it — a check that did not run must
# never be indistinguishable from a check that passed.
#
# Usage: check-graft.sh <plugin-dir>

set -uo pipefail

die() { printf 'check-graft: %s\n' "$1" >&2; exit 2; }

[ $# -eq 1 ] || die "usage: check-graft.sh <plugin-dir>"
[ -d "$1" ] || die "not a directory: $1"

ROOT=$(cd "$1" && pwd -P) || die "cannot resolve $1"
PLUGIN_JSON="$ROOT/.claude-plugin/plugin.json"
[ -f "$PLUGIN_JSON" ] || die "no .claude-plugin/plugin.json under $ROOT — not a plugin root"

FINDINGS=$(mktemp "${TMPDIR:-/tmp}/check-graft.XXXXXX") || die "cannot create temp file"
MD_LIST=$(mktemp "${TMPDIR:-/tmp}/check-graft-md.XXXXXX") || die "cannot create temp file"
trap 'rm -f "$FINDINGS" "$MD_LIST"' EXIT

err()  { printf 'ERROR\t%s\n' "$1" >>"$FINDINGS"; }
info() { printf 'note\t%s\n'  "$1" >>"$FINDINGS"; }
skip() { printf 'skip\t%s\n'  "$1" >>"$FINDINGS"; }

# --- Identity -----------------------------------------------------------------------
# The directory name is authoritative: it is what Claude Code namespaces resources by,
# and it cannot be reordered the way a JSON key can. plugin.json is cross-checked rather
# than trusted — taking the first textual "name" from it returns the *author's* name on a
# file that happens to order `author` first, which silently inverts every self-reference.
PLUGIN_NAME=$(basename "$ROOT")

# Only a "name" at brace depth 1 is the plugin's own. Collecting every "name" in the file
# let an author object's name satisfy the identity check, so a plugin.json declaring the
# wrong name passed whenever author.name happened to equal the directory name. Taking the
# first match instead would reintroduce the key-order dependence the comment above warns
# about, so track depth: exact, order-independent, indentation-independent, and no jq.
json_names() {
  awk '
    {
      instr = 0; esc = 0; stripped = ""
      for (i = 1; i <= length($0); i++) {
        c = substr($0, i, 1)
        if (esc) { esc = 0; stripped = stripped c; continue }
        if (c == "\\") { esc = 1; stripped = stripped c; continue }
        if (c == "\"") { instr = !instr; stripped = stripped c; continue }
        if (!instr && (c == "{" || c == "}")) {
          # Text accumulated before a brace sits at the depth in effect while it was read,
          # which is the depth BEFORE this brace changes it — for "{" the outer level, for
          # "}" the level being closed. Emitting after the change placed the name of a
          # nested author object at depth 1 on a minified line.
          prev = depth
          depth += (c == "{") ? 1 : -1
          emit(stripped, prev)
          stripped = ""
          continue
        }
        stripped = stripped c
      }
      emit(stripped, depth)
    }
    function emit(text, d) {
      if (d != 1) return
      while (match(text, /"name"[[:space:]]*:[[:space:]]*"[^"]*"/)) {
        v = substr(text, RSTART, RLENGTH)
        sub(/^"name"[[:space:]]*:[[:space:]]*"/, "", v)
        sub(/"$/, "", v)
        print v
        text = substr(text, RSTART + RLENGTH)
      }
    }
  ' "$1" 2>/dev/null
}

if ! json_names "$PLUGIN_JSON" | grep -qxF "$PLUGIN_NAME"; then
  err ".claude-plugin/plugin.json declares no \"name\" matching the directory \"$PLUGIN_NAME\""
fi

# --- Sibling plugins ----------------------------------------------------------------
# Read from the filesystem, not the catalog. The catalog carries the marketplace's own
# name and an author name per entry, each of which becomes a bogus namespace; the sibling
# directories are exactly the set of names that can actually resolve.
MARKET_PLUGINS=$(dirname "$ROOT")
KNOWN_PLUGINS="$PLUGIN_NAME"          # always present, so a self-reference is always checked
sibling_count=0
if [ -d "$MARKET_PLUGINS" ]; then
  for d in "$MARKET_PLUGINS"/*/; do
    [ -d "$d/.claude-plugin" ] || continue
    n=$(basename "$d")
    sibling_count=$((sibling_count + 1))
    case " $KNOWN_PLUGINS " in *" $n "*) ;; *) KNOWN_PLUGINS="$KNOWN_PLUGINS $n" ;; esac
  done
fi
if [ "$sibling_count" -le 1 ]; then
  skip "found $sibling_count sibling plugin(s) beside this one — cross-plugin reference checks are narrowed to self-references only"
fi

# --- Helpers ------------------------------------------------------------------------
# Lexical containment. Cheap, and correct for `..` traversal.
contained() { case "$1" in "$ROOT"/*|"$ROOT") return 0 ;; *) return 1 ;; esac; }

# Physical containment for a path that exists. A lexically-inside path can still land
# outside via a symlinked parent directory, which `test -e` follows without complaint.
phys_contained() {
  d=$(cd "$(dirname "$1")" 2>/dev/null && pwd -P) || return 1
  case "$d" in "$ROOT"|"$ROOT"/*) return 0 ;; *) return 1 ;; esac
}

find "$ROOT" -type f -name '*.md' -print0 > "$MD_LIST"
rel_of() { printf '%s' "${1#"$ROOT"/}"; }

# --- 0. Symlinks ---------------------------------------------------------------------
# A plugin subtree has no legitimate reason to carry one, and `cp -R` preserves them, so
# a symlink in a grafted payload is an escape route past every containment check below.
SYMLINKS=0
while IFS= read -r -d '' link; do
  SYMLINKS=1
  err "$(rel_of "$link") is a symlink -> $(readlink "$link") (a plugin subtree must not contain symlinks)"
done < <(find "$ROOT" -type l -print0)

# --- 1-4. One pass per file over links, path variables, and namespace tokens ----------
# A single awk invocation per file emits typed records for all three checks. Three
# separate per-file loops each spawning awk+grep cost ~370 subprocesses on this repo's
# largest plugin; the checker runs 2-3 times per graft, so that overhead is paid over.
#
# The pass keeps BOTH views of each line. Links are read from the sanitized view, because
# a markdown link inside a fence or a backtick span is a rendered sample, not a live link.
# Path variables and namespace tokens are read from the RAW line, because this repo writes
# real ${CLAUDE_PLUGIN_ROOT} paths and real subagent_type lists inside code spans and
# fences — sanitizing there hid the references most worth checking.
#
# Marker set for `invocational` is derived from how this repo actually writes dispatches.
# Keying only on `subagent_type` classified "Launch the `panels:rude-qa` subagent via the
# Task tool" as prose, which is a live cross-plugin dispatch. Bare lowercase `invoke` is
# deliberately absent: it matches ordinary prose ("skills that invoke real tools").
# `commands/` is a legal third resource kind: some marketplaces keep their slash commands
# there rather than as skills, and a `plugin:name` naming one resolves fine at runtime.
# Omitting it reported every such reference as a dangling self-reference — 6 of 15 errors
# on the first real plugin that used the directory.
resource_exists() {
  [ -d "$ROOT/skills/$1" ] || [ -f "$ROOT/agents/$1.md" ] || [ -f "$ROOT/commands/$1.md" ]
}

TAB=$(printf '\t')
NL=$'\n'   # NOT $(printf '\n') — command substitution strips the trailing newline

# A newline in a filename cannot be passed through `awk -v`, so such a file would be
# scanned partially or not at all. Reject it outright rather than reporting a clean pass
# over content that was never read — same reasoning as the symlink rule above.
reject_odd_name() {
  case "$1" in
    *"$NL"*) err "a file under $(dirname "$(rel_of "$1")") has a newline in its name (cannot be scanned — rename it)"; return 1 ;;
  esac
  return 0
}

while IFS= read -r -d '' file; do
  reject_odd_name "$file" || continue
  rel_file=$(rel_of "$file")
  # ${CLAUDE_SKILL_DIR} resolves against the enclosing skill directory, not the plugin root.
  skill_dir=$ROOT
  case "$file" in
    "$ROOT"/skills/*) skill_dir="$ROOT/skills/$(printf '%s' "${file#"$ROOT"/skills/}" | cut -d/ -f1)" ;;
  esac

  awk -v base="$(dirname "$file")" -v root="$ROOT" -v skilldir="$skill_dir" '
    function norm(p,   parts, n, i, keep, m, out) {
      n = split(p, parts, "/"); m = 0
      for (i = 1; i <= n; i++) {
        if (parts[i] == "" || parts[i] == ".") continue
        if (parts[i] == "..") { if (m > 0) m--; continue }
        keep[++m] = parts[i]
      }
      out = ""
      for (i = 1; i <= m; i++) out = out "/" keep[i]
      return (out == "") ? "/" : out
    }
    function placeholder(x) { return (x == "" || x ~ /^[<{$]/ || x ~ /\.\.\./) }
    # Strip code spans. ``...`` runs first and is cut by index() rather than a regex,
    # because a double-backtick span legally contains single backticks — ERE has no
    # non-greedy match, so one gsub over both forms shreds `` [`x`](url) `` into the
    # live-looking link `[](url)`. An unterminated `` is left alone.
    function strip_spans(s,   i, j) {
      while ((i = index(s, "``")) > 0) {
        j = index(substr(s, i + 2), "``")
        if (j == 0) break
        s = substr(s, 1, i - 1) substr(s, i + 2 + j + 1)
      }
      gsub(/`[^`]*`/, "", s)
      return s
    }
    {
      raw = $0

      # --- sanitized view, for links only
      if (raw ~ /^[[:space:]]*(```|~~~)/) { fence = !fence; clean = "" }
      else if (fence) { clean = "" }
      else { clean = strip_spans(raw) }

      s = clean
      while (match(s, /\]\([^)( \t]+\)/)) {
        link = substr(s, RSTART + 2, RLENGTH - 3)
        s = substr(s, RSTART + RLENGTH)
        sub(/#.*$/, "", link)
        if (placeholder(link) || link ~ /:\/\// || link ~ /^mailto:/) continue
        if (link ~ /^\//) { print "L\t" NR "\t" link "\tABSOLUTE"; continue }
        print "L\t" NR "\t" link "\t" norm(base "/" link)
      }

      # --- raw view, for path variables
      s = raw
      while (match(s, /\$\{CLAUDE_(PLUGIN_ROOT|SKILL_DIR)\}\/[^ )`"'"'"']*/)) {
        ref = substr(s, RSTART, RLENGTH)
        s = substr(s, RSTART + RLENGTH)
        ref2 = ref
        if (index(ref, "PLUGIN_ROOT")) { b = root;     sub(/^\$\{CLAUDE_PLUGIN_ROOT\}\//, "", ref2) }
        else                           { b = skilldir; sub(/^\$\{CLAUDE_SKILL_DIR\}\//,  "", ref2) }
        if (placeholder(ref2)) continue
        print "V\t" NR "\t" ref "\t" norm(b "/" ref2)
      }

      # --- raw view, for namespace tokens
      kind = (raw ~ /subagent_type|agentType|Skill\(|Task tool|Task call|Launch|Dispatch|Delegate|Spawn/) \
             ? "invocational" : "descriptive"
      s = raw
      while (match(s, /[a-z][a-z0-9-]*:[a-z][a-z0-9-]+/)) {
        tok = substr(s, RSTART, RLENGTH)
        s = substr(s, RSTART + RLENGTH)
        print "N\t" NR "\t" kind "\t" tok
      }
    }' "$file" | sort -u | while IFS="$TAB" read -r type lineno a b; do
      case "$type" in
        L)
          if [ "$b" = ABSOLUTE ]; then
            err "$rel_file:$lineno -> $a (absolute path escapes plugin root)"
          elif ! contained "$b"; then
            err "$rel_file:$lineno -> $a (escapes plugin root)"
          elif [ ! -e "$b" ]; then
            err "$rel_file:$lineno -> $a (dangling)"
          elif [ "$SYMLINKS" -eq 1 ] && ! phys_contained "$b"; then
            err "$rel_file:$lineno -> $a (resolves outside plugin root via a symlinked parent)"
          fi
          ;;
        V)
          if ! contained "$b"; then
            err "$rel_file:$lineno -> $a (escapes plugin root)"
          elif [ ! -e "$b" ]; then
            err "$rel_file:$lineno -> $a (missing from this plugin)"
          fi
          ;;
        N)
          ns=${b%%:*}
          res=${b#*:}
          case "$res" in *-) continue ;; esac          # `reviewer-*` and friends name nothing
          case " $KNOWN_PLUGINS " in *" $ns "*) ;; *) continue ;; esac
          if [ "$ns" = "$PLUGIN_NAME" ]; then
            resource_exists "$res" \
              || err "$rel_file:$lineno $b (no such resource in this plugin)"
          elif [ "$a" = invocational ]; then
            err "$rel_file:$lineno $b (invocational reference across a plugin boundary)"
          else
            info "$rel_file:$lineno $b (cross-plugin mention — descriptive, verify)"
          fi
          ;;
      esac
    done
done < "$MD_LIST"

# --- 5. Agent `skills:` frontmatter must name skills in this plugin -------------------
# Handles all three legal YAML shapes. Recognizing only the block list silently passed
# `skills: [a, b]`, and a `skills:` key that parses to nothing is reported rather than
# treated as an empty list.
if [ -d "$ROOT/agents" ]; then
  while IFS= read -r -d '' file; do
    reject_odd_name "$file" || continue
    rel_file=$(rel_of "$file")
    parsed=$(awk '
      /^---[[:space:]]*$/ { fm++; next }
      fm != 1 { next }
      /^skills:[[:space:]]*\[/ {
        line = $0
        sub(/^skills:[[:space:]]*\[/, "", line); sub(/\].*$/, "", line)
        n = split(line, a, ",")
        for (i = 1; i <= n; i++) { gsub(/[[:space:]"'"'"']/, "", a[i]); if (a[i] != "") print a[i] }
        seen = 1; next
      }
      /^skills:[[:space:]]*[^[:space:]]/ {
        line = $0; sub(/^skills:[[:space:]]*/, "", line)
        gsub(/[[:space:]"'"'"']/, "", line); if (line != "") print line
        seen = 1; next
      }
      /^skills:[[:space:]]*$/ { on = 1; seen = 1; next }
      on && /^[[:space:]]*-[[:space:]]*/ { sub(/^[[:space:]]*-[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); print; next }
      on && /^[^[:space:]]/ { on = 0 }
      END { if (seen && !NR) exit 0 }
    ' "$file")
    if grep -qE '^skills:' "$file" && [ -z "$parsed" ]; then
      info "$rel_file has a skills: key that parsed to no entries — check its YAML shape"
    fi
    printf '%s\n' "$parsed" | while IFS= read -r want; do
      [ -n "$want" ] || continue
      case "$want" in
        *:*)
          ns=${want%%:*}
          if [ "$ns" != "$PLUGIN_NAME" ]; then
            err "$rel_file skills: $want (cross-plugin reference — a skills: entry must name a skill in this plugin)"
            continue
          fi
          want=${want#*:}
          ;;
      esac
      [ -d "$ROOT/skills/$want" ] || err "$rel_file skills: $want (no such skill in this plugin)"
    done
  done < <(find "$ROOT/agents" -type f -name '*.md' -print0)
fi

# --- 6. Structural validation ---------------------------------------------------------
if command -v claude >/dev/null 2>&1; then
  if out=$(claude plugin validate "$ROOT" 2>&1); then
    VALIDATE='ok    claude plugin validate passed'
  else
    err "claude plugin validate failed: $(printf '%s' "$out" | tr '\n' ' ')"
    VALIDATE=''
  fi
else
  skip "claude not on PATH — structural validation did not run"
  VALIDATE=''
fi

# --- Report ---------------------------------------------------------------------------
printf '\n== %s (%s)\n\n' "$PLUGIN_NAME" "$ROOT"

DEDUP=$(mktemp "${TMPDIR:-/tmp}/check-graft-out.XXXXXX") || die "cannot create temp file"
sort -u "$FINDINGS" > "$DEDUP"

awk -F'\t' '$1=="ERROR"{printf "%-5s %s\n", $1, $2}' "$DEDUP"
awk -F'\t' '$1=="skip" {printf "%-5s %s\n", $1, $2}' "$DEDUP"
NOTE_CAP=20
awk -F'\t' -v cap="$NOTE_CAP" '$1=="note"{n++; if (n<=cap) printf "%-5s %s\n", $1, $2}
  END { if (n > cap) printf "note  ... %d more descriptive mention(s) not listed\n", n - cap }' "$DEDUP"
[ -n "$VALIDATE" ] && printf '%s\n' "$VALIDATE"

n_err=$(awk -F'\t' '$1=="ERROR"' "$DEDUP" | wc -l | tr -d ' ')
n_info=$(awk -F'\t' '$1=="note"' "$DEDUP" | wc -l | tr -d ' ')
n_skip=$(awk -F'\t' '$1=="skip"' "$DEDUP" | wc -l | tr -d ' ')
rm -f "$DEDUP"

printf '\n%s error(s), %s note(s), %s skipped check(s)\n' "$n_err" "$n_info" "$n_skip"
[ "$n_skip" -eq 0 ] || printf 'A skipped check did not run. Exit 0 does not mean it passed.\n'
[ "$n_err" -eq 0 ] || exit 1
