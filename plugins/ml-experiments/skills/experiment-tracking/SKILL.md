---
name: experiment-tracking
description: Disciplined experiment tracking for ML training and model benchmarks - run records, naming, reproducibility, comparison tables, promotion, and unattended grid runs. Use when running, comparing or logging experiments, when asked why a result is not reproducible, or when bootstrapping tracking in a project. Needs the project's experiment profile.
---

# Experiment Tracking

An experiment that no one can reproduce is not a trustworthy result. Tracking is not overhead: it is the minimum viable scientific practice. Without it, a promoted model or config can misbehave and no one can reconstruct where it came from.

The agent that runs an experiment writes the record itself, from the run's own outputs, and updates the comparison table itself. Never ask a human to transcribe numbers, and never hand-guess them.

## Glossary

- **Track**: one hypothesis or investigation, with one question to answer (for example "does dropping low-variance features hurt churn?"). Everything about a track lives in one folder, `<root>/<YYYYMMDD_HHMM>_<track>/`. The timestamp is when the track was opened, so folders sort in the order the work happened. `<track>` is a short kebab-case name without a date. `<root>` is `experiments/` unless the profile says otherwise.
- **Variant**: one configuration under test inside a track. The first variant is the baseline. Every other variant differs from the baseline by one variable. A variant has one short permanent name, `N-<name>`: `N` is its position in the track's sequence (`1-` is the baseline) and `<name>` says what it changes (`1-baseline`, `2-drop-low-variance`, `3-k_t24_poll`). The numbers make the file order tell the story of the investigation. That name is the variant's folder, the prefix of its record file and its row id in `COMPARISON.md`. A variant is never renamed, and its name and number are never reused for a different config.
- **Run**: one execution of a variant. A repeat or a corrected run of the same config is a new run with its own suffixed name (`<variant>_r2`) and its own record. The variant's row in `COMPARISON.md` holds its last valid run (Step 4).
- **Run name**: `<track>/<variant>`, or `<track>/<variant>_r2` for a repeat. It identifies a run in the record header and whenever the run is quoted outside the repo.
- **Run record**: `<variant>_run_record.md`, one per run (Step 1).
- **`COMPARISON.md`**: one per track, the reader's view: verdict, one comparison table, findings and dated notes (Step 4). Start from `assets/COMPARISON.template.md`.

## The experiment profile (read first)

This skill is the shared procedure. Everything that depends on the project lives in the repo's **experiment profile**: a small repo-local skill named `experiment-profile`. Load it before any step of the experiment. Where the profile and this skill disagree, the profile wins.

If the repo has no `experiment-profile` skill, do not guess metrics, paths or table columns. Write the profile with the user first. It must answer:

1. Layout: the `<root>` folder for tracks and where each variant's config file sits inside its track folder.
2. Run record: the exact template and the fields specific to this domain (metrics, artifacts, environment).
3. Metric protocol: primary and auxiliary metrics, and the evaluation set or bench parameters.
4. Provenance: how code identity is recorded (git SHA, or binary paths and image tags when the code is not in git) and the reproducibility tolerance.
5. Comparison document: path, the full comparison table columns, row identity, the report script if one exists. Write the columns out exactly: every column name in order, with its unit, the source of its value and how it aggregates (mean, peak, final). The table is the same in every track, so the columns are never "as in the source tracks". The profile lists the columns between the standard ones (Step 4).
6. Promotion: what "promoted" does (copy a config, export a model, update a summary file).
7. Domain rules and pitfalls that have already bitten this project.
8. Commands and scripts: record and report generators, grid drivers.

## Operating procedure

Follow the steps in order. The record (Step 1) must exist before naming (Step 2) matters. Reproducibility (Step 3) is unenforceable until the record captures seeds, commands and environment. Conclusions (Step 4) are only trustworthy if Steps 1-3 hold.

### Step 0: Plan the track before the first run

Write the plan where the profile says (an experiment spec file, or the top of `COMPARISON.md`) before any run starts. It holds:

- Goal, and the claim or baseline under test (quote an external claim verbatim).
- The frozen setup: engine or code version, data, hardware, flags. Include the commands that built it, not a link to install docs.
- The baseline: the latest valid champion for the same target, copied with its source name and marked `reference`, or a new base run. Check at the start of each track that it is still the champion, and ask the user only when none can be found. Record the engine or code version and the artifact revision. Re-measure the baseline when the metric is noisy or the rig has changed.
- The variants, in order, with the one variable each changes from the baseline. `1-` is the baseline row, copied or measured.
- The decision rule: the decision criterion of Step 4, including the threshold, and the baseline repeat for a noisy metric (Step 3).
- Predictions, if any, labelled as predictions and not results.

When the plan changes (a variant added, a decision made), update it and date the change in the notes. A change to the frozen setup ends the series (Step 3).

### Step 1: Write the run record

Inconsistent logging is as bad as no logging. For every run, the agent generates the record from the run's own output files. One record plus the logs must be enough to reconstruct the run. Start from `assets/run_record.template.md`; a script may generate the same fields. Capture:

- Config: every value that affects the result, in one config file or one recorded command. No defaults in code: a default can drift between library versions and change results silently. One commit hash plus that config or command must be enough to reproduce the run.
- Command: the exact command that reproduces the run, fully expanded and copy-pasteable, with its working directory and every environment override. When a wrapper script assembles the command, record both the wrapper invocation and the expanded command it produced: wrappers fill in defaults and drift silently. A run without a recorded command is not a run.
- Code: the git commit SHA. Fail the run if the working tree is dirty, and record any override. If part of the code is not in git, the profile says what to record instead.
- Also: identity (run name, date and time), the data or model under test (name, path, version or hash, splits), environment facts that differ from the defaults, the profile's metrics with the evaluation set named, and artifacts (the root output folder and the exported or promoted files, not every intermediate checkpoint).
- Anomalies: crashes, watchdog kills, OOM retries, interference. An anomalous run gets a note in the record, not silence. A phase that wrote bad values stays in the record and is not a result; the real measurement is a new `_rN` run.
- Outcome: `reference` (the baseline only), `promoted`, `rejected` or `inconclusive`, filled by the agent when the series is judged. A rejected run names the number that rejects it.

A track folder holds the configs, records and comparison of one track together, so a config is tied to the track it was written for:

```
<root>/<YYYYMMDD_HHMM>_<track>/
├── COMPARISON.md                 # one per track
├── <variant>.yaml                # a variant's config file, where the profile places it
└── <variant>/
    └── <variant>_run_record.md   # one record per run
```

The variant folder is the whole raw trail of that variant: the record, the serve or training log, the raw result files, monitor output and any `REFERENCES.md`. The profile decides whether the config sits in the variant folder or beside it. Do not write raw results to a file shared by every track: a shared key can collide across tracks and a re-patch can pick the wrong row.

### Step 2: Name and organize

Names are the index. Bad names make the tracker useless.

- Group runs into tracks by hypothesis. Never group by date or author: the hypothesis is the unit of learning, and the timestamp prefix only sorts track folders.
- A logged run is immutable: a wrong record stays, and a corrected run gets a new `_rN` name. Never reuse a name or a retired variant number.
- One variable per variant. A run that changes two things measures neither.
- An experiment owns a copy of every config it runs. Never run or edit a shared production config from an experiment, and never point at another experiment's output directories: copy the config into the track folder first.
- Number variants in the order they are created. Compare every variant against the baseline.
- Bad: `final_model_v2_new_ACTUALLY_FINAL`. It has no hypothesis and no lineage, and it invites reuse. Good: `feature-selection/2-drop-low-variance` (track `feature-selection`, variant `2-drop-low-variance`).

### Step 3: Enforce reproducibility

- A run is reproducible when the recorded command or config reconstructs it exactly. For seeded training, a re-run must land within the tolerance. Set the tolerance in the profile. Default: 0.5 percent relative difference on the primary metric. Looser than 2 percent means the run is non-deterministic: find unseeded operations, non-deterministic kernels or unstable data ordering.
- Dataset splits are deterministic and reproducible from the config alone. Use the project's existing split and hashing scheme; where there is none, hash a stable ID into buckets, which survives dataset growth.
- Freeze the setup before a series. If an engine, image or dependency must change mid-series, end the series and start a new one.
- When the profile gives no tolerance (throughput, latency and other noisy measurements), run a baseline repeat (`1-<name>_r2`), which keeps its own row, and use the spread of the two rows as the noise floor. A variant differs from the baseline on a cell only when it lands outside that spread. A change inside the tolerance or the noise floor, or a cell within the spread of a decision threshold, is `inconclusive` and gets an `_rN` run before the decision.

### Step 4: Compare and decide

Tracking only has value when it drives decisions.

- Define the decision criterion before the experiment starts: outcomes, their priority, the evaluation set or bench parameters, and the thresholds. It follows the stated goal. Observation is separate from selection: measurements say what happened, not which configuration wins. If the goal depends on an outcome you did not measure, ask the user or mark the result `inconclusive`; a proxy or a smoke check is not evidence for it. The track ends with a named winner, possibly the baseline. Deciding after you see the results is p-hacking with extra steps.
- Compare only runs on the same evaluation set and bench parameters. A changed evaluation set resets every comparison. Say so explicitly before changing it.
- When no held-out test set exists, a validation set may stand in, but only the same validation set for every compared variant. State the substitution in the comparison document.
- When variants were trained on different dataset versions, check each compared run's training set for leakage into the shared evaluation set before scoring. Diff the instance IDs and make sure no training set contains validation/test instances.
- When a pipeline has several steps and a variant changes only one, compare at the full-pipeline level. Carry the unchanged steps' metrics from the baseline and cite its record. A variant that only overrides one step's config needs a `REFERENCES.md` naming the config and commit used for every other step.
- Link every promoted artifact back to the exact run that produced it. An incident must trace to a commit, a dataset version and a seed.

The comparison document is read by reviewers who did not run the experiments. Its layout is part of the deliverable. Start from `assets/COMPARISON.template.md`:

- Open with a **Bottom line** of at most five numbered points: what is promoted or rejected, what the deliverable is (a model, a config, nothing) and the one number that decides each point.
- Use the profile's columns exactly: same names, same order, none added or dropped. If the profile does not list them, stop and complete the profile first. Every table has the same standard columns: `#` first (the variant name, `N-<name>`), `config` second (one line saying what the variant changes against the baseline; the baseline row states its key settings; not a command, which goes under `Commands`), then the profile's columns, then `outcome`, then `run` last (the record path of the row's run, relative to the track folder).
- One like-for-like table first, and only one. Measurements made with another validator, pipeline, dataset version or engine go to an appendix, each table labelled with its setup and the words "not comparable with" the main table.
- The outcome cell holds one of the four words. The baseline reads `reference`: it is the comparison anchor, not a deployment proposal. A rejected row adds the reason with its number (`rejected: 71 t/s at 236k`); negative results are data.
- One row per variant, baseline first. A row holds the last valid run of its variant, not its history. A valid re-run overwrites the row, and the superseded run stays in git history and in its run record. A run is valid when it finished, its tree was clean (or the override is recorded), it was scored on the track's shared evaluation set, and it ran against the same version of the evaluation code as every other row. An invalid or aborted run never replaces a valid row: explain it in the notes and in its record.
- Cells: missing or not applicable `NA`, estimate `~`. Never average repeats into one number. Quote the change against the baseline as relative percent, or as percentage points for ratios and rates, naming the evaluation set.
- Findings are numbered, one line each, always with the number that justifies them. The recommendation names the champion and the condition under which an alternative wins.
- Every number quoted outside the file (PR body, chat, ticket) names its dataset version or bench setup.
- Rows copied from another track keep their source name and name the source track. They are not re-measured and not duplicated as records.
- Below the table, `## Experiment notes` holds dated entries, newest first, each headed `### YYYYMMDD-HHMM - subject`. A note records a finding, a decision or a correction, and the variants its numbers came from. Rejections, invalid runs, superseded rows and changes of metric definition are written there. A decision names who made it (`user decision`). A row deliberately not added yet gets a note: what works, what fails, the deviation in force, and the command that will fill it later.
- Where the project has a report script, it patches the metric cells and nothing else. The agent fills `outcome` and `config`, and never hand-edits a cell the script produces.
- Write the report with the `write-simple-english` skill when it is available.

### Step 5: Unattended grid runs

Use this when a series is a table of rows that one driver can run. The agent sets everything up, starts one command, leaves, and analyzes in a later session. The scripts are project-specific. The pattern is not. Three parts:

1. The table: `<root>/<YYYYMMDD_HHMM>_<track>/grid.tsv`, tab-separated, one run per line: `<rowid> <engine-or-config> <mode> <variant>`. `rowid` is the comparison document's row id. Adding a line schedules a run.
2. The row driver (`run_<track>_row.sh`): serve or start, wait until ready, smoke test, measure, stop, collect. It must never wait for input, must exit non-zero on any failed phase, and must finish the Step 1 record itself, because no agent is watching.
3. The grid driver (`run_<track>_grid.sh`): reads the table, skips rows listed in `logs/grid_<track>.done` (append-only `rowid<TAB>OK<TAB><date>` lines), runs the rest in order, continues on failure, and writes START/OK/FAIL/DONE lines with timestamps to `logs/grid_<track>.out`. A `status` argument prints DONE or PENDING per row and runs nothing. Start it fire-and-forget: `setsid nohup ./run_<track>_grid.sh &`.

Rules:

- A FAIL row gets no done entry and no automatic retry: a retry would append a second set of result rows under the same name. Triage first. Re-runs take `_rN` suffixes.
- Seed the done file from rows already measured before editing the table.
- Before leaving, dry-run the setup: syntax checks, `status` output and, when affordable, one short row end to end including collection.
- On return, read `status` and the grid log tail, check that each DONE row has its record and table cells, triage FAIL rows, then write the Step 4 conclusions.

## Deliverables

- Per track: the Step 0 plan, one `COMPARISON.md` and one record per variant that started, even one that died at startup (the record says why).
- Per promoted result: the promotion action the profile defines, in the same commit as the record that justifies it.
- Per unattended series: the grid table, the row and grid drivers, and the append-only done file and run log.
