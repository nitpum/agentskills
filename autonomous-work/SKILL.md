---
name: autonomous-work
description: >
  General-purpose protocol for autonomous task execution without human interaction.
  Use when the user wants to run a task autonomously, go hands-off, delegate work to be done
  without follow-up questions, or mentions "autonomous", "hands-off", "unattended", "go ahead",
  "just do it", or "don't ask me". Enforces a strict two-phase approach: a pre-flight phase
  where all questions and verifications happen, followed by an execution phase with zero
  user interaction.
metadata:
  author: nitpum
  version: "1.0.0"
---

# Autonomous Work — Zero-Interaction Task Protocol

This skill enforces a strict two-phase protocol for tasks that must run without human interaction after kickoff. The user will be present during planning but unreachable during execution.

## Overview

```
Phase 1: PRE-FLIGHT (interactive)     Phase 2: EXECUTION (autonomous)
┌──────────────────────────┐          ┌──────────────────────────┐
│ 1. Understand the task   │          │ 1. Execute plan steps    │
│ 2. Ask all questions     │   ───►   │ 2. Self-resolve blockers │
│ 3. Verify tools/perm     │          │ 3. Validate work         │
│ 4. Present plan          │          │ 4. Report results        │
│ 5. Get user approval     │          │                          │
└──────────────────────────┘          └──────────────────────────┘
     User is available                     User is unreachable
```

---

## Phase 1: Pre-Flight (Interactive)

You **must** complete every step below before starting any work. Do not skip or abbreviate.

### Step 1: Understand the Task

Extract and restate your understanding of:
- **Goal**: What is the end state the user wants?
- **Scope**: What files, systems, or domains are involved?
- **Deliverables**: What concrete outputs are expected?
- **Constraints**: Time limits, style requirements, must-not-do rules
- **Definition of Done**: How will the user (or you) know the task is complete?

If any of these are unclear, formulate specific questions.

### Step 2: Ask All Questions

Ask the user every question that could possibly arise during execution. Think through the entire task end-to-end and surface ambiguities now. Categories to consider:

- **Ambiguous requirements**: Multiple valid interpretations? Ask which one.
- **Missing context**: Need credentials, paths, environment details, version info?
- **Design decisions**: Multiple approaches possible? Present options with a recommendation.
- **Edge cases**: What should happen if X fails? If Y is empty? If Z already exists?
- **Preferences**: Code style, naming conventions, test framework, output format?
- **Scope boundaries**: Should I also fix X while I'm there? Handle Y edge case?

Present questions in a single structured list using the question tool. Do not ask one question at a time.

### Step 3: Verify Tools, Permissions, and Environment

For every tool, command, API, or resource the task requires, verify access **before** starting work. Check:

- **Command availability**: Run `which <cmd>` or `command -v <cmd>` for every CLI tool needed.
- **File permissions**: Read/write access to all target files and directories.
- **Network access**: If the task needs to fetch resources or call APIs, test connectivity.
- **Disk space**: For tasks that generate large outputs, verify available space with `df -h`.
- **Authentication**: If credentials or tokens are needed, verify they exist and work.
- **Package availability**: If installing packages, verify the package manager works and the package exists.
- **Container runtime**: If using podman/docker, verify the daemon is running.
- **Opencode permission gates**: When running inside opencode, certain actions require user approval that will block autonomous execution. Specifically check:
  - File paths outside the current workspace — test that you can read/write them without an approval prompt.
  - Bash commands targeting external directories — verify they do not trigger approval.
  - Network requests (URL fetches, API calls) — confirm they are not gated.
  - Destructive or system-modifying commands — check if they require approval.
  - Test every tool call pattern you plan to use during execution to confirm it works without interactive approval.

If **any** verification fails, report the failure to the user and ask for resolution before proceeding. Do not assume you can fix it during execution.

### Step 4: Present the Execution Plan

Write a numbered plan showing every step you will take. Each step should be:

- **Concrete**: Specific files, specific commands, specific outputs.
- **Ordered**: Dependencies between steps are clear.
- **Validated**: Include a verification step where applicable (e.g., "run tests after edit").

Present the plan and ask the user to approve it. Use a single yes/no question.

### Step 5: Get Explicit Approval

Do not start execution until the user explicitly approves the plan. If the user suggests changes, update the plan and re-present.

Once approved, announce the transition:

> Entering autonomous mode. No further questions will be asked. Starting execution.

---

## Phase 2: Execution (Autonomous)

During this phase the user is unavailable. Follow these rules:

### Rule 1: Never Ask the User Questions

If you encounter ambiguity, make the best decision based on available context. Document your reasoning in your output.

### Rule 2: Self-Resolve Blockers

When something unexpected happens:

1. **Assess**: Can I solve this with available tools and information?
2. **Search**: Look at existing code, docs, error messages, and logs for clues.
3. **Try**: Attempt the most reasonable fix.
4. **Alternative**: If the fix fails, try the next best approach.
5. **Skip and continue**: If a sub-task is truly blocked, skip it, document the blocker, and proceed with the rest of the plan.
6. **Abort**: Only abort the entire task if a critical blocker makes the main goal impossible.

### Rule 3: Validate Every Step

After each meaningful action, verify the result:

- **Code edits**: Run linting, type checking, or formatting tools if available.
- **Test changes**: Run the relevant test suite.
- **File operations**: Verify the file exists and has expected content.
- **Command outputs**: Check exit codes and stderr.

If validation fails, fix the issue immediately and re-validate before moving on.

### Rule 4: Track Progress

Maintain a running todo list. Update the status of each step as you work. If steps are added or removed during execution, reflect that.

### Rule 5: Document Deviations

If you deviate from the approved plan (different approach, skipped step, extra step), note:
- What you changed
- Why you changed it
- What the outcome was

### Rule 6: Handle Partial Completion Gracefully

If the task cannot be fully completed:
- Complete everything that can be completed.
- Clearly list what was done and what was not.
- For each incomplete item, explain the blocker and suggest how the user could resolve it.

---

## Completion Report

When finished (whether fully successful or partially), output a structured report:

```
## Autonomous Task Report

**Status**: COMPLETE | PARTIAL | FAILED
**Goal**: <original goal>

### What was done
- <step 1 result>
- <step 2 result>
- ...

### What was not done (if any)
- <item>: <reason>

### Deviations from plan (if any)
- <deviation>: <reason>

### Verification
- <check 1>: PASS/FAIL
- <check 2>: PASS/FAIL

### Follow-up actions for user (if any)
- <action item>
```

---

## Gotchas

- The pre-flight phase exists because **during execution the user cannot help you**. Over-invest in pre-flight rather than under-invest.
- Interactive commands (prompts, `sudo`, confirmation dialogs) will hang in autonomous mode. Always use non-interactive flags (`-y`, `--yes`, `--no-input`, etc.).
- Package managers may prompt for input even with flags. Test the exact command in pre-flight.
- Git operations that require credentials will fail. Verify SSH keys or tokens are configured.
- Commands that open editors (`git commit` without `-m`, `crontab -e`) will hang. Use non-interactive alternatives.
- Long-running commands may time out. Use timeout-aware execution and consider backgrounding with status checks.
- If the task scope is very large, consider breaking it into sub-tasks with individual validation checkpoints rather than one monolithic execution.

### Opencode Permission Approval Traps

When running inside **opencode**, certain tool calls and commands require explicit user approval. During autonomous execution the user is unreachable, so **any approval prompt will block and hang indefinitely**. You must anticipate and avoid these during pre-flight:

- **File access outside workspace scope**: Reading, writing, or editing files outside the current workspace directory may trigger a user approval prompt. During pre-flight, identify every external path the task needs and either (a) get the user to pre-approve access, (b) rework the plan to stay within the workspace, or (c) explicitly warn the user that autonomous execution will block on approval.
- **Bash commands to external directories**: Running commands that target paths outside the workspace (e.g., `cp /workspace/file /etc/config`) can trigger approval. Use `workdir` parameter for directory changes and keep all operations within workspace boundaries when possible.
- **Network requests**: Fetching URLs or calling external APIs via tools may require approval. If the task needs network access, verify during pre-flight that the specific URLs or domains will not trigger an approval gate.
- **Destructive or privileged commands**: Commands like `rm -rf`, `sudo`, `chmod`, `pip install` (system-wide), or any operation that modifies system state may require approval. Always prefer non-destructive alternatives and scoped operations.
- **Tool calls with approval gates**: Some tool calls (e.g., Write to new files outside known directories, Bash with certain command patterns) may be gated. During pre-flight Step 3, **test every tool call pattern** you plan to use during execution to confirm it does not require interactive approval.
- **Pre-flight mitigation**: During Step 3 (Verify Tools, Permissions, and Environment), explicitly list every file path, URL, and command that falls outside normal workspace scope. For each one, either confirm it is pre-approved or ask the user to grant approval before execution begins.

**Rule of thumb**: If there is any doubt about whether a tool call or command will require approval, assume it will. Either avoid it, pre-approve it, or flag it as a risk in the plan.
