# [FILL: what is compared, e.g. "Churn model: feature-selection variants"] comparison

Track `[FILL: track]`, opened [FILL: YYYY-MM-DD HH:MM]. [FILL: one paragraph. The question this track answers. What varies between variants and what is held fixed. The metric protocol or bench parameters, fixed for the whole track. A link to the experiment spec, if there is one.]

Status: [FILL: which rows are measured, queued, or copied from another track, and anything a reader must know before reading the table.]

## Bottom line

1. [FILL: verdict, e.g. "`V1` is promoted: it lifts [primary metric] from [x] to [y] on [evaluation set]."]
2. [FILL: what is rejected and the one number that decides it.]
3. [FILL: what the deliverable is: a model, a config, or nothing.]

(At most five points. A reader who stops here must know the verdict.)

## Promotion criterion (set before the first run)

1. [FILL: the decision rule: primary and auxiliary metrics, the evaluation set or bench parameters, the threshold.]
2. [FILL: the noise floor: the baseline repeat `1-[name]_r2`, or the profile's tolerance.]
3. [FILL: what each outcome means for this track: promoted, rejected, inconclusive.]

## Predictions (to check rows against, not results)

[Delete this section when there are none.]

1. [FILL: what you expect and why, with the number it rests on.]

## Comparison table

[FILL: cell rules in one or two lines: the evaluation set or bench setup, what `NA` and `~` mean here, and which script patches the cells, if any.] Columns come from the profile; `#`, `config`, `outcome` and `run` are standard.

| # | config | [FILL: primary metric (evaluation set)] | [FILL: auxiliary metric] | outcome | run |
|---|--------|------------------------------------------|--------------------------|---------|-----|
| 1-baseline | [FILL: what it is] | [FILL] | [FILL] | reference | `1-baseline/1-baseline_run_record.md` |
| 2-[FILL: name] | [FILL: diff from baseline, one variable] | [FILL] | [FILL] | promoted | `2-[FILL: name]/2-[FILL: name]_run_record.md` |
| 3-[FILL: name] | [FILL: diff from baseline] | [FILL] | [FILL] | rejected: [FILL: reason in one phrase] | `3-[FILL: name]/3-[FILL: name]_run_record.md` |
| 4-[FILL: name] | [FILL: diff from baseline] | [FILL] | ~[FILL] | inconclusive | `4-[FILL: name]_r2/4-[FILL: name]_r2_run_record.md` (the last valid run) |
| 5-[FILL: name] | copied from `[FILL: other track]` row [FILL: id] | [FILL] | NA | [FILL] | source track |

Commands, one per row, expanded and copy-pasteable (the record holds the same command):

    1-baseline: [FILL: exact command]
    2-[FILL: name]: [FILL: exact command]
    3-[FILL: name]: [FILL: exact command]

## Findings

1. [FILL: one quantitative, comparative line, e.g. "`2-[name]` beats the baseline by +2.1 points on [metric]; `3-[name]` is flat."]
2. [FILL: one causal rule worth repeating, with the number that justifies it.]

Recommendation: [FILL: the champion and the condition that selects it, e.g. "`V1`, unless [condition], then `V3`."]

## Appendix: measurements not comparable with the table above

[Delete this section when it is empty.]

### [FILL: setup name]

Not comparable with the main table: [FILL: what differs, e.g. "validated with another tool", "dataset v4.0.3", "another engine version"].

| # | config | [FILL: metric] | outcome |
|---|--------|----------------|---------|
| [FILL] | [FILL] | [FILL] | [FILL] |

## Experiment notes

Newest first. One entry per finding, decision or correction. Name the variants the numbers came from.

### [FILL: YYYYMMDD-HHMM] - [FILL: subject]

- [FILL: what was found or decided, and why.]
- [FILL: the variants and rows it refers to.]

### [FILL: YYYYMMDD-HHMM] - track opened

- [FILL: the variants queued and the baseline decision (re-measured or copied).]
