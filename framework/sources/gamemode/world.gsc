// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: world.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned world systems
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

        self notify("stop_framework_world_spawn");
        self thread frameworkWorldSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

frameworkWorldSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_world_spawn");
    level endon("game_ended");

    // Reserved for framework-owned world features.
}
