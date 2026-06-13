# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable gameplay systems, addon systems, engine wrappers, data handling, and framework-owned logic so features can be added, tested, replaced, or expanded without turning the project into one large monolithic script.

This project is designed as a long-term base for:
- gameplay systems
- progression systems
- addon tools
- movement utilities
- bot behavior systems
- framework-owned mechanics
- future persistence backends
- reusable MW2019 scripting utilities

---

# Smart Bot System

The framework now includes a dedicated smart bot behavior module:

```text
framework/sources/gameplay/smartbots.gsc
```

The smart bot system adds lightweight behavior improvements while avoiding unstable bot-native calls that can cause script runtime errors on some builds.

### Included
- randomized bot rank metadata
- randomized bot prestige metadata
- jump behavior while firing
- crouch behavior while firing
- prone behavior while firing
- stuck-bot recovery helper
- isolated gameplay module ownership

### Notes
The smart bot system is intentionally kept safe and lightweight.

Risky bot-native systems such as forced nav goals, forced attackers, and internal bot AI state forcing are avoided to keep the framework stable.

---

# Saving / Data System

The framework includes a dedicated data layer through:

```text
framework/sources/core/data.gsc
```

### Current State
The current save system is structured as an abstraction layer so the rest of the framework does not need to know how data is stored.

At the moment, it handles:
- `frameworkSR`
- `frameworkKills`
- `frameworkDeaths`

### What it does now
- loads framework player data on connect/spawn
- saves framework player data after rank/stat changes
- separates match-stat reset from rank/SR handling
- keeps save/load ownership isolated in one file for future upgrades

### Persistence Status
The current implementation is a runtime/session fallback structure, not a fully proven restart-safe storage backend.

That means:
- runtime/session handling is supported
- the framework structure is ready for future persistence work
- true restart-safe rank saving will require a stronger backend if the current build does not expose proper persistent stat functions

When a better storage backend is found later, only `core/data.gsc` should need to change.

---

# Project Structure

```text
custom_scripts/
├── framework.gsc
└── framework/
    └── sources/
        ├── core/
        │   ├── addons.gsc
        │   ├── data.gsc
        │   ├── engine.gsc
        │   ├── shared.gsc
        │   └── ui.gsc
        └── gameplay/
            ├── perks.gsc
            ├── rewards.gsc
            ├── betterplunder.gsc
            ├── smartbots.gsc
            ├── stim.gsc
            └── weapons.gsc
```

---

# Ownership

### `framework.gsc`
Main framework bootstrap and player lifecycle ownership.

### `core/addons.gsc`
Framework-owned addon systems, DVAR watchers, movement tools, debug systems, and runtime addon ownership.

### `core/data.gsc`
Framework save/load abstraction layer and progression ownership.

### `core/engine.gsc`
Engine-facing wrappers, risky helper calls, ammo helpers, equipment helpers, and isolated engine interaction.

### `core/shared.gsc`
Shared framework utilities and reusable helpers.

### `core/ui.gsc`
Framework printing and UI utility ownership.

### `gameplay/smartbots.gsc`
Framework-owned smart bot behavior layer.

### `gameplay/*`
Reusable gameplay systems isolated from engine and persistence ownership.

---

# Console DVAR Commands

```commands
fw_nohud

fw_bot_team autoassign
fw_bot_team allies
fw_bot_team axis

fw_bot_difficulty regular
fw_bot_difficulty recruit
fw_bot_difficulty hardened
fw_bot_difficulty veteran

fw_addbot
fw_kickbot

fw_stim_boost_speed 1.05
fw_stim_boost_duration 10
fw_stim_boost_decay 0.1

fw_inf_ammo
fw_no_recoil

fw_movespeed 1.0
fw_inftacsprint 0

fw_playring 1
fw_ring_poi prison
fw_ring_timer 5

fw_status
fw_debug

fw_noclip
fw_noclip_bind
fw_noclip_speed
fw_noclip_sprint_speed

```

# Current Release

## Plunder Update — v1.8.8

This release expands the framework with a dedicated beta custom plunder gameplay.

### Included in v1.8.8
- New File added inside the framework —> gameplay/gameplay.gsc

- Added New Dvar for move speed loop. — (fw_movespeed 1.0)
- Added New Dvar for infinite tactical sprint loop. — (fw_inftacsprint 0)

- Added & Fixed center coordinates for the configured play areas poi.
-  —> (fw_ring_poi prison) — (control, factory, bio, tents) !!!
-  —> Added new Handles for play areas activation after host deploys, then periodically prints gameplay —> match & host info's.
  
- Added new Monitors for play areas.
-  —> Kills humans (real players) outside; but teleports the bots back to the configured play areas.
-  —> Added new loop counter for players outside the configured play roi areas before death.
-  —> After spawn & deployment, teleports player near the configured & selected play areas if the area ring is active.
  
- Added New Watcher for removing dropped loots & items via engine runtime; near the death player positions.

---