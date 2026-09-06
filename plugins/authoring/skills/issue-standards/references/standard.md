# Issue Standard

The canonical standard for tracked issues across cacack repositories, on GitHub
and GitLab alike.

An issue is the durable record of a piece of work, and it gets read at three
moments. Once to decide whether the work is understood well enough to start.
Once by whoever picks it up, who needs to begin without going back to the
author. Once at the end, to decide whether it is done.

This standard defines what an issue must carry to survive all three reads. A
section earns its place here only by serving one of them.

The third read is the one issues historically serve worst. Acceptance criteria
say what to look for and not where to look, so "is this done?" means
reconstructing the work from pull requests and memory a month later.
[Evidence](#evidence--must) exists to close that.

The standard is **forge-agnostic** in its requirements and forge-specific only
where the mechanism differs. Where GitHub and GitLab diverge, both are named.

---

## Scope and authority

This standard owns **issue anatomy** — the sections an issue carries, what each
must say, and the bar it clears before work starts. It also owns the **evidence
contract**: what a satisfied acceptance criterion has to name.

It deliberately does not restate what lives elsewhere:

| Topic | Owned by |
|---|---|
| Document types, locations, and templates | `documentation-standards` |
| `CLAUDE.md` and `.claude/rules/` authoring | `create-claudemd` |
| PR/MR ↔ issue linking keywords, partial delivery, deviation disclosure | `delivery:issue-delivery` |
| Scoring a diff against an issue's criteria | `delivery:issue-compliance` |
| Discovering and ranking open work | `delivery:whats-next` |

**Binding.** The `MUST` rules below are the bar an issue clears before work
starts on it. `SHOULD` rules are targets to aim at; they do not block.

## Issue types

The type is a semantic signal read off the board, not an interchangeable
container. Pick it by what the work *is*, using **latitude** and **boundedness**
as the discriminators.

| Type | The work is | Bounded by |
|---|---|---|
| **Spike** | Almost entirely discovery — investigation, review, bake-off, proof of concept | A time-box, always |
| **Story** | Building something, with real design latitude in *how* | Its acceptance criteria |
| **Task** | Predefined work, typically procedure-backed, with no design latitude beyond the decision points the procedure already carries | Its acceptance criteria |
| **Bug** | Something already built not working as intended | Its acceptance criteria |

Latitude is the line between Story and Task. If you decide *how*, it is a Story.
If the procedure already decides *how*, and the only latitude is improving that
procedure or choosing between branches it documents, it is a Task.

A Spike is the only type bounded by time rather than by outcome. Its acceptance
criterion is that a decision or finding is **recorded**, never that
investigation happened. A Spike that ends with nothing written has not met its
criteria.

Bug may carry heavy discovery — triage, troubleshooting — and is still not
timeboxed: it stays open until the defect is fixed or a blocker to fixing it is
named. *Bug vs Spike*: Bug fixes broken behavior and is open-ended, Spike
answers a question and is timeboxed.

**Type is carried by a label** — `type:story`, `type:task`, `type:spike`,
`type:bug`. GitHub's native issue types are organization-scoped and unavailable
on personal repositories, and GitLab has no type field at all, so the label is
the portable mechanism. Use the native field instead wherever the repository
actually has one, and keep the label off in that case rather than carrying both.

## Grouping

A **milestone** groups work issues so a body of work can be read whole, by
someone who will never open its children. GitLab additionally offers epics,
which nest; use one where the instance has them and the work spans several
milestones.

A milestone is a container rather than work. Nobody is assigned one, and none is
pulled.

### A milestone carries a closure condition — MUST

A milestone carries a **description** stating what it is and a **closure
condition** — what has to be true for it to close, in terms a reader can check.

Where closure is the children closing, say *which* children. "Closes when every
skill in `authoring/` has a matching auditor" can be checked. "Closes when the
authoring work is done" restates the title.

A milestone whose closure condition amounts to "when I stop doing this kind of
work" is a bucket rather than a milestone, and it will still be open a year from
now. The forge offers a due date; a due date is not a closure condition, because
the date arriving does not make the work true.

### How many children

Roughly five to ten children reads as one body of work. Past ten, a reader
scanning the milestone can no longer tell what is left.

Treat the count as a signal rather than a limit. The closure condition is the
diagnostic and the number is only what makes you look. Twelve issues that close
when the last of twelve repositories is migrated is one body of work, and it is
fine at twelve. Six that close "when the project is stable" is a bucket, and
splitting it into two buckets of three fixes nothing.

### Where the content lives

Context that holds for the whole group lives on the milestone and is not copied
into each child. Context specific to one child lives on that child.

A child still stands on its own, because whoever picks it up starts there. The
test is whether a reader who opens the child alone can begin. Where they cannot,
the child is missing its own Context, and a link to the milestone does not
supply it.

### Membership is the milestone field, not a mention

**Set the milestone field — MUST.** An issue that names its milestone only in
prose is invisible to the milestone view, to the progress bar, and to every
`--milestone` query, so a grouping recorded that way is one nothing can report
on.

An issue belongs to at most one milestone, which is a property of the field
rather than a rule this standard adds. Work that reads as belonging to two is
usually two issues.

**Planned work SHOULD carry a milestone.** One-off and reactive work
legitimately carries none, and creating a milestone to hold a single issue adds
a level of hierarchy without adding meaning.

## Required fields

| Field | Required when | Notes |
|---|---|---|
| Title | Always | See [Title line](#title-line) |
| Body | Always | The sections in [Issue anatomy](#issue-anatomy) |
| Labels | Always | See [Labels](#labels) |
| Milestone | Work that belongs to a larger body of work | See [Grouping](#grouping) |
| Assignee | Before work starts | Self-assign on pull; it is what makes "in progress" visible |

## Issue anatomy

The body carries these sections, in this order.

### At a glance — MUST

Three to five sentences of plain English, and always the first thing in the
issue. It says what the work is and why it matters, to a reader who knows the
project but not this issue.

Write it so a person who reads only this section comes away with the right idea
of the work. No jargon Context has not yet introduced, no implementation detail,
and no long sentences.

This is the section that lets you scan a backlog, so it is the one worth
rewriting until it is short.

### Context — MUST

Why this issue exists. It answers three things, and a reader should be able to
find each one:

- **Why now** — the trigger: a failure, an audit, a dependency, a panel review,
  or a request.
- **What is missing** — the concrete gap, in terms of observable behaviour
  rather than of the fix.
- **Value** — what you gain by doing it, or what it costs to keep not doing it.

Value is the part most often missing, and it is what makes a `value:` label
defensible rather than a guess. State it even when it feels obvious, because
"obvious" is a property of the author's context and not of the issue. Six months
on, you are not the author.

### Acceptance Criteria — MUST

What "done" looks like, as observable conditions.

**Acceptance criteria are tests, not a task list.** "Update the skill" is an
activity. "`audit-skill` reports no findings against `issue-standards`" is a
criterion. The difference is what lets a second reader — or a later you — decide
the issue is done without redoing the work.

Each criterion:

- Is verifiable without asking the author.
- Names the observable state, not the action that produced it.
- Is independent enough to be checked on its own.

More than five criteria is a signal the issue holds more than one deliverable.

**Write them as a task list.** GitHub and GitLab both render `- [ ]` natively:
the issue shows a progress count, the milestone view aggregates it, and ticking
a box is a recorded event.

```markdown
- [ ] `make lint` is clean on the default branch
- [ ] The pinned version is v2 and nothing references v1
```

> The upstream standard this was adapted from forbids checkboxes, because Jira's
> tooling cannot rewrite part of a description without risking the rest of it.
> A Markdown issue body has no such hazard, so the prohibition does not travel.
> Ticking a box is a *convenience* signal; it is not evidence, and
> [Evidence](#evidence--must) is still owed.

**The criteria are a list, and their order is stable.** A criterion is
identified by its position — the third item is the third item — because that is
what an evidence entry refers to. Reordering or removing an entry silently
re-points every reference to it; see [Changing an issue after work
starts](#changing-an-issue-after-work-starts).

### Scope — SHOULD

What is in, and explicitly what is out.

Write it whenever the work is not obviously bounded: when it spans repositories,
when a reasonable person could read the issue two ways, or when it sits next to
adjacent work someone might fold in. It is the line that most often decides
whether an estimate holds.

### References — SHOULD

Where the reader goes next: files, other issues, pull requests, decision
records, dashboards, and the conversation that started it.

Every entry is a link, per [Linking](#linking). A bare path in a References list
is the most common form of that failure, because the list reads as navigation
while resolving to nothing.

### Proposed approach — MAY

A suggested solution, where you have one.

Mark it non-binding. It is an input to the implementer's judgment, never a
substitute for it. A proposed approach that is actually a requirement belongs in
Acceptance Criteria.

### Technical detail — MAY

Snippets, log excerpts, error output, screenshots, and configuration fragments.

Last, because it is reference material for whoever picks the issue up rather
than something the decision to start needs.

Date any capture of live state, and say how it was taken. An undated capture
cannot be told apart from one that has gone stale, and a reader who cannot date
it has to take it again.

## Evidence — MUST

Every criterion names the evidence that satisfied it, or says why it did not.

Deciding an issue is done means reading it without the work fresh in mind, and a
criterion's wording says what to look for rather than where to look. Evidence
closes that gap. It is what turns "the pinned version is v2" from an assertion
into something checkable in a minute.

**Evidence is recorded in a comment, never in the body.** The body holds what
was asked for; the comment holds what happened. A comment is additive, so
recording evidence can never damage the wording the work was agreed against, and
the two readings stay separable when they disagree. One comment per issue,
carrying every criterion in the issue's order, is easier to audit than one
comment per criterion.

A ticked checkbox is not evidence. It records that someone believed the
criterion was met; it names neither what satisfied it nor where to look.

Three forms are admissible, and a criterion takes exactly one:

| Form | Use it when | It must carry |
|---|---|---|
| **A change** | The criterion is satisfied by code that landed | The PR/MR URL. Where the criterion turns on a specific commit, job, or line, link that permalink too |
| **A direct observation** | The criterion is satisfied by something with no PR behind it — a command's output, a dashboard reading, a setting changed in a console, a document that now exists | What was observed, when, and how. Link the query, dashboard, or document |
| **A deferral** | The criterion cannot be met inside this issue | The successor issue's URL, and one sentence on what the deferral needs that this issue could not supply |

Every entry is a link, per [Linking](#linking). **"Done in the PR" is not
evidence**, because it names neither which PR nor what in it satisfied the
criterion.

**A deferred criterion stays in the list.** Deleting it loses the fact that the
issue was scoped to include it, and it shifts every position after it. The
deferral names a **successor issue**, and that issue exists and is linked before
the deferral is recorded. A deferral naming no successor has moved the gap
rather than closed it.

The successor does not have to be fully formed at the moment of deferral. What
the deferral owes is a real, linked, readable issue: the At a glance and Context
that say what is outstanding and why this issue could not do it.

Deferral is a re-scope; see [Changing an issue after work
starts](#changing-an-issue-after-work-starts).

The [evidence comment](#evidence-comment) template is in [Templates](#templates).

## Changing an issue after work starts

Before work starts, edit the body freely — see [Fixing an issue you did not
write](#fixing-an-issue-you-did-not-write). Once work starts, the body is the
thing the work is being measured against, and a body that moves silently breaks
that.

**A scope change after work starts is recorded before it is made — MUST.**
Rewriting a criterion, adding one, dropping one, reordering them, or narrowing
the title: each gets a comment naming what changed and why, and then the body
may be edited to match.

```markdown
Dropping criterion 3 — the upstream API it depended on was never released.
Body updated to match. Tracked separately in #57.
```

The comment is the whole point. A Markdown body is safe to edit and the forge
keeps an edit history, but nothing surfaces that history to a reader and nobody
goes looking for it. What is lost to a silent edit is the record, not the field.

> The upstream standard this was adapted from freezes the description
> absolutely, because Jira's tooling corrupts a description it rewrites in part
> and because a separate person verifies against wording a refinement session
> agreed. Neither holds here, so the rule keeps its purpose — a visible record —
> and drops its absolutism.

Evidence recorded in error is corrected in a further comment, never by editing
the criterion until the claim becomes true.

## Per-type additions

Each type adds to the sections above.

| Type | Additional requirements |
|---|---|
| **Spike** | The **question** it answers, stated as a question. The **time-box**, in days or sessions. The **artifact** it produces — a decision record, a design, a written comparison, a recommendation on an issue |
| **Bug** | **Observed** versus **expected** behaviour. **Reproduction** steps, or why it is not reproducible. **Blast radius** — what is affected and how badly. **First seen**, where known |
| **Task** | A link to the **procedure** the task executes. Where none exists, say so; that is usually a sign the issue is a Story |
| **Story** | Nothing beyond the base sections |

## Title line

The title is a list-scanning surface, so it is written to be read in a list.

- **Imperative mood**, matching commit subjects: "Add drift detection to the
  image pipeline", not "Adding" and not "Drift detection".
- **One deliverable** — a title joined by "and", "+", or "/" is two issues.
- **A concrete artifact** — vague verbs such as "improve", "investigate", "look
  into", or "handle" need a noun that says what changes.
- **No decoration** — no `[WIP]`, no repository name, no type prefix. The forge
  shows the number, the labels carry the type, and the repository is the
  repository.

## Linking

**Every resource an issue names is reachable from it — MUST.** A resource named
anywhere in the issue is linked at least once, in References if nowhere else.
Repeating the URL at every mention is not required and hurts the prose.

An issue that names a file, decision record, dashboard, or pull request with no
way to reach it makes every reader repeat the same search.

| Named in an issue | Link |
|---|---|
| A file, module, or directory | Its **permalink** — the blob URL at a commit sha. `path/to/file.md` renders as plain text in an issue body and reaches nothing; a branch URL rots as the branch moves |
| A specific line or range | The permalink with the line anchor. On both forges, pressing <kbd>y</kbd> on the blob page rewrites the URL to its permalink form |
| Another issue or a PR/MR in the same repository | `#123` is enough. Both forges autolink it, render its title on hover, and strike it through when closed |
| An issue or PR in another repository | `owner/repo#123` on GitHub, the full URL on GitLab. GitLab's `!123` merge-request shorthand does **not** resolve outside its own project |
| A dashboard, log query, or CI run | Its URL |
| The conversation that started it | Its permalink |

A bare path is acceptable only where the resource has no URL, such as a file
that does not exist yet.

This section governs issue bodies and comments. Inside a repository document,
relative links are correct and `documentation-standards` owns that case.

### Resolving a reference also checks it

An issue citing another issue, a PR, or a branch is asserting something about
that thing's state. Open each one while writing or revising the issue, because
the assertion decays without the issue changing.

A cited issue may have closed, a PR may have been closed rather than merged, and
the change an issue describes as pending may already be on the default branch. A
reference that resolves to a different world than the issue describes is the
most common way an issue that reads as ready turns out to be wrong. Checking is
cheap, and it is the only thing that catches this.

### Relationships between issues

A link in the body is narrative: it tells a reader where to go next. It appears
on one of the two issues and is not a relationship the forge can query.

**GitLab** has typed linked issues — record a real relationship there as well:

| Relationship | Link type |
|---|---|
| Work that must finish before this starts | Blocked by |
| Work this issue blocks | Blocks |
| Anything else worth connecting | Relates to |

**GitHub has no typed-link mechanism.** A mention in the body creates a
back-reference on the other issue, which is bidirectional but untyped, so the
*type* has to be stated in words: write "Blocked by #41", not a bare "#41". A
task list of `- [ ] #41` entries on a tracking issue is the closest GitHub gets
to a queryable relationship, and it is what its progress bars read.

Use a causal claim — "introduced by", "regression from" — only where the cause
is established. Where a cause is suspected rather than shown, say what is known
and relate the two without asserting the cause.

## Rendering

Issue bodies on both forges are Markdown, so most of what breaks in other
trackers does not apply here. Four things still do.

- **Relative links do not resolve in an issue body.** They resolve in a
  repository document, which is why the habit forms. In an issue they render as
  a link to nothing. Use permalinks.
- **A bare `@name` notifies that person**, including inside a blockquote of
  someone else's text. Inside a fenced code block it does not. Quote logs and
  transcripts in fences.
- **`#` at the start of a line is a heading, not an issue reference.** `#123` on
  its own line renders as an H1 reading "123". Put it mid-sentence, or write
  `Closes #123`.
- **Autolinking is repository-scoped.** `#123` in a repository other than the
  one that owns the issue silently resolves to *that* repository's 123, which is
  a real issue with a plausible title and the wrong content.

**Read the saved issue rather than trusting the editor preview**, and confirm
the links resolve. This matters most for anything written through an API, where
nothing renders at all until it is stored.

## Attribution

**Content generated by Claude Code says so.** An issue body or comment that
Claude authored opens with an attribution line — "Generated by Claude Code" or
equivalent — before anything else.

The reason is not credit. Generated text and typed text carry different
warranties: the second reflects something a person checked, and the first
reflects something a person may or may not have read closely. A reader deciding
how much weight to put on a stated fact needs to know which one they have.

## Labels

Every issue carries four categories of label.

| Category | Cardinality | Values |
|---|---|---|
| Type | Exactly one | `type:story`, `type:task`, `type:spike`, `type:bug` |
| Class | Exactly one | `class:planned`, `class:unplanned` |
| Theme | One or more | Subject area, e.g. `skills`, `docs`, `ci`, `security`, `tooling` |
| Value | Exactly one | `value:low`, `value:medium`, `value:high` |
| Effort | Exactly one | `effort:low`, `effort:medium`, `effort:high` |

**GitLab scoped labels use `::`** — `value::high`, `type::bug` — and the forge
enforces one-per-scope for you. GitHub uses `:` and enforces nothing, so the
cardinality above is a discipline there rather than a guarantee.

Type, class, value, and effort take a **prefix**. Theme does not, and the
difference is a rule rather than an accident: a category whose values are a
closed set takes a prefix, and an open vocabulary stays bare. A prefix pays for
itself by making autocomplete offer the whole set. Theme is open-ended by
design, so a prefix there would namespace a list that never stops growing.

Value and effort exist so a backlog can be sliced by quadrant — high value
against low effort is the quick-win filter. `delivery:whats-next` reads exactly
these labels to rank open work, and it falls back to a `priority:` ladder where
they are absent. Prefer value and effort; the ladder is the fallback, not a
second system.

### Theme spelling

A theme **SHOULD** be kebab-case and **SHOULD** spell the word out —
`kubernetes` rather than `k8s`, `observability` rather than `o11y`. Both halves
exist for one reason: a reader reaching for a theme reaches for the spelled-out
kebab form, and every abbreviation invites a second spelling that halves the
filter.

**Drift is a split filter, not a style violation.** Before renaming a label,
count both spellings. Where the other holds no issues, nothing is split and the
rename is churn against a preference. Where it holds issues, one theme is being
reported as two and the rename is worth doing.

Labels inherited from a forge's defaults or from an upstream project keep the
casing their owners chose. Renaming one splits filters and breaks saved searches
built on it, which is the harm this rule exists to prevent rather than cause.

### Class decides whether work can join a milestone

**The test is whether the work arrived or whether you chose it**, and it is not
whether the work is operational.

`class:unplanned` is work that arrived — a failure, a break-fix, a dependency
alert, a request from outside. Nobody put it on a roadmap, and more of it will
arrive next week whether or not this issue closes.

`class:planned` is work someone chose to do, and it is the only class eligible
for a milestone. Plenty of planned work is routine: a dependency sweep, a
quarterly audit, rolling every plugin onto a new convention. Each was chosen,
each has an end state, and each belongs to a milestone that closes on it. Say so
with a theme label, which is the axis that carries the domain.

**An unplanned issue MUST NOT be given a milestone.** A milestone over arriving
work can close only "when I stop doing this kind of work", which
[Grouping](#grouping) already rules out as a bucket. Unplanned work is grouped by
its theme label instead, which keeps it filterable without asserting that it is a
body of work that finishes.

A recurring obligation is filed per instance, and the instance is planned. "Q2
dependency sweep" was chosen, has an end state, and closes. The obligation behind
it never closes, and it is not what gets filed.

An unlabelled issue is untriaged rather than planned. Carrying both values
explicitly is what makes the untriaged queue countable:

```bash
# GitHub — issues carrying neither class label
gh issue list --state open --limit 200 --json number,title,labels \
  --jq '.[] | select([.labels[].name] | any(startswith("class:")) | not)
        | "\(.number)\t\(.title)"'
```

The `select(... | not)` form is deliberate: an issue with **no labels at all**
has to fall into the untriaged bucket, and that is the issue most likely to be
untriaged. A filter written as "not in the set of class labels" over a label
array drops the empty case on most query languages.

A milestone carries a theme label and a `value:` label where the forge allows
labels on one at all, and no `effort:` and no `class:`. Effort on a container
would be the sum of its children's, which the progress bar already shows. A
milestone is planned by definition, so a class label on one records nothing.

## Definition of Ready

An issue may be started when all of the following hold.

1. Type is set, and matches the [type definitions](#issue-types).
2. Title is imperative, names one deliverable, and names a concrete artifact.
3. At a glance is present, in plain English, and runs three to five sentences.
4. Context states why now, what is missing, and the value.
5. Acceptance criteria are present, observable, and checkable without asking the
   author.
6. Per-type additions for the type are present.
7. Every resource the issue names is reachable from it, and file references are
   permalinks rather than paths.
8. Every reference has been opened, and what it shows matches what the issue says
   about it.
9. Relationships to other issues are recorded — as typed links on GitLab, as
   stated relationships in the body on GitHub.
10. Where the issue is part of a larger body of work, its milestone is set
    through the milestone field.
11. Labels carry a `type:`, a `class:`, a theme, a `value:`, and an `effort:`,
    and no `class:unplanned` issue carries a milestone.
12. No unanswered question sits in the comments.
13. Nothing it depends on is itself unready.

A Spike additionally states its time-box and the artifact it must produce.

A milestone is held to [Grouping](#grouping) instead of to this list, which
describes work a person can pull.

## Quality checklist

The signals below mark an issue that will stall after it is started. They are
review triggers rather than automatic rejections.

**Clarity:**

- No body, or a body under three sentences.
- At a glance missing, or written in implementation terms rather than plain
  English.
- No explicit acceptance criteria.
- Criteria phrased as activities rather than as observable conditions.
- No value stated in Context.
- Title contains a conjunction suggesting more than one deliverable.
- Title uses a vague verb with no concrete artifact.
- A file, decision record, dashboard, or PR named without a link.
- A repository-relative path used where a permalink exists.
- A branch URL used where a permalink was needed.
- A cross-repository `#123` that resolves to the wrong repository's issue.
- A cited issue, PR, or branch whose current state contradicts what the issue
  says about it.
- A capture of live state with no date on it.
- A criterion with no evidence recorded for it.
- Evidence recorded as "done in the PR", naming neither which PR nor what in it
  satisfied the criterion.
- A ticked checkbox offered in place of evidence.
- A deferred criterion with no successor issue, or a successor that does not say
  what is outstanding.
- A deferred criterion deleted from the list rather than left in place.
- A body edited after work started with no comment recording the change.
- Generated content with no attribution line.
- Unanswered questions in the comments.
- Depends on, or blocks, an issue that is itself not ready.
- A milestone with no closure condition, or one no reader can check.
- A milestone holding only Stories, where the bugs and spikes the work produced
  sit outside it.
- A child whose Context makes sense only with the milestone open beside it.
- Context copied from the milestone into each of its children.

**Size:**

- More than five acceptance criteria.
- Spans more than one repository.
- Mentions both design and implementation in the same issue.
- A milestone with more than about ten children, where the closure condition no
  longer names a finite set.

## Fixing an issue you did not write

Bringing someone else's issue up to this standard is useful work and does not
need their permission. It does need their meaning left intact. Most issues that
fail this standard fail on shape rather than on thinking, so the edit is usually
a restructure and not a rewrite.

- **Change shape, not substance.** Add the missing sections, reorder them, and
  resolve the references. Do not replace their facts or judgment with yours.
- **Leave the fields carrying someone else's decision.** Assignee stays. A label
  owned by an upstream project stays.
- **Correct a stale fact, and say so.** Where a reference resolves to a
  different state than the issue describes, fix the issue and name the
  correction. That is not a rewrite.
- **Flag a re-scope instead of performing it.** Narrowing the title or dropping
  a deliverable is the author's call. Record it as an open question in Scope and
  raise it in a comment.
- **Say what you could not source.** A value statement inferred from the issue's
  own facts is weaker than one the author can defend, and the difference
  matters. Mark which it is.
- **Comment what changed and why.** The edit history holds the diff, but no
  reader goes looking for it. One comment naming the structural changes, the
  corrections, and the open questions is what makes the edit reviewable.

## Templates

Copy-paste blocks live in `templates/blocks/`, one per type plus the evidence
comment. Drop-in forge issue templates live in `templates/forge/` — GitHub issue
forms under `github/`, GitLab description templates under `gitlab/` — and the
skill's `scaffold` mode writes them into a repository.

| Type | Block | GitHub form | GitLab template |
|---|---|---|---|
| Story, Task | `blocks/story-task.md` | `forge/github/story.yml`, `task.yml` | `forge/gitlab/Story.md`, `Task.md` |
| Spike | `blocks/spike.md` | `forge/github/spike.yml` | `forge/gitlab/Spike.md` |
| Bug | `blocks/bug.md` | `forge/github/bug.yml` | `forge/gitlab/Bug.md` |
| Milestone | `blocks/milestone.md` | — | — |
| Evidence comment | `blocks/evidence-comment.md` | — | — |

A milestone has no issue template because it is not an issue; paste the block
into its description field.
