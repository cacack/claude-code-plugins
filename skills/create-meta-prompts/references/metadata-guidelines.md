# Metadata Guidelines

Research and Plan outputs require structured metadata for downstream prompts to assess quality, dependencies, and gaps. This metadata enables intelligent chaining and helps users understand output reliability.

## Required Metadata Tags

All Research and Plan outputs must include these four XML metadata tags:

### 1. Confidence

Indicates how reliable the findings/plan are:

```xml
<confidence>
[High/Medium/Low] - [Reasoning explaining the rating]
</confidence>
```

**Levels:**

**High** - Use when:
- Sources are official documentation (2024-2025)
- Code examples are tested and verified
- Multiple sources confirm findings
- No significant gaps in research

```xml
<confidence>
High - All findings from official 2024 documentation. Code examples tested
against current library versions. Multiple sources confirm recommendations.
</confidence>
```

**Medium** - Use when:
- Mix of official and community sources
- Some areas lack recent documentation
- Code examples are adapted (not directly tested)
- Minor gaps exist but don't affect core recommendation

```xml
<confidence>
Medium - Primary recommendation based on official docs, but refresh token
patterns derived from community examples. jose library confirmed, rotation
approach needs validation.
</confidence>
```

**Low** - Use when:
- Relying on dated sources (pre-2023)
- Limited official documentation available
- Significant gaps in understanding
- Recommendation based on inference rather than evidence

```xml
<confidence>
Low - Limited official documentation for this library. Relying on 2022
blog posts and Stack Overflow answers. Recommend deeper investigation
before implementation.
</confidence>
```

### 2. Dependencies

External requirements needed to proceed:

```xml
<dependencies>
- [External dependency 1]
- [External dependency 2]
</dependencies>
```

**What to include:**
- Libraries/packages to install
- Services/APIs to configure
- Environment requirements
- Team resources needed
- Prerequisite knowledge

```xml
<dependencies>
- jose library (npm install jose)
- Redis for token family storage
- HTTPS-enabled domain for secure cookies
- Environment variables: JWT_SECRET, REFRESH_SECRET
</dependencies>
```

```xml
<dependencies>
- Stripe account with API keys
- Webhook endpoint accessible from internet
- Database for storing customer/subscription mappings
- Team member with Stripe dashboard access
</dependencies>
```

For plans, include phase dependencies:
```xml
<dependencies>
- Phase 1 completion before Phase 2
- Database schema approved before Phase 3
- Stripe test credentials before Phase 4
- Code review capacity for Phase 5
</dependencies>
```

If no external dependencies:
```xml
<dependencies>
None - can proceed with existing project setup
</dependencies>
```

### 3. Open Questions

What remains uncertain or unanswered:

```xml
<open_questions>
- [Unresolved question 1]
- [Area needing more investigation]
</open_questions>
```

**What to include:**
- Questions research couldn't answer
- Areas needing user input
- Trade-offs requiring decision
- Edge cases not covered
- Future considerations

```xml
<open_questions>
- Should refresh tokens be single-use or allow small reuse window?
- How to handle concurrent requests during token refresh?
- What's the policy for invalidating all user sessions?
- Multi-device session limits?
</open_questions>
```

```xml
<open_questions>
- Webhook retry policy if our server is down?
- How to handle partial subscription upgrades mid-cycle?
- Tax calculation responsibility (Stripe vs us)?
</open_questions>
```

Open questions often become refinement targets or plan decision points.

If all questions resolved:
```xml
<open_questions>
None - all key questions addressed in research
</open_questions>
```

### 4. Assumptions

What was assumed to be true during research/planning:

```xml
<assumptions>
- [Assumption 1]
- [Assumed condition 2]
</assumptions>
```

**What to include:**
- Technical assumptions (versions, environment)
- Business assumptions (requirements, constraints)
- User assumptions (skill level, preferences)
- Timeline assumptions
- Resource assumptions

```xml
<assumptions>
- Node.js 18+ with native fetch
- TypeScript strict mode enabled
- Single-tenant application (not multi-tenant)
- Users have modern browsers (no IE11)
- Team familiar with async/await patterns
</assumptions>
```

```xml
<assumptions>
- Stripe is approved vendor (no alternative evaluation needed)
- USD-only pricing initially
- No physical product shipping
- Monthly billing cycles only
- Team has 2 weeks for implementation
</assumptions>
```

Assumptions that prove false may require refinement or re-planning.

## Metadata Placement

Place metadata at the end of the document, after main content:

```markdown
# [Topic] Research

## Executive Summary
...

## Findings
...

## Recommendations
...

## Code Patterns
...

## Metadata

<confidence>
High - Official documentation and tested examples.
</confidence>

<dependencies>
- jose library
- Redis for token storage
</dependencies>

<open_questions>
- Multi-device session handling?
</open_questions>

<assumptions>
- Node.js 18+
- TypeScript strict mode
</assumptions>
```

## Metadata Evolution

### Research to Plan

Plan inherits and updates research metadata:

```xml
<!-- Research metadata -->
<confidence>High - Sources verified</confidence>
<open_questions>
- Refresh rotation approach?
</open_questions>

<!-- Plan metadata (updated) -->
<confidence>High - Based on high-confidence research</confidence>
<open_questions>
- (Resolved: using token family rotation)
- Task estimates may need adjustment
</open_questions>
```

### Refinement Updates

Refinement should improve metadata:

```xml
<!-- v1 -->
<confidence>Medium - Missing refresh details</confidence>
<open_questions>
- How to implement refresh rotation?
- Token revocation strategy?
</open_questions>

<!-- v2 (after refinement) -->
<confidence>High - All patterns documented with code</confidence>
<open_questions>
- (Resolved: refresh rotation documented)
- (Resolved: revocation via token families)
- Minor: Multi-device limits? (can defer)
</open_questions>
```

## Validation Rules

Metadata should be validated:

1. **Confidence has reasoning** - Not just "High" but why
2. **Dependencies are actionable** - Specific packages, services, resources
3. **Open questions are questions** - End with `?` or clearly interrogative
4. **Assumptions are falsifiable** - Can be verified true/false

## Anti-patterns

Avoid these metadata mistakes:

```xml
<!-- BAD: No reasoning -->
<confidence>High</confidence>

<!-- GOOD: Explains why -->
<confidence>
High - Based on official jose documentation (2024) and OWASP
authentication guidelines. All code examples tested.
</confidence>
```

```xml
<!-- BAD: Vague dependencies -->
<dependencies>
- Some libraries
- Database stuff
</dependencies>

<!-- GOOD: Specific and actionable -->
<dependencies>
- jose@5.x (npm install jose)
- PostgreSQL 14+ with uuid-ossp extension
- Redis 7+ for session storage
</dependencies>
```

```xml
<!-- BAD: Statements not questions -->
<open_questions>
- Token refresh
- Error handling
</open_questions>

<!-- GOOD: Actual questions -->
<open_questions>
- How should concurrent refresh requests be handled?
- What error codes should be returned for expired tokens?
</open_questions>
```

```xml
<!-- BAD: Unfalsifiable assumption -->
<assumptions>
- Good code quality
</assumptions>

<!-- GOOD: Verifiable assumption -->
<assumptions>
- TypeScript strict mode enabled
- ESLint with recommended rules
</assumptions>
```
