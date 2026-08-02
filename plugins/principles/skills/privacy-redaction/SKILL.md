---
name: privacy-redaction
description: Determine a destination's visibility, then redact local and internal specifics before they land in it. Use when checking whether a repo is public or private before writing local specifics into tracked files, scrubbing internal hostnames, IPs, ports, topology, device names or personal paths out of docs, examples, tests, commit messages, PR/MR bodies, issue text or published artifacts, when choosing the placeholder value that replaces a real one, and when deciding where a credential, token, API key, or password should be stored instead of a file.
user-invocable: false
---

<objective>
Decide what a destination is allowed to carry, then redact whatever it isn't. This is the
procedure behind the privacy floor already in always-on context: that floor states the rules, this
skill states how to execute them. The rules themselves are not repeated here.

The concern is exposure, not recording. Private and internal repos are *meant* to hold internal
setup — an infrastructure-management repo recording real hosts, IPs, topology and device names is
doing its job.
</objective>

<determine_visibility>
Run this ladder before writing any local specific into a tracked file. Stop at the first rung that
gives a definite answer.

1. **GitHub remote with `gh` installed and authenticated:**
   ```bash
   gh repo view --json visibility -q .visibility
   ```

2. **No `gh`, or a non-GitHub forge:** inspect the remote and its host.
   ```bash
   git remote -v
   ```
   A remote on a known-internal host (self-hosted GitLab/Gitea reachable only from the local
   network) is private. A path on a public forge that resolves without authentication is public.

**Every way this can fail resolves to public.** `gh` absent, `gh` unauthenticated, the command
erroring, no remote configured, an unrecognized host, an answer other than a definite `PRIVATE`
(`INTERNAL` included), or nobody available to ask — if the ladder does not return a definite
private verdict, the destination is public and gets the public treatment below. Never infer private
because a repo *feels* internal.
</determine_visibility>

<public_destinations>
Applies to public repositories and to anything published from any repository.

**Surfaces that count.** Tracked files, docs, examples, tests, commit messages, PR/MR bodies, issue
text, and every published artifact (PyPI packages, releases, build outputs). A value scrubbed from
the source file but left in the commit message is not redacted.

**What must not appear.** Internal hostnames, IPs, ports, network topology, device and node names,
home/network IDs, MAC addresses, and personal filesystem paths.

**Real local values live only in uncommitted places.** When an actual host, path, or other
non-secret local value is needed to run or test something, keep it in gitignored config (`.env`),
local memory, or the live session — never in a public repo's tracked files or examples. Secrets are
not covered by this rule; see <secrets>.
</public_destinations>

<published_artifacts>
**Published artifacts are always public regardless of the source repo's visibility.** A private repo
that publishes to PyPI, a release, or any downloadable build still gets the full public treatment
for whatever it ships — the visibility ladder answers for the repo, not for the artifact.
</published_artifacts>

<private_destinations>
**Internal specifics are allowed and often desired.** Real hostnames, IPs, ports, topology and
device names belong in a private repo that exists to manage or document that setup. Don't redact
them into uselessness — a runbook full of `<host>` is worse than no runbook.

The public rules above resume the moment content leaves the repo: see <published_artifacts>.
</private_destinations>

<secrets>
Credentials, tokens, keys and passwords are outside the placeholder machinery entirely — no
visibility check changes the answer, and there is no "just for testing" branch.

**Where a secret goes instead — your always-on profile decides, and the two profiles differ on
purpose.** Read the floor you actually have; do not average them:

- **`universal` floor:** a password manager, and nothing else. Not a private file, not a scratch
  note. This is the stricter of the two, and it is unconditional — having a repo does not unlock a
  file-based option.
- **`engineering` floor:** gitignored config or a secrets store, whatever the repo's visibility —
  private is not encryption.

Either way: never a session note, a scratch file, or a memory entry.

**If you cannot tell which floor is loaded, apply the `universal` one** — it is stricter, and
being wrong in that direction costs a little convenience rather than a credential. Do not offer
"gitignored config" to someone with no repo to ignore it from; that invites an ad-hoc `config`
file nothing actually protects.

This branch is stated here rather than deferred because the skill is model-invoked and can load
under either profile. It is a genuine divergence, recorded as such in the **Privacy core** row of
`principles/PROFILES.md` — not an inconsistency to reconcile away.
</secrets>

<placeholders>
Replace with a neutral value that keeps the shape and loses the specifics.

| Kind of value | Placeholder |
|---|---|
| An internal host and port in a URL | `ws://<host>:3000` |
| A LAN IP address | `<host>`, or `192.0.2.10` (RFC 5737 documentation range) |
| An internal domain name | `example.com` (RFC 2606 reserved) |
| A personal filesystem path | `/path/to/thing` |
| A device or node name | `<switch>`, `<access-point>`, `<node-1>` |

Keep the port, protocol and path structure — those are usually the load-bearing part of an example.
Angle-bracket placeholders read as fill-me-in; the reserved documentation domains and IP ranges read
as runnable. Prefer the reserved ranges in anything a reader might copy and execute.
</placeholders>

<remediation>
When you find internal details already sitting in a public or unknown-visibility tracked file, say
so and offer to replace them with placeholders. Two things the offer must be honest about:

- **Git history keeps the original.** Editing the file forward does not remove the value from
  earlier commits. Flag that separately; scrubbing history is the user's decision, not yours.
- **A published artifact cannot be recalled.** If the value already shipped, say so plainly rather
  than implying an edit fixes it.

Judging whether a borderline detail is safe at all is the always-on privacy floor's call, not this
skill's — that fail-safe is deliberately not restated here.
</remediation>

<success_criteria>
- Visibility was determined by the ladder, or the destination was treated as public because it
  could not be
- Every surface was checked, not just the file being edited — commit message, PR/MR body and issue
  text included
- Placeholders keep the shape of what they replace and use reserved documentation values where a
  reader might copy them
- No secret was written to a file at all under the `universal` floor, and none anywhere but
  gitignored config or a secrets store under the `engineering` floor
- Pre-existing exposure was flagged with an honest account of what an edit does and does not undo
</success_criteria>
