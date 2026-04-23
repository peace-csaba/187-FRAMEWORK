// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: rules.gsc

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    level.frameworkRulesEnabled = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_rules_spawn");
        self thread handleRulesSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleRulesSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_rules_spawn");
    level endon("game_ended");

    // Reserved for framework-owned round and spawn rules.
}
