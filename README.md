# 📌 187 — FRAMEWORK

**187 — FRAMEWORK** is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable systems from project-specific systems so features can be added, tested, and reworked without turning the project into one large monolithic script.

This project is designed as a long-term base for future gameplay systems, balance changes, custom progression, and framework-owned mode logic.

---

## Current Release

<<<<<<< HEAD
### Clean Gamemode Scaffold — v1.3  
**The Medical Nose Update**

This release includes a fresh gamemode scaffold under `framework/sources/gamemode/` with the first rebuilt systems for:

- visual HUD toggling
- bot management
- reworked stim DVAR control
- modular combat rebuild foundations

The goal of this version is to keep the public framework clean, modular, and easy to expand.

---

## Console DVAR Commands

Use these in console with `set`:

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
