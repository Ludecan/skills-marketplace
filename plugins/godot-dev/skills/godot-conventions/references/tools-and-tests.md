# Godot tools and tests

## Lint and format

[gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) gives `gdlint` and `gdformat`. Run it through `uv`, so it needs no install:

```
uv run --with gdtoolkit gdformat <dirs>          # format
uv run --with gdtoolkit gdformat --check <dirs>  # check only
uv run --with gdtoolkit gdlint <dirs>            # lint, config in gdlintrc
```

Pass the script folders, not `.`, so `addons/` and `.godot/` are not touched. Do not reformat vendored addons.

## Parse and type checks

`gdlint` does not compile the scripts. Godot does:

```
godot --headless --path . --import                   # import assets, refresh the class cache
godot --headless --path . --check-only -s <file.gd>  # parse check of one script
godot --headless --path . --quit-after 120           # boot the main scene for 120 frames
```

Run `--import` first on a fresh clone or after you add a `class_name`, or other scripts fail to find the class. After a headless boot, search the output for `SCRIPT ERROR` and `ERROR:`. Godot exits with code 0 even when a script fails.

To make the editor and the headless runs treat missing types as errors, set these in `project.godot` (Project Settings > Debug > GDScript):

```
[debug]
gdscript/warnings/untyped_declaration=2
gdscript/warnings/inferred_declaration=0
gdscript/warnings/unsafe_call_argument=1
```

`2` is error, `1` is warning, `0` is ignore. Change these only when the user agrees: an existing project can have many untyped lines.

## Tests

- Use the test runner that the repo already has (GUT, gdUnit4, or a custom `SceneTree` script). For a new small project, a `SceneTree` script per test file is enough: `extends SceneTree`, run the checks in `_initialize()`, and call `quit(1)` on failure.
- Run a test with `godot --headless --path . -s res://tests/<file>.gd`.
- Headless runs do not wait for vsync, so `_process` runs faster than 60 Hz, while `_physics_process` stays at the physics tick rate. Count time in tests with physics frames (`physics_frame` signal), never with `_process` frames.
- A test that waits for a frame number must always reach its `quit()` call. Check the order of `if`/`elif` frame branches, and add a frame limit that fails the test.
- In a `SceneTree` script call `quit()`. In a node script call `get_tree().quit()`.
- Test the game logic with real nodes in a real tree. Use stubs only for input devices, time or randomness.

## Screenshots

To see a frame without the editor, run the game with a window (not `--headless`), wait for `RenderingServer.frame_post_draw`, then save `get_viewport().get_texture().get_image()` with `save_png()`. Put this code behind a command-line flag (`OS.get_cmdline_user_args()`), and remove it before you commit, unless the repo keeps it as a tool.

## Other pitfalls

- Commit the `.uid` files that Godot 4.4+ writes next to scripts and resources. Do not commit `.godot/`.
- `pkill -f godot` can match the shell of the command itself. Use `pkill -x godot` or the process ID.
