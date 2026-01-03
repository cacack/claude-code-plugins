# Human Checkpoints in Plans

Plans execute autonomously, but some tasks require human involvement. Checkpoints formalize these interaction points.

## Checkpoint Types

### 1. `checkpoint:human-action`

**When:** Human must create/configure external resource Claude can't access.

**Examples:**
- Creating cloud resources (Upstash DB, Vercel project, Stripe account)
- Generating API keys/credentials
- Configuring DNS records
- Setting up payment accounts
- Manual deployment steps

**Structure:**
```xml
<task type="checkpoint:human-action" gate="blocking">
  <action>Create Upstash Redis database</action>
  <instructions>
    1. Visit console.upstash.com
    2. Click "Create Database" → Redis
    3. Name: myapp-prod-cache
    4. Region: US-East-1
    5. Copy UPSTASH_REDIS_REST_URL from dashboard
    6. Add to .env: UPSTASH_REDIS_REST_URL=https://...
  </instructions>
  <verification>Check .env file contains UPSTASH_REDIS_REST_URL</verification>
  <resume-signal>Type "done" when complete</resume-signal>
</task>
```

**Key elements:**
- `<action>`: Brief description of what human does
- `<instructions>`: Step-by-step (numbered, specific)
- `<verification>`: What Claude can check afterward (file exists, env var set)
- `<resume-signal>`: Clear indication of how to continue

### 2. `checkpoint:human-verify`

**When:** Claude builds something, human must verify it works correctly.

**Examples:**
- Visual UI checks (layout, styling, responsiveness)
- Interactive flows (click through wizard)
- Audio/video playback
- Animation smoothness
- Print layouts
- Accessibility testing

**Structure:**
```xml
<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Authentication flow UI</what-built>
  <how-to-verify>
    1. Run: npm run dev
    2. Visit: http://localhost:3000/login
    3. Test login with: test@example.com / password123
    4. Confirm:
       - Form validates empty fields
       - Error messages show for wrong credentials
       - Successful login redirects to /dashboard
       - No console errors
  </how-to-verify>
  <resume-signal>Type "approved" to continue, or describe issues to fix</resume-signal>
</task>
```

**Key elements:**
- `<what-built>`: What Claude just created
- `<how-to-verify>`: Exact steps to test (URLs, commands, expected behavior)
- `<resume-signal>`: Approval or issue description

### 3. `checkpoint:decision`

**When:** Human must make choice that affects implementation direction.

**Examples:**
- Technology selection (which auth provider?)
- Architecture decisions (monorepo vs separate repos?)
- Design choices (color scheme, layout approach)
- Feature prioritization (which variant to build?)
- Data model decisions (schema structure)

**Structure:**
```xml
<task type="checkpoint:decision" gate="blocking">
  <decision>Select authentication provider</decision>
  <context>
    We need user authentication. Three solid options with different tradeoffs:
  </context>
  <options>
    <option id="supabase">
      <name>Supabase Auth</name>
      <pros>Built-in with Supabase, free tier generous, already using Supabase DB</pros>
      <cons>Less customizable UI, tied to Supabase ecosystem</cons>
    </option>
    <option id="clerk">
      <name>Clerk</name>
      <pros>Beautiful pre-built UI, best DX, excellent docs</pros>
      <cons>Paid after 10k MAU, vendor lock-in</cons>
    </option>
    <option id="nextauth">
      <name>NextAuth.js</name>
      <pros>Free, self-hosted, maximum control, widely adopted</pros>
      <cons>More setup, you manage security, UI is DIY</cons>
    </option>
  </options>
  <resume-signal>Select: supabase, clerk, or nextauth</resume-signal>
</task>
```

**Key elements:**
- `<decision>`: What's being decided
- `<context>`: Why this decision matters
- `<options>`: Each option with pros/cons (be balanced, not prescriptive)
- `<resume-signal>`: How to indicate choice

## Execution Protocol

When Claude encounters `type="checkpoint:*"`:

1. **Stop immediately** - do not proceed to next task
2. **Display checkpoint clearly:**

```
════════════════════════════════════════
CHECKPOINT: Human Action Required
════════════════════════════════════════

Task 3 of 8: Create Upstash Redis database

Instructions:
1. Visit console.upstash.com
2. Click "Create Database" → Redis
3. Name: myapp-prod-cache
4. Region: US-East-1
5. Copy UPSTASH_REDIS_REST_URL
6. Add to .env file

Verification (I'll check after):
- .env contains UPSTASH_REDIS_REST_URL

Type "done" when complete.
════════════════════════════════════════
```

3. **Wait for user response** - do not hallucinate completion
4. **Verify if possible** - check files, env vars, whatever is specified
5. **Resume execution** - continue to next task only after confirmation

## Writing Good Checkpoints

**DO:**
- Be specific: "Visit console.upstash.com" not "go to Upstash"
- Number steps: easier to follow
- State expected outcomes: "You should see X"
- Provide context: why this checkpoint exists
- Make verification clear: what Claude will check afterward

**DON'T:**
- Assume knowledge: "Configure the usual settings" ❌
- Skip steps: "Set up database" ❌ (too vague)
- Mix multiple actions in one checkpoint (split them)
- Make verification impossible (Claude can't check visual appearance without user confirmation)

## When to Use Checkpoints

**Use checkpoints for:**
- External resource creation (APIs, databases, accounts)
- Visual verification (UI, layouts, animations)
- Human judgment calls (design, UX, copy)
- Security-sensitive operations (credentials, keys)
- Financial operations (payment setup, billing)

**Don't use checkpoints for:**
- Things Claude can verify programmatically (tests, builds, type checking)
- File creation (Claude can read files to verify)
- Code correctness (use tests instead)
- Things that can be automated (prefer automation)

## Checkpoint Placement

Place checkpoints:
- **After setup tasks** - before dependent work begins
- **After UI buildout** - before declaring phase complete
- **Before major decisions** - when direction affects many downstream tasks
- **At integration points** - when connecting to external services

Bad placement:
- Mid-flow (task 4 of 8 builds on checkpoint result but checkpoint is task 6) ❌
- Too frequent (every other task is a checkpoint) ❌
- Too late (checkpoint is last task, but earlier tasks needed its result) ❌

## Examples

### Good: External Resource Setup

```xml
<task type="checkpoint:human-action" gate="blocking">
  <action>Create Vercel project and link to repository</action>
  <instructions>
    1. Visit vercel.com/new
    2. Import Git repository: github.com/you/your-repo
    3. Framework: Next.js (auto-detected)
    4. Keep defaults, click "Deploy"
    5. Wait for initial deployment to complete
    6. Copy project URL (e.g., https://your-app.vercel.app)
  </instructions>
  <verification>Vercel project exists and is accessible</verification>
  <resume-signal>Paste the Vercel project URL</resume-signal>
</task>
```

### Good: UI Verification

```xml
<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Responsive dashboard layout</what-built>
  <how-to-verify>
    1. Run: npm run dev
    2. Visit: http://localhost:3000/dashboard
    3. Desktop (>1024px): Verify sidebar left, content right, header top
    4. Tablet (768px): Verify sidebar collapses to hamburger menu
    5. Mobile (375px): Verify single column layout, bottom nav
    6. Check: No layout shift, no horizontal scroll
  </how-to-verify>
  <resume-signal>Type "approved" or describe layout issues</resume-signal>
</task>
```

### Good: Decision Point

```xml
<task type="checkpoint:decision" gate="blocking">
  <decision>Choose payment flow architecture</decision>
  <context>
    Two approaches for handling subscription payments. Both work, different complexity.
  </context>
  <options>
    <option id="payment-links">
      <name>Stripe Payment Links</name>
      <pros>Zero frontend code, Stripe handles UI, fastest setup (30 min)</pros>
      <cons>Less customization, redirects away from site, basic branding</cons>
    </option>
    <option id="checkout-session">
      <name>Stripe Checkout Session</name>
      <pros>Embedded or redirect, more control, custom success pages</pros>
      <cons>More code, longer setup (2-3 hours), need to handle webhooks</cons>
    </option>
  </options>
  <resume-signal>Select: payment-links or checkout-session</resume-signal>
</task>
```

### Bad: Too Vague

```xml
<!-- ❌ BAD -->
<task type="checkpoint:human-action" gate="blocking">
  <action>Set up database</action>
  <instructions>
    1. Create a database
    2. Configure it
    3. Add credentials to .env
  </instructions>
  <verification>Database works</verification>
  <resume-signal>Done</resume-signal>
</task>
```

**Problems:**
- "Create a database" - where? what type? what name?
- "Configure it" - configure what? how?
- "Database works" - how does Claude verify this?

### Bad: Should Be Automated

```xml
<!-- ❌ BAD -->
<task type="checkpoint:human-action" gate="blocking">
  <action>Install dependencies</action>
  <instructions>
    1. Run: npm install
  </instructions>
  <verification>node_modules exists</verification>
  <resume-signal>Done</resume-signal>
</task>
```

**Why bad:** Claude can run `npm install` directly. This should be a regular `type="auto"` task, not a checkpoint.

## Checkpoint Anti-Patterns

**Too many checkpoints:**
```xml
<tasks>
  <task type="auto">Create schema</task>
  <task type="checkpoint:human-verify">Check schema</task>
  <task type="auto">Create API route</task>
  <task type="checkpoint:human-verify">Check API</task>
  <task type="auto">Create UI form</task>
  <task type="checkpoint:human-verify">Check form</task>
</tasks>
```

Better: One checkpoint at the end to verify the complete feature.

**Checkpoint with unverifiable outcome:**
```xml
<task type="checkpoint:human-action" gate="blocking">
  <action>Make the app look good</action>
  <verification>App looks good</verification>
</task>
```

Too subjective. Be specific about what "good" means.

**Dependency inversion:**
```xml
<task type="auto">Build feature that uses database</task>
<task type="checkpoint:human-action">Create database</task>
```

Checkpoint should come first - can't build features that depend on it.

## Summary

Checkpoints formalize human-in-the-loop points. Use them when Claude cannot complete a task autonomously. Be specific, provide context, make verification clear. Place them logically in the task sequence.
