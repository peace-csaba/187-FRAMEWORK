// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: world.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkWorldEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_world_spawn");
        self thread handleWorldSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleWorldSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_world_spawn");
    level endon("game_ended");

    // Reserved for framework-owned world features.
}
