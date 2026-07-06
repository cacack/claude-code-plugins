# Design Document Template

Standard template for design documents.
Platform and project documentation repositories should follow this format for documents in `docs/designs/`.

## Purpose

Design documents capture the implementation-level detail needed to build a system: code sketches, schema definitions, test strategies, coupling analysis, and trade-off reasoning.
They bridge the gap between architecture (what and why) and code (the implementation itself).

This distinction matters:

| If the reader needs to... | They need a... | Location |
|---|---|---|
| Understand the system's structure, stakeholders, and decisions | **Architecture doc** | `docs/architecture/` |
| Build the system from implementation details and code examples | **Design doc** | `docs/designs/` |
| Record a single decision with alternatives considered | **ADR** | `docs/decisions/` |
| Operate or troubleshoot the running system | **Runbook** | `docs/operations/runbooks/` |

## Lifecycle

Design documents are living during implementation, then archived.
Unlike architecture docs, they are not maintained after the system is built.

| Status | Meaning |
|---|---|
| **Draft** | Under development, not yet reviewed |
| **Active** | Reviewed and in use as an implementation reference |
| **Archived** | Implementation complete; code and architecture doc are now authoritative |

Once archived, the document remains as a historical artifact.
It explains the reasoning and exploration that led to the implementation.
Do not update archived design docs; update the architecture doc or code instead.

## Naming Convention

Design files use the format: `{topic}.md` or `{capability}-{topic}.md`

- Lowercase, hyphens for spaces
- Capability prefix when applicable (e.g., `monitoring-alerting-pipeline.md`)

## Template

```markdown
# {Design Title}

| Field | Value |
|---|---|
| **Status** | Draft / Active / Archived |
| **Last Updated** | {YYYY-MM-DD} |
| **Architecture Doc** | [{title}]({link}) |
| **Tracking Epic** | [{TICKET-ID}]({url}) |

## Overview

{What this design covers and what problem it solves. 2-3 sentences.
Link to the architecture doc for system context and stakeholder concerns.
Link to the tracking epic or issues for work tracking.}

## Goals and Non-Goals

**Goals:**

- {What this design aims to achieve}

**Non-Goals:**

- {What is explicitly out of scope for this design}

## Data Model

{Schema definitions, data structures, message formats.
Use concrete examples with realistic data.
Document field-level details in tables.}

## Component Design

{Implementation details for each major component.
Include code sketches, interface definitions, and module structure.
This is where the "how to build it" lives.}

### {Component Name}

{Purpose, responsibilities, key interfaces.
Include code examples in the implementation language.}

## Integration Points

{How components connect to each other and to external systems.
API contracts, event formats, IAM role assumptions, network paths.}

## Test Strategy

{How to validate the implementation.
Test pyramid: unit, contract, integration.
Include example test code where it clarifies the approach.}

## Coupling and Trade-offs

{Design tensions identified during exploration.
Inherent vs. accidental coupling.
Trade-offs accepted and why.}

## Implementation Plan

{Phased delivery: what ships first, what follows.
Issue-level breakdown with acceptance criteria.
Link to tracking issues once created.}

## Open Questions

{Unresolved decisions or areas needing further investigation.
Remove or convert to decisions as they are resolved.}

## References

- {Architecture doc, diagrams, tracking issues, related ADRs, external resources}
```

## Section Guidance

### Required Sections

Every design doc must include:

- **Metadata table** -- Status, Last Updated, Architecture Doc link, and Tracking Epic link.
- **Overview** -- What this design covers.
  Link to the architecture doc for broader context.
- **Component Design** -- The core implementation details.
  Without this, the document is not a design doc.
- **Test Strategy** -- How to validate the implementation.
  This is frequently the content most needed by the developer and most missing from other document types.

### Optional Sections

- **Data Model** -- Include when the design introduces schemas, message formats, or data structures.
  Especially valuable when multiple components share a contract.
- **Goals and Non-Goals** -- Include when scope boundaries need explicit statement.
- **Integration Points** -- Include when the design connects to external systems or crosses account boundaries.
- **Coupling and Trade-offs** -- Include when the design involves non-obvious trade-offs or when coupling decisions were debated.
  Valuable as a historical record of why the implementation looks the way it does.
- **Implementation Plan** -- Include when the work spans multiple issues or phases.
- **Open Questions** -- Include during Draft status.
  All questions should be resolved before moving to Active.

### Code Examples

Design docs should include concrete code examples in the implementation language.
These are sketches, not production code:

- Show the pattern, not every edge case
- Include enough context to be copy-pasteable as a starting point
- Use realistic variable names and data
- Comment only where the pattern is non-obvious

### Relationship to Architecture Docs

The architecture doc and design doc are complementary:

| Aspect | Architecture Doc | Design Doc |
|---|---|---|
| Audience | Architects, operators, stakeholders | Implementing developer |
| Lifespan | Maintained as long as system exists | Archived after implementation |
| Content | What, why, quality attributes, risks | How, code sketches, test strategy |
| Diagrams | System context, component relationships | Sequence flows, data models |
| Level of detail | Sufficient to evaluate and operate | Sufficient to implement |

The architecture doc links to the design doc as a developer reference.
The design doc links to the architecture doc for system context.
After archival, the architecture doc and code are authoritative; the design doc explains how we got there.

## Standards Traceability

This template draws from:

| Standard | Elements Used |
|---|---|
| [Google Design Docs](https://www.industrialempathy.com/posts/design-docs-at-google/) | Goals/Non-Goals, context/overview, design sections, open questions |
| [Diataxis Framework](https://diataxis.fr/) | Explanation type: understanding-oriented, for study and contemplation |
| [arc42](https://arc42.org/) | Crosscutting concepts, building block view, design decisions |

## Related Documents

| Document | Relationship |
|---|---|
| [Documentation Standards](../standard.md) | Writing style and placement rules |
| [Architecture Template](architecture-template.md) | For the companion architecture doc that the design doc implements |
| [ADR Template](adr-template.md) | For individual decisions referenced from design docs |
