---
name: task-store
description: >
  Persist task progress, research, and summaries as plain markdown under ~/ws/tasks/<task-name>/,
  so work survives across agent sessions and stays readable by both agents and humans. Use when
  starting or continuing a task, doing research or investigation, taking notes, preparing a
  handoff, or whenever the user says a task should survive across sessions, "take notes",
  "save progress", "write this down", "pick up where we left off", "continue the task", or
  mentions a task journal, task log, session notes, or handoff notes. Also use when a task has
  a Jira, Linear, or other ticket ID that should be tracked with the work.
---

# task-store

A durable, file-based task store. Every task, research topic, or investigation gets a folder
under `~/ws/tasks/` with a `README.md` index at minimum. Notes are written for **two readers**:
the human owner and the next agent session (which may be a different agent with zero context).

## Layout

```
~/ws/tasks/
├── AB-1234-fix-concurrent/     # ticket-prefixed task
│   ├── README.md               # REQUIRED: index + brief of the task
│   ├── PLAN.md                 # OPTIONAL: steps / roadmap for non-trivial work
│   └── notes/                  # OPTIONAL: free-form research notes, logs, snippets
└── research-auth-options/      # no ticket ID → no prefix
    └── README.md
```

## Task folder naming (strict)

Pattern: `<TASK-ID>-<short-kebab-name>` when a ticket ID exists, otherwise just
`<short-kebab-name>`. Never add a made-up ID.

- With Jira/Linear/ticket ID: `AB-1234-fix-concurrent`, `LIN-42-migrate-auth`
- Without ID: `research-auth-options`, `refactor-config-loader`
- Keep the kebab name short: 2–5 words, lowercase, hyphen-separated, no dates in the name
  (dates live inside README.md)
- Ticket ID stays uppercase, verbatim from the tracker (`AB-1234`, not `ab-1234`)

## Workflow

### Starting a new task

1. Derive the folder name (see naming rules above). If unsure, ask the user only when the
   ambiguity is real; otherwise pick a clear name and note it in the response.
2. Create the folder and copy the template in:
   ```bash
   mkdir -p ~/ws/tasks/<task-name>
   cp <skill-dir>/assets/templates/README.md ~/ws/tasks/<task-name>/README.md
   ```
   `<skill-dir>` is this skill's directory (e.g. `~/.agents/skills/task-store`).
3. Fill in the README front matter: title, summary, status, ticket link, date.
4. For non-trivial work, also copy `assets/templates/PLAN.md` to `PLAN.md` and sketch the steps.
5. Update the README **as work progresses** — after each meaningful unit of work, not just at
   the end. A stale README is worse than none.

### Continuing an existing task

1. List candidates: `ls ~/ws/tasks/`
2. Read the task's `README.md` first — it is the entry point. Then `PLAN.md` and `notes/` if present.
3. Verify claims against reality before building on them (files/repos may have changed since
   the last session). Trust, but check.
4. Continue work, appending to the progress log and updating status/next-steps.

### Session handoff (end of a session or when context is running out)

1. Update `Status`, `Last updated`, the progress log, and `Next steps` in README.md so the next
   session can resume with no other context.
2. Next steps must be **actionable commands or concrete actions**, not vague intentions.
   "Run `cargo test` and fix the two failing lints" — not "improve tests".
3. Record open questions and anything that was tried and failed (dead ends are findings too).

## Writing rules

- Plain markdown, no exotic syntax. Any editor/agent can read it.
- README.md stays a **brief index**: summary, status, decisions, next steps, links to deeper
  notes in `notes/`. Long research/detail goes into separate note files, linked from the README.
- Append-only progress log entries look like:
  `### 2026-10-15 — <what was done> / <what was found> / <what it means>`
- **Never store secrets or sensitive info in task notes** — no passwords, API keys, tokens,
  connection strings, private keys, `.env` contents, database dumps, or personal/customer data.
  If a note needs to reference a secret, name it (`$OPENAI_API_KEY`, "the prod DB password in
  the vault") — never paste the value. This applies to README.md, PLAN.md, and `notes/`.
- Mark dead ends explicitly (`**Dead end:** ...`) so future sessions don't retry them.

## Gotchas

- Secrets and sensitive info (credentials, tokens, keys, personal data) must never be written
  into task folders — notes are designed to be shared, committed, and read across sessions, so
  treat every line as public. Reference secrets by name/env var only; redact logs and error
  output before pasting them into notes.
- `~/ws/` may not exist yet — always `mkdir -p` the full task path; never assume the tree exists.
- One folder per task; don't pile unrelated work into a generic `misc/` or `notes/` task.
- If two tasks collide on a name, disambiguate with the ticket ID or a more specific kebab name —
  never suffix with `-1`, `-2`, `-new`.
- If the user references a task vaguely ("the auth thing"), search before creating:
  `ls ~/ws/tasks/ | grep -i auth`. Reuse the existing folder; don't fork a near-duplicate.
- Completing a task: set Status to `done` (or `abandoned` with a reason) — do not delete the
  folder. History is the point.
