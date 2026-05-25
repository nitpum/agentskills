---
name: gitignore-io
description: Generates .gitignore files using the gitignore.io (Toptal) API. Use when the user asks to create, update, or fetch .gitignore templates for specific languages, frameworks, IDEs, or operating systems. Also use when the user mentions gitignore, ignore files, or wants to know available gitignore templates.
---

# gitignore.io Skill

Generate `.gitignore` files from [gitignore.io](https://www.toptal.com/developers/gitignore) templates via their API.

## When to Use

- User asks to create or update a `.gitignore` file
- User wants to ignore files for a specific language, framework, IDE, or OS
- User asks what gitignore templates are available
- User mentions "gitignore", "ignore file", or similar terms

## API Endpoints

The gitignore.io API is hosted at `https://www.toptal.com/developers/gitignore/api`.

### List all available templates

```
GET https://www.toptal.com/developers/gitignore/api/list
```

Returns a newline-separated list of all template names.

### Generate a .gitignore

```
GET https://www.toptal.com/developers/gitignore/api/{template1},{template2},...
```

Comma-separated template names. Returns the combined `.gitignore` content.

## Base Templates

The following base templates **must always be included** in every generated `.gitignore` as a sensible default:

```
windows,linux,macos,dotenv
```

These cover cross-platform OS files, environment variable files, and log files. Always prepend these to any user-requested templates.

## Workflow

### Generating a .gitignore

1. Determine which templates the user needs based on their project (language, framework, IDE, OS).
2. **Always prepend the base templates**: `windows,linux,macos,dotenv`
3. If unsure which templates exist, list them first using the script or API.
4. Fetch the generated content using the helper script or a direct web fetch.
5. Write the result to `.gitignore` in the project root, or append if the file already exists.

### Listing available templates

1. Fetch the template list.
2. Filter or display relevant templates to the user.

## Using the Helper Script

The skill includes a helper script at `scripts/gitignore.sh`:

```bash
# List all available templates
bash scripts/gitignore.sh list

# Generate .gitignore (auto-includes windows,linux,macos,dotenv)
bash scripts/gitignore.sh generate python,node,visualstudiocode

# Generate and write directly to .gitignore in current directory
bash scripts/gitignore.sh generate python,node,visualstudiocode --write

# Generate without base templates
bash scripts/gitignore.sh generate python,node --no-base

# Search for templates matching a keyword
bash scripts/gitignore.sh search python
```

## Direct API Usage (without script)

If `curl` is available, you can call the API directly:

```bash
# List templates
curl -s https://www.toptal.com/developers/gitignore/api/list

# Generate
curl -s https://www.toptal.com/developers/gitignore/api/python,node
```

## Common Template Names

Here are frequently used templates for quick reference:

| Category    | Templates                                                                         |
|-------------|-----------------------------------------------------------------------------------|
| Languages   | `python`, `node`, `java`, `go`, `rust`, `c`, `c++`, `ruby`, `swift`, `kotlin`    |
| Frameworks  | `react`, `vue`, `nextjs`, `django`, `flask`, `rails`, `springboot`, `angular`    |
| IDEs        | `visualstudiocode`, `intellij`, `vim`, `emacs`, `eclipse`, `xcode`               |
| OS          | `macos`, `windows`, `linux`                                                       |
| Tools       | `docker`, `terraform`, `ansible`, `cmake`, `gradle`, `maven`                     |

Always verify template names against the API list if unsure, as names can be non-obvious (e.g., `visualstudiocode` not `vscode`).

## Important: Preserve API Comments

The gitignore.io API output includes header and footer comments that **must never be stripped**:

- **Header**: `# Created by https://www.toptal.com/developers/gitignore/api/...` and `# Edit at https://www.toptal.com/developers/gitignore?templates=...`
- **Footer**: `# End of https://www.toptal.com/developers/gitignore/api/...`

These comments provide an edit link for users to modify templates later. Always write the full API output verbatim, including these comments.

## Gotchas

- Template names are **case-sensitive** and must match exactly (e.g., `Node` will fail; use `node`).
- The API returns plain text, not JSON.
- Multiple templates are comma-separated with **no spaces**.
- Common mismatches: `visualstudiocode` (not `vscode`), `c++` (not `cpp`), `jekyll` (not `ruby-jekyll`).
- If the API is unreachable, fall back to generating a reasonable `.gitignore` from general knowledge.
- When appending to an existing `.gitignore`, check for duplicate entries first.
