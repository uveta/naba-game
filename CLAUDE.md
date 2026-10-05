## Project

NABA = small 3D arcade shooter. Godot 4.7, GDScript, GL Compatibility renderer, Jolt Physics. Ship moves XZ plane, shoots -Z. Enemies spawn at `spawn_z`, drift +Z. No tests. No linter.

## Commands

Need Godot 4.7.x editor binary. CI pins `GODOT_VERSION: 4.7.2`.

- Run: `godot --path .` (main = `res://scenes/main.tscn`) | F5 in editor | VS Code godot-tools
- Re-import (fresh clone, `.godot/` not committed): `godot --headless --import`
- Web export (= CI): `mkdir -p build/web && godot --headless --export-release "Web" build/web/index.html`

CI ([.github/workflows/deploy-web.yml](.github/workflows/deploy-web.yml)): exports "Web" preset from [export_presets.cfg](export_presets.cfg) on push/PR to `main`. Deploys GitHub Pages on push to `main`. Keep preset name `Web`.

## Architecture

- **`GameState` autoload** ([scripts/game_state.gd](scripts/game_state.gd)) = single source of truth: score, lives, `is_game_over`. Signals: `score_changed`, `lives_changed`, `game_over`. Mutate only via `add_score()`, `lose_life()`, `reset()`. Mutators no-op after game over. HUD + others subscribe to signals. No polling.
- **Main scene** ([scenes/main.tscn](scenes/main.tscn), [scripts/main.gd](scripts/main.gd)) owns `SpawnTimer`, `Enemies` container, `Player`, `HUD`. Calls `GameState.reset()` in `_ready()`. Restart = `reload_current_scene()` → re-runs `_ready()`. Reset state there only.
- **Collision = Area3D only**. No physics bodies. `Bullet` + `Enemy` connect `area_entered`, cast other area to `Enemy` / `Player` (both have `class_name`). Layers in [project.godot](project.godot): 1 `player`, 2 `enemy`, 3 `player_bullet`. New entity → set layer/mask on scene, else `area_entered` no fire.
- **Hit API**: enemy → `Player.hit()` (invuln frames + `GameState.lose_life()`). Bullet → `GameState.add_score(enemy.points)` then `Enemy.die()`. Bullets added as player siblings (`get_parent().add_child`) → live under main scene root.
- **Input** = actions in `project.godot`: `move_*`, `shoot`, `restart`. Keyboard (WASD/arrows/Space/Enter) + gamepad. Use action names. No raw keys.

## Conventions

### Code
- Tab indent ([.editorconfig](.editorconfig)). Static type annotations everywhere. `##` doc comments under `extends`. `@export` = tunables. `@onready` = child lookups. `_underscore` = private members + signal handlers (`_on_*`).

### Git
- Commit `.uid` files Godot makes next to each `.gd`.

### Workflow
- Trunk-based. New work, create branch. Finish, create PR, GitHub + CLI

| Prefix | Purpose | Example |
|---|---|---|
| `feat/` | New functionality | `feat/player-dash` |
| `fix/` | Non-urgent bug fix | `fix/enemy-spawn-crash` |
| `hotfix/` | Urgent production fix | `hotfix/save-file-corruption` |
| `chore/` | Maintenance, tooling, dependencies | `chore/update-godot-4-3` |
| `refactor/` | Restructuring without behavior change | `refactor/input-handling` |
| `docs/` | Documentation only | `docs/readme-setup` |
| `test/` | Adding or fixing tests | `test/inventory-unit-tests` |
| `ci/` | Pipelines and build config | `ci/pages-export` |
| `perf/` | Performance work | `perf/reduce-draw-calls` |
| `spike/` | Throwaway exploration | `spike/procedural-maps` |
