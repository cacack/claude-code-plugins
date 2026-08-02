# Runbook Template

Standard template for operational runbooks.
Platform and project documentation repositories should follow this format for documents in `docs/operations/runbooks/`.

## Template

```markdown
# {Runbook Title}

## Metadata

| Field | Value |
|---|---|
| **Last Updated** | {YYYY-MM-DD} |
| **Last Tested** | {YYYY-MM-DD} |
| **Estimated Duration** | {Time range, e.g., 15-30 minutes} |
| **Risk Level** | Low / Medium / High / Critical |
| **Tracking Issue** | [{TICKET-ID}]({url}), if applicable |
| **Support Channel** | {Channel for questions/escalation} |

## Overview

{1-3 sentences: what this runbook covers and why it exists.}

## Scope

- **In scope:** {What this runbook covers}
- **Out of scope:** {What it does NOT cover, with pointers to other runbooks}

## Trigger Conditions

When to use this runbook:

- {Alert name / error message / observable symptom}
- {Scheduled maintenance scenario}
- {Request from another team}

## Prerequisites

- {Access/permissions required}
- {Tools/CLI configured}
- {Environment variables set}
- {Pre-checks to complete before proceeding}

## Architecture

{Brief description or diagram of affected components.
Link to architecture docs rather than duplicating.}

---

## Procedures

### {Procedure Name}

**Trigger:** {Specific alert or condition} **Severity:** Low / Medium / High / Critical **Impact:** {What breaks if not addressed}

#### Step 1: {Action Name}

{Instructions with commands, expected output, and screenshots where helpful.}

\`\`\`bash

## command here

\`\`\`

**Expected result:** {What you should see}

### Step 2: {Action Name}

{Continue steps...}

> **Decision point:** If {condition A}, proceed to Step 3.
> If {condition B}, skip to [Rollback](#rollback).

---

### Verification

After completing the procedure, confirm success:

- {Check 1 with command or console step}
- {Check 2}
- {Monitor for N hours/minutes for delayed effects}

### Rollback

If the procedure fails or makes things worse:

1. {Undo step}
2. {Restore previous state}
3. {Verify rollback succeeded}

---

### Escalation

| Level | Contact | When |
|---|---|---|
| 1 | {Team/channel} | {First response / general questions} |
| 2 | {Specialist team} | {After N minutes without resolution} |
| 3 | {Management / vendor} | {Critical impact, SLA breach risk} |

**Required information for escalation:**

- {Diagnostic artifacts to gather before escalating}

### Troubleshooting

#### {Symptom description}

**Diagnosis:** {How to confirm this is the issue} **Resolution:** {Steps to fix}

---

### Monitoring

| Alarm Name | Trigger | Severity | Response |
|---|---|---|---|
| {name} | {condition} | {level} | {Link to procedure section above} |

### Cost Impact

{Optional.
Include when the procedure has financial implications: expected costs, budget thresholds, optimization notes.}

---

### References

- {Internal docs, architecture pages, infrastructure-as-code paths}
- {Vendor documentation}
- {Related runbooks}
```

## Section Guidance

### Required Sections

Every runbook must include:

- **Metadata** -- Operators need to know owner, risk, and duration before starting.
- **Overview** -- What this runbook is for.
- **Trigger Conditions** -- Operators must determine within 5 seconds whether they have the right runbook.
- **Procedures** -- The core step-by-step instructions.
- **Verification** -- Confirm success before declaring resolution.
- **Rollback** -- What to do when the procedure fails.
  Even "redeploy via infrastructure-as-code" counts.

### Optional Sections

Include when relevant:

- **Scope** -- When the boundary between this and related runbooks is unclear.
- **Prerequisites** -- When non-obvious access or setup is needed.
- **Architecture** -- When operators need context about affected components.
- **Escalation** -- Required for alert-driven runbooks.
  Optional for scheduled procedures.
- **Troubleshooting** -- When common failure modes are known.
- **Monitoring** -- When the runbook responds to specific alarms.
- **Cost Impact** -- When the procedure has financial implications.

### Writing Principles

- **Trigger conditions at the top.**
  Following Google SRE guidance, operators should find the right runbook fast.
  Alert names and observable symptoms appear before background context.
- **Decision points inline.**
  Branch logic ("if X, do Y; if Z, skip to rollback") belongs in the procedure steps, not in prose paragraphs.
- **Commands with expected output.**
  Every command should show what success looks like.
  Operators working under pressure should not have to guess.
- **Single-purpose runbooks.**
  Each runbook should cover one procedure or closely related set of procedures.
  Split large multi-topic runbooks into composable documents.
- **Test regularly.**
  The "Last Tested" date in metadata signals whether this runbook is trustworthy.
  Update it after each successful execution.

## Standards Traceability

This template draws from:

| Standard | Elements Used |
|---|---|
| [Google SRE](https://sre.google/sre-book/) | Trigger/Severity/Impact structure, playbook design principles |
| [ITIL v4](https://www.axelos.com/certifications/itil-service-management) | Goal, Scope, Roles, Trigger, Pre-checks, Process, Verification |
| [PagerDuty Runbook Guide](https://www.pagerduty.com/resources/automation/learn/what-is-a-runbook/) | Metadata header (Last Tested, Estimated Duration, Risk Level), decision points, rollback |
| [ISO 20000-1:2018](https://www.iso.org/standard/70636.html) | Document control, version management, periodic review |
| [FireHydrant](https://docs.firehydrant.com/docs/runbook-best-practices) | Single-purpose principle, composability |
| [NIST SP 800-53](https://csrc.nist.gov/pubs/sp/800/53/r5/upd1/final) | Baseline configuration documentation, change management procedures |

## Related Documents

| Document | Relationship |
|---|---|
| [Documentation Standards](../standard.md) | Writing style and placement rules |
| [Architecture Template](architecture-template.md) | For architecture docs referenced from runbooks |
| [Guide Template](guide-template.md) | For consumer-facing docs that complement runbooks |
