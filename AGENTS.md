# Shared skills

This repo holds agent skills that many projects share. A skill is a folder with a `SKILL.md` file and optional supporting files. The repo is also a Claude Code plugin marketplace.

## Layers

A skill here is always generic. Project facts do not belong in it. Each project adds what it needs in its own repo.

| Layer | Lives in | Holds | Example |
|---|---|---|---|
| Core | a plugin in this repo | rules that hold in any project and any language | `write-good-code`, `planning`, `experiment-tracking` |
| Language | a `<language>-dev` plugin in this repo | rules for one language, for every project that uses it | `python-conventions` |
| Project | the consuming repo, in its own skill folder | what only that project needs: commands, columns, exceptions, local agents | `code-conventions`, `experiment-profile` |

When layers disagree, the narrower layer wins: project, then language, then core.

A core skill that needs project facts says which project skill supplies them, and stops if it is missing. Example: `experiment-tracking` needs an `experiment-profile` skill that fixes the comparison table columns.

## Plugins

| Plugin | Skills |
|---|---|
| `engineering-core` | `planning`, `write-good-code`, `code-review`, `write-pr-description`, `write-simple-english`, `human-review-helper` |
| `ml-experiments` | `experiment-tracking` |
| `python-dev` | `python-conventions` |

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

**Other harnesses** (OpenCode, Codex, Zed). They read plain skill folders, mostly `.agents/skills/`. Copy the skills in:

```
./install.sh engineering-core,python-dev <path-to-project>
./install.sh --check engineering-core,python-dev <path-to-project>
```

The script writes `.agents/skills/.source` with the commit it copied from and the skills it manages. It never overwrites a skill it does not manage. Running it again updates the copies. `--dest` selects another folder. Commit the copies, so the project stays self-contained.

Project skills stay in the project's own skill folder. Link or copy them into `.agents/skills/` when the harness needs them there.

## Add or change a skill

1. Check that it is generic. If a rule names a path, command, file, tool or number that only one project uses, it belongs in that project's skill.
2. Put it in the plugin that matches its layer. Language rules go in the language plugin. Do not repeat a rule that a lower layer already states: state each rule once.
3. Keep the description specific about when to use the skill.
4. Keep `SKILL.md` short. Move detail to files in the skill folder, one link deep.
5. Raise the plugin `version` in `plugins/<name>/.claude-plugin/plugin.json`.
6. Run `./install.sh --check` against a test project before you merge.

A change that a consumer needs to override is a sign that a rule is too specific for this repo.
