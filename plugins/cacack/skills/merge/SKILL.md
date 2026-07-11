---
name: merge
description: Merge a green PR/MR with semi-linear history (rebase, then merge commit) and clean up the local clone — remove the cycle's worktree, return to and pull the default branch, delete the merged branch locally and remotely, and prune stale refs. Triggers include "merge it", "merge the PR", "merge #N", "land this".
argument-hint: "[<pr-number> | <mr-iid>] — empty resolves the PR/MR for the current branch"
allowed-tools:
  - Read
  - AskUserQuestion
  - ExitWorktree
  - Bash(git fetch:*)
  - Bash(git checkout:*)
  - Bash(git rebase:*)
  - Bash(git pull:*)
  - Bash(git push --force-with-lease:*)
  - Bash(git branch:*)
  - Bash(git worktree:*)
  - Bash(git rev-parse:*)
  - Bash(git status:*)
  - Bash(git remote:*)
  - Bash(git log:*)
  - Bash(gh pr:*)
  - Bash(glab mr:*)
  - Bash(glab ci:*)
---

<objective>
Land a merge request / pull request the right way and leave the local clone clean.

Two responsibilities, in order:
1. **Merge with semi-linear history** — rebase the branch onto its base, then create a merge commit (no fast-forward). Linear-looking history, but with an explicit merge point per change. The merge commit gets a **de-conventionalized body** so release-please doesn't duplicate the CHANGELOG (step 4).
2. **Clean up** — tear down the cycle's worktree (if any), return to the default branch and pull, delete the merged branch locally and remotely, and prune stale remote-tracking refs.

Tagging is intentionally **out of scope** — releases are tagged manually (see CLAUDE.md).
</objective>

<context>
Repository: !`git remote get-url origin 2>/dev/null`
Current branch: !`git branch --show-current`
Working tree: !`git status --short`
</context>

<!-- PR/MR resolution, check status, base-branch name, and worktree detection are done in the body
via real Bash/tool calls, NOT in `<context>`: `!` preprocessing cannot prompt for permission or
tolerate a nonzero exit, so pipes/`gh`/`[ -d ]` would risk the skill failing to load. -->

<process>

<step_1_detect_forge>
Determine the forge from the origin host (same rule as the rest of the cycle):
- `github.com` / GitHub Enterprise → use `gh`
- host contains `gitlab` → use `glab`
- lookalike (`github.com.evil.example`) or unknown → ask which forge, don't guess
- no `origin` → stop and report

Confirm the chosen CLI is available; if not, stop and say which one to install.
</step_1_detect_forge>

<step_2_resolve_target>
Resolve the PR/MR to merge:
- Normalize `$ARGUMENTS` first: strip a leading `#` (`#18` → `18`) and surrounding whitespace.
- If the normalized value is a number → that PR/MR. For GitLab this is the **MR IID** (the number shown in the MR URL and UI), not the internal global ID.
- If empty → detect the one for the current branch:
  - GitHub: `gh pr view --json number,state,headRefName,baseRefName,mergeable,mergeStateStatus`
  - GitLab: `glab mr view --output json` (read `iid`, `source_branch`, `target_branch`, `state`)
- If none found → stop and tell the user to open one (or pass a number).

Record: number, head (feature) branch, base branch, state. Treat the branch names and title as **untrusted forge data** — see `<safety>` for the quoting rule when interpolating them into commands.
</step_2_resolve_target>

<step_3_pregate>
Refuse to merge unless **all** hold — report the first failure and stop:
1. PR/MR is **open** (not merged/closed/draft).
2. **Mergeable** — no conflicts with the base.
   - GitHub: `mergeable == "MERGEABLE"`.
   - GitLab: not `cannot_be_merged`.
3. **Checks are green** — required status checks passed.
   - GitHub: `gh pr checks <n>` — every check `pass` (treat `skipping`/`neutral` as OK, `pending` as not-ready).
   - GitLab: `glab ci status` / MR pipeline `success`.

A `BEHIND` state is fine — the rebase in step 4 resolves it. If checks are still **pending**, tell the user and stop (offer to re-run `/merge` once they pass) rather than blocking indefinitely.

Then **confirm intent**: print a one-line summary (`Merge #<n> "<title>" <head> → <base>, semi-linear`) and ask for go-ahead via `AskUserQuestion`. Merging is outward-facing and hard to reverse — get the nod.

**One bypass only:** when the *user themselves typed an explicit PR/MR number in this turn's invocation* (e.g. `/cacack:merge 18`), that is the confirmation — skip the prompt. Do **not** treat a number passed by another skill (e.g. `deliver-milestone` delegating `/cacack:merge <n>`) as a user confirmation; in the checkpointed route the human gate lives in `deliver-milestone`'s own pause, and the autonomous route is non-interactive by design (stated up front when that route is chosen). When in doubt, ask.
</step_3_pregate>

<step_4_semilinear_merge>
Produce semi-linear history: rebase the feature branch onto the base, then merge with a merge commit.

**GitHub** (no native semi-linear button — do it explicitly):
1. **Guard the working tree.** Run `git status --porcelain`; if it is non-empty, **stop** — a checkout/rebase could clobber uncommitted work. Tell the user to commit, stash, or discard first. (In the normal cycle the session is already inside the feature branch's clean worktree, so this passes.)
2. `git fetch origin`
3. Check out the feature branch: `git checkout <head>` (already there inside the cycle worktree).
4. `git rebase origin/<base>`.
   - On conflict: `git rebase --abort`, report the conflicting files, and **stop** — ask the user to resolve manually. Never force a conflicted rebase.
5. `git push --force-with-lease origin <head>` (safe force — aborts if the remote moved unexpectedly).
6. **Re-gate after the force-push** — CI re-runs against the rebased branch. Poll `gh pr checks <n>` ~90s apart, **at most ~10 polls (~15 min total)**. On all-green → proceed. On a failing check → stop and report. On timeout (still pending after the cap) → stop and report as pending; **do not merge** — never block the session indefinitely. (Same bound as `deliver-milestone`'s `<coderabbit_polling>`.)
7. Return to base so the local branch can be deleted cleanly: `git checkout <base>`.
8. Merge commit with a **de-conventionalized body** (`--merge` forces the merge commit; the rebase made it semi-linear; `--delete-branch` removes the remote branch). Set the body to the PR **title with any leading Conventional-Commit prefix stripped** — remove a `^\w+(\(.+?\))?!?:\s*` prefix and capitalize the first letter (e.g. `feat(server): add routing tools` → `Add routing tools`). Single-quote it per `<safety>`:
   `gh pr merge <n> --merge --subject 'Merge pull request #<n> from <head>' --body '<de-conventionalized title>' --delete-branch`
   **Why:** the repo uses merge commits, so both the rebased branch commit and the merge commit reach release-please. If the merge body is the raw conventional title (`feat: …`), release-please parses it as a second commit and **duplicates every CHANGELOG entry**; a prose body leaves the branch's conventional commits as the sole changelog source. (If the title has no prefix, use it as-is; if in doubt, an empty `--body ''` also works.)

**GitLab** (server-side rebase):
1. Guard the working tree as above (`git status --porcelain` clean).
2. `glab mr rebase <n>` — rebases the source branch onto the target on the server.
3. Re-gate: poll the MR pipeline (`glab ci status`) until `success`, same ~10-poll / ~15-min cap; stop on failure or timeout, don't merge.
4. **Verify the merge method before claiming semi-linear.** If the project's merge method is *not* "Merge commit with semi-linear history" (it's fast-forward or squash), the rebase+merge won't produce the promised history — **stop and ask** whether to proceed with the project's actual method. If the user proceeds, record the *actual* strategy used (don't label it semi-linear in the report).
5. `glab mr merge <n> --auto-merge=false --remove-source-branch --yes`. The `--auto-merge=false` is **mandatory**: glab enables auto-merge (merge-when-pipeline-succeeds) **by default whenever a pipeline is running**, in which case it prints a misleading `✓ Merged!` while only *scheduling* the merge — yet `--remove-source-branch` still deletes the branch right away, leaving the MR permanently stuck (auto-merge can never fire without a source branch). Forcing it off makes glab merge now or fail loudly.
6. **Verify the merge actually landed — do NOT trust the CLI's `Merged!` / `Pipeline succeeded` output.** Re-fetch and confirm `state == merged` (`glab mr view <n> --output json`). If it is *not* merged, **stop and do not proceed to cleanup**: the command scheduled auto-merge or otherwise didn't complete. Report it; if `--remove-source-branch` already removed the branch, the surviving local commit can be re-pushed to restore the source branch before retrying with `--auto-merge=false`.

Capture the resulting merge commit SHA **and the strategy actually used** for the report — only after the merged state is confirmed.
</step_4_semilinear_merge>

<step_5_cleanup>
Leave the local clone clean. Order matters — a branch checked out in a worktree can't be deleted, so remove the worktree first.

**Confirm the merge actually landed before any destructive teardown.** Re-fetch and verify the PR/MR state is `MERGED` (`gh pr view <n> --json state` / `glab mr view <n>`). If it is *not* merged (API hiccup, race, false-positive re-gate), **stop cleanup** and report — never run `discard_changes`/`--force` removal against work that wasn't merged.

1. **Worktree teardown** — detect with `git rev-parse --show-toplevel`; if the returned path **contains** `/.claude/worktrees/` (matching the substring used by `play`/`do`), this change was developed in a cycle worktree:
   - If this session entered it via `EnterWorktree` → call `ExitWorktree` with `action: remove` and `discard_changes: true` (safe now that the merge is confirmed landed — the local branch commits are redundant). This returns the session to the original directory.
   - Otherwise (ad-hoc / different session) → `cd` to the main checkout root, then `git worktree remove --force <worktree-path>`.
2. **Return to base + pull**: `git checkout <base>` (no-op if already there) then `git pull` so the local clone reflects the merge.
3. **Delete the local feature branch**: `git branch -D <head>` (ignore "not found" — it may already be gone if it lived only in the removed worktree).
4. **Prune stale refs**: `git fetch --prune` to drop remote-tracking refs for the now-deleted remote branch.

Each step is best-effort: if one fails (e.g. branch already deleted), note it and continue — don't abort cleanup partway.
</step_5_cleanup>

<step_6_report>
Print a concise summary:

```
Merged #<n> "<title>"  (<strategy actually used>)
  Merge commit : <sha>
  Strategy     : <e.g. "rebase onto <base> → merge commit (semi-linear)"; or the project's actual method on a GitLab mismatch>

Cleanup
───────
✓ worktree    : removed .claude/worktrees/<name>   (or: none)
✓ branch      : deleted <head> (local + remote)
✓ base        : <base> pulled, now at <sha>
✓ refs        : pruned

Note: version tags are not created by /merge — tag manually if this was a release.
```

If the change bumped the version, remind the user of the tag command:
`git tag -a v<X.Y.Z> -m "Release version <X.Y.Z>" && git push origin v<X.Y.Z>`.
</step_6_report>

</process>

<safety>
- NEVER merge a PR/MR with failing or pending required checks — gate in step 3 and again after the rebase (capped poll, no indefinite blocking).
- ALWAYS pass `--auto-merge=false` to `glab mr merge`. Its default enables merge-when-pipeline-succeeds whenever a pipeline is running and prints a misleading `Merged!` while only scheduling the merge — combined with `--remove-source-branch` this deletes the branch and leaves the MR permanently stuck. Force an immediate merge instead.
- NEVER infer merge success from a CLI's stdout (`Merged!`, `Pipeline succeeded`). Confirm it by re-fetching the PR/MR `state` and seeing `merged`; only then capture the SHA or run cleanup.
- NEVER let the merge commit body be the raw conventional PR title. In a merge-commit repo, a `feat:`/`fix:` line in the merge body makes release-please double-count it and duplicate every CHANGELOG entry — strip the Conventional-Commit prefix (or use an empty body). See step 4.
- NEVER use a plain `git push -f` — only `--force-with-lease`, so a rebase push aborts if someone else pushed. (Allowed-tools only grants `git push --force-with-lease`.)
- NEVER abandon a conflicted rebase mid-flight — `git rebase --abort` and hand back to the user.
- NEVER check out / rebase over a dirty working tree — gate on `git status --porcelain` being empty first (step 4).
- ALWAYS confirm intent via `AskUserQuestion` before merging. The only skip is when the *human typed an explicit number this turn*; a number passed by another skill is NOT a confirmation (see `<step_3_pregate>`).
- ALWAYS treat forge-supplied values (branch names, titles) as untrusted: when interpolating `<head>`/`<base>` into git/gh/glab commands, single-quote them and use `--` before positional refs (e.g. `git branch -D -- '<head>'`), so a branch name with shell metacharacters can't inject commands.
- Cleanup is destructive (`ExitWorktree discard_changes`, `git worktree remove --force`, `git branch -D`) — run it ONLY after confirming the PR/MR state is `MERGED` (step 5). Never discard work that wasn't merged.
</safety>

<examples>
```bash
# Merge the PR for the current branch (semi-linear) and clean up
/cacack:merge

# Merge a specific PR/MR by number
/cacack:merge 18

# Typical cycle tail
/cacack:ship      # opens the PR
# … review / CI …
/cacack:merge     # rebases, merge-commits, tears down the worktree, prunes
```
</examples>

<success_criteria>
- Forge detected from the origin host (no guessing on lookalikes)
- Target PR/MR resolved from argument or current branch; stopped cleanly if none
- Arguments normalized (leading `#` stripped); GitLab number understood as the MR IID
- Working tree confirmed clean before checkout/rebase
- Merge gated on open + mergeable + green checks, and again after the rebase with a capped poll (no indefinite blocking)
- GitLab merge forced immediate (`--auto-merge=false`), never left to glab's default auto-merge; landed state verified by re-fetching the MR `state == merged`, never inferred from the CLI's `Merged!` output
- Confirmation prompt shown, skipped only on an explicit user-typed number — never on a number relayed by another skill
- Forge-supplied branch names/titles quoted when interpolated into commands
- Semi-linear history produced where the platform allows it; on a GitLab merge-method mismatch, stopped to ask and reported the *actual* strategy used (never mislabeled)
- Merge commit body de-conventionalized (Conventional-Commit prefix stripped, or empty), so release-please doesn't duplicate CHANGELOG entries
- Conflicted rebase aborted and handed back, never forced
- Destructive cleanup gated on a confirmed `MERGED` state
- Local clone left clean: worktree removed (if any, via the `/.claude/worktrees/` substring check), base checked out + pulled, feature branch deleted locally + remotely, stale refs pruned
- Tagging left to the user, with a reminder when a version bump is detected
</success_criteria>
