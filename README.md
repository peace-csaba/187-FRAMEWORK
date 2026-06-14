# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable gameplay systems, addon systems, engine wrappers, data handling, and framework-owned logic so features can be added, tested, replaced, or expanded without turning the project into one large monolithic gsc script.

---

# Current Release : Plunder Update — v1.8.8

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

# Project Structure

```text
custom_scripts/
├── README.MD
├── framework.gsc
└── framework/
    └── sources/
        ├── core/
        │   ├── addons.gsc
        │   ├── engine.gsc
        │   ├── shared.gsc
        │   └── ui.gsc
        └── gameplay/
            ├── gameplay.gsc
            ├── perks.gsc
            ├── rewards.gsc
            ├── smartbots.gsc
            └── stim.gsc
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

### `gameplay/gameplay.gsc`
Framework-owned gameplay logics.

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

fw_bot_difficulty regular | recruit | hardened | veteran |

fw_addbot
fw_kickbot

fw_stim_boost_speed 1.05
fw_stim_boost_duration 10
fw_stim_boost_decay 0.1

fw_inf_ammo 0
fw_no_recoil 0

fw_movespeed 1.0
fw_inftacsprint 0

fw_playring 1
fw_ring_poi prison | control | factory | bio | tents
fw_ring_timer 5

fw_status 0
fw_debug 0

fw_noclip 1
fw_noclip_bind 1
fw_noclip_speed 33
fw_noclip_sprint_speed 80

```