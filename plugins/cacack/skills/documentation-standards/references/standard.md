# Documentation Standard

The canonical standard for project documentation across cacack repositories.
Four dimensions: **types**, **locations**, **organization**, **formatting**.

The model is a lean **OSS-style root** (the files a newcomer or tool expects by
convention) over a structured **`docs/` reference layer** (in-depth material,
organized by document type and written from templates). Go is used for concrete
API-doc examples; substitute your language's idiom.

The standard is **forge-agnostic**: everything it prescribes lives at the repo
root or under `docs/`, the two locations both GitHub and GitLab recognize. The
handful of files that only exist as forge configuration — change-request
templates, issue templates, sponsorship — are irreducibly forge-specific and are called out
separately (see *Forge-specific config* in Dimension 2) rather than mixed into
the portable taxonomy.

---

## Dimension 1 — Types (what each document is, and its audience)

Classify every document by **audience** first — audience determines its
location, organization, and voice.

| Audience | The question it answers | Documents |
|----------|-------------------------|-----------|
| **Users / consumers** | "How do I use this?" | `README.md`, `USAGE.md`, inline API docs, `examples/` |
| **Contributors** | "How do I change this?" | `CONTRIBUTING.md`, `docs/TESTING.md`, dev-setup docs |
| **Maintainers (reference)** | "Why is it this way? What's the deep detail?" | `docs/**` reference layer (see Dimension 2), design & research notes |
| **Agents (Claude Code)** | "How should Claude work in this repo?" | `CLAUDE.md`, `.claude/rules/*.md` |
| **Operators** | "How do I run, deploy, or recover it?" | `SECURITY.md`, `docs/operations/**` |
| **Stewards (direction)** | "What is this, for whom, and what won't we do?" | `CONSTITUTION.md` (optional `GOVERNANCE.md` for *who decides & how*) |
| **Everyone (meta)** | project meta / legal / history | `LICENSE`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md` |

When writing the `docs/` reference layer, also consider which of these deeper
audiences the content serves — they determine technical depth and what to call
out explicitly:

| Audience | Primary concerns |
|----------|------------------|
| **Architects** | Patterns, integration, scalability |
| **DevOps / operators** | Operations, reliability, troubleshooting |
| **Managers** | Risk, dependencies, business impact |
| **Security engineers** | Threats, compliance, access control |

Call out security and operational concerns explicitly when relevant.

Canonical **root** types, each with **one** purpose:

- **`README.md`** — the front door. What it is (1–2 sentences), why it exists,
  quick start, install, minimal usage, and links out to everything else.
  User-facing entrypoint; never a dumping ground for reference detail.
- **`CLAUDE.md`** — guidance for Claude Code **only**, never user documentation.
  Slim; defers detail to `.claude/rules/` and `docs/`. (Author with
  `create-claudemd`; audit with `audit-claudemd`.)
- **`CONTRIBUTING.md`** — contributor onboarding: dev setup, commands, code
  standards, commit and change-request conventions, and the testing bar.
- **`CODE_OF_CONDUCT.md`** — expected conduct and enforcement contact. Adopt a
  standard text (e.g. Contributor Covenant) rather than authoring one; both
  GitHub and GitLab recognize it at the root.
- **`CHANGELOG.md`** — release history. Prefer **generated** (release-please /
  conventional commits) over hand-maintained.
- **`SECURITY.md`** — vulnerability-reporting policy and supported versions.
- **`CONSTITUTION.md`** — the project's charter/intent: mission, audience,
  principles, non-goals, success criteria. The apex doc every other document,
  decision, and policy is judged against. One screen; if it grows, the detail
  belongs in `docs/`. Optional but recommended. (Author/refresh with
  `constitution`; review activity against it with `panel-product`.)
- **`GOVERNANCE.md`** — *optional, and distinct from `CONSTITUTION.md`*: who runs
  the project and how — roles, decision-making process, how maintainers are
  added or removed. `CONSTITUTION.md` is *intent/direction*; `GOVERNANCE.md` is
  *people/authority*. Add only when the project has real multi-party governance;
  a solo or internal project rarely needs it.
- **`LICENSE`** — legal.
- **`CODEOWNERS`** — *optional*: maps paths to reviewers. Portable across forges
  only at `CODEOWNERS` (root) or `docs/CODEOWNERS` — both GitHub and GitLab
  resolve those; avoid the forge-specific `.github/`/`.gitlab/` copies if you
  want it to travel. Default to root (matching `LICENSE`/`SECURITY.md`); move to
  `docs/CODEOWNERS` only when the root is already at its indexing limit.
- **Optional root indexes** — `FEATURES.md` (exhaustive feature list), `IDEAS.md`
  (unvetted concepts), `USAGE.md` (extended examples). Add only when the root
  README genuinely cannot hold them.

Canonical **`docs/` reference-layer** types — each governed by a template in
`templates/` (copy the template, fill the sections, remove placeholder text):

| Document type | Lives in | Template |
|---------------|----------|----------|
| **Architecture** — how the pieces relate, patterns, intent | `docs/architecture/` | `templates/architecture-template.md` |
| **Architecture Decision Record** — one decision, its rationale and trade-offs | `docs/decisions/` | `templates/adr-template.md` |
| **Design** — implementation-level design, active during build | `docs/designs/` | `templates/design-template.md` |
| **Governance policy** — a requirement stated self-contained | `docs/governance/policies/` | `templates/policy-template.md` |
| **Guide** — consumer-facing how-to | `docs/guides/` | `templates/guide-template.md` |
| **Runbook** — one failure domain, how to run/recover | `docs/operations/runbooks/` | `templates/runbook-template.md` |
| **Reference** — lookup material (tables, ranges, enumerations) | `docs/reference/` | `templates/reference-template.md` |
| **Incubator** — raw ideas being shaped before they graduate | `docs/incubator/` | *(freeform; no template)* |

Other canonical pieces:

- **Inline API docs (godoc / docstrings)** — the API reference lives in the
  code, not in prose. Every exported symbol is documented. (Not covered by the
  templates above — the templates govern the `docs/` layer, the code governs its
  own reference.)
- **Non-file** — planned work lives in the issue tracker (Issues + Milestones),
  **not** a `ROADMAP.md`.

**New-type test:** create a new document type only when it has a distinct
audience **and** answers a distinct question no existing document owns.
Otherwise it is a *section* in an existing document.

---

## Dimension 2 — Locations (where each lives)

**Root** — only the documents a newcomer or a tool expects by convention:
`README`, `LICENSE`, `CONTRIBUTING`, `CHANGELOG`, `SECURITY`, `CLAUDE.md`,
`CODE_OF_CONDUCT`, and `CONSTITUTION.md` (plus an optional `GOVERNANCE.md` or
`CODEOWNERS`).
Plus, at most, a few top-level indexes (`FEATURES`/`IDEAS`/`USAGE`). The root is
a table of contents, not a library — keep it lean; the all-caps charter/meta
docs are the standing exception, not license to accrete reference material.

**`docs/`** — the structured reference layer. Use the standard subdirectories,
creating only those a project needs:

| Directory | Contents |
|-----------|----------|
| `docs/architecture/` | Solution and capability architectures with diagrams |
| `docs/decisions/` | Architecture Decision Records (ADRs) |
| `docs/designs/` | Implementation-level design documents (active during build, archived after) |
| `docs/governance/` | Policies, standards, and responsibility matrices |
| `docs/guides/` | Consumer-facing how-to documentation |
| `docs/incubator/` | Raw ideas being captured and shaped before they graduate |
| `docs/operations/` | Runbooks (`runbooks/`) and procedures (`procedures/`) |
| `docs/reference/` | Lookup material — tables, ranges, enumerations |
| `docs/images/` | Diagram PNGs, referenced from the docs that use them |

- Not all directories are required — create only those relevant to the project.
  At minimum, `decisions/` and `operations/` should exist once the project has
  either.
- Each directory carries a `README.md` explaining its purpose and indexing its
  contents.
- **ADRs** use a zero-padded numeric prefix (`0001-title-with-dashes.md`), never
  renumbered.

### Documentation altitude

Each artifact type documents at a fixed altitude; detail lives at exactly one
altitude and lower altitudes point up or down rather than duplicating:

| Altitude | Artifact | Records | Does NOT record |
|----------|----------|---------|-----------------|
| **Decision** | ADRs (`docs/decisions/`) | the choice, rationale, alternatives, trade-offs | statement- or implementation-level detail |
| **Conceptual** | Architecture docs (`docs/architecture/`) | how the pieces relate, patterns, intent | literal implementation; points to code |
| **Literal** | Code (+ inline API docs) | the exact implementation, kept self-documenting | — (it is the source of truth) |

**Alongside code** — API docs inline; every package/module carries a
package-level doc (Go: in `doc.go` or the primary file). Significant subpackages
may carry a local `README` for orientation.

**`.claude/rules/`** — agent rules; path-scoped when they apply to only part of
the tree.

**Issue tracker** — roadmap, planned features, bugs. Not files in the repo.

### Forge-specific config (not portable)

A few files are forge configuration, not documentation, and cannot live at the
root or under `docs/`. Prescribe neither location as canonical — use whichever
forge hosts the project, and treat these as out of the portable taxonomy:

| Purpose | GitHub | GitLab |
|---------|--------|--------|
| Change-request templates | `.github/PULL_REQUEST_TEMPLATE.md` | `.gitlab/merge_request_templates/*.md` |
| Issue templates | `.github/ISSUE_TEMPLATE/*` | `.gitlab/issue_templates/*.md` |
| Sponsorship | `.github/FUNDING.yml` | *(no direct equivalent)* |
| Reviewer mapping (`CODEOWNERS`) | *(portable — see Dimension 1)* | *(portable — see Dimension 1)* |

`CODEOWNERS` is the exception: it is portable, so its placement rule lives in
Dimension 1, not here.

**Placement test:** "Who looks for this, and where would they look first?" Put it
there. If two audiences want it, give it **one** home and link from the other —
never copy.

---

## Dimension 3 — Organization

- **Single source of truth (DRY).** Every fact has exactly one authoritative
  home: README → user entry; CLAUDE.md → agent guidance; issues → roadmap;
  ADRs → decisions & rationale; CHANGELOG → what shipped; CONSTITUTION.md →
  mission, direction & non-goals. Duplicated knowledge drifts out of sync.
- **Charter hierarchy.** `CONSTITUTION.md` sits above the reference layer:
  governance policies (`docs/governance/policies/`) *implement* it and ADRs
  *decide within* it — they cite the constitution, never restate it. The root
  README's documentation map links `CONSTITUTION.md` like any other doc so it is
  never orphaned.
- **Link, don't duplicate.** Cross-reference with relative links (within a repo).
  When tempted to copy, extract to one home and link to it.
- **Discoverability / index.** The root README links to the docs that matter to
  users. A "Documentation Structure" map (in README or CLAUDE.md) enumerates
  every document and its purpose so nothing is orphaned. Every directory under
  `docs/` has a `README.md` index, and every file is reachable from at least one
  link.
- **Progressive disclosure.** Shallow → deep. The README gives the five-minute
  version and links to `docs/` for the full treatment; don't front-load
  reference detail.
- **ADR lifecycle.** Each record has a status (Proposed / Accepted / Deprecated /
  Superseded), one decision, and is immutable once Accepted — supersede with a
  *new* ADR rather than editing history.
- **One runbook per failure domain.** A runbook covers exactly one failure
  domain — a distinct class of root cause the responder acts on — not one alert,
  and not a grab-bag of symptoms. Many alerts may share one runbook; different
  root causes get different runbooks. Split a runbook that accumulates unrelated
  domains and leave a pointer behind.
- **Name the owner of overlapping concerns.** When two documents touch the same
  topic, state the owner explicitly (e.g., "commit conventions: CONTRIBUTING.md
  owns; CLAUDE.md links").
- **Maintain, don't accrete.** Archive outdated content rather than deleting it;
  update docs as part of the implementation work that changes their subject.

---

## Dimension 4 — Formatting

**Markdown**

- One H1 per file (the title); nest with ATX `##` / `###`, no skipped levels.
- Fenced code blocks always carry a language tag (` ```go `, ` ```bash `).
- Tables for structured or enumerable data (options, mappings, comparisons).
- Relative links for in-repo targets (survive clone/rename); absolute for
  external.
- Sentence-case headings, not Title Case — and match the existing files in the
  repo.
- **One sentence per line.** Each sentence in a paragraph goes on its own line;
  never hard-wrap mid-sentence at a fixed column. This keeps diffs to the
  changed sentence. (`rumdl` enforces this as MD013; run `rumdl fmt <file>` to
  auto-fix.)
- Keep diffs quiet: stable heading structure, no trailing whitespace.

**Voice**

- Second person, imperative, present tense: "Run `make test`," not "You should
  run the tests."
- Delete filler — "basically", "simply", "just", "actually", "in order to".
- State facts, not feelings: "This API returns JSON," not "This powerful API
  conveniently returns JSON."
- No motivation paragraphs — skip "Why this matters"; the reader is already here.
- Lead with the action or answer; one concept per section.
- Show, don't tell: a copy-pasteable command or code block beats a description.
- Alphabetize lists and tables unless another order serves the concept
  (sequential steps, priority, hierarchy).
- Trust the reader — assume technical competence appropriate to the audience.

**What NOT to document**

- Content that duplicates upstream documentation.
- Implementation details that change frequently.
- Anything discoverable via `--help`, `make help`, or IDE tooltips.
- Obvious behavior.

**Code / API docs** (language-idiomatic; Go shown)

- Every exported symbol has a doc comment that **starts with the symbol's name**
  and is a full sentence: *"ParseLine parses a single GEDCOM line."*
- Package-level docs explain the purpose and the primary entry point, with a
  runnable Example where it helps.
- Field-level docs on exported struct fields that aren't self-evident.

**Diagrams**

- Use an architecture framework so diagrams are recognizable across contexts.
  The [C4 model](https://c4model.com/) (Context, Container, Component, Code)
  suits most software and infrastructure; use only the levels a solution needs.
- Store diagrams as **PNG exports** committed under `docs/images/` so they render
  without tool access; name them `{domain}-{topic}.png`, suffixed with the tier
  (`-overview` / `-resource`) where an overview and a build diagram would collide.
- **Mermaid** is acceptable for simple, self-contained diagrams that benefit from
  living inline and version-controlled (sequence diagrams in ADRs, small
  flowcharts in runbooks). For complex topology, prefer an exported PNG.

**Commit / change-request conventions** (documentation-relevant slice; the
repo's git standard owns the rest)

- Documentation changes use the `docs:` conventional-commit type — never `feat`
  or `fix`, which are reserved for consumable code changes.
- Change-request titles follow the repo's policy.

---

## Applying this standard

- **Consult** it when deciding what a document is, where it belongs, how to
  organize it, or how to format it.
- **Scaffold** a new repo's doc set from the canonical types and locations above,
  writing each `docs/` document from its template in `templates/`.
- **Check** an existing repo's structure, placement, and formatting against it.
  (For drift, dead links, and stale content, use `audit-docs`; for
  code-change-driven doc updates, use `docs-analyzer`.)

**Migrating repos built to an earlier version.** This standard supersedes an
earlier one with a looser `docs/` shape. When checking a pre-existing repo,
treat these as renames to apply, not fresh defects: `docs/adr/` → `docs/decisions/`;
a flat `docs/` → the structured subdirectories above; 3-digit ADR prefixes
(`001-`) → 4-digit (`0001-`); and "one paragraph per line" prose →
one-sentence-per-line. Recommend the migration rather than reporting the old
layout as non-compliant.
