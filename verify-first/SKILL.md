---
name: verify-first
description: >
  Always research and verify before answering — never answer version-sensitive or
  time-sensitive facts from trained knowledge or memory, which may be outdated.
  Search the internet first for the latest data, and when possible run or test the
  thing directly (strongest evidence). Use for any question about software versions,
  APIs, syntax, CLI flags, config defaults, prices, release dates, current events,
  "latest/current/newest" anything, deprecations, error messages, or when the user
  asks to check, confirm, or verify a fact. Also use before recommending libraries,
  commands, or solutions. Keywords: verify, verify-first, confirm, latest, current,
  version, outdated, up-to-date, check first, research, test it, prove it.
---

# verify-first

Trained knowledge has a cutoff and goes stale. Confidently reciting an outdated version,
flag, price, or API is worse than taking a moment to verify. **Never present recalled
facts as current — verify first, then answer.**

## Core rule

Before stating any fact that can change over time, climb this ladder and stop at the
first step that settles it (highest confidence first):

1. **Run it** — if the claim can be tested locally, run it. A direct execution is the
   strongest possible evidence.
2. **Read local ground truth** — the actual files on disk beat memory: read the real
   source file, `package.json`/`go.mod`, `--help` output, config, logs, changelogs in
   the repo.
3. **Search the internet** — for anything external or time-sensitive, fetch current
   data from authoritative sources (official docs, release/CHANGELOG pages, package
   registries: npm/pkg.go.dev/PyPI/crates.io, vendor status pages).
4. **Answer from memory — labeled** — absolute last resort. Say explicitly that the
   answer is unverified and may be outdated.

## What to verify (never trust recall for these)

- Software versions, release dates, "latest" anything, end-of-life/deprecation status
- CLI flags, config options, default values — they change between versions
- API signatures, SDK behavior, error messages, status codes
- Prices, quotas, rate limits, availability of services
- Current events, statistics, anything with a date attached
- Install instructions and system requirements

## How to verify quickly

Prefer the cheapest decisive check:

```bash
# Does the command exist? What version? What flags?
<cmd> --version
<cmd> --help

# What does this code actually do? Run it, don't recall it.
node -e 'console.log(process.version)'
go version

# What's actually installed in this project?
cat package.json go.mod requirements.txt pyproject.toml
```

For external facts, fetch the authoritative source, not a blog post:

- Official docs / CHANGELOG / releases page of the tool in question
- Package registries (`https://registry.npmjs.org/<pkg>/latest`, pkg.go.dev, PyPI, crates.io)
- Vendor status/pricing pages

Prefer sources dated within the last year; note the date of the source you used.

## When verification can be skipped

- Pure logic, math, definitions, stable fundamentals (e.g. language syntax that has
  been stable for a decade)
- The user's own code or context — but still read the actual files rather than
  recalling them
- Pure opinion or preference questions

Even then: local files beat memory, and if a quick check is trivially cheap, do it.

## Answering after verification

State what was verified and how, so the user can trust (or re-check) it:

- "Verified by running: `node --version` → v22.x"
- "Per the official docs (fetched 2026-10-16): ..."
- If you could NOT verify: "Unverified — from memory, may be outdated."

## Gotchas

- Confidence ≠ correctness. The most dangerous answers are fluent, confident recall of
  an old version or removed flag — always suspect your own memory on changeable facts.
- Blogs, forum posts, and AI-generated content age badly. Prefer primary sources and
  check the publish date; a 2022 tutorial is not "current" documentation.
- Running beats searching: if a 2-second local run settles the question, don't do a
  web search first.
- Don't over-verify: one authoritative source or one direct run is enough. Don't block
  trivial answers on endless research — match verification depth to the risk of being
  wrong.
- If offline or the fetch fails, say so and clearly mark the answer as unverified
  instead of presenting recall as fact.
- Distinguish "verified locally on this machine" (may differ from the user's target
  environment) from "verified against official docs" — they answer different questions.
