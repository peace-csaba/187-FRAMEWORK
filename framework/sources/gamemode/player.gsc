// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: player.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned player systems
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

        self notify("stop_framework_player_spawn");
        self thread frameworkPlayerSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

frameworkPlayerSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_player_spawn");
    level endon("game_ended");

    // Reserved for framework-owned player features.
}
