// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: combat.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkCombatEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_combat_spawn");
        self thread handleCombatSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleCombatSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_combat_spawn");
    level endon("game_ended");

    // Reserved for framework-owned combat features.
}
