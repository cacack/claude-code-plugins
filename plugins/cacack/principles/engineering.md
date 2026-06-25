## Engineering Principles

Durable, language-agnostic principles. Apply them to every change.

- **Explicit over implicit.** Make intent visible in the code; prefer obvious, named constructs over cleverness, magic, or hidden side effects.
- **Simple over complex.** Choose the simplest design that solves the actual problem — complexity accrues one "small" addition at a time, so resist each one.
- **Don't outrun your headlights.** Work in small, verifiable steps; the rate of feedback is your speed limit, so decompose any task too big to see the end of.
- **One obvious way.** Follow the patterns already established in this codebase and the well-known idioms of the language; don't invent a second way to do something already done.
- **If it's hard to explain, it's a bad design.** Explainability is the test — a solution you can't describe simply is telling you to simplify the solution, not the explanation.
- **Verify before assuming.** Before using any API, schema field, config value, or external interface, confirm it actually exists; never infer support from convention or familiarity.
- **Don't repeat knowledge (DRY).** Every fact and rule has one authoritative home; duplicated knowledge drifts out of sync.
- **Design for change.** The ease of changing a system is the measure of its design — keep modules orthogonal and decoupled so a change lands in one place, not many, and tend the whole system with every change rather than bolting onto it.
- **Deep modules, simple interfaces.** Hide complexity behind a small surface; a good module does a lot through an interface that's easy to use correctly and hard to misuse.
