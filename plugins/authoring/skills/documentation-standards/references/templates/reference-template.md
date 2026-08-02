# Reference Document Template

Standard template for reference documents.
Platform and project documentation repositories should follow this format for documents in `docs/reference/`.

## What Belongs in Reference

Reference documents are **lookup-oriented**.
They state facts for readers who know what they are looking for.

| Content Type | Belongs In | Example |
|---|---|---|
| IP address ranges, port lists | `docs/reference/` | Service public IP ranges |
| Code repository indexes | `docs/reference/` | Logging code and repos |
| Firewall rules, network policies | `docs/reference/` | On-premise firewall policies |
| Configuration parameter lists | `docs/reference/` | Parameter store exports |
| Compliance assessments with recommendations | `docs/governance/` or `docs/architecture/` | Not reference -- contains interpretation |
| Cost analyses with action items | `docs/architecture/` | Not reference -- contains recommendations |
| Vendor assessments with observations | `docs/decisions/` | Not reference -- contains judgment |

**Rule of thumb:** If the document contains analysis, recommendations, or interpretation, it is not a reference document.

## Template

```markdown
# {Document Title}

| Field | Value |
|---|---|
| **Canonical Source** | {Who or what maintains this data, e.g., "network team", "cloud console", "Terraform state"} |
| **Last Reviewed** | {YYYY-MM-DD} |

{1-2 sentences: what this reference contains and when to consult it.}

## {Data Section Title}

{Tables are the primary format.
One table per logical grouping.}

| Column A | Column B | Column C |
|---|---|---|
| ... | ... | ... |

## {Additional Data Section}

{Add sections as needed.
Each section covers one logical grouping.
Mirror the structure of the thing being documented.}

## Related

- [{Related reference doc}](relative-link.md)
- [{External source}]({url})
```

## Section Guidance

### Required Elements

Every reference document must include:

- **Metadata table** -- Canonical Source and Last Reviewed at minimum.
  Readers need to know where the data comes from and whether it is current.
- **Opening description** -- One to two sentences.
  State what this document contains and when someone would consult it.
- **Structured data** -- Tables, definition lists, or code blocks.
  Narrative prose is not reference content.

### Optional Elements

- **Related** -- Cross-link to related reference docs and external sources.
  Recommended when related documents exist.
- **Additional data sections** -- As many as needed, organized by logical grouping.
- **Notes or caveats** -- Brief callouts about data freshness, known gaps, or exceptions.
  Keep these inline near the relevant data, not in a separate section.

### Writing Principles

Reference documents follow the [Diataxis](https://diataxis.fr/) "reference" pattern:

- **Information-oriented** -- Describe the machinery.
  Do not instruct (that is a guide) or explain (that is architecture).
- **Mirror the subject's structure** -- If documenting a network, organize by network segment.
  If documenting an API, organize by endpoint.
  If documenting IP ranges, organize by environment or region.
- **Austere and consistent** -- Every entry of the same type should look the same.
  No motivation paragraphs, no background context.
- **Scannable** -- Tables and lists over paragraphs.
  Readers are looking up a specific fact, not reading start-to-finish.
- **Describe every element** -- Do not just list names.
  Every entry needs enough context to be useful without following a link.

### Maintenance

Reference documents are high-value, high-risk for staleness.
To manage this:

- **Canonical Source field** tells readers where to verify data and who to contact for updates.
- **Last Reviewed date** signals trustworthiness.
  Update it after each review, even if no data changed.
- **Prefer linking to authoritative sources** over duplicating data that changes frequently.
  A link to a Terraform output or cloud console page is better than a copied table that drifts.

## Standards Traceability

This template draws from:

| Standard | Elements Used |
|---|---|
| [Diataxis Framework](https://diataxis.fr/) | Reference type: information-oriented, mirrors subject structure |
| [Google Developer Documentation Style Guide](https://developers.google.com/style) | Element descriptions, consistent formatting |
| [Microsoft Writing Style Guide](https://learn.microsoft.com/en-us/style-guide/developer-content/reference-documentation) | Consistent article design, type differentiators, See Also |
| [Write the Docs](https://www.writethedocs.org/guide/) | Lookup-oriented, cross-referencing, information architecture |

## Related Documents

| Document | Relationship |
|---|---|
| [Documentation Standards](../standard.md) | Writing style and placement rules |
| [Architecture Template](architecture-template.md) | For analytical content that does not belong in reference |
