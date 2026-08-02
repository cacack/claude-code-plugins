---
name: security-review
description: Comprehensive security analysis of changes, context, or entire repository
argument-hint: [changes|context|repo]
allowed-tools: [Read, Grep, Glob, Bash(git status:*), Bash(git diff:*), Bash(git branch:*)]
effort: high
---

<objective>
Perform a comprehensive security analysis to identify potential vulnerabilities and security concerns.

Scope is determined by $ARGUMENTS:
- `changes` (default): Review pending git changes
- `context`: Review current conversation context and recent changes
- `repo`: Review entire repository codebase

This helps prevent security vulnerabilities from reaching production by catching issues early in the development cycle.
</objective>

<context>
Git status: !`git status`
Changed files: !`git diff --name-only`
Staged changes: !`git diff --cached --name-only`
Current branch: !`git branch --show-current`
</context>

<process>
1. Determine review scope based on $ARGUMENTS:
   - If $ARGUMENTS is empty or not provided, default to "changes" scope
   - If $ARGUMENTS is "changes", review pending git changes only
   - If $ARGUMENTS is "context", review files in conversation + recent changes
   - If $ARGUMENTS is "repo", review entire repository (WARNING: may be slow on large codebases - consider limiting to specific directories)
2. Identify files to review based on determined scope:
   - `changes`: Files with git modifications (staged + unstaged)
   - `context`: Files mentioned in conversation + recent changes
   - `repo`: All source code files in repository (excluding node_modules, vendor, etc.)
3. Analyze code for security vulnerabilities across all categories
4. Assign severity ratings to each issue found based on exploitability and impact
5. Provide specific remediation steps for each vulnerability
</process>

<security_checks>
<owasp_top_10>
- **Injection vulnerabilities**: SQL, Command, XSS, LDAP, XML, OS command injection
- **Broken authentication**: Weak password policies, session management, credential storage
- **Sensitive data exposure**: Unencrypted data, weak crypto, exposed secrets
- **XML external entities (XXE)**: Unsafe XML parsing, DTD processing
- **Broken access control**: Missing authorization, insecure direct object references
- **Security misconfiguration**: Default configs, unnecessary features, verbose errors
- **Cross-site scripting (XSS)**: Reflected, stored, DOM-based XSS
- **Insecure deserialization**: Unsafe object deserialization, type confusion
- **Using components with known vulnerabilities**: Outdated dependencies, unpatched libraries
- **Insufficient logging and monitoring**: Missing security logs, inadequate alerting
</owasp_top_10>

<additional_concerns>
- **Hardcoded credentials or secrets**: API keys, passwords, tokens in code
- **Insecure cryptographic practices**: Weak algorithms, improper key management, predictable randomness
- **Input validation issues**: Missing validation, insufficient sanitization, type confusion
- **Output encoding problems**: Improper escaping, encoding mismatches
- **Authentication and authorization flaws**: Privilege escalation, broken session management
- **Race conditions and concurrency issues**: TOCTOU, deadlocks, data races
- **Insecure file operations**: Path traversal, arbitrary file upload/download
- **API security issues**: Missing rate limiting, improper authentication, excessive data exposure
- **Server-side request forgery (SSRF)**: Unvalidated URLs, internal service access
- **Clickjacking**: Missing frame protection, UI redress attacks
- **Open redirects**: Unvalidated redirect targets
- **Mass assignment**: Unprotected mass parameter assignment
- **Information disclosure**: Stack traces, debug info, verbose errors in production
</additional_concerns>
</security_checks>

<output_format>

For each issue found, provide:

**[SEVERITY] Vulnerability Type**
- **Location**: `file/path.ext:line_number`
- **Issue**: Clear description of the vulnerability
- **Risk**: Potential security impact and exploitability
- **Recommendation**: Specific steps to remediate

Severity levels:
- **CRITICAL**: Immediate exploitation possible, severe impact (RCE, auth bypass, data breach)
- **HIGH**: Likely exploitable, significant impact (privilege escalation, XSS, injection)
- **MEDIUM**: Requires conditions to exploit, moderate impact (info disclosure, weak crypto)
- **LOW**: Difficult to exploit or minimal impact (verbose errors, missing hardening)

</output_format>

<success_criteria>
- Scope correctly determined from $ARGUMENTS
- All files in scope analyzed for vulnerabilities
- Each issue includes severity, location, description, risk, and remediation
- All OWASP Top 10 categories checked
- Additional security concerns evaluated
- Clear, actionable recommendations provided
- Issues prioritized by severity
</success_criteria>

<examples>

**Usage: Default (changes only)**
```bash
/security-review
```
Reviews only files with pending git changes.

**Usage: Context scope**
```bash
/security-review context
```
Reviews files mentioned in conversation plus recent changes.

**Usage: Full repository**
```bash
/security-review repo
```
Reviews entire codebase (use with caution on large repos).

**Example Output:**

```markdown
### Security Review Results (Scope: changes)

Analyzed 3 files with changes:
- src/db/users.ts
- src/auth/login.ts
- src/api/payments.ts

---

**[CRITICAL] SQL Injection**
- **Location**: `src/db/users.ts:45`
- **Issue**: User input directly concatenated into SQL query
  ```typescript
  const query = `SELECT * FROM users WHERE email = '${email}'`;
  ```
- **Risk**: Attacker could manipulate queries to access, modify, or delete arbitrary data. Complete database compromise possible.
- **Recommendation**: Use parameterized queries or an ORM:
  ```typescript
  const query = `SELECT * FROM users WHERE email = ?`;
  db.query(query, [email]);
  ```

**[HIGH] Hardcoded Secret**
- **Location**: `src/api/payments.ts:12`
- **Issue**: Stripe API key hardcoded in source code
  ```typescript
  const stripe = new Stripe('sk_live_abc123...');
  ```
- **Risk**: If code is exposed (git history, logs, public repo), attackers gain full access to payment processing.
- **Recommendation**: Use environment variables:
  ```typescript
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  ```

**[MEDIUM] Sensitive Data Logging**
- **Location**: `src/auth/login.ts:78`
- **Issue**: Password logged in plain text during authentication
  ```typescript
  logger.info(`Login attempt: ${email} ${password}`);
  ```
- **Risk**: Credentials exposed in log files, accessible to anyone with log access.
- **Recommendation**: Remove sensitive data from logs or redact:
  ```typescript
  logger.info(`Login attempt: ${email} [password redacted]`);
  ```

---

### Summary
- 🔴 Critical: 1
- 🟠 High: 1
- 🟡 Medium: 1
- ⚪ Low: 0

**Action Required**: Address critical and high severity issues before merging.
```

</examples>

<best_practices>

**When to run this command:**
- Before creating merge requests or pull requests
- After implementing authentication/authorization features
- When handling user input or external data
- When working with sensitive data (PII, credentials, financial data)
- After adding new dependencies or third-party integrations
- As part of CI/CD pipeline for automated security checks
- When refactoring security-critical code

**Integration with development workflow:**
1. Make changes to code
2. Run `/security-review` before committing
3. Address critical and high severity issues
4. Re-run to verify fixes
5. Commit with confidence

</best_practices>
