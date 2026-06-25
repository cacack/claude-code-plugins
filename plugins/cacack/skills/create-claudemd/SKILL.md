---
name: create-claudemd
description: Create, author, and migrate CLAUDE.md files and .claude/rules/ files following Anthropic best practices. Use when creating a new CLAUDE.md, authoring .claude/rules/ files, or migrating a monolithic CLAUDE.md into slim entry point + rules. For AUDITING an existing CLAUDE.md or rules file, use audit-claudemd instead. Does NOT apply to SKILL.md files.
argument-hint: "[path] [create|rules|migrate]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Bash(ls:*)
  - Bash(wc:*)
  - Bash(git:*)
---

<objective>
Author CLAUDE.md files and `.claude/rules/` files that follow Anthropic's official best practices — high-signal, low-bloat instructions that earn their context cost. This skill handles the **authoring** side (create / rules / migrate). For evaluating an existing file, hand off to `/cacack:audit-claudemd`, which drives the dedicated `claudemd-auditor` agent.
</objective>

<quick_start>
Tell me what you'd like to do, or pick from the intake menu. For all modes, read `references/anthropic-best-practices.md` first.
</quick_start>

<essential_principles>

**1. CLAUDE.md Is Context, Not Documentation**

CLAUDE.md consumes tokens on every session. Every line must earn its place.
Decision rule: "Would removing this line cause Claude to make mistakes?" If not, cut it.

**2. Under 200 Lines Per File**

Anthropic's official guidance. Longer files reduce adherence — important rules get lost in noise.
If growing large, split into `.claude/rules/` files or use `@imports`.

**3. Specific and Verifiable**

- "Use 2-space indentation" not "Format code properly"
- "Run `npm test` before committing" not "Test your changes"
- "API handlers live in `src/api/handlers/`" not "Keep files organized"

**4. Only What Claude Can't Discover**

Include: project-specific conventions, non-obvious commands, architectural decisions, gotchas.
Exclude: language conventions Claude knows, API docs, self-evident practices, content discoverable via `--help` or reading code.

**5. Hierarchical Structure**

| Level | File | Purpose | Loads |
|-------|------|---------|-------|
| Project root | `CLAUDE.md` | Project identity, overview, imports, dev commands | Always |
| Subdirectory | `component/CLAUDE.md` | Component-specific guidance | On demand |
| Rules (no paths) | `.claude/rules/*.md` | Topic-based rules | Always |
| Rules (path-scoped) | `.claude/rules/*.md` with `paths:` frontmatter | Contextual rules | When matching files accessed |
| Local overrides | `CLAUDE.local.md` | Personal preferences (gitignored) | Always |

**6. Path-Scoped Rules Save Context**

Rules with YAML frontmatter `paths:` only load when Claude works with matching files:

```markdown
---
paths:
  - "docs/**"
  - "*.md"
---
# Documentation Rules
...
```

Use path-scoping for rules that only apply to specific areas of the codebase.

</essential_principles>

<intake>
What would you like to do?

1. **Create** CLAUDE.md for a project
2. **Create rules** (`.claude/rules/` files)
3. **Migrate** a monolithic CLAUDE.md into slim entry point + rules

(To **audit** an existing CLAUDE.md or rules file, use `/cacack:audit-claudemd` — it drives the `claudemd-auditor` agent.)

**Wait for response before proceeding.**
</intake>

<routing>

| Response | Action |
|----------|--------|
| 1, "create", "new claude" | Read references/anthropic-best-practices.md, then the create-claudemd workflow |
| 2, "create rules", "rules" | Read references/anthropic-best-practices.md, then the create-rules workflow |
| 3, "migrate", "split", "break up" | Read references/anthropic-best-practices.md, then the migrate workflow |
| "audit", "review", "check" | Hand off to `/cacack:audit-claudemd` — do not audit inline |

**For ALL authoring workflows**: read `references/anthropic-best-practices.md` BEFORE starting.

</routing>

<workflow name="create-claudemd">

<process>

1. **Discover project context**
   - Read existing README.md, package.json, Makefile, go.mod, pyproject.toml, or equivalent
   - Identify: language, framework, build system, test commands
   - Check for an existing CLAUDE.md or `.claude/` directory

2. **Determine scope** — ask if not clear:
   - Root CLAUDE.md (project-level)?
   - Subdirectory CLAUDE.md (component-level)?

3. **Draft CLAUDE.md** with these sections only:
   - **Project overview** (2-3 lines: what it is, what it does)
   - **Imports** (`@` references to subdirectory CLAUDE.md files or shared docs)
   - **Development commands** (only non-obvious ones)
   - **Architecture notes** (only gotchas and non-obvious patterns)
   - **Rules index** (if `.claude/rules/` exists, a table of rule files and scopes)

4. **Validate against principles**
   - Under 200 lines?
   - Every line passes the "would Claude break without this?" test?
   - Specific and verifiable instructions?
   - No discoverable or self-evident content?

5. **Present to user** for review before writing.

</process>

<success_criteria>
- Under 200 lines
- No self-evident or discoverable content
- Specific, verifiable instructions only
- Appropriate use of `.claude/rules/` references
- Presented to the user before any file is written
</success_criteria>

</workflow>

<workflow name="create-rules">

<process>

1. **Identify topics** — ask what rules are needed, or analyze an existing CLAUDE.md for extractable topics.

2. **For each topic**, decide:
   - Path-scoped? (Only relevant to specific file patterns → `paths:` frontmatter)
   - Or always-loaded? (Applies everywhere)

3. **Draft each rule file**:
   - Path-scoped files get YAML frontmatter with `paths:` globs
   - Content: specific, verifiable rules only
   - Target: under 50 lines per file (keep focused)

4. **Update CLAUDE.md** — add a rules index table if one doesn't exist.

5. **Present to user** before writing.

</process>

<success_criteria>
- Each file focused on one topic
- Path-scoping applied where appropriate
- Specific, verifiable rules
- No duplication between rule files or with CLAUDE.md
- CLAUDE.md updated with a rules index
</success_criteria>

</workflow>

<workflow name="migrate">

<process>

1. **Read the full CLAUDE.md** and count lines (`wc -l`).

2. **Identify extractable topics** — group content by theme: security, git workflow, code style, documentation, testing, tooling, etc.

3. **For each topic**:
   - Determine if path-scopable
   - Extract content into a rule file
   - Trim self-evident and discoverable content during extraction

4. **Rewrite CLAUDE.md** as a slim entry point:
   - Project overview
   - Imports
   - Non-obvious dev commands
   - Rules index table

5. **Validate** — no content lost that passes the decision rule.

6. **Present the migration plan** (which topics move to which rule files, projected line counts) before writing any file.

</process>

<success_criteria>
- CLAUDE.md slimmed to an entry point (aim < 50 lines)
- All project-specific rules preserved in rule files
- Path-scoping applied where appropriate
- No self-evident content survived migration
- Rules index table in CLAUDE.md
- Migration plan presented before writing
</success_criteria>

</workflow>

<constraints>
- NEVER add self-evident rules ("write clean code", "handle errors", "test your code")
- NEVER include content discoverable via `--help`, `make help`, or reading code
- NEVER exceed 200 lines in a CLAUDE.md file
- NEVER exceed 50 lines in a single rule file (split if larger)
- ALWAYS read `references/anthropic-best-practices.md` before starting a workflow
- ALWAYS present changes to the user before writing
- For auditing, hand off to `/cacack:audit-claudemd` — do not duplicate the audit engine here
</constraints>
