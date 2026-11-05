---
name: planning
description: Multi-phase implementation planning workflow. Use when building complex features that require a structured plan - multi-file work, cross-module behavior changes, data schema/interface changes, or anything likely to need 3+ commits.
---

# Applicability: Choose Planning Mode First

Use this file in one of two modes:

- **Full Planning Mode (mandatory):** Use for complex or multi-phase work.
  Use this mode when at least one is true:
  - Multi-file feature work
  - Cross-module behavior changes
  - Data schema/interface changes
  - Work likely to require 3+ commits
- **Fast Path (allowed):** Use for small, low-risk tasks.
  Typical examples:
  - Single-file bugfix
  - Docs-only edit
  - Small test-only update

Fast Path flow:
1. Clarify request and success criteria
2. Implement directly with minimal change
3. Run targeted verification
4. Summarize what changed and why

If task scope expands during Fast Path execution, immediately switch to Full Planning Mode before continuing.

# Execution authorization

Use the current user request and working agreement to determine execution and approval boundaries. A plan supplies implementation steps; it does not grant permission or select unrelated work. Existing authorization remains valid through routine planning, verification and recovery. Pause for an approval only when the required decision is not already authorized or the user explicitly requested a review gate. Autonomous selection, retry and stopping policies belong to the active working mode.

# 1. Analyze the Request
Understand the user's request, scope and success criteria. Resolve ordinary implementation questions from available project context and research. Ask the user for information that only they can supply or decisions that materially change the authorized scope. Continue independent authorized research while a required answer is pending.

# 2. Research
Research the existing codebase with a clear research brief:
- What patterns and utilities already exist in the codebase, check the repo's map if it has one (`docs/repo-map.md`, a README or the agent instructions).
- What data formats, file structures, or schemas are relevant
- What conventions (naming, testing, logging) are already established
- Any related prior code for the specific problem

# 3. Draft a Plan
Based on research findings, write a multi-phase plan (3-10 phases) following the `<plan_style_guide>` below.

Each phase must:
- Have a single, focused objective
- Define verification suited to its output. Use meaningful failing checks for changed behavior; use source evidence or document checks for discovery and documentation phases. Follow project requirements for test sensitivity and acceptance.
- Be independently committable

# 4. Present the Plan
Share the plan synopsis, material decisions and unresolved questions. Obtain approval when the current working agreement requires it and it has not already been granted. Otherwise continue within the existing authorization.

# 5. Write Plan File
Once execution is authorized, write the plan to `plans/<YYYYMMDD_HHMM>_<task-name>-plan.md`. Get the timestamp from `date +%Y%m%d_%H%M` so plans sort by creation time.

# 6. Execute Phases (repeat per phase)

For each phase:

## 6.1 Execution
Execute the task considering:
- The specific phase objective
- Relevant files and functions identified by the research step
- The tests to write (from the plan)
- Any constraints (e.g., "match the existing API/dataclasses", "use pytest fixtures already in conftest.py")
- Apply the phase's verification method and report its result

## 6.2 Verification
After execution completion, verify success considering:
- The phase objective
- Expected test outcomes
- Review uncommitted changes and return one of: `APPROVED` / `NEEDS_REVISION` / `FAILED`

## 6.3 Handle verification results
- `APPROVED`: record the completed phase and advance within authorization.
- `NEEDS_REVISION`: revise the implementation and rerun the affected checks.
- `FAILED`: preserve evidence and identify the next resolving experiment or recovery action. The active working mode decides whether to recover, change approach, discuss the result or park the work. A failed check alone does not revoke execution authorization.

## 6.4 Commits

Create commits only when authorized. When commits are part of the requested workflow, group changes at meaningful phase boundaries and use the commit style below. A commit or a proposed commit message is not an acceptance requirement for the phase itself. Do not add a user pause solely because a phase ended.

# 7. Propose PR Slices and Align with the User
When all phases are complete, look at the real diff and propose how to split it into PR slices. Do this at the end, not in the plan: fixes and other changes that nobody could foresee during planning are in the diff now.

Each slice is one PR that stands alone: it can merge by itself, tests pass, and the codebase stays consistent. Split only along those lines. Steps that only work together stay in one PR, and intermediate phases are commits inside a PR, not separate PRs. Size is a warning, not a target: over about 500 changed lines (tests, lockfiles and generated files do not count), look for a split that follows this rule. If there is none, keep one PR and give it a clear way to verify it. If the repo's agent instructions set other PR rules, they win. For each slice, give:
- A title and the commits or files it contains
- What it depends on. Slices are independent where possible. Stack a slice on another one only when it needs it.
- The changed line count
- How a reviewer can verify it, if the slice is over the size warning and cannot be split

Choose the base branch from repository context. Propose slices for the changes actually implemented. Record unrelated findings separately; they do not authorize additional fixes or PRs.

Present the proposed slices. Follow existing authorization for creating branches and PRs; request a decision when that action remains unauthorized.

# 8. Final Report
When all phases are complete, summarize the overall result in chat, including:
- Overall summary of what was built and why
- All phases completed (checklist)
- Full list of files modified/created
- Key functions/classes added
- Test coverage summary
- Recommended next steps

# 9. Update Repo Map
If the repo keeps a map (`docs/repo-map.md`, a layout list in the agent instructions, or similar), review after all code and docs changes are complete whether repository structure or ownership has changed. Update the map only if it materially changed, in its own final commit so it does not hide the real change. If the repo has no map, skip this step.

Include updates such as:
- New top-level directories or important modules introduced by the task
- Moved, renamed, or removed key paths
- Any shift in the canonical location of major workflows or entry points

If no Repo-map changes are needed, explicitly state that in the final chat summary.

---

<plan_style_guide>

File name: `plans/<YYYYMMDD_HHMM>_<task-name>-plan.md` (timestamp, then the task name in kebab-case)

```
## Plan: {Task Title (2-10 words)}

{TL;DR - what is being built, why, and how it fits the codebase. 2-4 sentences.}
**Phases ({3-10})**

1. **Phase {N}: {Phase Title}**
   - **Objective:** {Single clear goal for this phase}
   - **Files/Functions to Modify/Create:** {List}
   - **Tests to Write:** {Specific test names or descriptions}
   - **Steps:**
     1. Write failing tests for {behaviour}
     2. Run tests - confirm they fail
     3. Implement {minimal code}
     4. Run tests - confirm they pass
     5. Lint / format

**Open Questions ({1-5})**
1. {Clarifying question? Option A / Option B}
```

Rules:
- No code blocks in the plan file - describe changes in prose and reference file paths
- Include the validation channels required by the project and the behavior under test, including manual or visual review when applicable
- Keep each phase cohesive; choose its file count from the dependency structure
- When using a red/green cycle, keep its failing control and verification with the corresponding behavior change

</plan_style_guide>

<git_commit_style_guide>

Format: `<type>(<scope>): <short description>`

Types: `feat`, `fix`, `test`, `refactor`, `chore`, `docs`
Scope: module or subsystem (e.g., `annotation-parser`, `frame-matcher`, `eval`, `training`)

Body: 2-4 bullet points describing what changed and why.

Example:
```
feat(annotation-parser): add CVAT XML frame extraction

- Parse <image> tags to extract frame_id and label metadata
- Match frame_id against detection outputs by timestamp offset
- Add unit tests covering missing frames and duplicate annotations
```

</git_commit_style_guide>

---

## Constraints
- In Full Planning Mode, resolve material scope decisions under the current authorization
- In Full Planning Mode, use meaningful phase boundaries without inventing approval or commit gates
- In Full Planning Mode, you do not start execution without a research pass first
- In Full Planning Mode, record unrelated defects without expanding the implementation scope
- In Fast Path, establish scope from context and run appropriate targeted verification
