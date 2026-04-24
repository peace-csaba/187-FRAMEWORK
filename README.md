# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable systems from project-specific systems so features can be added, tested, and reworked without turning the project into one large monolithic script.

This project is designed as a long-term base for future gameplay systems, balance changes, custom progression, and framework-owned mode logic.

Preview:
<video src="https://github.com/peace-csaba/187-FRAMEWORK/releases/download/1.5/2026-04-24_08-44-07.mp4">

---

## Current Release — Saving / Data System via GSC - v1.5

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
The current implementation is a **persistence test / fallback structure**, not a fully proven restart-safe storage backend.

That means:
- runtime/session handling is supported
- the framework structure is ready for future persistence work
- true restart-safe rank saving will require a stronger backend if the current build does not expose proper persistent stat functions

### Why this matters
Even though full restart-safe persistence is still backend-dependent, the framework is now prepared for it.

When a better storage backend is found later, only `core/data.gsc` should need to change, while the rest of the framework can continue using the same save/load flow.

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
