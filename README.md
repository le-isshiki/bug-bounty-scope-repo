# Bug Bounty Scope Repo

This repository is structured so GitHub-repository-only security tools can reason over a bug bounty scope as if it were a normal project.

## How to use

1. Keep this repo private.
2. Add the program scope to `scope/`.
3. Add each target as a separate file in `targets/`.
4. Add active findings or draft reports to `reports/`.
5. Add hunting strategy and hypotheses to `notes/`.

## Tooling guidance

Prioritize findings with proven impact:
- unauthenticated data access
- authorization bypass
- cross-tenant data exposure
- file download/upload abuse
- payment or account takeover flows
- sensitive document exposure

Ignore weak/noisy classes unless chained:
- missing headers
- version disclosure
- generic CORS without sensitive data
- clickjacking without impact
- directory listing without sensitive data
- schema/metadata disclosure only
