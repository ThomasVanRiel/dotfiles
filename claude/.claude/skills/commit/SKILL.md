---
name: commit
description: "Commit staged/unstaged changes to git with an auto-generated message based on diffs and recent commit history."
user-invocable: true
disable-model-invocation: true
model: claude-haiku-4-5-20251001
allowed-tools: "Bash, Read"
argument-hint: "[optional message hint]"
---

# Git Commit

Generate a commit message from the current diff and recent commit log, then commit.

## Instructions

1. Run the following commands in parallel to gather context:
   - `git diff --staged` to see staged changes. If empty, also run `git diff` for unstaged changes.
   - `git log --oneline -15` to see recent commit message style and history.
   - `git status --short` to see the full picture of changed/untracked files.

2. If there are no staged changes but there are unstaged changes, stage all modified (tracked) files with `git add -u` before proceeding. Do NOT stage untracked files automatically — list them and ask the user if they should be included.

3. If there are no changes at all (nothing staged, nothing unstaged), inform the user and stop.

4. Analyze the diff and the recent commit log. Draft a commit message that:
   - Follows the style/conventions visible in the recent log (e.g. conventional commits, imperative mood, lowercase, etc.)
   - If no clear convention exists, use a short imperative summary line (max 72 chars) and optionally a body separated by a blank line with bullet points for notable details.
   - Focuses on **why** the change was made, not just **what** changed.
   - If the user provided an argument (`$ARGUMENTS`), incorporate it as a hint for the message intent.

5. Show the proposed commit message to the user and ask for confirmation before committing.

6. Create the commit using a heredoc to preserve formatting:
   ```
   git commit -m "$(cat <<'EOF'
   <message here>
   EOF
   )"
   ```

7. After committing, run `git status` to confirm success and show the result.

## Rules

- NEVER use `git add .` or `git add -A` — only stage tracked files with `git add -u`, or ask about untracked files.
- NEVER amend a previous commit unless the user explicitly asks.
- NEVER push to remote unless the user explicitly asks.
- NEVER skip pre-commit hooks (no `--no-verify`).
- If a pre-commit hook fails, show the error, fix if possible, re-stage, and create a NEW commit (do not amend).

