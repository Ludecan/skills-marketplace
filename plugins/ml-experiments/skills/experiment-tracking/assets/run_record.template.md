# [FILL: track]/[FILL: variant] - run record

Run name: [FILL: <track>/<variant>, or <track>/<variant>_rN for a repeat]
Date: [FILL: YYYY-MM-DD HH:MM]

## Code and command

- Commit: [FILL: git SHA]. Dirty tree: no (yes only with a recorded override: [FILL: why]).
- Code outside git: [FILL: what the profile asks for, e.g. binary path, image tag, checkout SHA, applied patches. "NA" if none.]
- Command (fully expanded, copy-pasteable, with working directory and every env override):

      [FILL: exact command]

  Wrapper invocation, if a wrapper script built the command: [FILL: invocation, or "NA"]

## Config

- Config file: [FILL: path under the track folder]. Every value that affects the result is in it or in the command above.

## Data or model under test

- [FILL: name, path, version or content hash, split sizes and strategy, any sampling.]

## Environment

- [FILL: only what differs from the defaults or affects the numbers: hardware, co-tenants, library versions, env overrides.]

## Metrics

- Evaluation set or bench setup: [FILL: name it]
- [FILL: the profile's metrics, with units]

[FILL: profile-specific lines go here, e.g. extra metric groups, per-step results.]

## Artifacts

- [FILL: root output folder and the exported or promoted files. Not every intermediate checkpoint.]

## Anomalies

- [FILL: crashes, watchdog kills, OOM retries, interference, or "none". A phase that wrote bad values stays here as not a result.]

## Outcome

- Outcome: [FILL: reference | promoted | rejected | inconclusive]
- Reason (one sentence with the number that justifies it, required for rejected): [FILL]
