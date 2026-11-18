---
name: code-review
description: >
  The user's code review guidelines: self-explanatory code, comments only with
  TODO/NOTE/FIXME prefixes, verb-first function names, no magic numbers, absolute import
  paths, reuse existing or shared functions before adding new ones. Use when reviewing
  code, giving PR/MR/diff feedback, or writing code that must pass review. Keywords:
  review, code review, guideline, PR, MR, diff, diff suggestion, comment, TODO, NOTE,
  FIXME, magic number, naming, const, import, absolute path, reuse, shared function,
  self-explanatory.
---

# Code Review Guidelines

Code explains itself; comments are the exception.

## Rules

- Make code self-explanatory: good names, small functions.
- Never comment what the code already says — fix the code instead.
- Comment only when code is too complex to understand, or to explain why it exists.
- Every comment starts with `TODO:`, `NOTE:`, or `FIXME:` — e.g. `// TODO: Implement click function`.
- Keep comments short and to the point.
- No ticket/Jira/MR/PR IDs in comments — exceptions: `FIXME` ref to an open bug, a known-bug link, or a `TODO:` ref when the work will be done in that card.
- Function names start with a verb: `fetchUserData`, not `userInfo`.
- Before adding a new function, search for a similar existing one — reuse it, or extract a shared function. Skip only if its purpose is too specific to one place.
- No magic numbers — define a const: `const DASHBOARD_LOAD_DELAY_MS = 5000`.
- Absolute import paths when possible: `@/utils/date`, not `../../utils/date`.
- Delete dead code and dead comments — git keeps the history, don't keep it "just in case".

## Review checklist

- [ ] No comment restates the code; all comments prefixed `TODO:`/`NOTE:`/`FIXME:`.
- [ ] Comments short; no ticket IDs (except `FIXME` open-bug / known-bug / `TODO`-in-that-card refs).
- [ ] Function names start with a verb.
- [ ] New function reuses an existing one or extracts shared logic — unless too specific in scope.
- [ ] No magic numbers — named constants.
- [ ] Absolute imports where supported — no `../..` chains.
- [ ] No dead code or dead comments left behind.

When reviewing, propose the concrete fix (const name, rename, one-line `NOTE`) — deleting a comment is valid feedback. When the tool or venue supports it, include the change as a diff suggestion (e.g. GitHub/GitLab suggestion blocks, unified diff patch).
