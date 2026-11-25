# Shared skills

This repo holds agent skills that many projects share. A skill is a folder with a `SKILL.md` file and optional supporting files. The repo is also a Claude Code plugin marketplace.

## Layers

A skill here is always generic. Project facts do not belong in it. Each project adds what it needs in its own repo.

| Layer | Lives in | Holds | Example |
|---|---|---|---|
| Core | a plugin in this repo | rules that hold in any project and any language | `write-good-code`, `planning`, `experiment-tracking` |
| Language | a `<language>-dev` plugin in this repo | rules for one language, for every project that uses it | `python-conventions`, `godot-conventions` |
| Project | the consuming repo, in its own skill folder | what only that project needs: commands, columns, exceptions, local agents | `code-conventions`, `experiment-profile` |

When layers disagree, the narrower layer wins: project, then language, then core.

A core skill that needs project facts says which project skill supplies them, and stops if it is missing. Example: `experiment-tracking` needs an `experiment-profile` skill that fixes the comparison table columns.

## Plugins

| Plugin | Skills |
|---|---|
| `engineering-core` | `planning`, `write-good-code`, `review-changes`, `make-prs`, `write-pr-description`, `write-simple-english`, `human-review-helper`, `project-instructions` |
| `ml-experiments` | `experiment-tracking` |
| `python-dev` | `python-conventions` |
| `godot-dev` | `godot-conventions` |

A new language gets its own `<language>-dev` plugin, created with its first consumer. Do not create an empty one.

## Use in a project

There are two channels. Both give the same skill text.

**Claude Code.** Add the marketplace and enable plugins in the project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": { "<marketplace>": { "source": { "source": "github", "repo": "<org>/<this-repo>" } } },
  "enabledPlugins": { "engineering-core@<marketplace>": true }
}
```

Plugin skills are namespaced: `engineering-core:planning`. Claude Code caches plugins per user, outside the project, so other harnesses cannot see them.

**Other harnesses** (OpenCode, Codex, Zed). They read plain skill folders, not Claude Code plugins. Ask the user which harnesses the project uses, and do not guess. Then run the script with `--harness`:

```
./install.sh --harness claude,opencode engineering-core,python-dev <path-to-project>
./install.sh --harness claude,zed --check engineering-core,python-dev <path-to-project>
```

| Harnesses chosen | What the script does |
|---|---|
| `claude` only | Nothing. Enable the plugins in `.claude/settings.json`. |
| `opencode` | Copies the plugin skills into `.agents/skills/`. OpenCode reads `.claude/skills/` itself, so the project skills need nothing. |
| `codex` or `zed` | Copies the plugin skills into `.agents/skills/`, and links each project skill of `.claude/skills/` (for example `code-conventions` and `experiment-profile`) into `.agents/skills/` with a relative symlink. These harnesses do not read `.claude/skills/`. |

The script writes `.agents/skills/.source` with the commit it copied from, the skills it copied and the links it made. It never touches a folder that is not listed there, and it stops if a project skill has the same name as a copied one. Running it again updates the copies and the links. `--check` exits 1 if a copy differs or a link is missing. `--dest` selects another folder. Commit the copies and the links, so the project stays self-contained. A symlink needs Developer Mode or `core.symlinks` on Windows. In that case, copy the project skills by hand.

Where each harness looks for skills:

| Harness | Project folders | User folder |
|---|---|---|
| Claude Code | plugins enabled in `.claude/settings.json`, and `.claude/skills/` | `~/.claude/skills/` |
| OpenCode | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` | `~/.config/opencode/skills/` |
| Codex | `.agents/skills/` | `~/.agents/skills/` |
| Zed | `.agents/skills/` | `~/.agents/skills/` |

`.agents/skills/` is the one folder that Codex, Zed and OpenCode all read, so it is the default of `install.sh`.

### Zed

1. Run `./install.sh --harness zed engineering-core,python-dev <path-to-project>`. The plugin skills are copied, and the project skills are linked, in `<project>/.agents/skills/`. Commit them.
2. Open the project in Zed. The agent panel finds the skills in that folder, and the `.claude/skills/` folder of the project is not needed.
3. To have the plugin skills in every project, install them in your home folder instead: `./install.sh --harness zed engineering-core,python-dev ~`. They land in `~/.agents/skills/`. Do not install the same skill in both places.
4. After a marketplace update, run the same command with `--check` to see drift, and run the install again to refresh the copies.

## Add or change a skill

1. Check that it is generic. If a rule names a path, command, file, tool or number that only one project uses, it belongs in that project's skill.
2. Put it in the plugin that matches its layer. Language rules go in the language plugin. Do not repeat a rule that a lower layer already states: state each rule once.
3. The description holds a one-line summary of the skill and when to use it (and when not to), nothing else. The agent reads it only to choose the skill. What the skill covers, which skills it works with and what it needs go in the body.
4. Keep `SKILL.md` short. Move detail to files in the skill folder, one link deep.
5. Raise the plugin `version` in `plugins/<name>/.claude-plugin/plugin.json`.
6. When you add, rename or remove a skill, or move a responsibility between skills, update the "Who owns what" table in `engineering-core:project-instructions`.
7. Run `./install.sh --harness zed --check engineering-core <test-project>` against a test project before you merge.

A change that a consumer needs to override is a sign that a rule is too specific for this repo.
