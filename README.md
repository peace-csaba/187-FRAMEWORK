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

# Current Release

## Better Plunder Update — v1.8.7

This release expands the framework with a dedicated smart bot behavior layer while keeping the project structure clean, modular, and framework-owned.

### Included in v1.8
- added `framework/sources/gameplay/smartbots.gsc` as a dedicated smart bot module
- added randomized bot rank and prestige metadata
- added jump/crouch/prone behavior while bots are firing
- added stuck-bot recovery helper
- kept bot behavior isolated from `core/addons.gsc`
- preserved the framework-owned addon layer under `framework/sources/core/addons.gsc`
- kept `core/data.gsc` as the framework data layer
- kept save/load ownership for SR, kills, and deaths
- separated match-stat reset behavior from rank/SR handling
- kept restart persistence backend-ready without hardcoding storage into gameplay files
- continued cleanup of risky engine-facing helper ownership

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

fw_status
fw_debug

fw_noclip
fw_noclip_bind
fw_noclip_speed
fw_noclip_sprint_speed

```

---

# Notes

- `fw_nohud` is handled through the addon layer with a per-player watcher model.
- bot controls are DVAR-driven.
- smart bot behavior is isolated inside `gameplay/smartbots.gsc`.
- stim boost configuration is owned by the addon layer.
- infinite ammo supports weapon refill handling and framework equipment refill support.
- bounce tools support visible marker spawning and configurable marker models.
- `data.gsc` provides a clean save-load abstraction layer for future persistence work.
- `fw_status` prints a quick framework state readout in-game.
- `fw_debug` is a foundation toggle for future debug-only systems.

---

# Direction

The current direction of **187 — FRAMEWORK** is:

- cleaner ownership
- fewer oversized files
- framework-owned addon systems
- reusable gameplay modules
- stable DVAR-driven control
- cleaner combat and engine helper separation
- safer bot behavior expansion
- per-player noclip ownership
- removed bounce leftovers
- future-ready data and progression structure

This release is intended as a cleaner and stronger base for continued framework development.

---

# Better Plunder System — v1.8.7

Added `framework/sources/gameplay/betterplunder.gsc` as a framework-owned Plunder/DMZ gameplay module.

### Included
- Plunder/DMZ rule control
- safer match-end protection using `level.timelimitoverride`
- optional custom POI play area / ring system
- optional initial POI teleport
- optional kill reward speed boost
- optional reward perks and specialist bonus
- optional infinite tactical sprint
- optional infinite equipment / plates / ammo support
- match info prints and manual match info trigger
- optional dropped-loot cleanup
- optional super ability blocking

### Better Plunder DVARs

```commands
bp_enable
bp_force_enable
bp_prevent_match_end
bp_timer_minutes
bp_timer_refresh

bp_playring
bp_ring_poi
bp_ring_timer
bp_initial_teleport

bp_rewardspeed
bp_rewardspeed_speed
bp_rewardspeed_length
bp_rewardperks
bp_rewardperks_maxperks
bp_rewardperks_specialist

bp_inftacsprint
bp_infequip
bp_infequip_delay
bp_inf_guns
bp_inf_lethals
bp_inf_tac
bp_inf_plates

bp_matchinfo_trigger
bp_matchinfo_interval
bp_matchinfo_flags

bp_delete_dropped_loot
bp_blocksupers
bp_allowsupers
```

### Notes
The Better Plunder module avoids known unstable calls from the original script, including custom `level.ontimelimit` overrides and bot navigation queries.
