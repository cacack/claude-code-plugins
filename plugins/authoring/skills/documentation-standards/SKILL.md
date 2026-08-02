---
name: documentation-standards
description: The canonical standard for project documentation — what document types exist, where they live, how they're organized, and how they're formatted. Use when authoring or placing project docs, deciding what type a document is or where it belongs, scaffolding a repo's doc set, or checking existing docs against the standard. For CLAUDE.md authoring use create-claudemd; for doc drift and dead links use audit-docs; for code-change-driven doc updates use docs-analyzer.
argument-hint: "[consult|scaffold|check] [path]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(wc:*)
  - Bash(git:*)
---

<objective>
Apply one documentation standard across every repo. The standard lives in
`references/standard.md` and covers four dimensions — **types** (what each
document is, by audience), **locations** (where it lives), **organization**
(single-source-of-truth, discoverability, ADR lifecycle), and **formatting**
(markdown, voice, API docs). It pairs a lean OSS-style root with a structured
`docs/` reference layer; each `docs/` document type is written from a template in
`references/templates/`. This skill loads that standard and helps you consult,
scaffold, or check against it.
</objective>

<quick_start>
Read `references/standard.md` first — it is the source of truth. The `docs/`
document templates live in `references/templates/` (architecture, ADR, design,
guide, policy, runbook, reference). Then route by what the user wants: consult,
scaffold, or check.
</quick_start>

<scope>
This skill owns the **standard** and its application. It does not duplicate the
sibling skills — hand off instead:

| Need | Skill |
|------|-------|
| Author or migrate a `CLAUDE.md` / `.claude/rules/` file | `create-claudemd` |
| Audit docs for drift, dead links, stale content | `audit-docs` |
| Find docs needing updates after code changes | `docs-analyzer` |
| Author or refresh a `CONSTITUTION.md` | `constitution` |

CLAUDE.md and `.claude/rules/` are covered by the standard's *types* dimension
(agent-facing docs), but their **authoring** belongs to `create-claudemd`.
</scope>

<intake>
What would you like to do?

1. **Consult** — answer a question using the standard (what type is this? where
   does it go? how should it be organized or formatted?)
2. **Scaffold** — set up or complete a repo's documentation to the standard
3. **Check** — assess an existing repo's structure, placement, and formatting
   against the standard

**Wait for a response unless the request already makes the mode obvious.**
</intake>

<routing>

| Response | Action |
|----------|--------|
| 1, "consult", a direct question | Read `references/standard.md`, answer citing the relevant dimension |
| 2, "scaffold", "set up docs", "new repo" | Read `references/standard.md`, then the scaffold workflow |
| 3, "check", "review docs", "conform" | Read `references/standard.md`, then the check workflow |
| "audit", "dead links", "drift" | Hand off to `audit-docs` |
| "CLAUDE.md", "rules" | Hand off to `create-claudemd` |

**For every mode: read `references/standard.md` before acting.**

</routing>

<workflow name="scaffold">

<process>

1. **Survey the repo** — list existing docs (root, `docs/`, `.claude/`), language
   and build system, and the issue tracker in use.
2. **Map to the standard's types** — for the repo's audiences, determine which
   canonical documents should exist (Dimension 1) and where each belongs
   (Dimension 2). Always scaffold the **required** docs (`README`, `LICENSE`);
   scaffold an **optional** doc only when its Dimension 1 trigger holds for this
   repo.
3. **Report the gap** — a table of {document, exists?, correct location?,
   proposed action}. Flag misplaced or duplicated docs.
4. **Draft only what's missing or misplaced.** Reuse existing content; never
   overwrite substantive docs without showing the diff. Write each `docs/`
   document from its template in `references/templates/` (copy the template, fill
   the sections, remove placeholder text); give each `docs/` subdirectory a
   `README.md` index. For `CLAUDE.md` or `.claude/rules/`, hand off to
   `create-claudemd`.
5. **Wire up discoverability** — ensure the root README (or a "Documentation
   Structure" map) links every doc; no orphans.
6. **Present the plan before writing any file.**

</process>

<success_criteria>
- Only the standard's canonical types are present, each in its correct location
- No duplicated knowledge; each fact has one home with links from the rest
- Every doc is reachable from an index or the README
- Plan presented before any file was written
</success_criteria>

</workflow>

<workflow name="check">

<process>

1. **Inventory** the repo's docs and their locations (`find`, `ls`).
2. **Score against each dimension:**
   - *Types* — right documents for the audiences; no doc doing two jobs; each `docs/` document follows its template in `references/templates/`. Use Dimension 1's required/optional markers: flag a missing **required** root doc (`README`, `LICENSE`) as a finding; flag a missing **optional** doc only when its stated trigger applies; never flag an optional doc absent its trigger
   - *Locations* — root stays lean; reference material under the `docs/` structure (`architecture/ decisions/ designs/ governance/ guides/ operations/ reference/`); ADRs zero-padded and numbered; each `docs/` subdir has a `README.md`
   - *Organization* — single source of truth, no duplicated facts, everything indexed, ADR lifecycle honored, one runbook per failure domain
   - *Formatting* — one H1, tagged code fences, relative links, sentence-case headings, one sentence per line, documented exported symbols
3. **Report findings** grouped by dimension, each with the file and a concrete fix.
   Do **not** chase drift, dead links, or staleness — that is `audit-docs`.
4. **Offer to apply** the structural/placement fixes; keep content edits opt-in.

</process>

<success_criteria>
- Findings mapped to a specific dimension and file
- Structure/placement/formatting only — drift handed to `audit-docs`
- Concrete, actionable fix per finding
</success_criteria>

</workflow>

<constraints>
- ALWAYS read `references/standard.md` before acting — it is the source of truth
- Write `docs/` documents from their `references/templates/` template — never freehand a type that has one
- NEVER duplicate a fact across documents; extract to one home and link
- NEVER overwrite substantive existing docs without showing the change first
- Hand off CLAUDE.md/rules authoring to `create-claudemd`, drift/dead-links to
  `audit-docs`, and code-driven updates to `docs-analyzer` — do not reimplement them
- Keep the root lean: only convention-expected docs belong there
</constraints>
