# Architecture Decision Record Template

Standard template for architecture decision records (ADRs).
Platform and project documentation repositories should follow this format for documents in `docs/decisions/`.

## Naming Convention

ADR files use the format: `NNNN-title-with-dashes.md`

- `NNNN` is a zero-padded sequential number within the repository.
- Prefix with a capability name when ADRs span multiple capabilities (e.g., `monitoring-0007-grafana-workspace-architecture.md`).
- Investigation documents that do not result in a decision use a descriptive name without a number (e.g., `cis-benchmark-investigation.md`).

## Template

```markdown
# {NNNN} - {Short Noun Phrase Title}

| Field | Value |
|---|---|
| **Status** | Proposed / Accepted / Deprecated / Superseded by [{NNNN}]({link}) |
| **Date** | {YYYY-MM-DD} |
| **Tracking Issue** | [{TICKET-ID}]({url}) |
| **Decision Makers** | {Team or individuals} |

## Context

{Describe the situation, forces at play, and why a decision is needed.
Value-neutral. 2-5 sentences.
Link related epics or issues.}

## Decision

{State the decision in active voice: "We will..."
Include sub-sections for rationale and scope if the decision is complex.}

## Alternatives Considered

### {Alternative Name}

{Description.
Why it was rejected -- keep it concise.}

### {Alternative Name}

{Description.
Why it was rejected.}

## Consequences

**Positive:**

- {Benefit}

**Negative:**

- {Trade-off or accepted risk}

## Accepted Risks

{Optional.
Document risks that were explicitly reviewed and accepted, with mitigating factors.
Omit if none.}

## References

- {Links to docs, external references, related ADRs, the team wiki}
```

## Y-Statement Summary

Optionally include a [Y-statement](https://medium.com/olzzio/y-statements-10eb07b5a177) as the first line under **Decision** to provide a single-sentence summary:

> In the context of {use case}, facing {concern}, we decided for {option} to achieve {quality}, accepting {downside}.

## Section Guidance

### Required Sections

Every ADR must include:

- **Metadata table** -- Status, Date, and Decision Makers at minimum.
- **Context** -- The situation that requires a decision.
  Without context, the decision is not reviewable.
- **Decision** -- The choice made, in active voice.
  ADRs record decisions and principles, not implementation detail -- the choice, the rationale, the trade-offs.
  Literal detail (exact statements, config, code) lives in architecture docs or the code itself; link to it rather than restating it.
  See [Documentation Altitude](../standard.md#documentation-altitude).
- **Alternatives Considered** -- At least one alternative (including "do nothing" if evaluated).
- **Consequences** -- Both positive and negative outcomes of the decision.

### Optional Sections

- **Accepted Risks** -- Include when the decision introduces risk that was consciously accepted.
  Valuable for security-sensitive infrastructure decisions.
- **References** -- Include when external sources informed the decision.
- **Y-Statement** -- Useful as a quick summary, especially when decisions are cited from other documents.

### Status Lifecycle

| Status | Meaning |
|---|---|
| **Proposed** | Under discussion, not yet agreed |
| **Accepted** | Agreed and in effect |
| **Deprecated** | No longer recommended but not replaced |
| **Superseded** | Replaced by a newer ADR (link to replacement) |

Once accepted, ADR content is immutable.
To change a decision, create a new ADR that supersedes the old one and update the old ADR's status.

### Investigations

Investigation documents explore a topic without necessarily reaching a decision.
They use a relaxed structure:

```markdown
# {Investigation Title}

| Field | Value |
|---|---|
| **Investigation Date** | {YYYY-MM-DD} |
| **Tracking Issue** | [{TICKET-ID}]({url}) |
| **Investigator** | {Name} |

## Executive Summary

{Key findings and recommendation in 3-5 bullet points.}

## Analysis

{Detailed investigation with findings, data, and observations.
Use tables and code examples where appropriate.}

## Recommendation

{What action to take based on the findings.
If a decision follows, link to the resulting ADR.}

## References

- {Sources consulted}
```

## Standards Traceability

This template draws from:

| Standard | Elements Used |
|---|---|
| [Michael Nygard (2011)](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | Original ADR format: Context, Decision, Consequences |
| [MADR v4.0.0](https://adr.github.io/madr/) | YAML metadata, Decision Drivers, Confirmation, structured options |
| [Y-Statements](https://medium.com/olzzio/y-statements-10eb07b5a177) | Single-sentence decision summary format |
| [ISO/IEC/IEEE 42010:2022](https://www.iso.org/standard/74393.html) | Architecture Decisions and Rationale as first-class elements |
| [Thoughtworks Tech Radar](https://www.thoughtworks.com/en-us/radar/techniques/lightweight-architecture-decision-records) | Lightweight records stored in source control alongside code |

## Related Documents

| Document | Relationship |
|---|---|
| [Documentation Standards](../standard.md) | Writing style and placement rules |
| [Architecture Template](architecture-template.md) | For architecture docs that reference ADRs |
