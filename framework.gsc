// 📌 187 — FRAMEWORK

// Version: 1.5

////////////////////////////////////////////////////////////////////////

// File: framework.gsc

////////////////////////////////////////////////////////////////////////

// Main Entry

setupFrameworkConfig()
{
    level.enableAnnouncer = true;
    level.enableKillRewards = true;
    level.enableStimBoost = true;
    level.enablePlateRewards = true;
    level.enableWeaponSpeedBoost = true;
    level.enableAddons = true;
}

////////////////////////////////////////////////////////////////////////

// Full local reset
//
// Use this only when you truly want to wipe everything, including SR.
resetFrameworkPlayerStats(player)
{
    if (!isDefined(player))
        return;

    player.frameworkSR = 250;
    player.frameworkKills = 0;
    player.frameworkDeaths = 0;
    player.killStreak = 0;
    player.specialistActive = false;
}

////////////////////////////////////////////////////////////////////////

// Match-only reset
//
// Keeps saved rank/SR but clears round/match stats.
resetFrameworkMatchStats(player)
{
    if (!isDefined(player))
        return;

    player custom_scripts\framework\sources\core\data::resetFrameworkMatchData();
}

////////////////////////////////////////////////////////////////////////

// Match-only reset for all connected players
resetFrameworkAllPlayerStats()
{
    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        resetFrameworkMatchStats(player);
    }
}

////////////////////////////////////////////////////////////////////////

// BR-safe reset
//
// Wait until infil is ready, then clear all warmup match stats once.
// SR is preserved.
watchFrameworkInfilReset()
{
    level endon("game_ended");

    if (isDefined(level.frameworkInfilResetDone) && level.frameworkInfilResetDone)
        return;

    level waittill("infils_ready");
    wait 0.25;

    level.frameworkInfilResetDone = true;
    resetFrameworkAllPlayerStats();

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        player iPrintlnBold("^2MATCH STARTED^7 - ^5MATCH STATS RESET");
    }
}

////////////////////////////////////////////////////////////////////////

init()
{
    level.prefix = "^7[^5187^7]^7 » ";
    level.frameworkInfilResetDone = false;

    setupFrameworkConfig();

    custom_scripts\framework\sources\gameplay\perks::initPerkNames();
    custom_scripts\framework\sources\gameplay\perks::buildPerkList();

    if (level.enableAddons)
        level thread custom_scripts\framework\sources\core\addons::frameworkInit();

    level thread onPlayerConnected();
    level thread watchFrameworkInfilReset();
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);

        if (!isDefined(player))
            continue;

        player custom_scripts\framework\sources\core\data::loadFrameworkPlayerData();

        if (level.enableAnnouncer)
            player thread custom_scripts\framework\sources\core\ui::startAnnouncer();

        if (level.enableAddons)
            player thread custom_scripts\framework\sources\core\addons::onFrameworkPlayerConnected();

        player thread onPlayerSpawned();
    }
}

////////////////////////////////////////////////////////////////////////

onPlayerSpawned()
{
    level endon("game_ended");
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_killRewards");
        self notify("stop_stimBoost");
        self notify("stop_weaponSpeedBoost");
        self notify("stop_framework_death_watch");

        self.stimActive = false;

        self custom_scripts\framework\sources\core\data::loadFrameworkPlayerData();

        if (!isDefined(self.frameworkKills))
            self.frameworkKills = 0;

        if (!isDefined(self.frameworkDeaths))
            self.frameworkDeaths = 0;

        if (!isDefined(self.killStreak))
            self.killStreak = 0;

        if (!isDefined(self.specialistActive))
            self.specialistActive = false;

        wait 0.25;
        self custom_scripts\framework\sources\core\data::showFrameworkSavedDataDebug();

        if (isAlive(self))
            self setmovespeedscale(1.0);

        if (level.enableKillRewards)
            self thread custom_scripts\framework\sources\gameplay\rewards::killRewards();

        if (level.enableStimBoost)
            self thread custom_scripts\framework\sources\gameplay\stim::stimBoost();

        if (level.enableWeaponSpeedBoost)
            self thread custom_scripts\framework\sources\gameplay\weapons::weaponSpeedBoost();
    }
}