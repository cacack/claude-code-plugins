# Scope Estimation & Plan Splitting

A plan should complete within ~80% of context usage. Beyond that, quality degrades as Claude rushes to finish.

## The 80% Rule

**Goal:** Each plan uses ≤80% of context window by completion.

**Why:**
- Consistent quality throughout execution
- No late-stage compression ("I'll do this more concisely...")
- Room for iteration and fixes
- Better git commits (focused, atomic)

**What happens at >80%:**
- Claude starts optimizing for completion over quality
- Later tasks get less thorough implementation
- Comments/docs get skipped
- Error handling becomes minimal
- Tests become perfunctory

## Signals to Split Into Multiple Plans

### Hard Signals (Always Split)

**1. More than 7 tasks**
- Context will be tight
- Split into logical groups

**2. Multiple subsystems**
- Database setup + API routes + UI components = 3 plans
- Each subsystem is a plan

**3. Research + Implementation**
- Research is one plan (produces FINDINGS.md)
- Implementation is separate plan (uses FINDINGS.md)

**4. Long refactoring**
- Refactor session will accumulate diffs
- Split by: file/module boundaries, or logical groupings

**5. Checkpoint-heavy work**
- If >2 checkpoints in a phase, likely needs multiple plans
- Group: setup tasks (with checkpoints) → implementation → verification

### Soft Signals (Consider Splitting)

**1. Complex task descriptions**
- If a task needs 3+ bullet points to explain, it might be its own plan

**2. Uncertainty about approach**
- "Figure out how to integrate X" + "implement X" = 2 plans
- Research plan → implementation plan

**3. Natural breakpoints**
- Setup → Core → Features
- Backend → Frontend
- Local dev → Deployment

**4. Estimated file count**
- Creating/modifying >12-15 files? Probably too much for one plan

## How to Split Effectively

### By Subsystem

**Example Phase:** "User Authentication"

**Split:**
- `01-01-PLAN.md`: Database schema (User table, sessions, migrations)
- `01-02-PLAN.md`: API routes (signup, login, logout, middleware)
- `01-03-PLAN.md`: UI components (forms, validation, error handling)

Each plan is independently executable and testable.

### By Dependency

**Example Phase:** "Payment Integration"

**Split:**
- `02-01-PLAN.md`: Stripe setup (account, webhook endpoints, env vars) + CHECKPOINTS
- `02-02-PLAN.md`: Subscription logic (plans, checkout session, customer portal)
- `02-03-PLAN.md`: Frontend integration (pricing page, payment flow, success/cancel)

Later plans depend on earlier plans being complete.

### By Complexity

**Example Phase:** "Dashboard Buildout"

**Split:**
- `03-01-PLAN.md`: Layout shell (sidebar, header, routing, responsive structure)
- `03-02-PLAN.md`: Data visualization (charts, tables, filtering, real-time updates)
- `03-03-PLAN.md`: User actions (settings, profile, notifications)

Each plan is substantial but focused.

### By Checkpoint Boundaries

**Example Phase:** "Deployment Pipeline"

**Split:**
- `04-01-PLAN.md`: Vercel setup + CHECKPOINT (create project, link repo)
- `04-02-PLAN.md`: Environment config (secrets, env vars, build settings)
- `04-03-PLAN.md`: CI/CD (GitHub Actions, preview deploys, production checks)

Checkpoints naturally segment the work.

## Estimating Context Usage

**Rough heuristics:**

| Task Count | Subsystems | Estimated Files | Context Usage | Recommendation |
|------------|-----------|-----------------|---------------|----------------|
| 1-3 | 1 | 1-5 | 20-40% | Single plan ✅ |
| 4-7 | 1-2 | 6-12 | 50-80% | Single plan ✅ |
| 8-10 | 2-3 | 13-20 | 85-95% | Consider split ⚠️ |
| 11+ | 3+ | 20+ | >95% | Must split ❌ |

**Other factors that increase context:**
- Complex refactoring (large diffs)
- External API integration (reading docs, testing)
- New technology (learning curve, experimentation)
- Debugging sessions (multiple iterations)

When in doubt, split. Smaller plans are faster and higher quality.

## What Each Plan Should Accomplish

**Ideal plan characteristics:**
- **3-6 tasks** - sweet spot for focus
- **Single subsystem** - cohesive, testable
- **Clear outcome** - "auth works end-to-end" not "did some auth stuff"
- **Independent** - can resume from here if needed
- **Verifiable** - tests pass, feature works, checkpoint approved

**Plan too small:**
- <3 tasks
- <30 minutes of work
- Could easily be combined with adjacent plan

**Plan too large:**
- >7 tasks
- >3 subsystems
- Multiple checkpoints
- "Implementation" without specificity

## Multiple Plans in Practice

**Phase structure:**
```
phases/01-authentication/
├── 01-01-PLAN.md          # Database setup
├── 01-01-SUMMARY.md       # ✅ Complete
├── 01-02-PLAN.md          # API routes
├── 01-02-SUMMARY.md       # ✅ Complete
├── 01-03-PLAN.md          # UI components
└── (no summary yet)       # ⏳ In progress
```

**Roadmap view:**
```markdown
## Phase 1: Authentication [IN_PROGRESS]

Plans:
- [x] 01-01: Database setup (User table, sessions, migrations)
- [x] 01-02: API routes (signup, login, logout, auth middleware)
- [ ] 01-03: UI components (login/signup forms, protected routes)

Status: 2/3 plans complete
```

**Execution flow:**
1. Plan phase → generates 3 plans (01-01, 01-02, 01-03)
2. Execute 01-01 → summary created
3. Execute 01-02 → summary created
4. Execute 01-03 → summary created
5. Transition → phase marked complete, advance to phase 2

## Simple Phases Don't Need Splitting

Not every phase needs multiple plans.

**Single-plan phases:**
- Scaffolding (create Next.js app, initial structure)
- Deployment (configure Vercel, deploy, test)
- Simple features (add dark mode toggle)
- Documentation updates (README, API docs)

**Indicators of single-plan phase:**
- 3-5 tasks total
- Single subsystem
- Quick setup/config work
- <2 hours estimated

For these: `01-01-PLAN.md` and `01-01-SUMMARY.md` is fine.

## Dealing with Uncertainty

**When scope is unclear:**

1. **Research plan first:**
   ```
   01-01-PLAN.md: Research user sync approaches
   01-02-PLAN.md: Implement chosen approach (depends on 01-01 findings)
   ```

2. **Defer decision:**
   ```
   Create roadmap with: "Phase 2: User Sync (1-3 plans, TBD after research)"
   Update roadmap after research with actual plan breakdown
   ```

3. **Over-estimate splits:**
   ```
   Better to have 4 small plans that finish fast
   Than 1 large plan that struggles to complete
   ```

## Examples

### Good: E-commerce Product Catalog

**Phase 3: Product Catalog**

**Split:**
- `03-01-PLAN.md` (4 tasks):
  - Product schema (table, variants, inventory)
  - Database migration
  - Seed sample products
  - Basic queries

- `03-02-PLAN.md` (5 tasks):
  - API routes (GET /products, GET /products/:id, filters)
  - Pagination logic
  - Search implementation
  - Tests for API
  - OpenAPI documentation

- `03-03-PLAN.md` (4 tasks):
  - Product list UI (grid, filters, sorting)
  - Product detail page
  - Search UI component
  - Loading/error states

Each plan: single subsystem, clear outcome, verifiable independently.

### Bad: Mega-Plan

**Phase 3: Product Catalog**

**Single plan with 13 tasks:**
- Database schema
- Migration
- Seeding
- API routes (5 endpoints)
- Pagination
- Search
- Tests
- Product grid UI
- Product detail UI
- Search UI
- Loading states

This will hit 95%+ context. Tasks 9-13 will get rushed implementation.

## Summary

- Aim for 80% context usage maximum
- Split when: >7 tasks, multiple subsystems, research+implementation, checkpoint-heavy
- Each plan should be focused, independently executable, and verifiable
- Use naming: `{phase}-{plan}-PLAN.md` for clarity
- When uncertain, split - smaller plans execute faster with higher quality
