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

    // Only start modules that currently exist and are in use
    level thread custom_scripts\framework\sources\gamemode\visual::init();
    level thread custom_scripts\framework\sources\gamemode\bots::init();
    level thread custom_scripts\framework\sources\gamemode\combat::init();
}

////////////////////////////////////////////////////////////////////////

onFrameworkPlayerConnected()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!isbot(self))
        self custom_scripts\framework\sources\core\shared::frameworkPrint("^5[187]^7 » ^2Gamemode Systems Loaded");

    // Route directly to per-module player handlers
    self thread custom_scripts\framework\sources\gamemode\visual::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\bots::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\combat::onPlayerConnected();
}

////////////////////////////////////////////////////////////////////////

// Gamemode config / DVAR defaults
initFrameworkGamemodeDvars()
{
    if (isDefined(level.frameworkGamemodeDvarsReady))
        return;

    level.frameworkGamemodeDvarsReady = true;

    // VISUAL
    frameworkEnsureGamemodeDvar("fw_nohud", "0");

    // BOTS
    frameworkEnsureGamemodeDvar("fw_addbot", "0");
    frameworkEnsureGamemodeDvar("fw_kickbot", "0");
    frameworkEnsureGamemodeDvar("fw_bot_team", "autoassign");
    frameworkEnsureGamemodeDvar("fw_bot_difficulty", "mixed");

    // COMBAT
    frameworkEnsureGamemodeDvar("fw_inf_ammo", "0");
    frameworkEnsureGamemodeDvar("fw_no_recoil", "0");
}

////////////////////////////////////////////////////////////////////////

// Safe fallback instead of relying on setDvarIfUninitialized
frameworkEnsureGamemodeDvar(name, value)
{
    current = getDvar(name);

    if (!isDefined(current) || current == "")
        setDvar(name, value);
}