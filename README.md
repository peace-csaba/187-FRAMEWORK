# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable gameplay systems, addon systems, engine wrappers, data handling, and framework-owned logic so features can be added, tested, replaced, or expanded without turning the project into one large monolithic script.

This project is designed as a long-term base for:
- gameplay systems
- - addon tools
- movement utilities
- bot behavior systems
- framework-owned mechanics
- - reusable MW2019 scripting utilities

---

# Current Release

## Cleanup Update — v1.8.4.3

This release expands the framework with a dedicated smart bot behavior layer while keeping the project structure clean, modular, and framework-owned.

### Included in v1.8.4
- added `framework/sources/gameplay/smartbots.gsc` as a dedicated smart bot module
- added jump/crouch/prone behavior while bots are firing
- added stuck-bot recovery helper
- kept bot behavior isolated from `core/addons.gsc`
- preserved the framework-owned addon layer under `framework/sources/core/addons.gsc`
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
```

### Current State
The current save system is structured as an abstraction layer so the rest of the framework does not need to know how data is stored.

At the moment, it handles:
- `frameworkKills`
- `frameworkDeaths`

### What it does now
- loads framework player data on connect/spawn
- keeps save/load ownership isolated in one file for future upgrades

### Persistence Status
The current implementation is a runtime/session fallback structure, not a fully proven restart-safe storage backend.

That means:
- runtime/session handling is supported
- the framework structure is ready for future persistence work


---

# Project Structure

```text
custom_scripts/
├── framework.gsc
└── framework/
    └── sources/
        ├── core/
        │   ├── addons.gsc
        │   ├── engine.gsc
        │   ├── shared.gsc
        │   └── ui.gsc
        └── gameplay/
            ├── perks.gsc
            ├── rewards.gsc
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

fw_bot_skin_reroll
fw_bot_boss
fw_bot_aggressive

```

---

# Notes

- `fw_nohud` is handled through the addon layer with a per-player watcher model.
- bot controls are DVAR-driven.
- smart bot behavior is isolated inside `gameplay/smartbots.gsc`.
- stim boost configuration is owned by the addon layer.
- infinite ammo supports weapon refill handling and framework equipment refill support.
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
- future-ready data and progression structure

This release is intended as a cleaner and stronger base for continued framework development.
