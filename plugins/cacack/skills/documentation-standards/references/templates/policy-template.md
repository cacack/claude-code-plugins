# Policy Template

Standard template for platform policies.
Platform documentation repositories should follow this format for all policies in `docs/governance/policies/`.

## Template

```markdown
# <Policy Name>

## Policy Statement

<One to three sentences stating what the policy requires. Lead with the rule, not the rationale.>

## Scope

<Who and what this policy applies to. Include cloud/platform scope and audience (platform team, tenants, both).>

## Requirements

| ID | Requirement | Owner |
|---|---|---|
| <PREFIX>-01 | <Citable requirement statement> | <Platform \| Tenant \| Shared> |
| <PREFIX>-02 | ... | ... |

## Enforcement

<How non-compliance is detected and handled. Include progressive steps if applicable.>

## Related Documents

| Document | Relationship |
|---|---|
| <link> | <How it relates: implements, governed by, extends, etc.> |
```

## Conventions

### Platform Prefixes

Each platform has a namespace prefix used when citing requirements across platforms:

| Prefix | Platform |
|---|---|
| `CORE` | Team-wide policies |
| `OS` | OpenStack |
| `K8S` | Kubernetes |
| `AZR` | Azure |
| `GCP` | Google Cloud |

**Within a platform's own repo**, use the short form: `IMG-01`.
**In cross-platform contexts** (issue tracker, chat, team docs, compliance), prepend the platform prefix: `OS-IMG-01`.

Each platform's `docs/governance/policies/README.md` should declare its platform prefix.

### Requirement IDs

Each policy assigns a short prefix used for all its requirement IDs:

| Pattern | Example | Notes |
|---|---|---|
| `<PREFIX>-NN` | `IMG-01` | Two-digit, zero-padded, sequential |
| `<PLATFORM>-<PREFIX>-NN` | `OS-IMG-01` | Fully qualified, for cross-platform citation |

Prefixes should be 2-4 uppercase characters derived from the policy name.
Once assigned, IDs are stable — do not renumber when requirements are removed.

### Layered Platforms

Some platforms are built on top of others (e.g., Kubernetes runs as a tenant on OpenStack).
A layered platform is both a **platform** to its own tenants and a **tenant** of the platform beneath it.

When an upstream policy creates a downstream obligation:

1. The downstream platform creates its **own** requirement with its own ID
2. The **Related Documents** table cites the upstream requirement that drives it

Example for a Kubernetes policy driven by an OpenStack tenant obligation:

```markdown
| ID | Requirement | Owner |
|---|---|---|
| IMG-01 | Worker node images must use OS-supported versions | Platform |

## Related Documents

| Document | Relationship |
|---|---|
| OS-IMG-01 | Upstream requirement; K8S inherits image constraints as an OpenStack tenant |
```

This keeps each platform's policies self-contained while preserving the chain of custody.
If an upstream policy changes, the Related Documents links identify which downstream policies to review.

### Requirement Owner

The Owner column is a quick-reference summary.
The platform responsibility matrix (RACI) is authoritative if there is a conflict.

| Value | Meaning |
|---|---|
| Platform | Platform team is responsible |
| Tenant | Tenant owner is responsible |
| Shared | Both parties have responsibilities (clarify in the requirement text) |

### Sections

- **Policy Statement** and **Scope** are required for every policy.
- **Requirements** is required and must use the table format with IDs.
- **Enforcement** is required when non-compliance has consequences.
  Omit for purely informational policies (e.g., "how to request a flavor").
- **Related Documents** is optional but recommended when the policy references or is referenced by other governance documents.

### Writing Style

- State requirements as imperative rules, not descriptions of current behavior.
- One requirement per row — don't combine multiple obligations.
- Keep requirement text self-contained; a reader shouldn't need to follow a link to understand the rule.
- Link to architecture, procedures, or external docs for implementation details — not in the requirement itself.
