// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: gamemode.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned gamemode router

main()
{
    // Framework-owned, intentionally left empty.
}

////////////////////////////////////////////////////////////////////////

frameworkInit()
{
    level endon("game_ended");

    initFrameworkGamemodeDvars();

    level thread custom_scripts\framework\sources\gamemode\bots::init();
    level thread custom_scripts\framework\sources\gamemode\visual::init();
    level thread custom_scripts\framework\sources\gamemode\movement::init();
    level thread custom_scripts\framework\sources\gamemode\combat::init();
    level thread custom_scripts\framework\sources\gamemode\world::init();
    level thread custom_scripts\framework\sources\gamemode\player::init();
}

////////////////////////////////////////////////////////////////////////

onFrameworkPlayerConnected()
{
    self endon("disconnect");
    level endon("game_ended");

    self thread frameworkPlayerRuntime();
}

////////////////////////////////////////////////////////////////////////

frameworkPlayerRuntime()
{
    self endon("disconnect");
    level endon("game_ended");

    self custom_scripts\framework\sources\core\shared::frameworkPrint("^5[187]^7 » ^2Gamemode Systems Loaded");

    for (;;)
    {
        self waittill("spawned_player");

        if (isbot(self))
            return;

        self notify("stop_framework_gamemode_runtime");

        self thread custom_scripts\framework\sources\gamemode\movement::onPlayerSpawned();
        self thread custom_scripts\framework\sources\gamemode\combat::onPlayerSpawned();
        self thread custom_scripts\framework\sources\gamemode\visual::onPlayerSpawned();
        self thread custom_scripts\framework\sources\gamemode\world::onPlayerSpawned();
        self thread custom_scripts\framework\sources\gamemode\player::onPlayerSpawned();
        self thread custom_scripts\framework\sources\gamemode\bots::onPlayerSpawned();
    }
}

////////////////////////////////////////////////////////////////////////

// Gamemode config / DVAR defaults
initFrameworkGamemodeDvars()
{
    if (isDefined(level.frameworkGamemodeDvarsReady))
        return;

    level.frameworkGamemodeDvarsReady = true;

    // Visual
    setDvarIfUninitialized("fw_nohud", 0);

    // Bots
    setDvarIfUninitialized("fw_addbot", 0);
    setDvarIfUninitialized("fw_kickbot", 0);
    setDvarIfUninitialized("fw_bot_team", "autoassign");
    setDvarIfUninitialized("fw_bot_difficulty", "mixed");
}