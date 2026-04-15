187 — FRAMEWORK is a modular GSC framework built for clean project structure, easier maintenance, and long-term expansion.

The framework separates reusable systems from project-specific or gamemode-specific logic so features can be added, tested, and reworked without turning the project into one large monolithic script.

This project is designed as a long-term base for future gameplay systems, balance changes, custom progression, and framework-owned mode logic.

CURRENT SYSTEM DIRECTION
The framework currently centers around:
- modular player lifecycle handling
- reward-based perk flow
- SR / ranked-style progression messaging
- stim boost tuning through live DVARs
- framework-owned system routing and separation

DESIGN GOALS
- Keep framework.gsc as the single bootstrap.
- Keep gamemode.gsc as the framework-owned router. (@elbasedd - later?!)
- Group source files by responsibility.
- Separate low-level engine-facing code from higher-level gameplay logic.
- Keep reusable systems modular so future forks and rewrites stay manageable.
- Prefer clean source ownership over expanding one script into too many responsibilities.

STATUS
187 — FRAMEWORK is an active long-term framework project that began on 03.25.2026 and continues to evolve around stability, reusable systems, and cleaner project ownership.
