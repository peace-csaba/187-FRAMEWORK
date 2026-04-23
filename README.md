# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable systems from project-specific systems so features can be added, tested, and reworked without turning the project into one large monolithic script.

This project is designed as a long-term base for future gameplay systems, balance changes, custom progression, and framework-owned mode logic.

---

## Current Release

### Addons Rework — v1.4  
**The Medical Nose Update**

This release focuses on a cleaner framework-owned addon layer and a more consistent DVAR structure.

### Included in v1.4
- reworked addon routing through `framework/sources/core/addons.gsc`
- cleaned `framework.gsc` bootstrap flow
- simplified `shared.gsc` into shared-only helpers
- rebuilt DVAR-controlled HUD toggle
- rebuilt DVAR-controlled bot management
- reworked stim boost DVAR ownership
- cleaned combat addon watcher foundations
- unified `fw_` naming for addon DVARs

The goal of this version is to keep the public framework cleaner, easier to maintain, and easier to expand without falling back into a monolithic project structure.

---

## Project Structure

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
            ├── stim.gsc
            └── weapons.gsc

---

## Console DVAR Commands

```commands
fw_nohud

fw_addbot
fw_kickbot
fw_bot_team
fw_bot_difficulty

fw_stim_boost_speed
fw_stim_boost_duration
fw_stim_boost_decay

fw_inf_ammo
fw_no_recoil
