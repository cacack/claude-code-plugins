# Workflow: Execute Phase

<purpose>
Execute a phase prompt (PLAN.md) and create the outcome summary (SUMMARY.md).
</purpose>

<process>

<step name="identify_plan">
Find the next plan to execute:
- Check ROADMAP.md for "In progress" phase
- Find plans in that phase directory
- Identify first plan without corresponding SUMMARY

```bash
cat .planning/ROADMAP.md
# Look for phase with "In progress" status
# Then find plans in that phase
ls .planning/phases/XX-name/*-PLAN.md 2>/dev/null | sort
ls .planning/phases/XX-name/*-SUMMARY.md 2>/dev/null | sort
```

**Logic:**
- If `01-01-PLAN.md` exists but `01-01-SUMMARY.md` doesn't → execute 01-01
- If `01-01-SUMMARY.md` exists but `01-02-SUMMARY.md` doesn't → execute 01-02
- Pattern: Find first PLAN file without matching SUMMARY file

Confirm with user if ambiguous.

Present:
```
Found plan to execute: {phase}-{plan}-PLAN.md
[Plan X of Y for Phase Z]

Proceed with execution?
```
</step>

<step name="load_prompt">
Read the plan prompt:
```bash
cat .planning/phases/XX-name/{phase}-{plan}-PLAN.md
```

This IS the execution instructions. Follow it exactly.
</step>

<step name="previous_phase_check">
Before executing, check if previous phase had issues:

```bash
# Find previous phase summary
ls .planning/phases/*/SUMMARY.md 2>/dev/null | sort -r | head -2 | tail -1
```

If previous phase SUMMARY.md has "Issues Encountered" != "None" or "Next Phase Readiness" mentions blockers:

Use AskUserQuestion:
- header: "Previous Issues"
- question: "Previous phase had unresolved items: [summary]. How to proceed?"
- options:
  - "Proceed anyway" - Issues won't block this phase
  - "Address first" - Let's resolve before continuing
  - "Review previous" - Show me the full summary
</step>

<step name="execute">
Execute each task in the prompt. **Deviations are normal** - handle them automatically using embedded rules below.

1. Read the @context files listed in the prompt

2. For each task:

   **If `type="auto"`:**
   - Work toward task completion
   - **When you discover additional work not in plan:** Apply deviation rules (see below) automatically
   - Continue implementing, applying rules as needed
   - Run the verification
   - Confirm done criteria met
   - Track any deviations for Summary documentation
   - Continue to next task

   **If `type="checkpoint:*"`:**
   - STOP immediately (do not continue to next task)
   - Execute checkpoint_protocol (see below)
   - Wait for user response
   - Verify if possible (check files, env vars, etc.)
   - Only after user confirmation: continue to next task

3. Run overall verification checks from `<verification>` section
4. Confirm all success criteria from `<success_criteria>` section met
5. Document all deviations in Summary (automatic - see deviation_documentation below)
</step>

<deviation_rules>
## Automatic Deviation Handling

**While executing tasks, you WILL discover work not in the plan.** This is normal.

Apply these rules automatically. Track all deviations for Summary documentation.

---

**RULE 1: Auto-fix bugs**

**Trigger:** Code doesn't work as intended (broken behavior, incorrect output, errors)

**Action:** Fix immediately, track for Summary

**Examples:**
- Wrong SQL query returning incorrect data
- Logic errors (inverted condition, off-by-one, infinite loop)
- Type errors, null pointer exceptions, undefined references
- Broken validation (accepts invalid input, rejects valid input)
- Security vulnerabilities (SQL injection, XSS, CSRF, insecure auth)
- Race conditions, deadlocks
- Memory leaks, resource leaks

**Process:**
1. Fix the bug inline
2. Add/update tests to prevent regression
3. Verify fix works
4. Continue task
5. Track in deviations list: `[Rule 1 - Bug] [description]`

**No user permission needed.** Bugs must be fixed for correct operation.

---

**RULE 2: Auto-add missing critical functionality**

**Trigger:** Code is missing essential features for correctness, security, or basic operation

**Action:** Add immediately, track for Summary

**Examples:**
- Missing error handling (no try/catch, unhandled promise rejections)
- No input validation (accepts malicious data, type coercion issues)
- Missing null/undefined checks (crashes on edge cases)
- No authentication on protected routes
- Missing authorization checks (users can access others' data)
- No CSRF protection, missing CORS configuration
- No rate limiting on public APIs
- Missing required database indexes (causes timeouts)
- No logging for errors (can't debug production)

**Process:**
1. Add the missing functionality inline
2. Add tests for the new functionality
3. Verify it works
4. Continue task
5. Track in deviations list: `[Rule 2 - Missing Critical] [description]`

**Critical = required for correct/secure/performant operation**
**No user permission needed.** These are not "features" - they're requirements for basic correctness.

---

**RULE 3: Auto-fix blocking issues**

**Trigger:** Something prevents you from completing current task

**Action:** Fix immediately to unblock, track for Summary

**Examples:**
- Missing dependency (package not installed, import fails)
- Wrong types blocking compilation
- Broken import paths (file moved, wrong relative path)
- Missing environment variable (app won't start)
- Database connection config error
- Build configuration error (webpack, tsconfig, etc.)
- Missing file referenced in code
- Circular dependency blocking module resolution

**Process:**
1. Fix the blocking issue
2. Verify task can now proceed
3. Continue task
4. Track in deviations list: `[Rule 3 - Blocking] [description]`

**No user permission needed.** Can't complete task without fixing blocker.

---

**RULE 4: Ask about architectural changes**

**Trigger:** Fix/addition requires significant structural modification

**Action:** STOP, present to user, wait for decision

**Examples:**
- Adding new database table (not just column)
- Major schema changes (changing primary key, splitting tables)
- Introducing new service layer or architectural pattern
- Switching libraries/frameworks (React → Vue, REST → GraphQL)
- Changing authentication approach (sessions → JWT)
- Adding new infrastructure (message queue, cache layer, CDN)
- Changing API contracts (breaking changes to endpoints)
- Adding new deployment environment

**Process:**
1. STOP current task
2. Present clearly:
```
⚠️ Architectural Decision Needed

Current task: [task name]
Discovery: [what you found that prompted this]
Proposed change: [architectural modification]
Why needed: [rationale]
Impact: [what this affects - APIs, deployment, dependencies, etc.]
Alternatives: [other approaches, or "none apparent"]

Proceed with proposed change? (yes / different approach / defer)
```
3. WAIT for user response
4. If approved: implement, track as `[Rule 4 - Architectural] [description]`
5. If different approach: discuss and implement
6. If deferred: log to ISSUES.md, continue without change

**User decision required.** These changes affect system design.

---

**RULE 5: Log non-critical enhancements**

**Trigger:** Improvement that would enhance code but isn't essential now

**Action:** Add to .planning/ISSUES.md automatically, continue task

**Examples:**
- Performance optimization (works correctly, just slower than ideal)
- Code refactoring (works, but could be cleaner/DRY-er)
- Better naming (works, but variables could be clearer)
- Organizational improvements (works, but file structure could be better)
- Nice-to-have UX improvements (works, but could be smoother)
- Additional test coverage beyond basics (basics exist, could be more thorough)
- Documentation improvements (code works, docs could be better)
- Accessibility enhancements beyond minimum

**Process:**
1. Create .planning/ISSUES.md if doesn't exist (use template)
2. Add entry with ISS-XXX number (auto-increment)
3. Brief notification: `📋 Logged enhancement: [brief] (ISS-XXX)`
4. Continue task without implementing

**Template for ISSUES.md:**
```markdown
# Project Issues Log

Enhancements discovered during execution. Not critical - address in future phases.

## Open Enhancements

### ISS-001: [Brief description]
- **Discovered:** Phase [X] Plan [Y] Task [Z] (YYYY-MM-DD)
- **Type:** [Performance / Refactoring / UX / Testing / Documentation / Accessibility]
- **Description:** [What could be improved and why it would help]
- **Impact:** Low (works correctly, this would enhance)
- **Effort:** [Quick / Medium / Substantial]
- **Suggested phase:** [Phase number or "Future"]

## Closed Enhancements

[Moved here when addressed]
```

**No user permission needed.** Logging for future consideration.

---

**RULE PRIORITY (when multiple could apply):**

1. **If Rule 4 applies** → STOP and ask (architectural decision)
2. **If Rules 1-3 apply** → Fix automatically, track for Summary
3. **If Rule 5 applies** → Log to ISSUES.md, continue
4. **If genuinely unsure which rule** → Apply Rule 4 (ask user)

**Edge case guidance:**
- "This validation is missing" → Rule 2 (critical for security)
- "This validation could be better" → Rule 5 (enhancement)
- "This crashes on null" → Rule 1 (bug)
- "This could be faster" → Rule 5 (enhancement) UNLESS actually timing out → Rule 2 (critical)
- "Need to add table" → Rule 4 (architectural)
- "Need to add column" → Rule 1 or 2 (depends: fixing bug or adding critical field)

**When in doubt:** Ask yourself "Does this affect correctness, security, or ability to complete task?"
- YES → Rules 1-3 (fix automatically)
- NO → Rule 5 (log it)
- MAYBE → Rule 4 (ask user)

</deviation_rules>

<deviation_documentation>
## Documenting Deviations in Summary

After all tasks complete, Summary MUST include deviations section.

**If no deviations:**
```markdown
## Deviations from Plan

None - plan executed exactly as written.
```

**If deviations occurred:**
```markdown
## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed case-sensitive email uniqueness constraint**
- **Found during:** Task 4 (Follow/unfollow API implementation)
- **Issue:** User.email unique constraint was case-sensitive - Test@example.com and test@example.com were both allowed, causing duplicate accounts
- **Fix:** Changed to `CREATE UNIQUE INDEX users_email_unique ON users (LOWER(email))`
- **Files modified:** src/models/User.ts, migrations/003_fix_email_unique.sql
- **Verification:** Unique constraint test passes - duplicate emails properly rejected
- **Commit:** abc123f

**2. [Rule 2 - Missing Critical] Added JWT expiry validation to auth middleware**
- **Found during:** Task 3 (Protected route implementation)
- **Issue:** Auth middleware wasn't checking token expiry - expired tokens were being accepted
- **Fix:** Added exp claim validation in middleware, reject with 401 if expired
- **Files modified:** src/middleware/auth.ts, src/middleware/auth.test.ts
- **Verification:** Expired token test passes - properly rejects with 401
- **Commit:** def456g

**3. [Rule 3 - Blocking] Fixed broken import path for UserService**
- **Found during:** Task 5 (Profile endpoint)
- **Issue:** Import path referenced old location (src/services/User.ts) but file was moved to src/services/users/UserService.ts in previous plan
- **Fix:** Updated import path
- **Files modified:** src/api/profile.ts
- **Verification:** Build succeeds, imports resolve
- **Commit:** ghi789h

**4. [Rule 4 - Architectural] Added Redis caching layer (APPROVED BY USER)**
- **Found during:** Task 6 (Feed endpoint)
- **Issue:** Feed queries hitting database on every request, causing 2-3 second response times under load
- **Proposed:** Add Redis cache with 5-minute TTL for feed data
- **User decision:** Approved
- **Fix:** Implemented Redis caching with ioredis client, cache invalidation on new posts
- **Files created:** src/cache/RedisCache.ts, src/cache/CacheKeys.ts, docker-compose.yml (added Redis)
- **Verification:** Feed response time reduced to <200ms, cache hit rate >80% in testing
- **Commit:** jkl012m

### Deferred Enhancements

Logged to .planning/ISSUES.md for future consideration:
- ISS-001: Refactor UserService into smaller modules (discovered in Task 3)
- ISS-002: Add connection pooling for Redis (discovered in Task 6)
- ISS-003: Improve error messages for validation failures (discovered in Task 2)

---

**Total deviations:** 4 auto-fixed (1 bug, 1 missing critical, 1 blocking, 1 architectural with approval), 3 deferred
**Impact on plan:** All auto-fixes necessary for correctness/security/performance. No scope creep.
```

**This provides complete transparency:**
- Every deviation documented
- Why it was needed
- What rule applied
- What was done
- User can see exactly what happened beyond the plan

</deviation_documentation>

<step name="checkpoint_protocol">
When encountering `type="checkpoint:human-action"`, `type="checkpoint:human-verify"`, or `type="checkpoint:decision"`:

**Display checkpoint clearly:**
```
════════════════════════════════════════
CHECKPOINT: [Type]
════════════════════════════════════════

Task [X] of [Y]: [Action/What-Built/Decision]

[Display task-specific content based on type]

[Resume signal instruction]
════════════════════════════════════════
```

**For checkpoint:human-action:**
```
Instructions:
1. [Step 1]
2. [Step 2]
3. [Step 3]

I'll verify after: [verification]

[Resume signal - e.g., "Type 'done' when complete"]
```

**For checkpoint:human-verify:**
```
I just built: [what-built]

How to verify:
1. [Step 1]
2. [Step 2]
3. [Step 3]

[Resume signal - e.g., "Type 'approved' or describe issues"]
```

**For checkpoint:decision:**
```
Decision needed: [decision]

Context: [context]

Options:
1. [option-id]: [name]
   Pros: [pros]
   Cons: [cons]

2. [option-id]: [name]
   Pros: [pros]
   Cons: [cons]

[Resume signal - e.g., "Select: option-id"]
```

**After displaying:** WAIT for user response. Do NOT hallucinate completion. Do NOT continue to next task.

**After user responds:**
- Run verification if specified (file exists, env var set, etc.)
- If verification passes or N/A: continue to next task
- If verification fails: inform user, wait for resolution
</step>

<step name="verification_failure_gate">
If any task verification fails:

STOP. Do not continue to next task.

Present inline:
"Verification failed for Task [X]: [task name]

Expected: [verification criteria]
Actual: [what happened]

How to proceed?
1. Retry - Try the task again
2. Skip - Mark as incomplete, continue
3. Stop - Pause execution, investigate"

Wait for user decision.

If user chose "Skip", note it in SUMMARY.md under "Issues Encountered".
</step>

<step name="create_summary">
Create `{phase}-{plan}-SUMMARY.md` as specified in the prompt's `<output>` section.
Use templates/summary.md for structure.

**File location:** `.planning/phases/XX-name/{phase}-{plan}-SUMMARY.md`

**Title format:** `# Phase [X] Plan [Y]: [Name] Summary`

The one-liner must be SUBSTANTIVE:
- Good: "JWT auth with refresh rotation using jose library"
- Bad: "Authentication implemented"

**Next Step section:**
- If more plans exist in this phase: "Ready for {phase}-{next-plan}-PLAN.md"
- If this is the last plan: "Phase complete, ready for transition"
</step>

<step name="issues_review_gate">
Before proceeding, check SUMMARY.md content:

If "Issues Encountered" is NOT "None":
  Present inline:
  "Phase complete, but issues were encountered:
  - [Issue 1]
  - [Issue 2]

  Please review before proceeding. Acknowledged?"

  Wait for acknowledgment.

If "Next Phase Readiness" mentions blockers or concerns:
  Present inline:
  "Note for next phase:
  [concerns from Next Phase Readiness]

  Acknowledged?"

  Wait for acknowledgment.
</step>

<step name="update_roadmap">
Update ROADMAP.md:

**If more plans remain in this phase:**
- Update plan count: "2/3 plans complete"
- Keep phase status as "In progress"

**If this was the last plan in the phase:**
- Mark phase complete: status → "Complete"
- Add completion date
- Update plan count: "3/3 plans complete"
</step>

<step name="git_commit_plan">
Commit plan completion (PLAN + SUMMARY + code):

```bash
git add .planning/phases/XX-name/{phase}-{plan}-PLAN.md
git add .planning/phases/XX-name/{phase}-{plan}-SUMMARY.md
git add .planning/ROADMAP.md
git add src/  # or relevant code directories
git commit -m "$(cat <<'EOF'
feat({phase}-{plan}): [one-liner from SUMMARY.md]

- [Key accomplishment 1]
- [Key accomplishment 2]
- [Key accomplishment 3]
EOF
)"
```

Confirm: "Committed: feat({phase}-{plan}): [what shipped]"

**Commit scope pattern:**
- `feat(01-01):` for phase 1 plan 1
- `feat(02-03):` for phase 2 plan 3
- Creates clear, chronological git history
</step>

<step name="offer_next">
**If more plans in this phase:**
```
Plan {phase}-{plan} complete.
Summary: .planning/phases/XX-name/{phase}-{plan}-SUMMARY.md

[X] of [Y] plans complete for Phase Z.

What's next?
1. Execute next plan ({phase}-{next-plan})
2. Review what was built
3. Done for now
```

**If phase complete (last plan done):**
```
Plan {phase}-{plan} complete.
Summary: .planning/phases/XX-name/{phase}-{plan}-SUMMARY.md

Phase [Z]: [Name] COMPLETE - all [Y] plans finished.

What's next?
1. Transition to next phase
2. Review phase accomplishments
3. Done for now
```
</step>

</process>

<success_criteria>
- All tasks from PLAN.md completed
- All verifications pass
- SUMMARY.md created with substantive content
- ROADMAP.md updated
</success_criteria>
