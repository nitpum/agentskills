---
name: tech-stack
description: >
  The user's preferred tech stack for new projects and features. Use when starting a new
  project, choosing technologies, scaffolding an app, picking a backend language, building a
  CLI tool, deciding on a frontend approach, building a web UI, adding interactivity to a
  page, choosing a build tool, selecting a CSS framework, picking a state management
  library, or building a game. Also use when the user mentions Go, Golang, Alpine.js, Vite,
  Vitest, React, UnoCSS, Jotai, Godot, GDScript, three.js, or phaser.js. Core philosophy:
  simple, portable, minimal tooling, few dependencies.
---

# Preferred Tech Stack

The user values **simplicity, portability, and minimal tooling**. Default to the technologies
below. Reach for heavier options only when the lightweight option genuinely cannot do the job.

## Decision Hierarchy

When choosing tech for a new task, work top-down and stop at the first that fits:

1. A single Go binary / a plain script with no install step → use that.
2. A static HTML page with one `<script>` include → use that.
3. The smallest viable build-tool setup (Vite) when a real SPA is required.
4. Avoid heavy frameworks, runtimes, or anything requiring a long install/dependency chain unless the task demands it.

## Backend & CLI: Go

Default for backend services **and CLI tools**: **Go**.

- Lightweight, simple, fast to compile, produces a single small static binary.
- Cross-compile to any OS/arch with `GOOS`/`GOARCH` — one binary per target, no install step on the user's machine.
- Strong standard library covers most needs without external deps — prefer stdlib first (e.g. `flag` or `os.Args` for arg parsing, `net/http`, `encoding/json`, `os/exec`).
- Add external dependencies only when the stdlib cannot do the job. Fewer deps = worry-free upgrades and security.
- No runtime or VM to install on the target; ship one binary.

## Web Interactivity (simple): Alpine.js

For pages that need light interactivity (dropdowns, modals, tabs, small forms), default to **Alpine.js**.

- No package manager, no build step. Download one `alpine.js` file, include it via `<script src>`, done.
- Upgrading = download the new file and replace it. No toolchain involved.
- Reach for this before any framework when interactivity is modest.

## Web (advanced): Vite + React + UnoCSS + Jotai

When a page needs a real SPA or complex UI that Alpine.js cannot reasonably handle, use:

- **Vite** — build tool and dev server
- **Vitest** — test runner
- **React** — UI framework
- **UnoCSS** — atomic/utility CSS
- **Jotai** — state management, only when state is genuinely shared or complex

When a Node/npm package manager is needed, use **pnpm** as the default.

## Games

Default game engine: **Godot + GDScript**.

- No special compiler/toolchain needed to author or iterate.
- Exports to nearly any platform (desktop, mobile, web, consoles) — decide the target later.

For small web-only games, prefer **three.js** or **phaser.js** (single-file include, no build step) over a full engine.

## Gotchas

- Do NOT reach for Node, npm, or pip when a single Go binary or a single `<script>` include will do. This includes CLI tools — prefer Go over a Node/Python script. When a Node package manager is genuinely needed, default to **pnpm**.
- Alpine.js is loaded via a plain `<script src>` tag, NOT via npm import. Keep it that way for simple cases.
- Prefer Go stdlib over pulling a third-party module. Only add a dependency when the gap is real.
- The "advanced web" stack (Vite/React/UnoCSS/Jotai) is opt-in, not default. Confirm the UI actually needs it before scaffolding.
- In Godot, GDScript is the default language, not C# or GDExtension/C++.
- When a task fits the lightweight path, do not propose the heavy path "just in case" — that contradicts the user's philosophy.
