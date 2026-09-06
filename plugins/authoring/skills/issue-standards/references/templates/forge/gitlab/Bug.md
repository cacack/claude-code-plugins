<!-- .gitlab/issue_templates/Bug.md
     A Bug stays open until the defect is fixed or a blocker to fixing it is
     named — it is not timeboxed, even when it carries heavy triage.
     This template presets class::unplanned, which means NO milestone. If this
     defect was chosen and scheduled rather than arriving, switch the label.
     Quote logs inside a fenced code block, so a stray @name notifies nobody.
     Add a theme, a value, and an effort label yourself: a preset guess makes an
     untriaged issue look triaged. -->

## At a glance

<!-- 3-5 sentences of plain English. -->

## Context

**Observed:**

**Expected:**

**Blast radius:**

**First seen:**

## Reproduction

1.
2.

<!-- Or: why it is not reproducible. -->

## Acceptance Criteria

- [ ] <observable condition proving the defect is gone>
- [ ] <regression coverage, where applicable>

## References

-

/label ~"type::bug" ~"class::unplanned"
