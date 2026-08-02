# Guide Template

Standard template for consumer-facing guides.
Platform and project documentation repositories should follow this format for documents in `docs/guides/`.

## Audience

Guides target **consumers and users** -- teams that use your products.
Assume familiarity with the platform surface but not internal implementation details.

This distinction matters:

| If the reader is... | They need a... | Location |
|---|---|---|
| A user deploying or using a service | **Guide** | `docs/guides/` |
| An operator running or maintaining a service | **Runbook** | `docs/operations/runbooks/` |
| An architect understanding how a service works | **Architecture doc** | `docs/architecture/` |

## Template

```markdown
# {Task-Based Title}

{Use an action-oriented title: "Setting Up X", "Using X", "Requesting X".
Noun phrases are acceptable for reference-style guides: "Ingress FAQ", "Query Snippets".}

## Introduction

{1-3 sentences: what this guide covers and who it is for.
Link to architecture or explanation docs for deeper context.
Do not explain "why this matters" -- readers are already here.}

## Prerequisites

- {Required access, permissions, or roles}
- {Tools or CLI versions needed}
- {Prior setup steps, with links to guides that cover them}

## {Procedure / Usage}

### 1. {First Major Step}

{Instructions in second person ("you"), active voice.
State conditions before instructions: "To create a network, navigate to..."
Bold UI elements for console steps: **Click Create**.}

\`\`\`hcl

## Code examples in languages users use (Terraform HCL, CDK, Python)

\`\`\`

### 2. {Second Major Step}

{Continue the pattern.
Use tables for reference data within steps.}

### Verification

{How to confirm the procedure worked.
Expected output, console state, or test command.}

### Troubleshooting

{Optional.
Common issues and resolutions.
Use problem/solution format or Q&A.}

#### {Problem: Symptom description}

**Cause:** {Why this happens} **Fix:** {Steps to resolve}

### FAQ

{Optional.
Use when the topic generates recurring questions.
Each entry: bold question, answer below.}

**{Question}**

{Answer.
Keep it concise.
Link to detailed docs if needed.}

### Related Resources

- {Upstream vendor documentation}
- {Related guides within this repo}
- {Architecture docs for implementation context}

### Getting Help

- Chat: {Channel link}
- {Other support channels}
```

## Section Guidance

### Required Sections

Every guide must include:

- **Introduction** -- What this guide covers.
  Keep it brief.
- **Prerequisites** -- What the reader needs before starting.
  This is the most commonly missing section in existing guides and the most common source of support requests.
- **Procedure / Usage** -- The core content.
- **Getting Help** -- Where to go when stuck.
  Every consumer-facing guide should answer this.

### Optional Sections

- **Verification** -- Include when the procedure has a confirmable end state.
- **Troubleshooting** -- Include when common failure modes are known.
- **FAQ** -- Include when the topic generates recurring questions.
  Can replace Troubleshooting for simpler topics.
- **Related Resources** -- Include when upstream docs or related guides exist.

### Writing Principles

Guides follow the [Diataxis](https://diataxis.fr/) "how-to guide" pattern:

- **Goal-oriented** -- Each guide addresses a real-world task the reader wants to accomplish.
- **For competent users** -- Assume the reader has relevant background.
  Do not teach concepts (that belongs in architecture docs).
- **Practical over exhaustive** -- Cover the common path.
  Link to reference docs for edge cases and full parameter lists.
- **Conditions before instructions** -- "To configure logging, add the following to your Terraform module:" not "Add the following to your Terraform module to configure logging."
- **Code examples in user languages** -- Terraform HCL, CDK TypeScript, Python.
  Not internal tooling or platform-specific scripts.

### Guides vs. Tutorials

This template covers **how-to guides** (task-oriented, for practitioners).
If you need a **tutorial** (learning-oriented, for beginners), the structure differs:

| Aspect | How-To Guide | Tutorial |
|---|---|---|
| Reader | Knows what they want to do | Learning the basics |
| Structure | Steps toward a goal | Guided lesson |
| Assumptions | Competent user | Minimal prior knowledge |
| Completeness | Covers the task, links for depth | Self-contained |

Most documentation is how-to guides.
Tutorials are rare and should be discussed with the team before writing.

## Standards Traceability

This template draws from:

| Standard | Elements Used |
|---|---|
| [Diataxis Framework](https://diataxis.fr/) | How-to guide type: goal-oriented, for competent users |
| [Google Developer Documentation Style Guide](https://developers.google.com/style) | Task-based titles, second person, conditions before instructions |
| [Microsoft Writing Style Guide](https://learn.microsoft.com/en-us/style-guide/) | Procedural writing, step numbering, UI element formatting |

## Related Documents

| Document | Relationship |
|---|---|
| [Documentation Standards](../standard.md) | Writing style and placement rules |
| [Runbook Template](runbook-template.md) | For operator procedures that complement consumer guides |
| [Architecture Template](architecture-template.md) | For design docs that guides reference for context |
