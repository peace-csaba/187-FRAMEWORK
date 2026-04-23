// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: loadout.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkLoadoutEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_loadout_spawn");
        self thread handleLoadoutSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleLoadoutSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_loadout_spawn");
    level endon("game_ended");

    // Reserved for framework-owned loadout and equipment logic.
}
