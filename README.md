# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable systems from framework-owned systems so features can be added, tested, and reworked without turning the project into one large monolithic script.

This project is designed as a long-term base for future gameplay systems, balance changes, custom progression, addon tools, and framework-owned logic.

---

## Current Release

### Included in v1.7
- added `framework/sources/core/data.gsc` as the framework data layer
- added save/load ownership for SR, kills, and deaths
- separated match-stat reset behavior from rank/SR handling
- cleaned `framework.gsc` player lifecycle and spawn debug flow
- kept restart persistence backend-ready without hardcoding storage into gameplay files
- cleaned `engine.gsc` ammo helper comments and risky clip-channel notes
- kept addon DVAR systems under `framework/sources/core/addons.gsc`

### Bounce System v1.0 - introduces the first framework-owned bounce utility system.

- runtime bounce creation
- runtime bounce deletion
- bounce clearing
- configurable bounce trigger radius
- configurable minimum fall-speed handling
- visible bounce marker spawning
- configurable marker model handling
- movement utility experimentation through framework-owned addon systems

### Saving Status
The current data layer supports runtime/session-style data handling and is structured for future persistence backends.

True restart-safe rank saving is still backend-dependent. If a stronger player-stat or external storage backend is added later, only `core/data.gsc` should need to change.

---

## Project Structure

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
            ├── stim.gsc
            └── weapons.gsc
```

### Ownership
- `framework.gsc` → main bootstrap and player lifecycle
- `core/addons.gsc` → framework-owned addon systems and addon DVAR watchers
- `core/data.gsc` → framework data load/save abstraction
- `core/engine.gsc` → engine-facing wrappers and risky helper calls
- `core/shared.gsc` → shared helpers and generic framework utilities
- `core/ui.gsc` → framework printing and UI helpers
- `gameplay/*` → reusable gameplay systems

---

## Console DVAR Commands

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

fw_bounce_spawn
fw_bounce_delete
fw_bounce_clear
fw_bounce_bind
fw_bounce_radius
fw_bounce_min_fall_speed
fw_bounce_marker
fw_bounce_marker_model

```

---

## Saving / Data System

The framework now includes a dedicated data layer through `framework/sources/core/data.gsc`.

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

### Important Note
The current implementation is a runtime/session fallback structure, not a fully proven restart-safe storage backend.

That means:
- runtime/session handling is supported
- the framework structure is ready for future persistence work
- true restart-safe rank saving will require a stronger backend if the current build does not expose proper persistent stat functions

### Why this matters
When a better storage backend is found later, only `core/data.gsc` should need to change, while the rest of the framework can continue using the same save/load flow.

---

## Notes

- `fw_nohud` is handled through the addon layer with a per-player watcher model.
- bot controls are fully DVAR-driven.
- stim boost configuration is owned by the addon layer.
- infinite ammo supports weapon refill handling and framework equipment refill support.
- `data.gsc` provides a clean save-load abstraction layer for future persistence work.
- `fw_status` prints a quick framework state readout in-game.
- `fw_debug` is a foundation toggle for future debug-only systems.

---

## Direction

The current direction of **187 — FRAMEWORK** is:

- cleaner ownership
- fewer oversized files
- framework-owned addon systems
- reusable gameplay modules
- stable DVAR-driven control
- cleaner combat and engine helper separation
- future-ready data and progression structure

This release is intended as a cleaner and stronger base for continued framework development.
