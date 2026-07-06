# Documentation Standard

The canonical standard for project documentation across cacack repositories.
Four dimensions: **types**, **locations**, **organization**, **formatting**.

Derived from mature working practice (gedcom-go's structure, sortpics-go's
conventions), generalized to be repo- and language-agnostic. Go is used for
concrete API-doc examples; substitute your language's idiom.

---

## Dimension 1 — Types (what each document is, and its audience)

Classify every document by **audience** first — audience determines its
location, organization, and voice.

| Audience | The question it answers | Documents |
|----------|-------------------------|-----------|
| **Users / consumers** | "How do I use this?" | `README.md`, `USAGE.md`, inline API docs, `examples/` |
| **Contributors** | "How do I change this?" | `CONTRIBUTING.md`, `docs/TESTING.md`, dev-setup docs |
| **Maintainers (reference)** | "Why is it this way? What's the deep detail?" | `docs/*.md`, `docs/adr/*`, design & research notes |
| **Agents (Claude Code)** | "How should Claude work in this repo?" | `CLAUDE.md`, `.claude/rules/*.md` |
| **Operators** | "How do I run, deploy, or recover it?" | `SECURITY.md`, `docs/runbooks/*` (when applicable) |
| **Everyone (meta)** | project meta / legal / history | `LICENSE`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md` |

Canonical types, each with **one** purpose:

- **`README.md`** — the front door. What it is (1–2 sentences), why it exists,
  quick start, install, minimal usage, and links out to everything else.
  User-facing entrypoint; never a dumping ground for reference detail.
- **`CLAUDE.md`** — guidance for Claude Code **only**, never user documentation.
  Slim; defers detail to `.claude/rules/` and `docs/`. (Author with
  `create-claudemd`; audit with `audit-claudemd`.)
- **`CONTRIBUTING.md`** — contributor onboarding: dev setup, commands, code
  standards, commit/PR conventions, and the testing bar.
- **`CHANGELOG.md`** — release history. Prefer **generated** (release-please /
  conventional commits) over hand-maintained.
- **`SECURITY.md`** — vulnerability-reporting policy and supported versions.
- **`LICENSE`** — legal.
- **`docs/`** — reference material too detailed for the root: design docs,
  version/spec references, performance notes, research.
- **`docs/adr/NNN-*.md`** — Architecture Decision Records: one decision per
  file, numbered, immutable once accepted.
- **Inline API docs (godoc / docstrings)** — the API reference lives in the
  code, not in prose. Every exported symbol is documented.
- **Optional indexes** — `FEATURES.md` (exhaustive feature list), `IDEAS.md`
  (unvetted concepts), `USAGE.md` (extended examples). Add only when the root
  README genuinely cannot hold them.
- **Non-file** — planned work lives in the issue tracker (Issues + Milestones),
  **not** a `ROADMAP.md`.

**New-type test:** create a new document type only when it has a distinct
audience **and** answers a distinct question no existing document owns.
Otherwise it is a *section* in an existing document.

---

## Dimension 2 — Locations (where each lives)

- **Repo root** — only the documents a newcomer or a tool expects by convention:
  `README`, `LICENSE`, `CONTRIBUTING`, `CHANGELOG`, `SECURITY`, `CLAUDE.md`,
  `CODE_OF_CONDUCT`. Plus, at most, a few top-level indexes
  (`FEATURES`/`IDEAS`/`USAGE`). The root is a table of contents, not a library —
  keep it lean.
- **`docs/`** — all reference material. Flat until it grows; then group by theme
  (`docs/adr/`, `docs/specs/`).
- **`docs/adr/`** — ADRs with a zero-padded numeric prefix (`001-...`), never
  renumbered.
- **Alongside code** — API docs inline; every package/module carries a
  package-level doc (Go: in `doc.go` or the primary file). Significant
  subpackages may carry a local `README` for orientation.
- **`.claude/rules/`** — agent rules; path-scoped when they apply to only part
  of the tree.
- **Issue tracker** — roadmap, planned features, bugs. Not files in the repo.

**Placement test:** "Who looks for this, and where would they look first?" Put it
there. If two audiences want it, give it **one** home and link from the other —
never copy.

---

## Dimension 3 — Organization

- **Single source of truth (DRY).** Every fact has exactly one authoritative
  home: README → user entry; CLAUDE.md → agent guidance; issues → roadmap;
  ADRs → decisions & rationale; CHANGELOG → what shipped. Duplicated knowledge
  drifts out of sync.
- **Link, don't duplicate.** Cross-reference with relative links. When tempted
  to copy, extract to one home and link to it.
- **Discoverability / index.** The root README links to the docs that matter to
  users. A "Documentation Structure" map (in README or CLAUDE.md) enumerates
  every document and its purpose so nothing is orphaned. Every file under
  `docs/` is reachable from at least one link.
- **Progressive disclosure.** Shallow → deep. The README gives the five-minute
  version and links to `docs/` for the full treatment; don't front-load
  reference detail.
- **ADR lifecycle.** Each record has a status (Proposed / Accepted / Superseded),
  one decision, and is immutable once Accepted — supersede with a *new* ADR
  rather than editing history.
- **Name the owner of overlapping concerns.** When two documents touch the same
  topic, state the owner explicitly (e.g., "commit conventions: CONTRIBUTING.md
  owns; CLAUDE.md links").

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
- Soft-wrap prose (one sentence per line, *or* one paragraph per line — pick one
  per repo and hold it); never hard-wrap at a fixed column.
- Keep diffs quiet: stable heading structure, no trailing whitespace.

**Voice**

- Second person, imperative, present tense: "Run `make test`," not "You should
  run the tests."
- Show, don't tell: a copy-pasteable command or code block beats a description.
- Concise. Every sentence earns its place — the same bar you hold for code.

**Code / API docs** (language-idiomatic; Go shown)

- Every exported symbol has a doc comment that **starts with the symbol's name**
  and is a full sentence: *"ParseLine parses a single GEDCOM line."*
- Package-level docs explain the purpose and the primary entry point, with a
  runnable Example where it helps.
- Field-level docs on exported struct fields that aren't self-evident.

**Commit / PR conventions** (documentation-relevant slice; the repo's git
standard owns the rest)

- Documentation changes use the `docs:` conventional-commit type — never `feat`
  or `fix`, which are reserved for consumable code changes.
- PR titles follow the repo's policy.

---

## Applying this standard

- **Consult** it when deciding what a document is, where it belongs, how to
  organize it, or how to format it.
- **Scaffold** a new repo's doc set from the canonical types and locations above.
- **Check** an existing repo's structure, placement, and formatting against it.
  (For drift, dead links, and stale content, use `audit-docs`; for
  code-change-driven doc updates, use `docs-analyzer`.)
