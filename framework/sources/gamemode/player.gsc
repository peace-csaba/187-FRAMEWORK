// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: player.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkPlayerSystemsEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    if (!isDefined(self.frameworkPlayerFlags))
        self.frameworkPlayerFlags = [];

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_player_spawn");
        self thread handlePlayerSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handlePlayerSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_player_spawn");
    level endon("game_ended");

    // Reserved for framework-owned player systems.
}
