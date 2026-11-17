# <Project name>

## Project overview

<What the project does, in 2-4 lines.>

**Stack:** <languages, frameworks, tools>

This AGENTS.md file is kept intentionally lean. Avoid cluttering with instructions and use progressive disclosure when context starts to grow.

## Repo map

```
<dir>/             <role of the directory>
  <file>           <what it does>
<dir>/
```

## Repo map updates

Whenever a substantial code modification has been implemented, or an outdated repo map is detected while exploring the codebase, edit the repo map for review. Put the repo map edit in its own final commit, so it does not hide the real change.

## Commands

```
<install command>
<run command>
<test command>
<lint command>
```

## Small, focused PRs

Reviewers must be able to read a PR in one sitting and quickly understand intent in a diagonal read of its PR message. Follow these rules:
- One PR does one thing, and it stands alone: it can merge by itself, tests pass, and the codebase stays consistent. It either adds useful behavior or is a no-op preparation (for example, a refactor).
- Split only along those lines. Steps that only work together stay in one PR. For example, "add function `f`", "switch callers to `f`" and "remove old `g`" are one PR. Intermediate phases are commits inside a PR, not separate PRs.
- Size is a warning, not a target. If the work is heading over about 500 changed lines (tests, lockfiles and generated files do not count), stop and discuss with the user at the next natural pause. At the end of the task, propose the PR slices and agree on them with the user before you create any branch or PR. Look for a split that follows the rule above. If there is none, keep one PR and give it a clear way to verify it (see the PR description skill).
- Make the smallest change that works. Stay inside the task and do not break what already works.
- Do not add dependencies, renames, refactors or new abstractions that weren't asked for.
- If you find a bug or a cleanup need outside the task, write it down and tell the user. Do not fix it in the same branch. It gets its own PR.
- Put fixes, refactors, renames and formatting in their own PR, ahead of the behavior change. Branch it from the target branch of the PR (usually `main`) so it can merge first. If the fix cannot be separated cleanly, say so in the PR description.
- Before you finish, run `git diff --stat <target-branch>` and check that every changed file traces to the task. Revert or split out the rest.
- Back up before you delete or overwrite anything that git does not track.

## Search scope

<Directories that are large or noisy (dependency installs such as `.venv` or `node_modules`, data, outputs, logs), which ones the search tool skips on its own, and the exclude flags to pass to `grep -r`, `find` or `ls -R`. Fill this section with the folders of this repo. If there are none, write "None".>

## Gotchas

<Project-specific traps the code does not show. If there are none, keep this section empty and add a note for filling as they appear.>
