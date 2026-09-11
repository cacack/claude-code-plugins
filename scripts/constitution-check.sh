#!/usr/bin/env bash
#
# constitution-check.sh — verify the Success Criteria in CONSTITUTION.md.
#
# Each criterion in CONSTITUTION.md names the check below that settles it. A
# criterion that cannot be settled by a command is reported as a judgement call
# and never passes or fails silently — it is printed for a human to rule on.
#
# Exit codes:
#   0  every mechanical criterion passed
#   1  at least one mechanical criterion failed
#   2  at least one could not be evaluated (missing tooling); nothing failed
#
# Usage: make constitution-check   |   scripts/constitution-check.sh

set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "constitution-check: must run inside the git repository" >&2
  exit 2
}

FAILED=0
SKIPPED=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAILED=1; }
skip() { printf '  \033[33mSKIP\033[0m  %s\n' "$1"; SKIPPED=1; }
info() { printf '        %s\n' "$1"; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ── C1 ────────────────────────────────────────────────────────────────────────
# "The collection stays in use." Invocation frequency lives in the maintainer's
# local Claude Code history, not in this repository, and no in-repo proxy for it
# is honest — a stable skill needs no commits. Reported, never scored.
head_ "C1  The collection stays in use  (judgement call — reported, not scored)"

# `find -depth N` is BSD-only; count SKILL.md files, which is portable and exact.
total_skills=$(find plugins -name SKILL.md | wc -l | tr -d ' ')
stale=0
stale_list=""
while IFS= read -r skill; do
  dir=$(dirname "$skill")
  last=$(git log -1 --format=%ct -- "$dir" 2>/dev/null)
  [ -z "$last" ] && continue
  age_days=$(( ( $(date +%s) - last ) / 86400 ))
  if [ "$age_days" -gt 365 ]; then
    stale=$((stale + 1))
    stale_list="${stale_list}\n        · $(basename "$dir") (${age_days}d)"
  fi
done < <(find plugins -name SKILL.md | sort)

info "$total_skills skills; $stale with no commit in the last 365 days"
[ "$stale" -gt 0 ] && printf "%b\n" "$stale_list"
info "Whether they are actually invoked is yours to judge at the next refresh."

# ── C2 ────────────────────────────────────────────────────────────────────────
# "New skills can be added without restructuring existing ones." Checkable as:
# a commit adding a SKILL.md touches nothing outside that skill's own directory
# except the shared registry files every addition must touch.
head_ "C2  A new skill can be added without restructuring existing ones"

WINDOW_DAYS=90
SIBLING_EDIT_MAX=20   # see CONSTITUTION.md § Success Criteria, C2
SHARED='^(README\.md|CLAUDE\.md|CONSTITUTION\.md|\.claude-plugin/marketplace\.json|plugins/[^/]+/\.claude-plugin/plugin\.json|\.github/)'

adds=$(git log --diff-filter=A --format='%h' --since="${WINDOW_DAYS} days ago" -- '*/skills/*/SKILL.md')
if [ -z "$adds" ]; then
  pass "no skill added in the last ${WINDOW_DAYS} days — nothing to check"
else
  c2_bad=0
  for c in $adds; do
    sk=$(git show --format='' --name-only --diff-filter=A "$c" | grep 'skills/.*/SKILL\.md' | head -1)
    [ -z "$sk" ] && continue
    dir=$(dirname "$sk")
    # Only MODIFIED and DELETED files count — a commit that also *adds* a companion
    # agent or doc is additive growth, which is what this criterion wants. And a
    # small edit to a sibling is a cross-reference, not a restructure; the line
    # between them is SIBLING_EDIT_MAX, which CONSTITUTION.md states openly so the
    # number is auditable and movable rather than buried here.
    while IFS=$'\t' read -r added deleted f; do
      [ -z "${f:-}" ] && continue
      case "$f" in
        "$dir"/*) continue;;
      esac
      printf '%s' "$f" | grep -Eq "$SHARED" && continue
      [ "$added" = "-" ] && added=0
      [ "$deleted" = "-" ] && deleted=0
      churn=$((added + deleted))
      if [ "$churn" -gt "$SIBLING_EDIT_MAX" ]; then
        c2_bad=1
        fail "$c ($(basename "$dir")) reworked $f — $churn lines changed (limit $SIBLING_EDIT_MAX)"
      else
        info "cross-reference only: $c touched $f ($churn lines)"
      fi
    done < <(git show --format='' --numstat --diff-filter=MD "$c")
  done
  [ "$c2_bad" = "0" ] && pass "every skill added in the last ${WINDOW_DAYS} days was self-contained"
fi

# ── C3 ────────────────────────────────────────────────────────────────────────
head_ "C3  All resources validate cleanly against \`claude plugin validate\`"

if ! command -v claude >/dev/null 2>&1; then
  skip "the \`claude\` CLI is not on PATH — criterion not evaluated"
else
  c3_bad=0
  for p in plugins/*/; do
    if out=$(claude plugin validate "$p" 2>&1); then
      if printf '%s' "$out" | grep -qi 'warn'; then
        fail "$(basename "$p") validates with warnings"
        c3_bad=1
      fi
    else
      fail "$(basename "$p") failed validation"
      printf '%s\n' "$out" | tail -3 | sed 's/^/          /'
      c3_bad=1
    fi
  done
  [ "$c3_bad" = "0" ] && pass "all $(find plugins -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ') plugins validate with no warnings"
fi

# ── C4 ────────────────────────────────────────────────────────────────────────
# "The marketplace stays coherent." Three mechanical parts: every plugin
# directory is registered and every entry resolves; versions agree between
# plugin.json and marketplace.json; no plugin hard-dispatches another's agent.
head_ "C4  The marketplace stays coherent"

if ! command -v jq >/dev/null 2>&1; then
  skip "jq is not on PATH — registration and version-sync not evaluated"
else
  # (a) directories <-> marketplace entries
  dirs=$(for d in plugins/*/; do basename "$d"; done | sort)
  entries=$(jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort)
  if [ "$dirs" = "$entries" ]; then
    pass "every plugin directory is registered, and every entry resolves"
  else
    fail "plugins/ and marketplace.json disagree"
    diff <(printf '%s\n' "$dirs") <(printf '%s\n' "$entries") | sed 's/^/          /'
  fi

  # (b) version sync
  c4_ver=0
  for p in plugins/*/; do
    name=$(basename "$p")
    pv=$(jq -r '.version' "$p/.claude-plugin/plugin.json")
    mv=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .version' .claude-plugin/marketplace.json)
    if [ "$pv" != "$mv" ]; then
      fail "$name: plugin.json $pv != marketplace.json $mv"
      c4_ver=1
    fi
  done
  [ "$c4_ver" = "0" ] && pass "every plugin's version matches its marketplace entry"
fi

# (c) plugin boundaries — a dispatch target must live in the dispatching plugin
# Only real plugin names count as a dispatch target. Prose like `plugin:name` or
# a bare `skills:` frontmatter key is documentation, not a cross-plugin call.
c4_cross=0
PLUGINS_ALT=$(for d in plugins/*/; do basename "$d"; done | paste -sd'|' -)
while IFS= read -r hit; do
  file=${hit%%:*}
  owner=$(printf '%s' "$file" | cut -d/ -f2)
  targets=$(printf '%s' "$hit" | grep -oE "(${PLUGINS_ALT}):[a-z0-9-]+" || true)
  [ -z "$targets" ] && continue
  for target in $targets; do
    tplugin=${target%%:*}
    if [ "$tplugin" != "$owner" ]; then
      fail "$file dispatches \`$target\` across a plugin boundary (CLAUDE.md rule 7)"
      c4_cross=1
    fi
  done
done < <(grep -rn 'subagent_type' plugins/ --include='*.md' || true)
[ "$c4_cross" = "0" ] && pass "no plugin hard-dispatches another plugin's agent"

# ── C5 ────────────────────────────────────────────────────────────────────────
head_ "C5  CLAUDE.md stays within its line ceiling"

CEILING=250
lines=$(wc -l < CLAUDE.md | tr -d ' ')
if [ "$lines" -le "$CEILING" ]; then
  pass "CLAUDE.md is $lines lines (ceiling $CEILING)"
else
  fail "CLAUDE.md is $lines lines, $((lines - CEILING)) over the $CEILING-line ceiling"
fi

# ── result ────────────────────────────────────────────────────────────────────
printf '\n'
if [ "$FAILED" = "1" ]; then
  printf '\033[31mconstitution-check: at least one criterion failed.\033[0m\n'
  printf 'Fix the breach, or change the criterion in CONSTITUTION.md and say why it moved.\n'
  exit 1
elif [ "$SKIPPED" = "1" ]; then
  printf '\033[33mconstitution-check: nothing failed, but not everything could be evaluated.\033[0m\n'
  exit 2
else
  printf '\033[32mconstitution-check: every mechanical criterion passed.\033[0m\n'
  exit 0
fi
