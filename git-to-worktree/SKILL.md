---
name: git-to-worktree
description: Converts a normal (non-bare) Git repository into a bare repository plus linked Git worktrees, preserving all local branches, tags, stashes, and reflogs. Use when the user wants to restructure an existing repo into a bare + worktree layout (one directory per branch), mentions git worktree conversion, bare repo with worktrees, converting a repo to worktrees, multi-branch checkout setup, or wants multiple branches checked out side-by-side without losing stashes or local-only branches.
---

# git-to-worktree

Convert a normal cloned Git repository into a **bare repo + linked worktrees**:

```
project/
├── .git/        # bare repository (shared object + ref store)
├── main/        # linked worktree on branch main
├── featureA/    # linked worktree on branch featureA
└── featureB/    # linked worktree on branch featureB
```

## When to Use

- User wants a bare repo + worktree layout for an existing repo.
- User wants multiple branches checked out side-by-side in sibling directories.
- User mentions converting/transforming a repo into worktrees, or "bare repo with worktrees".
- User explicitly needs local-only branches and stashes preserved through the conversion.

## Core principle (read before acting)

- `git clone --bare` does **not** carry local-only branches, and **never** carries stashes (stashes live in `refs/stash`, which clone ignores).
- So the conversion must **reuse the real `.git` directory**, not re-clone. Branches (`refs/heads/*`), tags, stashes (`refs/stash` + reflog), and all reflogs live inside `.git`, so moving `.git` preserves everything.
- The conversion is just: move `.git` into the new container → flip `core.bare=true` → `git worktree add <dir> <branch>` per branch.

## Procedure

Given a non-bare source at `SRC` and a new container at `DEST`:

```bash
# 0. Backup (cheap insurance)
cp -a SRC SRC.bak

# 1. Create the container
mkdir -p DEST

# 2. Move the real .git into it (carries branches/tags/stashes/reflogs)
mv SRC/.git DEST/.git

# 3. Convert to bare
git --git-dir=DEST/.git config core.bare true
git --git-dir=DEST/.git config --unset core.worktree 2>/dev/null || true
rm -f DEST/.git/index          # drop stale index from the non-bare days

# 4. Create one worktree per branch
cd DEST
git worktree add main      main
git worktree add featureA  featureA
git worktree add featureB  featureB
```

Resulting layout matches the diagram above. The orphaned source tree (`SRC/`, now without `.git`) can be deleted once verified: `rm -rf SRC`.

## Verify nothing was lost

```bash
git --git-dir=DEST/.git worktree list          # bare repo + N linked worktrees
git --git-dir=DEST/.git for-each-ref refs/heads # all local branches present
git -C DEST/main stash list                     # stashes survived (shared refs)
```

Recover a stash from any worktree: `cd DEST/main && git stash pop`.

## Workflow

- [ ] Confirm `SRC` is non-bare: `git -C SRC rev-parse --is-bare-repository` → `false`.
- [ ] Capture the current branch: `git -C SRC symbolic-ref --short HEAD`.
- [ ] List local branches to decide worktrees: `git -C SRC for-each-ref --format='%(refname:short)' refs/heads/`.
- [ ] Make a backup of `SRC`.
- [ ] Run the procedure (move `.git`, set bare, `worktree add` per branch).
- [ ] Verify branch/tag/stash counts are unchanged.
- [ ] Delete the orphaned `SRC` tree if no uncommitted changes remain there.

## Gotchas

- **Stashes are shared refs** (`refs/stash` is not per-worktree). They survive the move and are visible from every worktree; `git stash pop` works from any of them.
- **"already checked out" on the default branch**: after flipping to bare, the bare repo's HEAD still symrefs the old default branch. Modern Git treats a bare main worktree as *not* holding a checkout, so this usually doesn't trigger. If it does, either pass `--force` to that `worktree add` (safe here — there are no other worktrees yet), or detach/redirect the bare HEAD first: `git --git-dir=DEST/.git symbolic-ref HEAD refs/heads/<other-branch>`.
- **Uncommitted working-tree changes are NOT in `.git`** and stay behind in `SRC/` once `.git` is moved. Commit or stash them first, or copy them into the new worktree manually before deleting `SRC`.
- **Running git from the container root**: `DEST/` contains a `.git`, so running git commands from `DEST/` itself latches onto the bare repo ("bare repository"). Do real work inside the worktree subdirectories (`DEST/main/`, etc.).
- **Submodules**: worktree + submodule support is incomplete upstream. `.git/modules` stays in the bare dir; submodule checkouts need separate handling per worktree — out of scope for this skill.
- **Idempotency**: refuse an existing `DEST`. Remove it (or pick another path) to re-run.
- Requires Git ≥ 2.5 for `worktree add` (≥ 2.20 recommended).

## Adding / removing worktrees later

```bash
cd DEST
git worktree add featureC featureC   # add
git worktree remove featureB         # remove (keeps the branch)
git worktree prune                   # clean stale admin entries
```
