// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: movement.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned movement systems
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

        self notify("stop_framework_movement_spawn");
        self thread frameworkMovementSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

frameworkMovementSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_movement_spawn");
    level endon("game_ended");

    // Reserved for framework-owned movement features.
}
