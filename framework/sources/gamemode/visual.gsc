// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: visual.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkVisualEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_visual_spawn");
        self thread handleVisualSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleVisualSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_visual_spawn");
    level endon("game_ended");

    // Reserved for framework-owned visual features.
}
