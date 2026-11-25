# New Godot project

1. Ask the user which Godot version and renderer to use. For 2D, small games and the web export, use the Compatibility renderer.
2. Create the project with the editor, or write a minimal `project.godot` and run `godot --headless --path . --import` once.
3. Add this layout. Add only the folders the first task needs:

   ```
   project.godot
   scenes/        .tscn scenes, main.tscn first
   scripts/       .gd scripts; one folder per area when it grows (entities/, ui/)
   resources/     .tres data and Resource subclasses
   assets/        art and audio, with a CREDITS.md that records each license
   tests/         headless test scripts
   Makefile
   gdlintrc
   .gitignore
   ```

4. `.gitignore`: `.godot/`, `*.tmp`, `export/` (or the export folder you use). Keep the `.uid` and `.import` files tracked.
5. `Makefile` with these targets (see [tools and tests](tools-and-tests.md) for the commands):

   ```make
   GODOT ?= godot
   DIRS := scenes scripts tests

   .PHONY: run import lint format test smoke
   run:    ; $(GODOT) --path .
   import: ; $(GODOT) --headless --path . --import
   lint:   ; uv run --with gdtoolkit gdlint $(DIRS)
   format: ; uv run --with gdtoolkit gdformat $(DIRS)
   test: import
   	@for t in tests/test_*.gd; do $(GODOT) --headless --path . -s "res://$$t" || exit 1; done
   smoke: import
   	@$(GODOT) --headless --path . --quit-after 120 2>&1 | tee smoke.log; ! grep -q "SCRIPT ERROR" smoke.log
   ```

6. In `project.godot`, turn on the typing warnings from [tools and tests](tools-and-tests.md).
7. Create `AGENTS.md` with the `project-instructions` skill.
8. Run `make lint`, `make test` and `make smoke`.
