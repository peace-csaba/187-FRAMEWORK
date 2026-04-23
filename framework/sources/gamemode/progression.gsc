// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: progression.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkProgressionEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    if (!isDefined(self.frameworkMatchXP))
        self.frameworkMatchXP = 0;

    if (!isDefined(self.frameworkLevel))
        self.frameworkLevel = 1;

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_progression_spawn");
        self thread handleProgressionSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleProgressionSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_progression_spawn");
    level endon("game_ended");

    // Reserved for framework-owned progression logic.
}
