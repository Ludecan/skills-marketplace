---
name: godot-conventions
description: Godot 4 and GDScript rules for writing code. Use whenever you start a new Godot project, or write, fix, refactor or review `.gd`, `.tscn`, `.tres`, `.gdshader` or `project.godot` files.
---

# Godot conventions

These rules add to `write-good-code`. The repo's own `code-conventions` skill, if it has one, wins where they disagree.

- **New project:** follow [the new-project procedure](references/new-project.md).
- Follow the official Godot best practices and the GDScript style guide. Use the idioms of the Godot version that `project.godot` declares (`config/features`). Do not use Godot 3 APIs (`yield`, `export var`, `onready var`, `connect("signal", self, "method")`).

## Typing and names

- The typing warnings in `project.godot` are mandatory (see [tools and tests](references/tools-and-tests.md)). Add a type wherever GDScript accepts one.
- Add static types to new or changed functions, variables, signals and loops: `var lives: int = 3`, `func rescue_friend() -> void`, `signal hit(damage: int)`, `for enemy: Enemy in enemies`. Use typed arrays and dictionaries (`Array[Enemy]`, `Dictionary[String, int]` on 4.4+).
- Use `:=` only when the type is clear from the right side (`var speed := 0.0`, `var timer := Timer.new()`). Write the type when the right side is a `Variant`, for example `dict["key"]` or `get_node()`.
- Type node references with `@onready` (`@onready var sprite: Sprite2D = $Sprite2D`). Use `%UniqueName` for nodes that the script must find even after the scene tree changes.
- Names: `snake_case` for files, functions and variables, `PascalCase` for `class_name` and nodes, `UPPER_CASE` for constants and enum values. A leading `_` marks a private member.
- Register a shared type with `class_name`. Use `res://` absolute paths with `preload` (constant paths) or `load` (paths known only at run time).

## Structure

- Signals go up, calls go down: a node calls methods on its children and emits signals for its parent. Do not reach up the tree with `get_parent()` or `../` paths.
- Connect signals in code with callables: `button.pressed.connect(_on_button_pressed)`. Use `CONNECT_ONE_SHOT` or disconnect when a listener goes away before the emitter.
- Prefer composition through child nodes and `Resource` subclasses (for example one `WeaponData` resource per weapon) over deep inheritance.
- Use an autoload only for state or services that are truly global (an event bus, save data, audio). Do not use one to avoid passing a reference.
- Put tuning values in `const` at the top of the owning script, or in `@export` fields that a designer can change.

## Runtime behavior

- Movement, physics and collisions go in `_physics_process(delta)`. Visual-only updates go in `_process(delta)`. Scale every rate by `delta`, so behavior does not change with the frame rate.
- Free nodes with `queue_free()`, not `free()`. Check `is_instance_valid()` before you use a reference to a node that another system can free.
- After you `await`, the node can be freed or out of the tree. Check before you continue.
- Do not hand-edit `.tscn` or `.tres` files for cosmetic changes. Edit them only for a structural change that the task needs, and then load the scene to check it.

## Errors and logs

- Script errors in the Godot output must be fixed. A parse error in one script can silently give a black screen or a missing node, with no crash.
- Fail loudly on states that must not happen: `assert()` in debug builds, `push_error()` for errors that must also show in release builds.
- Do not leave debug `print()` calls in committed code. Guard temporary logging with `if OS.is_debug_build():`.

## Check your work

Use the repo's `make` targets when they exist. [Tools and tests](references/tools-and-tests.md) gives the commands for lint, format, parse checks, headless tests and screenshots, and the pitfalls of headless runs.
