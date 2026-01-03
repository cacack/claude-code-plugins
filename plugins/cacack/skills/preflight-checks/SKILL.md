---
name: preflight-checks
description: Run project-defined code quality checks (lint, test, security) via Make targets before shipping. Detects available targets automatically and reports pass/fail status for each.
---

<objective>
Execute project-defined quality gates before shipping code. This skill respects project conventions by running checks through Make targets rather than imposing external tooling. Projects define their own lint, test, and security checks - this skill discovers and runs them.
</objective>

<quick_start>
Run preflight checks for the current project:

```bash
# Detect available targets
make -qp 2>/dev/null | awk -F: '/^[a-z][a-z0-9_-]*:/ && !/^\./ {print $1}' | grep -E '^(lint|test|check|security|audit|verify|validate)' | sort -u

# Run each target and collect results
make lint && make test && make security
```

Report format:
```
Preflight Results
─────────────────
✓ lint     : passed
✓ test     : 47/47 passed
- security : target not found

Blockers: 0 | Warnings: 0
Ready to ship: YES
```
</quick_start>

<workflow>
<step name="detect">
Discover available Make targets related to code quality:

```bash
# Extract target names from Makefile
make -qp 2>/dev/null | awk -F: '/^[a-z][a-z0-9_-]*:/ && !/^\./ {print $1}' | sort -u
```

**Target categories to look for:**

| Category | Common targets |
|----------|----------------|
| Linting | `lint`, `check`, `verify`, `fmt-check` |
| Testing | `test`, `tests`, `test-unit`, `test-integration` |
| Security | `security`, `audit`, `security-check`, `vulnerability-check` |
| Validation | `validate`, `typecheck`, `type-check` |

If no Makefile exists, report "No Makefile found - preflight checks not configured".
</step>

<step name="execute">
Run each detected target and capture results:

```bash
# Run with output capture
make <target> 2>&1
echo "Exit code: $?"
```

**Result classification:**
- Exit 0 → PASS
- Exit non-zero → FAIL (capture output for report)
- Target not found → SKIP

**Execution order:**
1. Linting (fast feedback)
2. Type checking (if available)
3. Testing (may be slower)
4. Security (often external checks)
</step>

<step name="report">
Generate structured report:

```
Preflight Results
─────────────────
[status] [target] : [details]

Blockers: N | Warnings: N
Ready to ship: [YES/NO/WITH WARNINGS]
```

**Status symbols:**
- `✓` - Passed
- `✗` - Failed (blocker)
- `⚠` - Warning (non-blocking)
- `-` - Skipped (not configured)

**Include failure details:**
For any FAIL, include:
- Exit code
- Last 10 lines of output
- Suggested fix if obvious
</step>
</workflow>

<common_targets>
**Node.js projects:**
```makefile
lint:
	npm run lint

test:
	npm test

security:
	npm audit
```

**Python projects:**
```makefile
lint:
	ruff check .

test:
	pytest

security:
	pip-audit
```

**Rust projects:**
```makefile
lint:
	cargo clippy

test:
	cargo test

security:
	cargo audit
```

**Go projects:**
```makefile
lint:
	golangci-lint run

test:
	go test ./...

security:
	gosec ./...
```
</common_targets>

<fallback_detection>
If no Makefile but common project files exist, suggest adding targets:

| File detected | Suggested make targets |
|---------------|------------------------|
| `package.json` | `lint: npm run lint`, `test: npm test` |
| `pyproject.toml` | `lint: ruff check .`, `test: pytest` |
| `Cargo.toml` | `lint: cargo clippy`, `test: cargo test` |
| `go.mod` | `lint: golangci-lint run`, `test: go test ./...` |

Report: "No preflight checks configured. Consider adding these Make targets: [suggestions]"
</fallback_detection>

<output_format>
<template name="full_report">
```
Preflight Results
═════════════════

Project: [project name from pwd]
Makefile: [found/not found]

Checks
──────
[✓/✗/⚠/-] lint     : [passed/failed/warning/skipped] [details]
[✓/✗/⚠/-] test     : [N/N passed or details]
[✓/✗/⚠/-] security : [passed/N issues found/skipped]

[If any failures, include details:]
─────────────────────────────────
lint failed (exit 1):
  src/main.ts:42:10 - 'foo' is declared but never used
  src/utils.ts:15:1 - Missing semicolon

Summary
───────
Passed: N | Failed: N | Skipped: N
Ready to ship: [YES/NO/WITH WARNINGS]

[If NO:]
Fix the above issues before shipping.

[If WITH WARNINGS:]
Warnings are non-blocking but should be addressed.
```
</template>
</output_format>

<success_criteria>
Preflight checks complete when:

- All available Make targets discovered
- Each target executed with results captured
- Clear pass/fail status for each check
- Failure details included with actionable information
- Summary indicates ship readiness
- If no targets available, clear guidance provided
</success_criteria>

<integration>
This skill is typically invoked by the shipper agent or /ship command:

```
/ship → shipper agent → preflight-checks skill → report
                      ↓
              [if FAIL: escalate to user]
              [if PASS: continue to next phase]
```

Can also be invoked directly for manual preflight:
```
> Run preflight checks before I commit
```
</integration>
