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