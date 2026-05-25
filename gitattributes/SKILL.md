---
name: gitattributes
description: Generates .gitattributes files with sensible defaults for line endings and binary handling. Use when the user asks to create or update a .gitattributes file, wants to enforce LF line endings, needs binary file handling, or mentions gitattributes, line endings, eol, or text normalization.
---

# gitattributes Skill

Generate `.gitattributes` files with proper line ending normalization and binary file handling.

## When to Use

- User asks to create or update a `.gitattributes` file
- User wants to enforce consistent line endings (LF vs CRLF)
- User mentions gitattributes, line endings, eol, text normalization
- Setting up a new project that needs consistent file handling

## Base Configuration

Every `.gitattributes` file **must** start with these base rules:

```
# Auto detect text and perform LF normalization
* text=auto eol=lf
```

This ensures:
- Git auto-detects text files
- All text files use LF line endings on checkout (consistent across Windows/Linux/macOS)

## Workflow

### Generating a .gitattributes

1. Always include the base rule `* text=auto eol=lf` at the top.
2. Determine which language/framework-specific rules the project needs.
3. Add binary file exclusions so Git doesn't corrupt binaries.
4. Write the result to `.gitattributes` in the project root.

### Updating an existing .gitattributes

1. Read the existing file.
2. Ensure the base rule `* text=auto eol=lf` is present (add if missing).
3. Add any new rules without duplicating existing entries.

## Common Binary File Patterns

These should be marked as `binary` to prevent text normalization:

```
# Archives
*.zip binary
*.tar binary
*.gz binary
*.7z binary
*.rar binary

# Images
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.ico binary
*.webp binary
*.svg binary

# Fonts
*.woff binary
*.woff2 binary
*.ttf binary
*.eot binary
*.otf binary

# Documents
*.pdf binary
*.doc binary
*.docx binary
*.xls binary
*.xlsx binary
*.ppt binary
*.pptx binary

# Media
*.mp3 binary
*.mp4 binary
*.avi binary
*.mov binary
*.wav binary
*.flac binary

# Executables / compiled
*.exe binary
*.dll binary
*.so binary
*.dylib binary
*.bin binary
*.wasm binary
```

## Language-Specific Patterns

### Go

```
*.go text eol=lf diff=golang
go.sum text eol=lf
```

### Python

```
*.py text eol=lf
*.pyi text eol=lf
requirements.txt text eol=lf
pipfile.lock text eol=lf
```

### Node.js / JavaScript / TypeScript

```
*.js text eol=lf
*.jsx text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.json text eol=lf
*.css text eol=lf
*.scss text eol=lf
*.less text eol=lf
*.html text eol=lf
*.md text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
package-lock.json text eol=lf
yarn.lock text eol=lf
```

### Rust

```
*.rs text eol=lf
Cargo.lock text eol=lf
```

### Java / JVM

```
*.java text eol=lf
*.kt text eol=lf
*.kts text eol=lf
*.scala text eol=lf
*.groovy text eol=lf
*.properties text eol=lf
*.xml text eol=lf
gradlew text eol=lf
```

### Shell scripts

```
*.sh text eol=lf
*.bash text eol=lf
*.zsh text eol=lf
```

## Using the Helper Script

```bash
# Generate base .gitattributes
bash scripts/gitattributes.sh generate

# Generate with language-specific rules
bash scripts/gitattributes.sh generate --lang python,node

# Generate and write to file
bash scripts/gitattributes.sh generate --lang go --write

# List available languages
bash scripts/gitattributes.sh list

# Show help
bash scripts/gitattributes.sh help
```

## No Explanatory Comments in Output

The generated output must not include any explanatory comments. Only output the raw rules. Preserve any existing comments when appending to an existing file.

## Gotchas

- `.gitattributes` rules are evaluated top-to-bottom; **later rules override earlier ones**.
- Always place `* text=auto eol=lf` at the very top as the catch-all base rule.
- Forgetting to mark binaries causes corruption (Git tries to convert line endings in images, etc.).
- After changing `.gitattributes`, existing files need re-normalization: `git add --renormalize .`
- `eol=lf` forces LF on checkout regardless of OS; use `eol=crlf` only for Windows-specific tooling that requires it.
- `.gitattributes` must be committed to the repo to apply to all collaborators.
