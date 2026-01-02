# SUMMARY.md Template

Every prompt execution must create a SUMMARY.md file for human scanning. This enables quick understanding of outputs without reading full XML-structured documents.

## Core Template

```markdown
# [Topic] [Purpose] Summary

**[Substantive one-liner describing the key outcome]**

**Version:** v1 (or iteration info)

## Key Findings
- Most important takeaway 1
- Most important takeaway 2
- Most important takeaway 3

## Files Created
<!-- For Do prompts only -->
- `path/to/file1.ts` - Description
- `path/to/file2.ts` - Description

## Decisions Needed
- Decision requiring user input
- Another decision point

## Blockers
- External impediment (or "None")

## Next Step
Concrete forward action
```

## Field Requirements

### One-liner (Required)

The most critical field. Must be:
- **Substantive**: Describes actual outcome, not generic completion
- **Actionable**: Reader knows what was accomplished
- **Specific**: Includes key detail or recommendation

**Good examples:**
```markdown
**JWT with jose library and httpOnly cookies recommended**
**4-phase implementation: types -> JWT core -> refresh -> tests**
**Auth middleware complete with 6 files, ready for integration**
**Zustand recommended for best TypeScript DX and simplicity**
```

**Bad examples:**
```markdown
**Research completed**  <!-- Too generic -->
**Plan created**  <!-- No information -->
**Implementation done**  <!-- What was implemented? -->
**Several options evaluated**  <!-- Which was chosen? -->
```

### Version (Required)

Track iterations:
- `v1` - Initial output
- `v2` - First refinement
- `v2.1` - Minor refinement
- `Iteration 3 of auth-research` - For ongoing work

### Key Findings (Required)

3-5 bullet points summarizing what was learned or decided:

```markdown
## Key Findings
- jose outperforms jsonwebtoken with better TypeScript support
- httpOnly cookies required (localStorage is XSS vulnerable)
- Refresh rotation is OWASP standard for token management
- 15-minute access token expiry balances security and UX
```

For **Do prompts**, focus on what was built:
```markdown
## Key Findings
- JWT middleware handles access and refresh tokens
- Token rotation implemented with family tracking
- All routes protected with authMiddleware
- Tests cover happy path and error cases
```

### Files Created (Do prompts only)

List files created during implementation:

```markdown
## Files Created
- `src/middleware/auth.ts` - JWT verification middleware
- `src/services/tokenService.ts` - Token generation and refresh
- `src/types/auth.ts` - Authentication type definitions
- `tests/auth.test.ts` - Auth middleware tests
```

Omit this section for Research and Plan outputs.

### Decisions Needed (Required)

What requires human input before proceeding:

```markdown
## Decisions Needed
- Approve 15-minute access token expiry
- Confirm refresh token rotation approach
- Select error message verbosity level
```

If no decisions needed:
```markdown
## Decisions Needed
None - ready for next phase
```

### Blockers (Required)

External impediments preventing progress:

```markdown
## Blockers
- Waiting for Stripe API credentials
- Need database schema approval from DBA
- Third-party API documentation incomplete
```

If no blockers:
```markdown
## Blockers
None
```

### Next Step (Required)

Single concrete action to move forward:

```markdown
## Next Step
Create auth-plan referencing this research
```

```markdown
## Next Step
Implement Phase 1: TypeScript type definitions
```

```markdown
## Next Step
Review implementation and run integration tests
```

## Purpose-Specific Templates

### Research Summary

```markdown
# Auth Research Summary

**JWT with jose library and httpOnly cookies recommended**

**Version:** v1

## Key Findings
- jose has superior TypeScript experience and async API
- httpOnly cookies prevent XSS token theft
- Refresh rotation per OWASP prevents replay attacks
- 15-min access / 7-day refresh is standard practice

## Decisions Needed
- Approve jose library selection
- Confirm cookie-based approach

## Blockers
None

## Next Step
Create auth-plan referencing jose library
```

### Plan Summary

```markdown
# Auth Implementation Plan Summary

**4-phase implementation: types -> JWT core -> refresh -> tests**

**Version:** v1

## Key Findings
- Phase 1: Type definitions (4 tasks)
- Phase 2: JWT generation/validation (6 tasks)
- Phase 3: Refresh token rotation (5 tasks)
- Phase 4: Testing and integration (4 tasks)
- Estimated: 3 days total implementation

## Decisions Needed
- Approve 15-minute token expiry
- Confirm refresh rotation approach

## Blockers
None

## Next Step
Begin Phase 1: Create auth types
```

### Do Summary

```markdown
# Auth Implementation Summary

**JWT middleware complete with 6 files created**

**Version:** v1

## Key Findings
- Middleware protects all /api/* routes
- Token refresh handles rotation correctly
- Type-safe throughout with full inference
- 94% test coverage on auth paths

## Files Created
- `src/middleware/auth.ts` - Route protection
- `src/services/tokenService.ts` - JWT operations
- `src/services/refreshService.ts` - Rotation logic
- `src/types/auth.ts` - Type definitions
- `tests/auth.test.ts` - Unit tests
- `tests/auth.integration.test.ts` - E2E tests

## Decisions Needed
- Review before Phase 2 (refresh UI)
- Confirm error message format

## Blockers
None

## Next Step
Run full test suite and code review
```

### Refine Summary

```markdown
# Auth Research Summary (Refined)

**v2: Added complete refresh token rotation implementation patterns**

**Version:** v2 (refined from v1)

## Key Changes
- Added refresh token rotation code patterns
- Added token family tracking for replay detection
- Resolved open questions about revocation

## Key Findings
- Refresh rotation with family tracking prevents replay
- Redis recommended for token family storage
- Revocation via family invalidation (not blocklist)
- Original jose recommendation confirmed

## Decisions Needed
- Approve Redis for token families
- Confirm family-based revocation approach

## Blockers
None

## Next Step
Update auth-plan with refined refresh approach
```

## Validation Rules

SUMMARY.md must be validated after creation:

1. **One-liner is substantive** - Not generic like "Research completed"
2. **Key Findings exist** - At least 3 bullet points
3. **Decisions Needed present** - Even if "None"
4. **Blockers present** - Even if "None"
5. **Next Step is concrete** - Specific action, not vague
6. **Version indicated** - v1, v2, etc.

## Anti-patterns

Avoid these common mistakes:

```markdown
<!-- BAD: Generic one-liner -->
**Research has been completed successfully**

<!-- GOOD: Specific outcome -->
**jose library recommended for JWT with httpOnly cookie storage**
```

```markdown
<!-- BAD: Vague next step -->
## Next Step
Continue with implementation

<!-- GOOD: Specific action -->
## Next Step
Create auth-plan using jose library patterns from this research
```

```markdown
<!-- BAD: Missing blockers section -->
(no blockers section)

<!-- GOOD: Explicit even when none -->
## Blockers
None
```
