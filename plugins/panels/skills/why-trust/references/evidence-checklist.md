<overview>
The dimensions a trust review must cover, the commands that establish each one on GitHub (`gh`) and GitLab (public REST API at `https://gitlab.com/api/v4`, or `glab api`), and the observed signals that settle what configuration alone can't show. `R=owner/repo` on GitHub. On GitLab, `P` is the URL-encoded project path (`group%2Fproject`) and `B=https://gitlab.com/api/v4/projects/$P`; for self-hosted GitLab, swap the host. Commands are starting points: adapt them, and record what each one returned.
</overview>

<dimension name="1. Project basics and stakes context">
- Age, stars, license, release cadence, owner type (person or organization).
  - GitHub: `gh repo view $R --json createdAt,stargazerCount,licenseInfo,isInOrganization,latestRelease`
  - GitLab: `curl -s $B`
- Very young projects and very fast release cadences raise the bar for every other dimension.
</dimension>

<dimension name="2. Security policy and disclosure">
- Is there a `SECURITY.md` in the root, `.github/` or `docs/`, or in the owner's `.github` repo?
  - GitHub: `gh repo view $R --json isSecurityPolicyEnabled,securityPolicyUrl`
  - GitLab: `curl -s -o /dev/null -w '%{http_code}' "$B/repository/files/SECURITY.md?ref=<default>"`
- Is private vulnerability reporting enabled?
  - GitHub: `gh api repos/$R/private-vulnerability-reporting`
- Published advisories, and how fast fixes landed. An advisory history with quick fixes is a *positive* signal.
  - GitHub: `gh api repos/$R/security-advisories`
  - OSV: `curl -s -X POST https://api.osv.dev/v1/query -d '{"package":{"name":"<pkg>","ecosystem":"<crates.io|npm|PyPI|Go|...>"}}'` (`{}` means none)
- Do fixes ship without advisories? Compare security-titled PRs and changelog entries against the advisory list: `gh pr list -R $R --state merged --search 'security in:title' --json number,title`. Fixes with no advisory leave users on old versions with no scanner warning.
</dimension>

<dimension name="3. Repo protections">
- Default-branch protection: required checks, required reviews, and whether admins are bound by the rules.
  - GitHub: `gh api repos/$R/branches/<default> --jq .protection`, then `gh api repos/$R/rulesets` and each ruleset's `bypass_actors`. If `bypass_actors` is `null`, it isn't visible to you; it doesn't mean "none".
  - GitLab: `curl -s $B/protected_branches`
- Observed bypass: do commits reach the default branch without a PR? For the last 30 commits, `gh api repos/$R/commits/<sha>/pulls --jq length` returns 0 for direct pushes. Ignore merge-bot and release-bot commits.
- Tag protection: rulesets with `target: tag`, or GitLab protected tags (`$B/protected_tags`).
- Signed commits: `gh api "repos/$R/commits?per_page=30" --jq '[.[].commit.verification.verified]|group_by(.)|map("\(.[0]):\(length)")'`
</dimension>

<dimension name="4. CI/CD pipeline hardening">
Fetch the pipeline files into a fresh `mktemp -d` and grep them there:
- GitHub: every file in `.github/workflows/`, via `gh api repos/$R/contents/.github/workflows/<f> -H 'Accept: application/vnd.github.raw'`
- GitLab: `.gitlab-ci.yml` plus its `include:` files

Check for:
- **Third-party actions/includes pinned to a full commit SHA.** List the refs with `grep -hE '^\s*(-\s*)?uses:' *.yml | grep -v 'uses: *\./'`, then count the ones without `@<40-hex>`. Local reusable workflows (`./...`) don't need pinning. On GitLab, check `include:` refs and image digests.
- **Least privilege.** A top-level `permissions:` block (ideally `{}`), with per-job grants.
- **Dangerous triggers.** `pull_request_target` or `workflow_run` that check out or run PR code. With `permissions: {}` and no checkout of the PR head, these are fine.
- **Secret exposure to forks.** Are secrets gated to trusted actors or branches? On GitLab, look for protected and masked variables.
- **Script injection.** `${{ github.event.* }}` interpolated directly into `run:`. Inputs passed through `env:` are fine.
- **Secrets in workflow-level `env:`.** A secret set at the top of a workflow reaches every step of every job, including third-party actions. It should be scoped to the one step that needs it. Check the top of each file for `env:` blocks that reference `secrets.`.
- **Long-lived tokens in release jobs**, and AI or third-party steps that receive secrets in the release path.
- **Checked-out credentials.** `actions/checkout` without `persist-credentials: false` leaves the token in git config for every later step, including builds.
</dimension>

<dimension name="5. Release integrity">
- What ships with the latest release: signatures, `.sig`/`.pem`/`.sigstore.json` files, checksums, SBOMs.
  - GitHub: `gh release view <tag> -R $R --json assets --jq '.assets[].name'`
  - GitLab: `curl -s "$B/releases?per_page=1"` (asset links and `evidences`)
- Build provenance and attestations. On GitHub:
  - Take an asset's digest from `gh api repos/$R/releases/latest --jq '.assets[]|{name,digest}'`.
  - Decode what each attestation is: `gh api repos/$R/attestations/<digest> --jq '.attestations[].bundle.dsseEnvelope.payload' | while read p; do echo "$p" | base64 -d | python3 -c 'import json,sys;d=json.load(sys.stdin);print(d["predicateType"])'; done`. `slsa.dev/provenance` means build provenance, and its payload names the workflow and ref that built the asset.
  - Also look in the release workflow for SLSA generators or `actions/attest-build-provenance`.
- Immutable releases (GitHub): `gh api repos/$R/releases --jq '[.[].immutable]|group_by(.)|map("\(.[0]):\(length)")'`.
- Platform signing: macOS notarization, Windows code signing (look in the release workflow).
- Registry provenance where it applies: npm provenance, PyPI attestations or trusted publishing, container image signing, and crates.io trusted publishing (`curl -s -A why-trust https://crates.io/api/v1/crates/<name>/versions`; `trustpub_data` is set per version).
- Channel divergence: does the latest registry version have a matching signed forge release? A registry version with no release (a failed or skipped release job) leaves those users nothing to verify against.
- Do the docs explain how users verify a download? Signing nobody can verify is only half the value.
</dimension>

<dimension name="6. Dependency and vulnerability hygiene">
- Config files: `.github/dependabot.yml`, `renovate.json` and its `extends` presets (read the shared preset too), and deny/audit config (`deny.toml`, `.cargo/audit.toml`, `osv-scanner.toml`, `govulncheck`, `npm audit`, `pip-audit` in CI).
- Automerge policy: does anything merge without human review? Is there a `minimumReleaseAge` or cooldown? Are any dependencies excluded from updates (`ignoreDeps`), and why? Search the PR history for the reason.
- Lockfiles are committed.
</dimension>

<dimension name="7. Code scanning, testing and fuzzing">
- Static analysis config: CodeQL workflow, Semgrep, GitLab `Security/SAST` templates, secret detection.
- Fuzzing: `fuzz/` directory, cargo-fuzz, go-fuzz, OSS-Fuzz membership (search `google/oss-fuzz` `projects/<name>`).
- Test coverage reporting (codecov or similar) is supporting evidence only.
</dimension>

<dimension name="8. Independent, third-party review">
- OpenSSF Scorecard: `curl -s https://api.securityscorecards.dev/projects/github.com/$R`. GitLab works too: `.../projects/gitlab.com/<path>`. Empty means it isn't published.
- deps.dev: `curl -s https://api.deps.dev/v3/projects/github.com%2F<owner>%2F<repo>` (includes Scorecard data when present).
- OpenSSF Best Practices badge: `curl -sL 'https://www.bestpractices.dev/en/projects.json?url=<url-encoded repo URL>'` (`[]` means not registered; otherwise read `badge_level`). Also check the README for badges.
- Published security audits: search the web for "<project> security audit" and check OSTIF, Trail of Bits, Cure53, NCC and Include Security publications. A real audit is the strongest single signal; also check that its findings were resolved.
- Third-party scanning apps visible in checks (see the observed signals below).
</dimension>

<dimension name="9. Maintainers and continuity">
- Contributor distribution: `gh api "repos/$R/contributors?per_page=10"`. Separate bots from humans. Bus factor is the number of humans doing most of the work.
- Count an account as automation when its type is `Bot`, or when it only authors release, version-bump or dependency PRs (a `type: User` account can still be a machine account). Say which accounts you classified this way.
- Organization or individual ownership, sponsorship, and any documented succession or backup maintainer.
- Does anyone review the maintainer's own changes, or is everything self-merged?
</dimension>

<dimension name="10. Design transparency">
- Threat model or security design doc: what's trusted, how keys and secrets are stored, what's out of scope.
  - Search the docs: `gh api "search/code?q=repo:$R+%22threat+model%22"`
- Open issues that touch trust boundaries: search issues for security, trust, untrusted, injection, crypto.
</dimension>

<observed_signals>
Use these when a setting can't be read without admin access. Absence over a long history is meaningful; absence in a new repo is not.
- **Check runs on the default branch and on a recent merged PR.**
  - GitHub: `gh api "repos/$R/commits/<sha>/check-runs?per_page=100" --jq '.check_runs[]|"\(.app.slug) | \(.name)"'` and `.../check-suites` for the app list. A CodeQL check means code scanning is on; Socket, Snyk, CodeRabbit and similar apps show up here. Remember that AI review bots aren't independent human review.
  - GitLab: job names from `$B/pipelines?ref=<default>&status=success&per_page=1` → `$B/pipelines/<id>/jobs` (for example `gitlab-advanced-sast`, `secret_detection`, `dependency-scanning-*`, `govulncheck`).
- **Vulnerability alerting.**
  - Dependabot PRs: `gh pr list -R $R --state all --author app/dependabot`
  - Renovate security PRs: search ignores brackets, so filter on the client side: `gh pr list -R $R --state all --author app/renovate --limit 500 --json number,title --jq '.[]|select(.title|startswith("[SECURITY]"))'`
  - Renovate raises vulnerability PRs only when the forge's alerts are on, so none at all over a long history suggests alerts are off, or that nothing vulnerable has ever been flagged. Say it's ambiguous.
- **Review practice.** Review counts on recently merged bot PRs and maintainer PRs: `gh pr list -R $R --state merged --limit 10 --json number,author,reviews`
- **Venue and contribution policy.** Check `.github/ISSUE_TEMPLATE/config.yml` (`blank_issues_enabled`, `contact_links`) and the discussion categories. Read CONTRIBUTING (root, `.github/`, or `docs/`) and any AGENTS.md for rules on AI-assisted posts: disclosure requirements, and bans or auto-closing of agent-found reports.
- **Code scanning alerts and Dependabot alert settings** return 403 to non-admins: mark them as couldn't check, and rely on the signals above.
</observed_signals>
