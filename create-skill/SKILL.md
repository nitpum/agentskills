---
name: create-skill
description: Create Agent Skills for AI agents. Use when asked to create, build, or write a new skill, or when asked about the Agent Skills format, SKILL.md structure, or skill best practices.
metadata:
  author: ene
  version: "1.0"
  source: https://agentskills.io
---

You are an expert at creating Agent Skills following the open standard from agentskills.io. When asked to create a skill, follow this guide precisely.

## Skill Structure

A skill is a directory containing, at minimum, a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## Creating a SKILL.md

Every `SKILL.md` must have YAML frontmatter followed by Markdown body content.

### Frontmatter Fields

| Field           | Required | Description |
|-----------------|----------|-------------|
| `name`          | Yes      | 1-64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing/consecutive hyphens. Must match the folder name. |
| `description`   | Yes      | 1-1024 chars. Describe what the skill does AND when to use it. Include specific keywords for activation matching. |
| `license`       | No       | License name or reference to bundled license file. |
| `compatibility` | No       | 1-500 chars. Environment requirements (OS, packages, tools needed). |
| `metadata`      | No       | Arbitrary key-value mapping for extra properties. |
| `allowed-tools` | No       | Space-separated string of pre-approved tools (experimental). |

### Name Rules

- Only `a-z`, `0-9`, and hyphens `-`
- Cannot start or end with a hyphen
- No consecutive hyphens (`--`)
- Must match the parent directory name

### Description Guidelines

A good description tells the agent both WHAT the skill does and WHEN to use it:

Good: `Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.`

Bad: `Helps with PDFs.`

### Body Content

The Markdown body contains the skill instructions the agent follows after activation. Include:

1. Step-by-step instructions
2. Examples of inputs and outputs
3. Common edge cases and gotchas

## Where to Place Skills

- **Project-level**: `.agents/skills/` in the project root (applies to that project only)
- **Global/user-level**: `~/.agents/skills/` (available across all projects)

## Progressive Disclosure

Skills load in 3 stages:

1. **Discovery**: Agent reads only `name` and `description` from frontmatter (~100 tokens)
2. **Activation**: Agent loads the full `SKILL.md` body when the skill is relevant
3. **Execution**: Agent reads referenced files (scripts, references, assets) only when needed

Keep `SKILL.md` under 500 lines / 5000 tokens. Move detailed content to `references/`.

## Best Practices

### Add What the Agent Lacks, Omit What It Knows

Don't explain general concepts the agent already knows. Focus on project-specific conventions, domain procedures, non-obvious edge cases, and specific tools/APIs.

### Match Specificity to Fragility

- **Be prescriptive** when operations are fragile, consistency matters, or a specific sequence is required
- **Give freedom** when multiple approaches are valid and the task tolerates variation

### Provide Defaults, Not Menus

Pick a default tool/approach. Mention alternatives briefly instead of presenting equal options.

### Include a Gotchas Section

The highest-value content in many skills. List environment-specific facts that defy reasonable assumptions:

```markdown
## Gotchas

- The `users` table uses soft deletes. Always filter `WHERE deleted_at IS NULL`.
- The user ID is `user_id` in the DB, `uid` in auth, and `accountId` in billing.
```

### Use Validation Loops

Instruct the agent to validate its work before proceeding:

```markdown
1. Make edits
2. Run validation: `python scripts/validate.py output/`
3. If validation fails, fix issues and re-validate
4. Only proceed when validation passes
```

### Use Checklists for Multi-step Workflows

```markdown
## Workflow

- [ ] Step 1: Analyze the form
- [ ] Step 2: Create field mapping
- [ ] Step 3: Validate mapping
- [ ] Step 4: Execute
- [ ] Step 5: Verify output
```

## Scripts in Skills

Scripts go in the `scripts/` directory. Reference them with relative paths from the skill root.

### Script Design Rules

1. **No interactive prompts** - agents run in non-interactive shells. Use flags/env vars/stdin.
2. **Implement `--help`** - agents learn your script's interface from help output.
3. **Write helpful errors** - say what went wrong, what was expected, what to try.
4. **Use structured output** - JSON/CSV over free-form text. Data on stdout, diagnostics on stderr.
5. **Make idempotent** - agents may retry. "Create if not exists" beats "create and fail on duplicate."
6. **Support `--dry-run`** for destructive operations.

### Self-contained Scripts

Use inline dependency declarations so scripts run without a separate install step:

- **Python**: PEP 723 inline metadata, run with `uv run script.py`
- **Deno**: `npm:` imports, run with `deno run script.ts`
- **Bun**: auto-installs packages, run with `bun run script.ts`
- **Ruby**: `bundler/inline` gemfile, run with `ruby script.rb`

### One-off Commands

For simple tasks, reference existing tools directly in SKILL.md without a scripts directory:

- `uvx ruff@0.8.0 check .` (Python)
- `npx eslint@9 --fix .` (Node.js)
- `go run golang.org/x/tools/cmd/goimports@v0.28.0 .` (Go)

Pin versions for reproducibility.

## Workflow for Creating a Skill

When asked to create a skill, follow this process:

1. **Clarify the skill's purpose** - What task should it handle? When should it activate?
2. **Choose a name** - Follow naming rules, keep it short and descriptive
3. **Write the description** - Include what + when, with specific trigger keywords
4. **Identify what the agent won't know** - Project-specific facts, non-obvious gotchas, tool specifics
5. **Write instructions** - Step-by-step, concise, with defaults and examples
6. **Add scripts if needed** - Self-contained, non-interactive, with `--help`
7. **Add gotchas** - Environment-specific corrections to common mistakes
8. **Test and iterate** - Run against real tasks, refine based on results

For the full specification, see [references/specification.md](references/specification.md).
