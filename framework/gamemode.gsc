// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: gamemode.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned gamemode router
//
// Clean-room router for project-specific systems.

frameworkInit()
{
    level endon("game_ended");

    level thread custom_scripts\framework\sources\gamemode\rules::init();
    level thread custom_scripts\framework\sources\gamemode\progression::init();
    level thread custom_scripts\framework\sources\gamemode\loadout::init();
    level thread custom_scripts\framework\sources\gamemode\movement::init();
    level thread custom_scripts\framework\sources\gamemode\combat::init();
    level thread custom_scripts\framework\sources\gamemode\visual::init();
    level thread custom_scripts\framework\sources\gamemode\world::init();
    level thread custom_scripts\framework\sources\gamemode\player::init();
    level thread custom_scripts\framework\sources\gamemode\bots::init();
}

////////////////////////////////////////////////////////////////////////

onFrameworkPlayerConnected()
{
    self endon("disconnect");

    self thread custom_scripts\framework\sources\gamemode\rules::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\progression::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\loadout::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\movement::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\combat::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\visual::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\world::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\player::onPlayerConnected();
    self thread custom_scripts\framework\sources\gamemode\bots::onPlayerConnected();
}
