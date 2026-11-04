# Shared skills marketplace

Agent skills shared across projects, in layers: core, language and project. This repo is a Claude Code plugin marketplace, and its skills also install as plain skill folders for other harnesses.

| Plugin | What it gives you |
|---|---|
| `engineering-core` | Planning, code writing, code review, PR descriptions, simple English and human review walkthroughs, for any language. |
| `ml-experiments` | Experiment tracking: run records, naming, comparison tables, baselines and decisions. It needs an `experiment-profile` skill in the project. |
| `python-dev` | Python rules that add to the core code skill. |
| `godot-dev` | Godot and GDScript rules that add to the core code skill. |

[AGENTS.md](AGENTS.md) explains the layers, how a project enables the plugins or copies the skills with `install.sh`, and how to add or change a skill.

See [LICENSE](LICENSE): this repo is proprietary.
