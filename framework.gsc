// 📌 187 — FRAMEWORK

// Version: 1.3

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

    // Clean framework-owned gamemode layer
    level.enableGamemode = true;
}

////////////////////////////////////////////////////////////////////////

// Reset all framework-tracked player state
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

// Reset all connected players
resetFrameworkAllPlayerStats()
{
    foreach (player in level.players)
        resetFrameworkPlayerStats(player);
}

////////////////////////////////////////////////////////////////////////

// BR-safe reset
//
// Wait until infil is ready, then clear all warmup stats once.
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

        player iPrintlnBold("^2MATCH STARTED^7 - ^5SR RESET");
    }
}

////////////////////////////////////////////////////////////////////////

// Framework startup
init()
{
    level.prefix = "^7[^5187^7]^7 » ";
    level.frameworkInfilResetDone = false;

    setupFrameworkConfig();

    custom_scripts\framework\sources\gameplay\perks::initPerkNames();
    custom_scripts\framework\sources\gameplay\perks::buildPerkList();

    level thread custom_scripts\framework\sources\core\shared::initDvarsProtection();

    if (level.enableGamemode)
        level thread custom_scripts\framework\gamemode::frameworkInit();

    level thread onPlayerConnected();
    level thread watchFrameworkInfilReset();
}

////////////////////////////////////////////////////////////////////////

// Player connect flow
onPlayerConnected()
{
    level endon("game_ended");

    for (;;)
    {
        level waittill("connected", player);

        if (!isDefined(player))
            continue;

        resetFrameworkPlayerStats(player);

        if (level.enableAnnouncer)
            player thread custom_scripts\framework\sources\core\ui::startAnnouncer();

        if (level.enableGamemode)
            player thread custom_scripts\framework\gamemode::onFrameworkPlayerConnected();

        player thread onPlayerSpawned();
    }
}

////////////////////////////////////////////////////////////////////////

// Player spawn flow
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

        if (!isDefined(self.frameworkSR))
            self.frameworkSR = 250;

        if (!isDefined(self.frameworkKills))
            self.frameworkKills = 0;

        if (!isDefined(self.frameworkDeaths))
            self.frameworkDeaths = 0;

        if (!isDefined(self.killStreak))
            self.killStreak = 0;

        if (!isDefined(self.specialistActive))
            self.specialistActive = false;

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