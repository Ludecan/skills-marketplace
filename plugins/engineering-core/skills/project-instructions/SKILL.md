---
name: project-instructions
description: How to create or fix a project's agent instructions file, `AGENTS.md`. Use when a repo has no `AGENTS.md` file, when it lacks a repo map, commands or search scope, or when the user asks to set up or audit it. The other engineering-core skills (`planning`, `human-review-helper`, `write-pr-description`) expect this structure.
---

# Project instructions

The skills in this plugin read the repo's instructions file for the repo map, the commands, the PR rules and the search scope. Without that structure they cannot work. The file is the only place for the repo map: not a `docs/` file, not the README.

## Which file

- The instructions live in `AGENTS.md` at the repo root. All the content goes there.
- `CLAUDE.md` at the repo root holds only the line `@AGENTS.md`, so Claude Code reads the same text. It has no other content.
- If a repo has its instructions in `CLAUDE.md` or `.claude/CLAUDE.md`, move the content to the root `AGENTS.md`. Then make the root `CLAUDE.md` hold only the import line, and delete `.claude/CLAUDE.md`. An import resolves relative to the file that contains it, so a nested file must use `@../AGENTS.md`.
- Keep one source. Never copy the content into two files.

## Structure

Follow [the template](assets/AGENTS.template.md). Sections, in this order:

1. **Project overview**: what the repo does and its stack, in 3-6 lines.
2. **Repo map**: every directory and key file with one line on its role. Update it when the structure changes.
3. **Repo map updates**: the rule to update the map in its own final commit.
4. **Commands**: how to install, run, test and lint. Real commands only.
5. **Small, focused PRs**: the PR rules in the template. Keep them as written; `planning` follows them.
6. **Search scope**: directories and tools that are large or noisy, and how to exclude them.
7. **Gotchas**: project-specific pitfalls, quirks, or non-obvious behaviors that agents should be aware of, so they don't need to be rediscovered each time.

Additional sections are allowed, but these must exist.

## Rules

- Write only what the agent cannot see from the code. No style rules that a linter enforces.
- Do not repeat what a skill already says. Do not add sections that tell the agent to use `write-good-code`, `planning` or another skill: their descriptions already do that.
- Project rules that are not about structure go in the repo's `code-conventions` skill, not here.
- Keep the file short. It loads on every turn, so a long map costs context each time. Trim detail that a directory listing shows.

## Setting up a repo

1. Read the repo: top-level tree, README, `pyproject.toml` or build files, the Makefile, CI config.
2. Fill the template from what you found. Ask the user only for what you cannot find, for example gotchas.
3. Check every path and command in it exists or runs.
4. Show the file to the user before committing it.
