// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: movement.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkMovementEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_movement_spawn");
        self thread handleMovementSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleMovementSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_movement_spawn");
    level endon("game_ended");

    // Reserved for framework-owned movement features.
}
