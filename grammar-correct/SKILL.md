---
name: grammar-correct
description: >
  ALWAYS RUN THIS FIRST — before processing the user's prompt or starting any task.
  Corrects English grammar, spelling, and phrasing in the user's raw message and shows two
  short natural rewrites (polite + casual). It runs as a background sub-agent fired at the
  very start of the turn, so the real task is never blocked; it replies with a single ✅
  check mark when the text is already correct. Apply on every natural-language English
  message, especially non-native.
  Keywords: grammar, English, spelling, typo, rewrite, rephrase, proofread, "fix my English",
  Grammarly, sentence, word choice, tense, article, preposition, agreement, punctuation,
  imperfect English.
metadata:
  author: nitpum
  version: "1.1.0"
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

---

## The non-blocking pattern (do this every message)

Run correction as a **side task**, not inline. The main agent's job is the real task; a sub-agent handles grammar.

1. **Fire the sub-agent first.** At the very start of handling a message, launch one `Task` call (subagent type `general`) using the prompt template below, passing the user's **raw original message**.
2. **Immediately start the real task.** In the same turn, begin the actual work (Read/Grep/Bash/edits/etc.). Do **not** wait for the grammar sub-agent to finish before starting.
3. **Combine at the end.** Once the real task is done and the sub-agent has returned, append its note to the **bottom** of your final response, after the real-task output, under a `### ✍️ Grammar` heading.
4. **✅ on clean.** If the sub-agent returns `NO_CORRECTIONS`, append `### ✍️ Grammar` followed by `✅ Correct — no corrections needed.` under it.

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
- If the grammar AND spelling are already correct, reply with exactly: NO_CORRECTIONS
  (the main agent turns this into a ✅ check-mark line for the user)
- Otherwise fix the errors and give TWO natural rewrites of the full message:
  • Polite: clear, professional but friendly — how you would write to a respected colleague.
  • Casual: relaxed, contractions OK, colloquial — how you would text a friend.
- Keep each rewrite one or two lines. Preserve the original meaning and tone of voice.
- Fix grammar, spelling, tense, articles, prepositions, word order, and agreement only.
  Do NOT censor, do NOT rewrite clean sentences, do NOT add content.

Reply in EXACTLY this format and nothing else:

✍️ Grammar
• Polite: "<rewrite>"
• Casual: "<rewrite>"
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

## Worked examples

**Example 1 — tense + plural**
- User message: `I goes to the store yesterday and buy some milks.`
- Sub-agent returns:
  ```
  ✍️ Grammar
  • Polite: "I went to the store yesterday and bought some milk."
  • Casual: "I went to the store yesterday and grabbed some milk."
  ```

**Example 2 — wrong verb form / preposition**
- User message: `I am agree with you, we should focuses in that.`
- Sub-agent returns:
  ```
  ✍️ Grammar
  • Polite: "I agree with you; we should focus on that."
  • Casual: "I'm with you — we should focus on that."
  ```

**Example 3 — already clean (✅)**
- User message: `See you tomorrow.`
- Sub-agent returns: `NO_CORRECTIONS`
- Main agent appends:
  ```
  ### ✍️ Grammar
  ✅ Correct — no corrections needed.
  ```

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
