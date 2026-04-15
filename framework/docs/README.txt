📌 187 — FRAMEWORK — README

Created by PEACE
Discord: @peaceofficial
Started: 03.25.2026

OVERVIEW
187 — FRAMEWORK is a modular GSC framework for IW8-Mod and Warzone, built for clean project structure, reusable systems, and long-term custom development.

The framework is designed to keep shared infrastructure and reusable gameplay systems separated from project-specific code so the project stays easier to maintain, expand, and rework over time.

This release focuses on framework-owned systems only.

ENTRY POINT
custom_scripts/framework.gsc

ROUTER
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

CURRENT SYSTEM DIRECTION
The framework currently centers around:
- modular player lifecycle handling
- reward-based perk flow
- SR / ranked-style progression messaging
- stim boost tuning through live DVARs
- framework-owned startup, shared helpers, and gameplay systems

DESIGN GOALS
- Keep framework.gsc as the single bootstrap.
- Keep gamemode.gsc as a safe framework-owned router layer.
- Group source files by responsibility.
- Separate low-level engine-facing code from higher-level gameplay logic.
- Keep reusable systems modular so future forks and rewrites stay manageable.
- Prefer clean source ownership over expanding one script into too many responsibilities.

RELEASE NOTE
Legacy gamemode-specific implementation has been removed from this release. The current public framework focuses on framework-owned core and gameplay systems only.

STATUS
187 — FRAMEWORK is an active long-term framework project that began on 03.25.2026 and continues to evolve around stability, reusable systems, and cleaner project ownership.