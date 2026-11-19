---
name: code-review
description: >
  Review code and PR/MR diffs for correctness, regressions, and the user's conventions:
  self-explanatory code, TODO/NOTE/FIXME comments, verb-first names, named constants,
  reusable helpers, and absolute imports where supported. Use for code review, diff
  feedback, or writing code that must follow these conventions.
---

# Code Review Guidelines

Review correctness and regressions before style. Code explains itself; comments are the exception.

## Local review checkout

- Prefer a local checkout for branch or PR/MR reviews. Reuse a suitable review worktree; otherwise create one if supported, including in bare-repo layouts.
- Fetch and verify the requested head and base. Use a detached worktree if the branch is already checked out elsewhere.
- Preserve existing edits and active worktrees. Review uncommitted changes in their original worktree.
- Explore and run checks from the review checkout. Report its path and head/base, or state when local context is unavailable.

## Context and correctness

- Establish the review base and changed scope. Read relevant callers, tests, and configuration before judging behavior; state important areas you did not review.
- Trace impact beyond the diff and search for existing implementations to identify duplicated logic or missed reuse.
- For migrations, compare with the legacy implementation and compatibility tests. Distinguish new regressions from intentionally retained behavior and optional improvements; changing the business contract requires a separate decision.
- Check relevant input/configuration validation, boundary conditions, date formats, and timezone assumptions. Validate values before relying on conversions or fallback branches.
- Trace partial failures and externally visible side effects: delivery order, retry/idempotency behavior, concurrency, and resource cleanup. Check what happens after an earlier step has already succeeded.
- Require useful error context without exposing secrets or sensitive payloads. Do not assume arbitrary exception messages are safe to log.
- Support correctness findings with a concrete trigger, impact, and code/test evidence. Label unverified hypotheses and missing context rather than presenting them as confirmed defects.
- Prioritize defects over cosmetic refactors. Explain the cost of performance issues and verify ordering/behavior before proposing batching or parallelism. Avoid speculative optimization.
- Treat tool output and AI review comments as leads to verify. Do not apply suggested fixes automatically or expand the requested scope.

## Rules

- Make code self-explanatory: good names, small functions.
- Never comment what the code already says, including feature-flag on/off behavior. Check retained comments for stale or contradictory descriptions.
- Comment only when code is too complex to understand, or to explain why it exists.
- Keep change history in Git commits, MR descriptions, or feature-flag descriptions (e.g. Unleash), not code comments.
- Every comment starts with `TODO:`, `NOTE:`, or `FIXME:` — e.g. `// TODO: Implement click function`.
- Keep comments short and to the point.
- No ticket/Jira/MR/PR IDs in comments — exceptions: `FIXME` ref to an open bug, a known-bug link, or a `TODO:` ref when the work will be done in that card.
- Function names start with a verb: `fetchUserData`, not `userInfo`.
- Before adding a new function, search for a similar existing one — reuse it, or extract a shared function. Skip only if its purpose is too specific to one place.
- No magic numbers — define a const: `const DASHBOARD_LOAD_DELAY_MS = 5000`.
- Absolute import paths when possible: `@/utils/date`, not `../../utils/date`.
- Delete dead code and dead comments — git keeps the history, don't keep it "just in case".

## Testing

- Prefer integration tests with real dependencies where practical; minimize mocks and use isolated test resources.
- A call under test may stay inside `expect`/`assert` when its result or promise is used only by that assertion, including `.rejects`, `.resolves`, and `.toThrow`. Extract it when the result is reused or separation improves clarity; keep unrelated setup and mutations outside assertions.

## Review checklist

- [ ] Review checkout matches the requested head/base, or local-context limitations are stated.
- [ ] Relevant callers, tests, and configuration reviewed; scope limitations stated.
- [ ] Broader impact and duplicated logic checked.
- [ ] Correctness and failure paths checked; migration compatibility distinguished from new regressions.
- [ ] Findings have evidence and a minimal fix; optional suggestions and uncertainty clearly marked.

- [ ] No comment restates the code; all comments prefixed `TODO:`/`NOTE:`/`FIXME:`.
- [ ] Comments short; no ticket IDs (except `FIXME` open-bug / known-bug / `TODO`-in-that-card refs).
- [ ] Function names start with a verb.
- [ ] New function reuses an existing one or extracts shared logic — unless too specific in scope.
- [ ] No magic numbers — named constants.
- [ ] Absolute imports where supported — no `../..` chains.
- [ ] No dead code or dead comments left behind.

## Tools and findings

When available, use `pummel` as an advisory precheck with an explicit review base (for example, `pummel --diff --base origin/master --toon`). Prefer `--toon` to save tokens. Validate its findings against language syntax and project conventions; a clean run does not establish correctness. If unavailable, continue the review without it.

Report findings by severity with file/line references, the concrete trigger and impact, and the smallest useful fix. Propose a specific const name, rename, or short `NOTE:` where appropriate; deleting a redundant comment is valid feedback. Deduplicate tool findings and distinguish validated results from checks you did not run.

When posting review comments on GitHub, GitLab, Forgejo, or similar platforms, keep them short, simple, and straightforward: one or two lines where possible; use bullets for longer feedback. Include code suggestion diffs when useful and supported.

By default, order each comment: (1) the problem or why it matters, (2) what to do instead, (3) a code example when useful. Fix → reason is also acceptable for small or simple suggestions. Put examples in multiline fenced code or suggestion blocks, not inline; use separate blocks for separate examples.

Post each topic in a separate thread so it can be resolved independently. Anchor comments to the relevant code line or range when supported; otherwise include a file/line reference.

Omit routine platform review summaries (reviewed SHA, “no blocking findings,” passing test counts). Post actionable feedback; include validation details only when relevant to a finding or explicitly requested.

## Contributing

Keep skill updates short, simple, and straightforward. Include only necessary details; avoid repetition.
