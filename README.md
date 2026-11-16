# Scrap Sprint

Roblox scrap-collecting simulator: grab junk in the Starter Junkyard, sell it for cash, and upgrade tools and backpacks. Built with Rojo and modular Luau (`src/shared`, `src/server`, `src/client`).

## Rojo sync

1. Install [Rojo](https://rojo.space/) (CLI + Studio plugin).
2. From this repo root: `rojo serve`
3. In Roblox Studio, connect the Rojo plugin to the local server and sync.
4. Press Play — Output should show `[ScrapSprint] server boot` and `[ScrapSprint] client boot`.

`default.project.json` maps:

| Disk | DataModel |
| --- | --- |
| `src/shared` | `ReplicatedStorage.Shared` |
| `src/server` | `ServerScriptService.Server` |
| `src/client` | `StarterPlayer.StarterPlayerScripts.Client` |
| (empty folder) | `Workspace.Map` |

Studio-only meshes/sounds stay in Studio; see `assets/README.md`.

## Phase-gate workflow

1. Implement **one** task from the master plan.
2. Sync with Rojo and run that task’s checklist in Studio.
3. Fix and retest the same task if anything fails.
4. Only start the next task after an explicit “looks good / go.”

No multi-phase leaps. Economy numbers change only in `src/shared/Config/*`.
