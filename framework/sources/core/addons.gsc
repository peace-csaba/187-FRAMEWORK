// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: addons.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned addon systems
//
// Active DVARs:
// - fw_nohud
// - fw_addbot
// - fw_kickbot
// - fw_bot_team
// - fw_bot_difficulty
// - fw_stim_boost_speed
// - fw_stim_boost_duration
// - fw_stim_boost_decay
// - fw_inf_ammo
// - fw_no_recoil

main()
{
    // Framework-owned, intentionally left empty.
}

////////////////////////////////////////////////////////////////////////

// Addon bootstrap
frameworkInit()
{
    level endon("game_ended");

    initFrameworkAddonDvars();

    level thread watchBotDvars();
    level thread watchFrameworkStimDvars();
}

////////////////////////////////////////////////////////////////////////

// Per-player addon startup
onFrameworkPlayerConnected()
{
    self endon("disconnect");
    level endon("game_ended");

    self thread watchFrameworkNoHudDvar();
    self thread watchFrameworkInfiniteAmmoDvar();
    self thread watchFrameworkNoRecoilDvar();
    self thread frameworkAddonPlayerRuntime();
}

////////////////////////////////////////////////////////////////////////

frameworkAddonPlayerRuntime()
{
    self endon("disconnect");
    level endon("game_ended");

    self custom_scripts\framework\sources\core\shared::frameworkPrint("^5[187]^7 » ^2Addon Systems Loaded");

    for (;;)
    {
        self waittill("spawned_player");

        if (isbot(self))
            return;

        self notify("stop_framework_addon_runtime");
        self thread handleFrameworkAddonSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleFrameworkAddonSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_addon_runtime");
    level endon("game_ended");

    wait 0.15;

    self applyFrameworkCombatState();
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// DVAR DEFAULTS
// =====================================================

initFrameworkAddonDvars()
{
    if (isDefined(level.frameworkAddonDvarsReady))
        return;

    level.frameworkAddonDvarsReady = true;

    // Visual
    setDvarIfUninitialized("fw_nohud", 0);

    // Bots
    setDvarIfUninitialized("fw_addbot", 0);
    setDvarIfUninitialized("fw_kickbot", 0);
    setDvarIfUninitialized("fw_bot_team", "autoassign");
    setDvarIfUninitialized("fw_bot_difficulty", "regular");

    // Stim
    setDvarIfUninitialized("fw_stim_boost_speed", 1.05);
    setDvarIfUninitialized("fw_stim_boost_duration", 10);
    setDvarIfUninitialized("fw_stim_boost_decay", 0.1);

    // Combat
    setDvarIfUninitialized("fw_inf_ammo", 0);
    setDvarIfUninitialized("fw_no_recoil", 0);

    level.frameworkLastAddBot = 0;
    level.frameworkLastKickBot = 0;
    level.frameworkLastBotTeam = "";
    level.frameworkLastBotDifficulty = "";

    frameworkEnsureStimDvars();
    frameworkCacheStimDvars();
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// VISUAL
// =====================================================

watchFrameworkNoHudDvar()
{
    self endon("disconnect");
    level endon("game_ended");

    lastValue = -1;

    for (;;)
    {
        currentValue = getDvarInt("fw_nohud");

        if (currentValue != 0 && currentValue != 1)
        {
            currentValue = 0;
            setDvar("fw_nohud", "0");
        }

        if (currentValue != lastValue)
        {
            lastValue = currentValue;
            self applyFrameworkNoHudValue(currentValue);
        }

        wait 0.2;
    }
}

////////////////////////////////////////////////////////////////////////

applyFrameworkNoHudValue(value)
{
    if (value != 0 && value != 1)
        value = 0;

    self setclientomnvar("ui_hide_full_hud", value);
    setDvar("LOPKSRNTTS", value == 1 ? 0 : 1);

    if (value == 1)
        self iprintln(level.prefix + "^5[VISUAL]^7 » ^1No HUD:^7 ^2Enabled");
    else
        self iprintln(level.prefix + "^5[VISUAL]^7 » ^1No HUD:^7 ^1Disabled");
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// BOTS
// =====================================================

resolveFrameworkBotTeam(rawValue)
{
    if (!isDefined(rawValue) || rawValue == "")
        return "autoassign";

    value = toLower(rawValue);

    if (value == "auto" || value == "autoassign" || value == "random")
        return "autoassign";

    if (value == "allies" || value == "ally")
        return "allies";

    if (value == "axis" || value == "enemy")
        return "axis";

    return "autoassign";
}

////////////////////////////////////////////////////////////////////////

resolveFrameworkBotDifficulty(rawValue)
{
    if (!isDefined(rawValue) || rawValue == "")
        return "regular";

    value = toLower(rawValue);

    if (value == "1" || value == "easy" || value == "recruit")
        return "recruit";

    if (value == "2" || value == "normal" || value == "regular")
        return "regular";

    if (value == "3" || value == "hard" || value == "hardened")
        return "hardened";

    if (value == "4" || value == "vet" || value == "veteran")
        return "veteran";

    return "regular";
}

////////////////////////////////////////////////////////////////////////

getFrameworkBotTeamLabel(teamValue)
{
    if (!isDefined(teamValue) || teamValue == "autoassign")
        return "Autoassign";

    return teamValue;
}

////////////////////////////////////////////////////////////////////////

broadcastFrameworkBotMessage(text)
{
    foreach (player in level.players)
    {
        if (isDefined(player))
            player iprintln(level.prefix + "^5[BOTS]^7 » " + text);
    }
}

////////////////////////////////////////////////////////////////////////

watchBotDvars()
{
    level endon("game_ended");

    for (;;)
    {
        wait 0.25;

        addCount = getDvarInt("fw_addbot");
        kickCount = getDvarInt("fw_kickbot");
        teamRaw = getDvar("fw_bot_team");
        difficultyRaw = getDvar("fw_bot_difficulty");

        if (addCount < 0)
        {
            addCount = 0;
            setDvar("fw_addbot", "0");
        }

        if (kickCount < 0)
        {
            kickCount = 0;
            setDvar("fw_kickbot", "0");
        }

        teamValue = resolveFrameworkBotTeam(teamRaw);
        difficultyValue = resolveFrameworkBotDifficulty(difficultyRaw);

        if (teamValue != level.frameworkLastBotTeam)
        {
            level.frameworkLastBotTeam = teamValue;
            setDvar("fw_bot_team", teamValue);
            level broadcastFrameworkBotMessage("^2Team:^7 " + getFrameworkBotTeamLabel(teamValue));
        }

        if (difficultyValue != level.frameworkLastBotDifficulty)
        {
            level.frameworkLastBotDifficulty = difficultyValue;
            setDvar("fw_bot_difficulty", difficultyValue);
            level broadcastFrameworkBotMessage("^2Difficulty:^7 " + difficultyValue);
        }

        if (addCount > 0)
        {
            level custom_scripts\framework\sources\core\engine::spawnBotsSafe(addCount, teamValue, difficultyValue);
            level broadcastFrameworkBotMessage("^2Spawned:^7 " + addCount + " ^2bot(s)^7 • ^2Team:^7 " + getFrameworkBotTeamLabel(teamValue) + " ^7• ^2Difficulty:^7 " + difficultyValue);

            setDvar("fw_addbot", "0");
            level.frameworkLastAddBot = 0;
        }

        if (kickCount > 0)
        {
            removed = level custom_scripts\framework\sources\core\engine::removeBotsSafe(kickCount, teamValue);
            level broadcastFrameworkBotMessage("^1Kicked:^7 " + removed + " ^1bot(s)");

            setDvar("fw_kickbot", "0");
            level.frameworkLastKickBot = 0;
        }
    }
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// STIM
// =====================================================

frameworkBroadcastSettingChange(label, value, color)
{
    foreach (player in level.players)
    {
        if (isDefined(player))
            player iprintln(level.prefix + "^1[DVAR]^7 » " + color + label + ":^7 " + color + value + " ^7(updated)");
    }
}

////////////////////////////////////////////////////////////////////////

frameworkEnsureStimDvars()
{
    speed = getDvarFloat("fw_stim_boost_speed");
    duration = getDvarInt("fw_stim_boost_duration");
    decay = getDvarFloat("fw_stim_boost_decay");

    if (!isDefined(speed) || speed <= 0)
    {
        speed = 1.05;
        setDvar("fw_stim_boost_speed", "" + speed);
    }

    if (!isDefined(duration) || duration <= 0)
    {
        duration = 10;
        setDvar("fw_stim_boost_duration", "" + duration);
    }

    if (!isDefined(decay) || decay < 0)
    {
        decay = 0.1;
        setDvar("fw_stim_boost_decay", "" + decay);
    }

    level.frameworkStimSpeed = speed;
    level.frameworkStimDuration = duration;
    level.frameworkStimDecay = decay;
}

////////////////////////////////////////////////////////////////////////

frameworkCacheStimDvars()
{
    level.cachedStimSpeed = level.frameworkStimSpeed;
    level.cachedStimDuration = level.frameworkStimDuration;
    level.cachedStimDecay = level.frameworkStimDecay;
}

////////////////////////////////////////////////////////////////////////

frameworkCheckStimDvarChanges()
{
    speed = getDvarFloat("fw_stim_boost_speed");
    duration = getDvarInt("fw_stim_boost_duration");
    decay = getDvarFloat("fw_stim_boost_decay");

    if (!isDefined(speed) || speed <= 0)
        speed = level.cachedStimSpeed;

    if (!isDefined(duration) || duration <= 0)
        duration = level.cachedStimDuration;

    if (!isDefined(decay) || decay < 0)
        decay = level.cachedStimDecay;

    if (speed != level.cachedStimSpeed)
    {
        level.cachedStimSpeed = speed;
        frameworkBroadcastSettingChange("Stim Speed", speed, "^2");
    }

    if (duration != level.cachedStimDuration)
    {
        level.cachedStimDuration = duration;
        frameworkBroadcastSettingChange("Stim Duration", duration, "^3");
    }

    if (decay != level.cachedStimDecay)
    {
        level.cachedStimDecay = decay;
        frameworkBroadcastSettingChange("Stim Decay", decay, "^1");
    }

    level.frameworkStimSpeed = speed;
    level.frameworkStimDuration = duration;
    level.frameworkStimDecay = decay;
}

////////////////////////////////////////////////////////////////////////

frameworkEnforceStimDvars()
{
    if (getDvarFloat("fw_stim_boost_speed") != level.frameworkStimSpeed)
        setDvar("fw_stim_boost_speed", "" + level.frameworkStimSpeed);

    if (getDvarInt("fw_stim_boost_duration") != level.frameworkStimDuration)
        setDvar("fw_stim_boost_duration", "" + level.frameworkStimDuration);

    if (getDvarFloat("fw_stim_boost_decay") != level.frameworkStimDecay)
        setDvar("fw_stim_boost_decay", "" + level.frameworkStimDecay);
}

////////////////////////////////////////////////////////////////////////

watchFrameworkStimDvars()
{
    level endon("game_ended");

    for (;;)
    {
        wait 1;
        frameworkCheckStimDvarChanges();
        frameworkEnforceStimDvars();
    }
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// COMBAT
// =====================================================

applyFrameworkCombatState()
{
    ammoState = getDvarInt("fw_inf_ammo");
    recoilState = getDvarInt("fw_no_recoil");

    if (ammoState != 0 && ammoState != 1)
        ammoState = 0;

    if (recoilState != 0 && recoilState != 1)
        recoilState = 0;

    self notify("stop_framework_infinite_ammo");
    self notify("stop_framework_no_recoil");

    if (ammoState == 1)
        self thread frameworkInfiniteAmmoLoop();

    if (recoilState == 1)
        self thread frameworkNoRecoilLoop();
}

////////////////////////////////////////////////////////////////////////

watchFrameworkInfiniteAmmoDvar()
{
    self endon("disconnect");
    level endon("game_ended");

    lastValue = getDvarInt("fw_inf_ammo");

    if (lastValue != 0 && lastValue != 1)
    {
        lastValue = 0;
        setDvar("fw_inf_ammo", "0");
    }

    if (lastValue == 1)
        self thread frameworkInfiniteAmmoLoop();

    for (;;)
    {
        currentValue = getDvarInt("fw_inf_ammo");

        if (currentValue != 0 && currentValue != 1)
        {
            currentValue = 0;
            setDvar("fw_inf_ammo", "0");
        }

        if (currentValue != lastValue)
        {
            lastValue = currentValue;
            self notify("stop_framework_infinite_ammo");

            if (currentValue == 1)
            {
                self thread frameworkInfiniteAmmoLoop();
                self iprintln(level.prefix + "^5[COMBAT]^7 » ^2Infinite Ammo:^7 ^2Enabled");
            }
            else
            {
                self iprintln(level.prefix + "^5[COMBAT]^7 » ^2Infinite Ammo:^7 ^1Disabled");
            }
        }

        wait 0.1;
    }
}

////////////////////////////////////////////////////////////////////////

frameworkInfiniteAmmoLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_infinite_ammo");
    level endon("game_ended");

    self custom_scripts\framework\sources\core\engine::refillAllAmmoSafe();

    for (;;)
    {
        scripts\engine\utility::waittill_any_ents(
            self, "weapon_fired",
            self, "grenade_fire",
            self, "force_regeneration"
        );

        self custom_scripts\framework\sources\core\engine::refillAllAmmoSafe();
    }
}

////////////////////////////////////////////////////////////////////////

watchFrameworkNoRecoilDvar()
{
    self endon("disconnect");
    level endon("game_ended");

    lastValue = getDvarInt("fw_no_recoil");

    if (lastValue != 0 && lastValue != 1)
    {
        lastValue = 0;
        setDvar("fw_no_recoil", "0");
    }

    if (lastValue == 1)
        self thread frameworkNoRecoilLoop();

    for (;;)
    {
        currentValue = getDvarInt("fw_no_recoil");

        if (currentValue != 0 && currentValue != 1)
        {
            currentValue = 0;
            setDvar("fw_no_recoil", "0");
        }

        if (currentValue != lastValue)
        {
            lastValue = currentValue;
            self notify("stop_framework_no_recoil");

            if (currentValue == 1)
            {
                self thread frameworkNoRecoilLoop();
                self iprintln(level.prefix + "^5[COMBAT]^7 » ^2No Recoil:^7 ^2Enabled");
            }
            else
            {
                self custom_scripts\framework\sources\core\engine::disableNoRecoilSafe();
                self iprintln(level.prefix + "^5[COMBAT]^7 » ^2No Recoil:^7 ^1Disabled");
            }
        }

        wait 0.1;
    }
}

////////////////////////////////////////////////////////////////////////

frameworkNoRecoilLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_no_recoil");
    level endon("game_ended");

    for (;;)
    {
        self custom_scripts\framework\sources\core\engine::enableNoRecoilSafe();
        wait 0.05;
    }
}