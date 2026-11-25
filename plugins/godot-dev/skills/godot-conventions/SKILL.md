---
name: godot-conventions
description: Godot and GDScript rules for writing code. Use whenever writing, fixing, refactoring or reviewing `.gd`, `.tscn`, `.tres` or `.gdshader` files.
---

# Godot conventions

These rules add to `write-good-code`. The repo's own `code-conventions` skill, if it has one, wins where they disagree.

- Use `res://` absolute paths with `preload` or `load`. Register shared types with `class_name` instead of loading them ad hoc.
- Add static types to new or changed functions and variables (`var lives: int = 3`, `func rescue_friend() -> void`). Type node references with `@onready` (`@onready var sprite: Sprite2D = $Sprite2D`). Follow the official Godot best practices and the GDScript style guide, and the repo's `gdlint` rules: `snake_case` for functions and variables, `PascalCase` for class names, `UPPER_CASE` for constants.
- Prefer composition through nodes and shared dictionaries or resources over deep inheritance.
- Run the game and the tests through the Godot editor or `godot --headless`. Do not hand-edit `.tscn` or `.tres` files for cosmetic changes.
- Script errors in the Godot logs must be fixed. A parse error can silently render a black screen.
- Do not leave debug `print()` calls in committed code. Guard temporary logging with `if OS.is_debug_build():`.
