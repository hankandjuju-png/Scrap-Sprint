# Scrap Sprint — Dev Rules

Hard rules for every contributor and agent. Violating these slows the phase gate.

## Naming conventions

- **Modules:** PascalCase (`PlayerDataService`, `HudController`, `Remotes`).
- **Server systems:** `*Service` under `src/server/`.
- **Client systems:** `*Controller` under `src/client/`.
- **Bootstraps only:** `Main.server.lua`, `Main.client.lua` — thin requires + `init()`, no giant scripts.
- **Config keys / ids:** stable string ids (`"scrap_can"`, `"tool_starter_magnet"`, `"bp_small"`, `"area_starter"`). Display names can change; ids should not.
- **Remotes:** PascalCase event names matching `src/shared/Remotes.lua` exactly.

## Client vs server trust boundary

| Owns | Does not own |
| --- | --- |
| **Server:** cash, inventory, collect validation, purchases, unlocks, saves | Client-reported cash, value, rarity, capacity |
| **Client:** input, UI, local FX, optimistic feedback the server can reject | Authoritative state changes |
| **Shared:** configs, remote names, pure helpers, types | Side effects or DataStore |

Never trust the client for economy outcomes. Distance, ownership, capacity, and prices are validated on the server.

## Remote rules

1. Create remotes once via `shared/Remotes.lua` (server creates; client waits).
2. Use the MVP list only until a later phase explicitly adds remotes: `ProfileLoaded`, `ProfileUpdated`, `CollectResult`, `SellResult`, `ShopResult`, `Notify`, `BackpackFull`, `RequestCollect`, `RequestSell`, `RequestPurchase`, `RequestEquipTool`, optional `GetShopCatalog`.
3. Rate-limit every inbound (`Request*`) remote per player.
4. Ignore unknown ids; never accept cash/value/rarity from the client.
5. Prefer RemoteEvents; RemoteFunctions sparingly.

## Phase gate

1. Implement **one** task only.
2. Sync with Rojo and run that task’s test checklist.
3. If it fails, fix and retest **the same task**.
4. Start the next task only after an explicit “looks good / go.”

**No multi-phase leaps.** Do not batch Phase 2+ gameplay into Phase 1. Do not invent services, map builders, or DataStores ahead of their phase.

## Config-only economy tuning

- Change sell values, prices, capacities, collect times, and spawn caps **only** in `src/shared/Config/*`.
- Do not hardcode economy numbers inside services or controllers.
- Document formulas later in `docs/ECONOMY.md`; keep live numbers in Config.
