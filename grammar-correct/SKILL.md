---
name: grammar-correct
description: >
  ALWAYS RUN THIS FIRST — before processing the user's prompt or starting any task.
  Corrects English grammar, spelling, and phrasing in the user's raw message and shows two
  short natural rewrites (polite + casual). It runs as a background sub-agent fired at the
  very start of the turn, so the real task is never blocked; it replies with a single ✅
  check mark when the text is already correct. Apply on every natural-language English
  message, especially non-native. Also logs mistake categories (never message text) to a
  local state file and reports whether the user's grammar is improving or getting worse
  over time. Keywords for progress: "my grammar progress", "am I improving", "mistake
  stats", "learning progress".
  Keywords: grammar, English, spelling, typo, rewrite, rephrase, proofread, "fix my English",
  Grammarly, sentence, word choice, tense, article, preposition, agreement, punctuation,
  imperfect English.
metadata:
  author: nitpum
  version: "1.3.0"
---

# grammar-correct

**Run this BEFORE processing the user's prompt or starting any task.** It is the first step of every turn, not an optional extra.

A lightweight, **non-blocking** English grammar checker. Whenever the user writes a natural-language message, hand it to a background sub-agent for correction while you keep doing the real work. The result is a short note appended at the end of your response — never a wall of explanation.

The user values short, correction-only output. Show the fix, not the lesson.

---

## Core behavior

- **Always-on, ✅ when clean.** Check every natural-language English message. If the grammar/spelling is already correct, show a single check-mark line — nothing else.
- **Two registers.** When there are errors, give exactly two rewrites:
  - **Polite** — clear, professional but friendly. How you'd write to a colleague or acquaintance you respect. Not stiff, not slangy.
  - **Casual** — relaxed, contractions welcome, colloquial. How you'd text a friend.
- **No explanations.** No "you should use past tense because…". Just the corrected sentences.
- **Never blocks the real task.** The main agent must start the real work immediately; grammar correction happens off to the side.
- **Tracks progress locally.** Every checked message is logged as one JSON line — mistake categories and word count only, **never the message text** — to `${XDG_STATE_HOME:-$HOME/.local/state}/grammar-correct/history.jsonl`. If that path isn't writable, tracking is silently disabled; it must never warn, error, or block.

---

## The non-blocking pattern (do this every message)

Run correction as a **side task**, not inline. The main agent's job is the real task; a sub-agent handles grammar.

1. **Fire the sub-agent first.** At the very start of handling a message, launch one `Task` call (subagent type `general`) using the prompt template below, passing the user's **raw original message**.
2. **Immediately start the real task.** In the same turn, begin the actual work (Read/Grep/Bash/edits/etc.). Do **not** wait for the grammar sub-agent to finish before starting.
3. **Combine at the end.** Once the real task is done and the sub-agent has returned, append its note to the **bottom** of your final response, after the real-task output, under a `### ✍️ Grammar` heading.
4. **✅ on clean.** If the sub-agent's reply starts with `NO_CORRECTIONS`, append `### ✍️ Grammar` followed by `✅ Correct — no corrections needed.` under it.
5. **Log the data point.** Append one JSON line to the state file (see *Progress tracking* below) — categories + word count only, **never the sentence or any part of the message text**. Clean messages included. One quick `printf >>` call; if the write fails, drop it and move on. Never log skipped messages (short greetings, code, non-English).

> Why a sub-agent? It runs concurrently with the real work and keeps the main context free of grammar noise — matching the user's request to "not block the real task" and "spawn sub-agents instead of main agent".

---

## Sub-agent prompt template

Use the `Task` tool, subagent type `general`. Copy this verbatim, inserting the user's message:

```text
You are an English grammar checker. Be concise. No explanations.

Input message (may contain errors):
"""
<INSERT_USER_RAW_MESSAGE_HERE>
"""

Rules:
- If the grammar AND spelling are already correct, reply with exactly: NO_CORRECTIONS Words: <word count of the message>
  (the main agent turns this into a ✅ check-mark line for the user)
- Otherwise fix the errors and give TWO natural rewrites of the full message:
  • Polite: clear, professional but friendly — how you would write to a respected colleague.
  • Casual: relaxed, contractions OK, colloquial — how you would text a friend.
- Keep each rewrite one or two lines. Preserve the original meaning and tone of voice.
- Fix grammar, spelling, tense, articles, prepositions, word order, and agreement only.
  Do NOT censor, do NOT rewrite clean sentences, do NOT add content.
- On the final Kinds line, tag each mistake using EXACTLY this guide (fixed vocabulary —
  never invent kinds; count each error instance once):
  - tense — wrong verb time: "I go yesterday" → "went"
  - verb-form — wrong verb form, not time: "I am agree" → "I agree", "should focuses" → "should focus"
  - agreement — subject–verb person/number mismatch: "he go" → "he goes", "they was" → "were"
  - plural — noun number/countability: "some milks" → "milk", "two book" → "books"
  - article — a/an/the wrong, missing, or extra: "a advice" → "some advice", "please a privacy" → "for privacy"
  - preposition — wrong/missing/extra in/on/at/with/to/for…: "focuses in" → "focus on"
  - word-order — wrong sequence: "always I go" → "I always go", "a red big car" → "a big red car"
  - word-choice — wrong/extra/missing word not covered above: "make a photo" → "take a photo", "want to consistency" → "want consistency"
  - spelling — misspelling, including capitalization: "entirr" → "entire", "macos" → "macOS"
  - punctuation — missing/wrong , . ? ! ' " ; —: "works on macOS right" → "works on macOS, right?"
  - other — genuine error none of the above cover (use sparingly)
  Tie-breakers (apply in order): (1) verb error → time wrong? tense; form wrong? verb-form;
  subject mismatch? agreement. (2) noun number itself wrong? plural; determiner/verb
  mismatching the noun? agreement. (3) function word → article (a/an/the) or preposition
  (in/on/at/with/to…), else word-choice. Use the message's total word count for Words.

Reply in EXACTLY this format and nothing else:

✍️ Grammar
• Polite: "<rewrite>"
• Casual: "<rewrite>"
Kinds: tense×2, article×1 — Words: 18
```

---

## Output format

Append to the end of your final response — **always**, clean or not.

**When there are errors:**

```markdown
### ✍️ Grammar

- Polite: "I went to the store yesterday and bought some milk."
- Casual: "I went to the store yesterday and grabbed some milk."
```

**When the grammar is already correct:**

```markdown
### ✍️ Grammar

✅ Correct — no corrections needed.
```

One line per register (or a single ✅ line when clean). No bullet list of "mistakes found". No commentary. Done.

---

## Progress tracking (local, optional, permission-guarded)

Storage location (XDG state dir — standard place for this kind of per-user history):

```
${XDG_STATE_HOME:-$HOME/.local/state}/grammar-correct/history.jsonl
```

**Format** — one JSON line per checked natural-language message (clean ones too; they're needed to compute an error rate):

```json
{"ts":"2026-10-02T07:11:01Z","kinds":{"tense":2,"article":1},"words":18}
{"ts":"2026-10-02T07:40:12Z","kinds":{},"words":12}
```

`kinds` is empty when the message was clean. The kind vocabulary, definitions, examples, and tie-breaker rules live in the **sub-agent prompt template** above — that is the single source of truth; every sub-agent gets the same guide pasted into its prompt so tagging stays consistent. Do not edit one without the other.

**Write-permission guard** — check once per session, before the first write:

```bash
D="${XDG_STATE_HOME:-$HOME/.local/state}/grammar-correct"
mkdir -p "$D" 2>/dev/null && touch "$D/history.jsonl" 2>/dev/null || true
```

If either command fails, tracking is **off for the rest of the session**: no retries per message, no warning to the user, no effect on the real task. (Tested: read-only paths disable tracking silently.)

**Append** (after the sub-agent returns, one quick Bash call — skip entirely if tracking is off):

```bash
D="${XDG_STATE_HOME:-$HOME/.local/state}/grammar-correct"
printf '%s\n' '{"ts":"'"$(date -u +%FT%TZ)"'","kinds":{"tense":2,"article":1},"words":18}' >> "$D/history.jsonl"
```

Build the `kinds` object from the sub-agent's `Kinds:` line; use `{}` when clean (a clean message is **always** still logged — that's what makes the clean rate meaningful); take `words` from its `Words:` value (estimate with `wc -w` if missing). Only skip the log when an *error* message comes back without a `Kinds:` line.

**Privacy rules:**
- Never store the user's message text, the rewrites, or anything identifying — only `ts`, `kinds`, `words`.
- The file is local-only. Never commit it, never sync it, never paste its raw contents into a response without the user asking.

---

## Progress report (when the user asks)

Trigger: the user asks about their grammar progress — "am I improving?", "what mistakes do I make?", "mistake stats". Run the aggregation (verified working) with `jq`:

```bash
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/grammar-correct/history.jsonl"
jq -s '
  def errs: (.kinds | to_entries | map(.value) | add) // 0;
  def summ: {messages: length,
             errors: (map(errs) | add // 0),
             errorsPerMsg: (if length == 0 then 0 else ((map(errs) | add // 0) / length * 100 | round / 100) end),
             cleanRate: (if length == 0 then 0 else (map(select((.kinds|length)==0)) | length) * 100 / length | round end)};
  (now - 604800) as $c7 | (now - 1209600) as $c14 |
  {last7: (map(select((.ts|fromdateiso8601) >= $c7)) | summ),
   prev7: (map(select((.ts|fromdateiso8601) >= $c14 and (.ts|fromdateiso8601) < $c7)) | summ),
   topKinds7: (map(select((.ts|fromdateiso8601) >= $c7)) | map(.kinds) | add // {}
               | to_entries | sort_by(-.value) | .[0:5] | from_entries)}
' "$STATE"
```

Portable: uses jq's `now` instead of shell `date -d` (GNU-only, absent on macOS/BSD). Everything else (`mkdir -p`, `touch`, `printf`, `date -u +%FT%TZ`) works on macOS as-is.

If `jq` is missing, read the file and compute the same numbers inline (python3 or by hand).

**Verdict rules** (compare `last7` vs `prev7`):
- Fewer than 5 messages in either window → "not enough data yet, keep chatting".
- `errorsPerMsg` down ≥ 20% **or** `cleanRate` up ≥ 10 points → **improving 📈**.
- `errorsPerMsg` up ≥ 20% **or** `cleanRate` down ≥ 10 points → **getting worse 📉**.
- Otherwise → **stable ➡️**.

**Report format** — keep it short, appended like any other answer:

```markdown
### 📊 Grammar progress

Verdict: improving 📈 — 0.83 → 0.42 errors/message, clean rate 30% → 60% (last 7d vs prior 7d).
Top mistakes: article (6), tense (4), preposition (3).
Tip: watch your articles — "a/an/the" is your most frequent slip.
```

---

## Worked examples

**Example 1 — tense + plural**
- User message: `I goes to the store yesterday and buy some milks.`
- Sub-agent returns:
  ```
  ✍️ Grammar
  • Polite: "I went to the store yesterday and bought some milk."
  • Casual: "I went to the store yesterday and grabbed some milk."
  Kinds: tense×2, plural×1 — Words: 10
  ```
- Main agent logs: `{"ts":"<now>","kinds":{"tense":2,"plural":1},"words":10}`

**Example 2 — wrong verb form / preposition**
- User message: `I am agree with you, we should focuses in that.`
- Sub-agent returns:
  ```
  ✍️ Grammar
  • Polite: "I agree with you; we should focus on that."
  • Casual: "I'm with you — we should focus on that."
  Kinds: verb-form×2, agreement×1 — Words: 9
  ```

**Example 3 — already clean (✅)**
- User message: `See you tomorrow.`
- Sub-agent returns: `NO_CORRECTIONS Words: 3`
- Main agent appends:
  ```
  ### ✍️ Grammar
  ✅ Correct — no corrections needed.
  ```
- Main agent logs: `{"ts":"<now>","kinds":{},"words":3}`

---

## Fallback (when sub-agent/Task tool is unavailable)

If the `Task` tool cannot be used, the main agent does the correction **inline at the very end** of its response using the same format and rules above. Keep it to two lines. Never let it delay or crowd out the real task output.

---

## Gotchas

- **Don't correct code, commands, file paths, logs, or non-English text.** Only natural-language English sentences. A message like `git push` or `run npm test` needs no correction.
- **Don't correct the user mid-task in a way that interrupts.** Always append at the end, after the real answer.
- **✅ is the clean result.** If it's already correct, show the single ✅ line — nothing more. Resist the urge to offer "polishing" rewrites of clean text.
- **Meaning over pedantry.** Preserve the user's intent, dialect, and personality. Fix genuine errors; don't flatten their voice into generic textbook English.
- **Code blocks, quotes, and pasted content inside the user's message are not theirs to fix** — skip quoted/pasted regions and only correct the user's own prose.
- **Short messages** (one or two words, greetings like "hi", or pure punctuation) → skip silently.
- **Tracking is best-effort.** If the state dir isn't writable, disable logging for the session — don't retry every message, don't mention it, don't let it touch the real task.
- **Never log message text.** Only `ts`, `kinds`, `words`. `history.jsonl` stays on the user's machine — never commit it to any repo.
- **Don't force a progress report.** Only show 📊 stats when the user asks for them.
- **Tag with the fixed guide only.** Never invent new kinds or reclassify mid-conversation — consistency of the categories is what makes the stats meaningful over time.
