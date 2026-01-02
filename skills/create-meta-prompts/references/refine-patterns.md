# Refine Prompt Patterns

Templates for iterating on and improving existing research or plan outputs.

## Core Template

```xml
<refine_objective>
Refine: [Existing output to improve]

Target: @.prompts/{number}-{topic}-{purpose}/{topic}-{purpose}.md
Feedback: [What needs improvement]
Preserve: [What should stay the same]
Output: Save refined version to `.prompts/{number}-{topic}-{purpose}-refine/{topic}-{purpose}.md`
</refine_objective>

<refinement_scope>
**Improve:**
- [Specific area needing improvement 1]
- [Specific area needing improvement 2]
- [Gap to fill or question to answer]

**Preserve:**
- [Key finding or decision to keep]
- [Code example that works well]
- [Structure that's effective]

**Do not change:**
- [Area that's already satisfactory]
- [Previous decision that stands]
</refinement_scope>

<refinement_approach>
1. Read existing output: @.prompts/{number}-{topic}-{purpose}/{topic}-{purpose}.md
2. Identify specific sections needing refinement
3. Preserve effective content by copying forward
4. Add depth to weak areas
5. Fill identified gaps
6. Update metadata to reflect changes

**Version tracking:**
- Archive previous version to: `.prompts/{number}-{topic}-{purpose}-refine/archive/{topic}-{purpose}-v{n}.md`
- Label new version in output
</refinement_approach>

<output_structure>
Save refined output to: `.prompts/{number}-{topic}-{purpose}-refine/{topic}-{purpose}.md`

Maintain same structure as original with:
- Clear version indicator (v2, v3, etc.)
- Change summary at top showing what was refined
- Updated metadata reflecting new confidence/gaps

```xml
# [Topic] [Purpose] v{n}

## Changes from v{n-1}
- [What was added]
- [What was improved]
- [What was corrected]

## [Rest of original structure with updates]
...

## Metadata

<confidence>
[Updated confidence based on refinement]
</confidence>

<dependencies>
[Updated dependencies]
</dependencies>

<open_questions>
[Updated - some may be resolved, new ones may emerge]
</open_questions>

<assumptions>
[Updated assumptions]
</assumptions>
```
</output_structure>

<summary>
Create `.prompts/{number}-{topic}-{purpose}-refine/SUMMARY.md` with:

**One-liner:** [What specifically improved from previous version]

**Version:** v{n} (refined from v{n-1})

**Key Changes:**
- What was added or improved
- Gaps that were filled
- New findings or clarifications

**Key Findings:** [Updated from refinement]

**Decisions Needed:** [Any remaining decisions]

**Blockers:** [Any remaining blockers]

**Next Step:** [What to do with refined output]
</summary>

<success_criteria>
- Previous version archived
- Specified improvements made
- Preserved content maintained
- New version clearly labeled
- Metadata updated
- Change summary included
- SUMMARY.md reflects refinement
</success_criteria>
```

## Refinement Types

### 1. Research Deepening

Adding depth to an existing research output:

```xml
<refine_objective>
Refine: auth-research

Target: @.prompts/001-auth-research/auth-research.md
Feedback: JWT section lacks implementation details for refresh tokens
Preserve: Library comparison and recommendation (jose)
Output: Deeper research on refresh token patterns
</refine_objective>

<refinement_scope>
**Deepen:**
- Refresh token rotation implementation patterns
- Token revocation strategies
- Concurrent session handling

**Preserve:**
- Library recommendation (jose)
- Token storage findings (httpOnly cookies)
- Basic JWT generation examples

**Add:**
- Complete refresh flow code example
- Token family tracking implementation
- Revocation list patterns
</refinement_scope>

<output_structure>
Archive: .prompts/002-auth-research-refine/archive/auth-research-v1.md

Create v2 with:
- All v1 content preserved
- New "Refresh Token Deep Dive" section
- Updated code examples with full refresh flow
- Revised confidence (should be higher)
- Fewer open questions
</output_structure>

<summary>
**One-liner:** Added complete refresh token rotation implementation with token family tracking

**Version:** v2 (refined from v1)

**Key Changes:**
- Added refresh token rotation code patterns
- Added token family tracking for replay detection
- Added revocation list implementation options

**Next Step:** Update auth-plan to incorporate refresh patterns
</summary>
```

### 2. Plan Expansion

Expanding a plan with more detail:

```xml
<refine_objective>
Refine: auth-plan

Target: @.prompts/002-auth-plan/auth-plan.md
Feedback: Phase 2 (refresh tokens) needs more detailed tasks
Preserve: Overall 4-phase structure and timeline
Output: Expanded phase 2 with granular tasks
</refine_objective>

<refinement_scope>
**Expand:**
- Phase 2 task breakdown (currently 3 tasks, need 8-10)
- Specific file creation details
- Test cases for each task

**Preserve:**
- 4-phase structure
- Estimated timeline
- Phase 1, 3, 4 details
- Dependencies between phases

**Add:**
- Granular Phase 2 tasks
- Specific test scenarios
- Error handling tasks
</refinement_scope>

<output_structure>
Archive: .prompts/003-auth-plan-refine/archive/auth-plan-v1.md

Create v2 with:
- Phase 2 expanded from 3 to 10 tasks
- Each task has clear deliverable
- Test scenarios specified
- Error cases enumerated
</output_structure>
```

### 3. Feedback Integration

Incorporating user feedback:

```xml
<refine_objective>
Refine: stripe-plan

Target: @.prompts/005-stripe-plan/stripe-plan.md
Feedback: User requested adding subscription pause/resume feature
Preserve: Existing checkout and webhook phases
Output: Plan updated with subscription management phase
</refine_objective>

<refinement_scope>
**Add based on feedback:**
- New Phase 4: Subscription Management
  - Pause subscription
  - Resume subscription
  - Upgrade/downgrade handling

**Preserve:**
- Phases 1-3 unchanged
- Webhook integration approach
- Test strategy

**Update:**
- Timeline (add 2 days for new phase)
- Dependencies (new phase depends on Phase 3)
- Success criteria (add subscription management)
</refinement_scope>

<output_structure>
Archive: .prompts/006-stripe-plan-refine/archive/stripe-plan-v1.md

Create v2 with:
- New Phase 4 section
- Updated timeline
- Updated success criteria
- Change summary documenting user feedback
</output_structure>
```

### 4. Gap Filling

Addressing open questions from previous output:

```xml
<refine_objective>
Refine: state-management-research

Target: @.prompts/007-state-research/state-research.md
Feedback: Open questions about Zustand DevTools need answers
Preserve: Library recommendation and comparison matrix
Output: Research with DevTools questions resolved
</refine_objective>

<refinement_scope>
**Resolve open questions:**
- How does Zustand DevTools compare to Redux DevTools?
- Can Zustand debug in production?
- What's the setup process for DevTools?

**Preserve:**
- Library recommendation (Zustand)
- Comparison matrix
- Code examples

**Add:**
- DevTools setup guide
- Comparison with Redux DevTools
- Production debugging options
</refinement_scope>

<output_structure>
Archive: .prompts/008-state-research-refine/archive/state-research-v1.md

Create v2 with:
- New "DevTools Deep Dive" section
- Updated open_questions (should be fewer)
- Higher confidence level
- Complete DevTools code examples
</output_structure>
```

## Key Principles

### 1. Always Archive Previous Versions

Never overwrite - always preserve history:

```
.prompts/{number}-{topic}-{purpose}-refine/
├── archive/
│   ├── {topic}-{purpose}-v1.md
│   └── {topic}-{purpose}-v2.md  (if refining again)
├── {topic}-{purpose}.md  (current version)
└── SUMMARY.md
```

### 2. Change Summary Required

Every refinement starts with what changed:

```markdown
## Changes from v1
- **Added**: Complete refresh token rotation section with code
- **Improved**: JWT generation example now includes proper error handling
- **Resolved**: Open question about token expiry (15 min confirmed via OWASP)
- **Preserved**: Library recommendation, storage approach
```

### 3. Preserve What Works

Don't refine for the sake of refining:

```xml
<!-- Good: Targeted refinement -->
<refinement_scope>
**Improve:** JWT refresh implementation (weak area)
**Preserve:** Library choice, storage recommendation, basic examples
</refinement_scope>

<!-- Bad: Wholesale rewrite -->
<refinement_scope>
**Improve:** Everything - rewrite from scratch
</refinement_scope>
```

### 4. Update Metadata Accurately

Refinement should change metadata:

```xml
<!-- v1 metadata -->
<confidence>Medium - Missing refresh token details</confidence>
<open_questions>
- How to implement refresh rotation?
- Token revocation strategy?
</open_questions>

<!-- v2 metadata (after refinement) -->
<confidence>High - All patterns documented with working code</confidence>
<open_questions>
- (Resolved: refresh rotation documented)
- (Resolved: revocation via token families)
- New: Multi-device session limits? (minor, can defer)
</open_questions>
```

### 5. Version Naming

Clear version indicators:

- **v1**: Original output
- **v2**: First refinement
- **v2.1**: Minor refinement (typos, small additions)
- **v3**: Second major refinement

Include in SUMMARY.md one-liner: "v2: Added refresh token rotation patterns"

## Template Selection

Choose refinement depth based on feedback:

- **Minor**: Typos, small clarifications, formatting
- **Moderate**: New section, expanded detail, gap filling
- **Major**: Significant restructure, new research, feedback integration

All refinements should:
- Archive previous versions
- Document changes clearly
- Update metadata accurately
- Preserve effective content
- Create updated SUMMARY.md
