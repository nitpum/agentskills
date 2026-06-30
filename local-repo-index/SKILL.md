---
name: local-repo-index
description: >
  Index of the local repositories on this machine: what each repo is, which service it is, its
  full service name, a short description, and how it relates to other services. Use when the user
  asks what a local repo is, which service it belongs to, how repos/services relate, which repos
  exist, where something lives, or to map the local service landscape. Also use when adding or
  updating a repo entry. The shared skill (this file) travels with the repo; the actual
  per-machine data lives in references/index.json, which is gitignored and local to each PC.
---

# local-repo-index

A per-machine catalogue of local repositories and the services they implement. The **schema and
workflow live here (shared)**; the **data lives in [references/index.json](references/index.json)
(gitignored, local to this PC)**. On a new machine, sync this skill and create a fresh
`references/index.json` from the schema below.

## Schema

`references/index.json` is one JSON object:

```json
{
  "updated": "2026-06-30",
  "repos": {
    "repo-folder-name": {
      "path": "/absolute/path/to/repo",
      "service": "Full Human-Readable Service Name",
      "type": "api | worker | web | cli | library | database | infra | mobile | other",
      "language": "go",
      "description": "One short line: what this repo/service does.",
      "relations": ["other-repo-folder-name"],
      "notes": "optional extra context"
    }
  }
}
```

Field rules:

- `repos` key = the repo's directory name (the `basename` of `path`).
- `service` = the **full service name** as people refer to it.
- `type` = primary role; pick the closest single fit.
- `relations` = folder names of repos this one depends on, calls, or ships with. Use folder names,
  not service names.
- Keep `description` to one line. Use `notes` only for genuinely extra context.

## How to use

1. Read [references/index.json](references/index.json).
2. Answer questions from it: what is repo X, which service, how does it relate to Y, which repos
   exist, where does Z live.
3. For relationships, follow each entry's `relations` list to map the service landscape.
4. If a repo is asked about but **missing** from the index, say so and offer to add it (below).

## How to update

Add or fix an entry in `references/index.json`:

1. Gather facts about the repo:
   ```bash
   git -C <repo> remote -v        # origin / full name
   ls <repo>                       # README, go.mod, package.json, etc.
   ```
   Read its README / `package.json` / `go.mod` to confirm language and dependencies.
2. Add or edit the entry under `repos[folder]` using the schema above. Bump `updated` to today.
3. Validate it is well-formed and self-consistent:
   ```bash
   jq . references/index.json > /dev/null
   ```
4. Only stop when `jq` exits 0 and every value in every `relations` list resolves to a key in
   `repos`.

## Gotchas

- `references/index.json` is **gitignored and per-machine** — never commit it; it is not shared.
- If the file is missing on this PC, create it from the schema above before using the skill.
- `relations` values must be folder-name keys, not service names, or the map breaks.
- `jq` is required to validate.
