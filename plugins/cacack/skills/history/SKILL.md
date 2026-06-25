---
name: history
description: Reads Claude Code conversation history from ~/.claude/history.jsonl and presents it in an easy-to-scan formatted table. Shows recent conversations with date, project, topic, and session ID. Use when reviewing past sessions, finding a conversation to resume, or browsing Claude Code usage history.
allowed-tools: Bash, Read
---

<objective>
Reads the user's Claude Code conversation history from `~/.claude/history.jsonl` and presents it as a formatted, easy-to-scan plain text table. Each entry shows the date, project, conversation topic, and session ID — enabling quick lookup and resumption of past sessions.
</objective>

<quick_start>
Read `~/.claude/history.jsonl` and display the most recent conversations as a plain text table with padded columns. Use `python3 -c` for parsing and formatting.
</quick_start>

<output_format>

**Plain text tables only.** Use fixed-width, column-padded plain text tables. Never use markdown table syntax (`|` delimiters). Columns must be aligned with spaces.

**Human-readable dates.** Format timestamps as `"Mon DD, YYYY HH:MM"` (e.g., `"Nov 10, 2025 15:48"`). Use 24-hour time.

**Short project names.** Extract just the final directory component from the project path, not the full path.

**Truncate topics cleanly.** Show 60-80 characters of the conversation topic. Truncate at a word boundary when possible, appending `...` if truncated.

**Respect privacy.** Only extract metadata fields (timestamp, project path, session ID) and the first user message for the topic summary. Do not display full conversation content.

</output_format>

<workflow>

**Step 1 — Read the history file**

Read the conversation history:

```bash
tail -100 ~/.claude/history.jsonl
```

If the file does not exist or is empty, inform the user that no history was found and stop.

**Step 2 — Parse entries**

Each line in `history.jsonl` is a JSON object. Extract these fields from each entry:
- **Timestamp** — from the `createdAt` or `timestamp` field
- **Project** — from the `cwd` or `projectPath` field (extract final directory name only)
- **Topic** — from the first user message or `title`/`summary` field
- **Session ID** — from the `sessionId` or `id` field

Use `python3 -c` to parse and format — it handles column padding and date formatting reliably.

**Step 3 — Format and display**

Present the **10 most recent** conversations in a primary table:

```
 #   Date                Project          Topic                                                         Session ID
 --  ------------------  ---------------  ------------------------------------------------------------  ----------------------------
  1  Nov 10, 2025 15:48  my-project       Created new slash command for deployment workflow...          abc123-def456-789
  2  Nov 09, 2025 11:22  infrastructure   Fixed Terraform state drift in production cluster             xyz789-abc012-345
```

Column widths:
- `#` — 3 chars, right-aligned
- `Date` — 18 chars
- `Project` — 15 chars (truncate with `...` if longer)
- `Topic` — 60 chars (truncate at word boundary with `...`)
- `Session ID` — remainder

If more than 10 conversations exist, show an additional table of 5-7 older entries under the heading `Additional Recent Conversations`.

**Step 4 — Show resume tip**

After the table(s), print:

```
---
Tip: Resume any conversation by running:
  claude --resume <session-id>
  claude --resume (to see an interactive list of recent sessions)
```

</workflow>

<success_criteria>

- [ ] History file was read from `~/.claude/history.jsonl`
- [ ] Output uses plain text tables with properly padded columns
- [ ] Dates are human-readable (`Mon DD, YYYY HH:MM` format)
- [ ] Project names show only the final directory component
- [ ] Topics are truncated to 60-80 characters at word boundaries
- [ ] 10 most recent conversations are shown in the primary table
- [ ] Additional older conversations shown if available
- [ ] Resume tip is displayed at the end

</success_criteria>
