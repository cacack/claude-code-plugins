# Canon Profiles — the contract

The canon ships as **profiles**: self-contained payload files that the [`instill-principles`](../skills/instill-principles/SKILL.md) skill copies verbatim into a managed block. This file is the contract between the payloads and the installer — the registry, the marker format, the migration rule, and the map that keeps two wordings of one idea from drifting apart.

Profiles are an **override** model, not an additive one. A person receives *either* the engineering wording of an idea *or* the universal wording, never both. That is why the last section exists: when two files say the same thing in two voices, something has to record that they are the same thing.

This file is **maintainer-facing**. It is never copied into a managed block and never reaches a user's context.

## The profiles

| Profile | Payload | Repo target | Repo target, no `.claude/` | User target |
|---|---|---|---|---|
| `universal` | `principles/profiles/universal.md` | `.claude/rules/working-with-claude.md` | `CLAUDE.md` | `~/.claude/rules/working-with-claude.md` |
| `engineering` | `principles/profiles/engineering.md` | `.claude/rules/engineering-kit.md` | `CLAUDE.md` | `~/.claude/rules/engineering-kit.md` |

Payload paths are relative to the plugin root (`${CLAUDE_PLUGIN_ROOT}`). Each payload is a complete document on its own: bare content, no markers, no assembly. The installer reads exactly one payload per install and writes it unchanged.

The engineering target is deliberately **unchanged** from the pre-profile installer. An existing install migrates in place; no file is ever moved or renamed.

**The `CLAUDE.md` fallback** is a real registry entry, not a footnote — it has its own column above because a lookup that silently misses it produces the duplication this contract promises is impossible. A repo with no `.claude/` directory has no home for either target; in that case, and only at repo scope, **both** profiles target a managed section in the repo-root `CLAUDE.md`. Same markers, same rules.

Two consequences a reader must carry into the guard below:

- It is the one target the two profiles **share**, so "one canon block per scope" and "one canon block per file" coincide there.
- A sibling lookup done by registry must resolve to `CLAUDE.md` for *both* rows when the fallback is in play. Reading the sibling's `.claude/rules/…` path instead finds nothing — that path cannot exist, because its absence is what triggered the fallback in the first place.

## Marker format

One block, two markers. `<profile>` is the registry key (`universal` or `engineering`); `<VERSION>` is the `version` field from the plugin's `plugin.json`.

```markdown
<!-- BEGIN canon:<profile> v<VERSION> — managed block. Re-sync with the instill-principles skill; edit above or below, not inside. Source: https://github.com/cacack/claude-code-plugins (cacack plugin). -->

<contents of the profile payload>

<!-- END canon:<profile> -->
```

So the engineering profile — at whatever version `plugin.json` currently carries, shown here as `vX.Y.Z` because any real number written into this file would be wrong by the next release — opens with:

```markdown
<!-- BEGIN canon:engineering vX.Y.Z — managed block. Re-sync with the instill-principles skill; edit above or below, not inside. Source: https://github.com/cacack/claude-code-plugins (cacack plugin). -->
```

and closes with `<!-- END canon:engineering -->`.

**How to match a block.** The block ID is `canon:<profile>` and it is the only thing a reader may key on. A BEGIN marker is any HTML comment whose content starts with `BEGIN canon:<profile>`; everything after the ID — the version stamp and the prose — is informational and must be tolerated in any form. The END marker is the exact string `<!-- END canon:<profile> -->`. **Never match on the version:** a re-sync from v2.0.0 has to find a v2.0.1 block, and a stale stamp is the normal case, not an error. Every write re-emits the whole BEGIN marker so the stamp refreshes.

## Legacy migration

Installs made before profiles existed carry the block ID `engineering-kit:instill-principles` — BEGIN comments starting `BEGIN engineering-kit:instill-principles`, closed by `<!-- END engineering-kit:instill-principles -->`, at any version stamp.

A legacy block is an `engineering` block that predates the naming. **Replace it in place** with a `canon:engineering` block in the same file: same path, same position, old markers gone. Never append a second block, never leave the old marker behind, never migrate by writing the new block and deleting the old one in two steps.

**Where to look for one.** The pre-profile installer wrote to two places, so detection must check both — **regardless of which profile is being installed**, because a legacy block is an engineering block and it is the *engineering* locations it can occupy:

| Scope | Look in |
|---|---|
| Repo | `.claude/rules/engineering-kit.md` **and** the repo-root `CLAUDE.md` |
| User | `~/.claude/rules/engineering-kit.md` |

The `CLAUDE.md` entry is not hypothetical: the pre-profile skill offered exactly that fallback when a repo had no `.claude/` directory, and wrote its block there. Such a repo very commonly acquires a `.claude/` later — a single `settings.json` is enough. If detection then looked only at `.claude/rules/`, it would find nothing, classify a fresh install, and leave a live legacy block in `CLAUDE.md` beside a brand-new one. Two canon copies, one scope, produced by the migration path that advertises it cannot happen.

**Never scope detection to the selected profile's own target.** Installing `universal` must still look in the engineering locations above; otherwise the one case the cross-profile guard exists for — a legacy engineering install, plus a universal request — is precisely the case that escapes it. A legacy block found outside the table above was moved by hand and is outside this contract.

## The invariant

**After any write, a scope holds at most one canon block.**

Per *scope*, not per file. The registry gives the two profiles different target files, so a per-file rule can never fire for the case the override model exists to prevent: `canon:universal` in `working-with-claude.md` and `canon:engineering` in `engineering-kit.md` are each individually legal per file, live at the same scope, and both load in the same session. That is two wordings of one idea in one context — the violation, stated exactly. Two blocks in a single file (legacy plus new, or both profiles in the `CLAUDE.md` fallback) is the same bug seen from the other side, and the per-scope rule catches it too.

An installer about to create the second block at a scope must stop and ask. The only outcomes are *switch* or *cancel*; there is no "add it anyway".

**Enforcing it: search by location, never by resolved target.** Target resolution answers where a block *would go* today; only a search of every registry location for the scope — all three columns, both profile rows — answers where one *is*. The two diverge whenever the filesystem changed between runs, and the fallback makes that routine: a repo installs to `CLAUDE.md` for want of a `.claude/`, later gains one for an unrelated reason, and now resolves somewhere its existing block is not. An installer that trusts resolution reports "fresh install", writes a second block, and passes a per-file check while doing it. Every known way to break this invariant has that shape, including the one the in-place migration itself produces: migrating a legacy `CLAUDE.md` block correctly leaves a `canon:engineering` block in a file that later resolution no longer points at. A re-sync therefore happens **where the block lives**, not where resolution points; relocating one is a migration a person approves, never a side effect.

**Switching profiles** means removing the installed block and writing the other one. Removal takes the block and its markers, nothing else — *own only your block* applies on the way out as much as on the way in. If removal leaves the target file with no content of its own, say so and offer to delete it; never delete it unasked. An empty rules file is inert, and the person may have reasons for it the installer cannot see.

**Across scopes, surface it — do not block.** A `universal` block at user scope and an `engineering` block at repo scope both load in one session, which is the same duplication one level up. It is nonetheless allowed, for a reason that decides it: a repo-scope install is checked in and serves the whole team, so one contributor's personal user-scope profile must not be able to veto it. The installer names the situation, says which block is the narrower one, and proceeds. What it must never do is create the collision silently.

## The idea→variant map

One row per idea in the canon. This table is the DRY guard: it is the only place recording that a line in `universal.md` and a line in `engineering.md` are the same idea in two voices.

Relationship values are exactly four: `same text` (identical wording in both payloads), `tuned variant` (one idea, two wordings — the rows that can drift), `engineering only`, `universal only`.

| Idea | In universal? | In engineering? | Relationship |
|---|---|---|---|
| Explicit over implicit | no | yes | engineering only |
| Simple over complex | yes | yes | tuned variant |
| Don't outrun your headlights | yes | yes | same text |
| One obvious way | no | yes | engineering only |
| If it's hard to explain, it's a bad design | yes | yes | same text |
| Verify before assuming | yes | yes | tuned variant |
| Don't repeat knowledge | yes | yes | tuned variant |
| Design for change | no | yes | engineering only |
| Deep modules, simple interfaces | no | yes | engineering only |
| Follow the rules | yes | yes | tuned variant |
| Align before you build | yes | yes | tuned variant |
| Smallest change that works | yes | yes | tuned variant |
| Match the surrounding code | yes | yes | tuned variant |
| Be concise | yes | yes | tuned variant |
| Confirm before irreversible or outward-facing actions | yes | yes | tuned variant |
| Privacy core | yes | yes | tuned variant |
| Issue delivery | no | yes | engineering only |
| Precedence and floors | yes | yes | tuned variant |

Two rows are `same text` and both were verified by string comparison against the payloads, not by intent. Every other shared row is a `tuned variant`, which is the expected outcome: two audiences rarely need the identical sentence, and the rows that survive identical are the ones whose wording happened to name nothing audience-specific.

Where the universal payload gives a shared idea a different heading, the counterpart is listed here so a maintainer can find both wordings:

| Idea | Heading in `universal.md` |
|---|---|
| Align before you build | Align before you start |
| Smallest change that works | Do what was asked, and only that |
| Match the surrounding code | Match the surrounding style |

Notes on the trickier rows:

- **Explicit over implicit** and **One obvious way** are `engineering only` by deliberate omission, not oversight. Every general wording of *explicit over implicit* collapses to "make your intent visible", a platitude, and the behaviors it would buy a non-developer are already owned by *align before you start*, *do what was asked, and only that*, and *confirm before irreversible or outward-facing actions*. *One obvious way*, generalized, becomes indistinguishable from the working rule *match the surrounding style*. A weakened principle is worse than an absent one, and a payload that says one thing twice fails *don't repeat knowledge* inside itself.
- **Verify before assuming** was the highest-value rule in the set for a non-developer, so the universal payload keeps it and generalizes its examples off software — a fact, figure, name, quote, or file rather than an API, schema field, or config value.
- **Don't repeat knowledge** diverges only in its lead-in: the universal payload drops the `(DRY)` acronym as jargon. The body is verbatim in both. The row's Idea cell drops the acronym to match; `DRY` remains fair game as a maintainer's shorthand.
- **Align before you build**, **Smallest change that works** and **Match the surrounding code** are present in both profiles but cannot share text: the engineering wording names refactors, reformatting, and code idioms on purpose, and the universal wording generalizes to work, style, and voice.
- **Be concise** and **Confirm before irreversible or outward-facing actions** each diverge by a single word, and the word is the point. "Succinct **code**" and "**Pushing**, deleting, publishing" mean nothing to someone who writes no code, so universal says "succinct **work**" and "**Deleting, sending**, publishing". Both are broadenings; neither softens the rule.
- **Follow the rules** diverges because the engineering wording names the mechanism (`user-level and project-level .claude/rules/ files`) and the universal wording names the experience ("your personal rules and the project you are working in"). Reconciling them would mean pushing `.claude/rules/` into a payload written for someone who has never opened that directory. The clause that carries the actual instruction — "if two conflict, ask" — is identical in both.
- **Precedence and floors** is not a canon principle; it is the one-line statement that project instructions override these defaults except for privacy and confirm-before-irreversible. It diverges in form rather than content: the engineering payload leads the file with it in bold, before any heading, while the universal payload closes with it under a `## Precedence` heading. The exception list is the same in both. It drifts like anything else, so it gets a row.
- **Privacy core** is a tuned variant in size, shape, **and — for one bullet — substance.** Engineering carries five bullets plus a pointer to the `privacy-redaction` skill; universal carries five bullets and no pointer, because it also carries the remediation behavior that engineering defers to the skill.

  The substantive divergence is the **secrets destination**, and it is deliberate: engineering says gitignored config or a secrets store, universal says a password manager and no file at all. Universal is the stricter of the two. That is right for its reader — someone with no repo has nothing to gitignore a file *from*, and pointing them at "config" invites an ad-hoc file nothing protects — but it means the two payloads do not merely differ in voice here. `skills/privacy-redaction/SKILL.md` carries the same branch and defers to whichever floor is loaded, applying the universal one when it cannot tell.

  **Editing either bullet means checking all three places.** This is the row most likely to be "fixed" into agreement by someone who sees the difference and assumes it is drift; it is not.
- No idea is `universal only` today. The value exists for the case where a rule earns its place for a non-developer and not for an engineer.

## Maintaining the map

Editing a `tuned variant` row means editing **both** payloads or deliberately diverging them — and a deliberate divergence still gets written down here, because the next maintainer has no other way to learn the two wordings were ever one idea. Nothing else in the repo records that relationship: not the payloads, which are self-contained by design, and not the installer, which only copies.

Adding an idea to one payload adds a row here in the same change. Removing one removes its row. A row whose Relationship no longer matches what the payloads actually say is a defect, not a stale comment.
