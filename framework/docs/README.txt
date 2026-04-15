📌 187 — FRAMEWORK — README

Created by PEACE
Discord: @peaceofficial
Started: 03.25.2026

OVERVIEW
187 — FRAMEWORK is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable systems from project-specific or gamemode-specific logic so features can be added, tested, and reworked without turning the project into one large monolithic script.

This project is designed as a long-term base for future gameplay systems, balance changes, custom progression, and framework-owned mode logic.

ENTRY POINT
custom_scripts/framework.gsc

MAIN ROUTER
custom_scripts/framework/gamemode.gsc

PROJECT STRUCTURE
custom_scripts/
    framework.gsc
    framework/
        gamemode.gsc
        docs/
        sources/
            core/
            gameplay/
            gamemode/

SOURCE GROUPS

core/
Shared framework infrastructure and engine-facing helpers.
Examples:
- shared.gsc
- ui.gsc
- engine.gsc

gameplay/
Reusable gameplay systems that can be reused across projects or mode variants.
Examples:
- perks.gsc
- rewards.gsc
- stim.gsc

gamemode/
Project-specific or mode-specific systems.
Examples:
- movement.gsc
- combat.gsc
- visual.gsc
- world.gsc
- player.gsc
- bots.gsc

CURRENT SYSTEM DIRECTION
The framework currently centers around:
- modular player lifecycle handling
- reward-based perk flow
- SR / ranked-style progression messaging
- stim boost tuning through live DVARs
- framework-owned system routing and separation

DESIGN GOALS
- Keep framework.gsc as the single bootstrap.
- Keep gamemode.gsc as the framework-owned router.
- Group source files by responsibility.
- Separate low-level engine-facing code from higher-level gameplay logic.
- Keep reusable systems modular so future forks and rewrites stay manageable.
- Prefer clean source ownership over expanding one script into too many responsibilities.

STATUS
187 — FRAMEWORK is an active long-term framework project that began on 03.25.2026 and continues to evolve around stability, reusable systems, and cleaner project ownership.