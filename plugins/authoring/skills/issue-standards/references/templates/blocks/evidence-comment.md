# Evidence comment

One comment per issue, posted before the issue closes, carrying every criterion
in the issue's order. Number the entries to match the criteria list, so a reader
can pair them without guessing.

State each criterion's outcome in words. A criterion that is neither met nor
deferred is named as such, with what is outstanding. **Silence on a criterion is
the one thing this comment must never do**, because a reader cannot tell it apart
from an oversight.

```markdown
<Attribution line, where the comment was generated rather than typed.>

**Acceptance criteria evidence**

1. **<criterion, in short>** — met.
   [<descriptive label>](<PR URL>) — <what in it satisfies the criterion>
2. **<criterion, in short>** — met.
   Observed <what> on <date>, via <how>. [<query or dashboard>](<URL>)
3. **<criterion, in short>** — deferred to #<NN>.
   <One sentence on what the deferral needs that this issue could not supply.>
4. **<criterion, in short>** — not met.
   <What is outstanding.>
```

The link label is descriptive text. GitLab's `repo!NN` shorthand does not
resolve outside its own project, so a label built from it teaches a form that
reaches nothing; the URL is what makes the reference resolve.
