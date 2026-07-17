---
name: tech-stack
description: >
  The user's preferred tech stack for new projects and features. Use when starting a new
  project, choosing technologies, scaffolding an app, picking a backend language, building a
  CLI tool, deciding on a frontend approach, building a web UI, adding interactivity to a
  page, choosing a build tool, selecting a CSS framework, picking a state management
  library, or building a game. Also use when picking a database or the user mentions Go, Golang,
  Alpine.js, Vite, Vitest, React, UnoCSS, Jotai, Godot, GDScript, three.js, phaser.js, libsql,
  libSQL, SQLite, or PostgreSQL. Also use when a C/C++ toolchain is needed or the user mentions
  Zig, zig cc, cgo, cross-compilation, or a C compiler. Core philosophy: simple, portable,
  minimal tooling, few dependencies.
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
- When **cgo** is needed (wrapping a C library, or a dependency pulls in C), use **`zig cc`** as
  the C/C++ compiler — see "C/C++ Toolchain" below. Do not require a system `gcc`/`clang`.

## C/C++ Toolchain: `zig cc`

Default C/C++ compiler for any project that needs one (Go cgo, Rust builds needing a C
toolchain, native C/C++ code, cross-compilation): **Zig**'s drop-in compiler driver, `zig cc`
/ `zig c++`.

- One self-contained Zig download provides a full, modern clang+lld-based C/C++ toolchain
  with **no system dependencies** — no `build-essential`, no Xcode, no separate LLVM install.
- Works as a transparent drop-in: set `CC=zig cc` and `CXX=zig c++` and most build systems
  (Go, Cargo, CMake, Make, Bazel, etc.) just work.
- **Best-in-class cross-compilation out of the box.** Target any OS/arch with a single flag,
  e.g. `zig cc -target x86_64-windows-gnu` or `zig cc -target aarch64-linux-musl`. No
  sysroot juggling, no separate toolchain per target.
- Produces fully static binaries easily when paired with musl, which lines up with the
  "ship one binary, no install step" philosophy.
- Prefer this over installing `gcc`/`clang`/MinGW/etc. whenever a C toolchain is required.

### Go with cgo via `zig cc`

When a Go project needs cgo, compile with Zig instead of a system C compiler:

```sh
export CC="zig cc"
export CXX="zig c++"
CGO_ENABLED=1 go build ./...
```

For cross-compilation, point `zig cc` at the target through a small wrapper so cgo inherits
the target triple, e.g. for `linux/amd64` static musl builds:

```sh
# save as e.g. ~/.local/bin/zigcc-musl-amd64
#!/bin/sh
exec zig cc -target x86_64-linux-musl "$@"
```

then `CC=$HOME/.local/bin/zigcc-musl-amd64 CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build`.

This avoids the usual pain of setting up a cross C toolchain for cgo and keeps the
one-command build story intact.

## Database

Default for any persistence need: **libSQL** (the open-source fork of SQLite).

- Lightweight, modern, and embeddable — no server process required for local/embedded use.
- Wire-compatible with SQLite, so existing SQLite tooling, files, and SQL all work.
- Adds features SQLite lacks: native HTTP client/server, embedded replicas, sync with a remote
  primary, vector search, and (optionally) a managed endpoint. Take only what you need.
- Same philosophy as the rest of the stack: small footprint, minimal ops, no heavyweight
  dependency.

Fallback if libSQL is unavailable or impractical: **plain SQLite**.

Reach for a full-fledged database **only** when the workload genuinely demands it
(high concurrency writes, large multi-tenant scale, advanced replication, etc.). In that case
the preference is **PostgreSQL**. Do not default to PostgreSQL "just in case".

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
- For databases, default to **libSQL** (fall back to plain SQLite). Only reach for **PostgreSQL** when a real need for a full-fledged database exists.
- When a C/C++ toolchain is needed (Go cgo, Rust with C deps, native C/C++, cross-compiling), default to **`zig cc`** / **`zig c++`** rather than installing `gcc`, `clang`, MinGW, or a per-target sysroot.
