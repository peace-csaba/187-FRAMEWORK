// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: combat.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned combat systems
//
// Clean-room scaffold for future rebuild.

init()
{
    level endon("game_ended");
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_combat_spawn");
        self thread frameworkCombatSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

frameworkCombatSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_combat_spawn");
    level endon("game_ended");

    // Reserved for framework-owned combat features.
}
