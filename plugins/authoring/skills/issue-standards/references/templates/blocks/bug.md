# Bug block

Paste into the issue body and fill it in. Quote logs and transcripts inside a
fenced code block, so a stray `@name` does not notify anyone.

```markdown
## At a glance

<3-5 plain-English sentences.>

## Context

**Observed:** <what happens>
**Expected:** <what should happen>
**Blast radius:** <what is affected, how badly>
**First seen:** <date, or "unknown">

## Reproduction

1. <step>
2. <step>

<Or: why it is not reproducible.>

## Acceptance Criteria

- [ ] <observable condition proving the defect is gone>
- [ ] <regression coverage, where applicable>

## References

- [<CI run, log query, or transcript>](<URL>) — <what it shows>
- #<NN> — <how it relates>
```
