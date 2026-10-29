---
name: python-conventions
description: Python rules for writing code. Use whenever writing, fixing, refactoring or reviewing Python (.py) code, alongside `write-good-code`. Covers imports, running Python, logging, type annotations, lookups and tests.
---

# Python conventions

These rules add to `write-good-code`. The repo's own `code-conventions` skill, if it has one, wins where they disagree.

- Follow the zen of Python.
- Use absolute imports. Do not modify `PATH` or `PYTHONPATH`.
- Run Python through `uv run` (or an activated virtual environment). If the repo has a `make` target for the task, use it.
- Do not add `print` debugging. Use the `logging` module.
- **Type annotations:** add annotations for new or changed functions. Parameterize generic types: `list[str]`, `dict[str, Any]`, `tuple[int, ...]`; never a bare `list`, `dict` or `tuple`. If the repo configures a type checker (for example `basedpyright`), follow its mode.
- **Lookups:** use `data["key"]` when the schema or invariant requires the key, so a `KeyError` names it. Reserve `.get()` with a default for values that are genuinely optional. The same applies to `getattr(obj, "attr", fallback)`.
- **Tests:** while you work, run `uv run pytest <path>` on the tests of the changed modules.
