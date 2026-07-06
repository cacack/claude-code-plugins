# Architecture Document Template

Standard template for architecture documents.
Platform and project documentation repositories should follow this format for documents in `docs/architecture/`.

## Document Types

Architecture documents serve two purposes.
Choose the type that fits:

| Type | Use When | Examples |
|---|---|---|
| **Specification** | Documenting a foundational platform component end-to-end | Landing zone, centralized networking, centralized logging |
| **Capability Overview** | Introducing a capability and its available solutions/products | Monitoring overview, backup overview, logging overview |

Both types share a common metadata header.
The body sections differ.

## Metadata Header

All architecture documents begin with:

```markdown
# {Document Title}

| Field | Value |
|---|---|
| **Last Reviewed** | {YYYY-MM-DD} |
| **Status** | Draft / Current / Deprecated |
```

## Type A: Architecture Specification

Full architecture description for a platform component.
Use for foundational designs that teams build on.

```markdown
# {Component Name} Architecture

| Field | Value |
|---|---|
| **Last Reviewed** | {YYYY-MM-DD} |
| **Status** | Draft / Current / Deprecated |

## Purpose and Scope

{What this architecture covers, its boundaries, and key objectives. 1-3 sentences.
State what is in scope and out of scope.}

Traces to: TOGAF (Scope/Goals), arc42 s1, ISO/IEC 42010 (System of Interest)

## Stakeholders

| Stakeholder | Concerns |
|---|---|
| {Role or team} | {What they care about regarding this component} |

Traces to: ISO/IEC 42010 (Stakeholders & Concerns), TOGAF, arc42 s1

## Constraints

- {Technical, organizational, regulatory, or cost constraints}

Traces to: arc42 s2, TOGAF (Constraints)

## Context

{System in scope, external dependencies, and data flows.
Include a C4 Level 1 (System Context) diagram or equivalent.}

Traces to: arc42 s3, C4 Level 1, ISO/IEC 42010 (Views)

## Solution Architecture

{How it works: topology, key components, interactions.
Include a C4 Level 2 (Container) diagram where helpful.
Use Mermaid or reference an image file.}

Traces to: arc42 s4+s5, TOGAF (Target Architecture), C4 Level 2

## Deployment View

{Environments, regions, accounts, infrastructure mapping.
Show how logical components map to physical infrastructure.}

Traces to: arc42 s7, AWS Well-Architected (Operational Excellence)

## Crosscutting Concerns

{Security, logging, monitoring, tagging, backup.
Reference other architecture docs rather than duplicating content.}

Traces to: arc42 s8, AWS Well-Architected (all pillars)

## Design Decisions

{Key choices with rationale and alternatives considered.
Link to ADRs in `docs/decisions/` for major decisions.
Keep inline entries brief -- 2-3 sentences per decision.}

Traces to: arc42 s9, ISO/IEC 42010 (Decisions & Rationale), TOGAF

## Quality Attributes

| Attribute | Target | Notes |
|---|---|---|
| Availability | {e.g., 99.9%} | |
| RPO | {e.g., 1 hour} | |
| RTO | {e.g., 4 hours} | |
| {Other} | {Target} | |

Traces to: arc42 s10, ISO/IEC 42010 (Concerns), AWS Well-Architected (Reliability/Performance)

## Risks and Technical Debt

| Risk / Debt Item | Impact | Mitigation |
|---|---|---|
| {Description} | {Consequence if unaddressed} | {Current or planned mitigation} |

Traces to: arc42 s11

## Operational Model

{Deployment pipeline, change management approach, monitoring/alerting strategy.
Link to runbooks in `docs/operations/runbooks/` rather than duplicating procedures.}

Traces to: AWS Well-Architected (Operational Excellence), TOGAF (Governance)

## Related Documentation

| Document | Relationship |
|---|---|
| {link} | {How it relates: implements, extends, governed by, etc.} |
```

## Type B: Capability Overview

Lightweight introduction to a platform capability.
Use for service catalog pages and capability indexes.

```markdown
# {Capability Name}

| Field | Value |
|---|---|
| **Last Reviewed** | {YYYY-MM-DD} |
| **Status** | Draft / Current / Deprecated |

## Purpose

{What problem this capability solves and where it fits in the platform. 1-3 sentences.
Optional C4 Level 1 diagram.}

## Platform Solutions

{What the platform provides centrally.
Bullet list or table.}

## Service Catalog Products

| Product | Description | Provisioning |
|---|---|---|
| {Product name} | {What it provides} | {Self-service / Request-based} |

## Key Design Decisions

- {Brief rationale for approach taken -- 2-3 bullets, not full ADRs}

## Related Documentation

| Document | Relationship |
|---|---|
| {link} | {Architecture detail, user guide, runbook, etc.} |
```

## Section Guidance

All sections in both types are optional -- include only what adds value.
However:

- **Purpose/Scope** and **Related Documentation** should appear in every architecture document.
- **Design Decisions** should appear even if brief -- capture the "why" while it is fresh.
  Architecture docs document the conceptual model -- how the pieces relate, the patterns, the intent.
  Literal implementation detail lives in code; major decisions and their rationale live in ADRs.
  Link to both rather than restating them.
  See [Documentation Altitude](../standard.md#documentation-altitude).
- **Quality Attributes** are required for any component with SLA commitments.
- **Diagrams** are strongly encouraged.
  Use PNG-exported diagrams for architecture and infrastructure (see the diagram guidance in the standard: [../standard.md](../standard.md)).
  [Mermaid](https://mermaid.js.org/) is acceptable for simple inline diagrams (sequence diagrams, small flowcharts).

## Standards Traceability

This template draws from:

| Standard | Elements Used |
|---|---|
| [arc42](https://arc42.org/) | 12-section structure (s1-s12), pragmatic scope |
| [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/) | Six-pillar crosscutting concerns, operational model |
| [C4 Model](https://c4model.com/) | Diagram hierarchy (Context, Container, Component) |
| [ISO/IEC/IEEE 42010:2022](https://www.iso.org/standard/74393.html) | Stakeholders & Concerns, Views, Decisions & Rationale |
| [TOGAF](https://www.opengroup.org/togaf) | Scope/Goals, Constraints, Target Architecture, Governance |

## Related Documents

| Document | Relationship |
|---|---|
| [Documentation Standards](../standard.md) | Writing style and placement rules |
| [ADR Template](adr-template.md) | For detailed design decisions referenced from architecture docs |
| [Design Template](design-template.md) | For implementation-level companion documents that developers build from |
| [Runbook Template](runbook-template.md) | For operational procedures referenced from architecture docs |
