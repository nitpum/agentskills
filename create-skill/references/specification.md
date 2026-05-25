# Agent Skills Specification Reference

Source: https://agentskills.io/specification

## SKILL.md Frontmatter

### Minimal Example

```markdown
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

### Full Example

```markdown
---
name: pdf-processing
description: Extract PDF text, fill forms, merge files. Use when handling PDFs.
license: Apache-2.0
compatibility: Requires Python 3.14+ and uv
metadata:
  author: example-org
  version: "1.0"
allowed-tools: Bash(git:*) Bash(jq:*) Read
---
```

## Name Validation Rules

Valid: `pdf-processing`, `data-analysis`, `code-review`, `my-skill-123`
Invalid: `PDF-Processing` (uppercase), `-pdf` (starts with hyphen), `pdf--processing` (consecutive hyphens), `pdf processing` (space)

## Progressive Disclosure Limits

- Metadata: ~100 tokens (name + description only)
- Instructions: < 5000 tokens recommended (full SKILL.md body)
- Resources: loaded on demand (scripts, references, assets)

Keep SKILL.md under 500 lines. Move detailed content to separate files.

## File References

Use relative paths from the skill root:

```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script:
scripts/extract.py
```

Keep file references one level deep. Avoid deeply nested reference chains.

## Validation

Validate skills using skills-ref: https://github.com/agentskills/agentskills/tree/main/skills-ref

```bash
skills-ref validate ./my-skill
```
