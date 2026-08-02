---
name: issue-delivery
description: Close the loop between a PR/MR and the tracked issue it traces to. Use when opening a hand-rolled pull or merge request that references a GitHub/GitLab issue, choosing between the closing keywords (Closes/Fixes/Resolves) and a non-closing reference (Refs), confirming a diff meets the issue's stated acceptance criteria before merging, deciding what to do with an issue that a PR only partially delivers, and disclosing where the implementation departed from what the issue specified.
user-invocable: false
---

<objective>
Never let "merged" masquerade as "done." A merged PR is evidence that code landed, not that an
issue's deliverables were met — the boxes get checked deliberately or not at all. This skill covers
the mechanics of linking, the bookkeeping when delivery is partial, and the disclosure owed at
review time.
</objective>

<scope>
`/ship`, the `shipper` agent and `deliver-milestone` already run this loop on the paths they own.
This skill is for the hand-rolled path: a `gh pr create` / `glab mr create` typed directly, or a
merge performed outside those workflows.

**Coverage scoring belongs to `issue-compliance`, not here.** That skill owns detecting the issue
reference, fetching the issue, extracting explicit and implicit acceptance criteria, scoring each
one COMPLETE / PARTIAL / MISSING, and recommending a linking keyword from the resulting coverage.
Invoke it to get the verdict. Everything below is what you do with the verdict once you have it.
</scope>

<linking>
Put the reference in the **PR/MR body**, not only in a commit message or the title.

- **Closing keywords** — `Closes #N`, `Fixes #N`, `Resolves #N` are equivalent; pick one and use it
  consistently. Merging then auto-closes the issue and the work stays traceable.
- **Non-closing reference** — `Refs #N` when the PR touches the issue without finishing it. It links
  the two without letting the merge close anything.
- **Cross-repository** — `Closes owner/repo#N` when the issue lives elsewhere.

Two traps worth knowing:

- A closing keyword only fires when the PR merges into the **default branch**. Stacked onto a
  feature branch, it links but never closes — the issue then needs closing by hand once the stack
  lands.
- Nothing validates the number. A typo'd `#N` silently closes an unrelated issue or nothing at all;
  confirm the number resolves to the issue you mean before opening the PR.
</linking>

<partial_delivery>
When any criterion is unmet or deliberately deferred, the issue does **not** close.

1. Use `Refs #N` rather than a closing keyword.
2. Comment on the issue stating exactly what is done and what remains — not "partially addressed."
   The comment is what makes the remaining scope legible to whoever picks it up.
3. Narrow the issue to what actually remains, so its title and body describe the open work rather
   than the original whole.
4. If the remainder is large or belongs to a different concern, split it into a fresh issue and
   link the two, then close the original against what shipped.

Deferring a criterion is a decision, so say it was one. Silence reads as an oversight and gets
re-litigated later.
</partial_delivery>

<deviations>
When the implementation departs from what the issue specifies — a different pattern than the one
requested, a sub-feature deferred, an approach the issue ruled out — state it explicitly in the PR
body at review time. Diverging silently and letting a reviewer discover it costs more than saying
so up front, and a deviation that survives review unmentioned becomes undocumented behavior.

Name the deviation, why it happened, and what it costs.
</deviations>

<success_criteria>
- The PR/MR body carries a reference to every issue it traces to
- The keyword matches the actual coverage: closing only when the criteria are met, `Refs` otherwise
- Partial delivery left the issue open, scoped to the remaining work, with a comment saying what
  shipped
- Every departure from the issue's stated approach is named in the PR body
</success_criteria>
