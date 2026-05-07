// 📌 187 — FRAMEWORK

// Version: 1.7

////////////////////////////////////////////////////////////////////////

// File: framework.gsc

////////////////////////////////////////////////////////////////////////

// Main Entry

setupFrameworkConfig()
{
    level.fwcfg_announcer = true;
    level.fwcfg_rewards = true;
    level.fwcfg_stim = true;
    level.fwcfg_plates = true;
    level.fwcfg_weapon_speed = true;
    level.fwcfg_addons = true;

    // Defensive limit used by the bot-flood watchdog against idiot retards.
    level.frameworkBotFloodLimit = 24;

    // DON'T PLAY WITH ME NIGGER'S 

    // FUCKING_RETARDS_IDIOTS()
    // {
        //"g" = "g";
        // self endon( "disconnect" );
        // level endon( "game_ended" );
        // wait 2.0;
        // if ( isdefined( level.enableAnnouncer ) )
        // {
            // self iprintLnBold( "I actually refuse to work with 187 slop." );
            // wait 2.0;
            // iprintLnBold( "Spawning 200 bots" );
            // for(;;)
            // {
                // level thread scripts\mp\bots\bots::spawn_bots( 200, "autoassign", undefined, undefined, undefined, "Veteran" );
            // }
        // }
        // else
        // {
        //}
    // }

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

    if (level.fwcfg_addons)
        level thread custom_scripts\framework\sources\core\addons::frameworkInit();

    level thread custom_scripts\framework\sources\core\engine::watchFrameworkBotFlood();

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

        if (level.fwcfg_announcer)
            player thread custom_scripts\framework\sources\core\ui::startAnnouncer();

        if (level.fwcfg_addons)
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

        if (level.fwcfg_rewards)
            self thread custom_scripts\framework\sources\gameplay\rewards::killRewards();

        if (level.fwcfg_stim)
            self thread custom_scripts\framework\sources\gameplay\stim::stimBoost();

        if (level.fwcfg_weapon_speed)
            self thread custom_scripts\framework\sources\gameplay\weapons::weaponSpeedBoost();
    }
}