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

// - fw_debug
// - fw_status

// - fw_noclip
// - fw_noclip_bind
// - fw_noclip_speed
// - fw_noclip_sprint_speed

// - fw_bounce_spawn
// - fw_bounce_delete
// - fw_bounce_clear
// - fw_bounce_bind
// - fw_bounce_radius
// - fw_bounce_min_fall_speed
// - fw_bounce_marker
// - fw_bounce_marker_model

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
    self thread watchFrameworkNoClipDvar();
    self thread watchFrameworkBounceDvars();
    self thread watchFrameworkBounceMonitor();
    self thread watchFrameworkStatusDvar();
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

    self disableFrameworkNoClip();
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

    // Debug / status
    setDvarIfUninitialized("fw_debug", 0);
    setDvarIfUninitialized("fw_status", 0);

    // Noclip
    setDvarIfUninitialized("fw_noclip", 0);
    setDvarIfUninitialized("fw_noclip_bind", 1);
    setDvarIfUninitialized("fw_noclip_speed", 33);
    setDvarIfUninitialized("fw_noclip_sprint_speed", 80);

    // Bounce
    setDvarIfUninitialized("fw_bounce_spawn", 0);
    setDvarIfUninitialized("fw_bounce_delete", 0);
    setDvarIfUninitialized("fw_bounce_clear", 0);
    setDvarIfUninitialized("fw_bounce_bind", 0);
    setDvarIfUninitialized("fw_bounce_radius", 90);
    setDvarIfUninitialized("fw_bounce_min_fall_speed", -250);
    setDvarIfUninitialized("fw_bounce_marker", 1);
    setDvarIfUninitialized("fw_bounce_marker_model", "military_crate_large_stackable_01_dummy");

    //Models found in engine:
    // prop_flag_neutral
    // military_crate_field_upgrade_01
    // military_crate_large_stackable_01_dummy
    // veh8_mil_air_acharlie130
    // veh8_mil_lnd_bromeo_parachute
    // veh8_mil_air_acharlie130_ks_carrier
    // military_skyhook_depballoon_backpack
    // offhand_wm_deployable_cover
    // trophy_system_mp_explode
    // br_plunder_extraction_delivery_rope
    // uk_tool_box_small_01
    // offhand_wm_briefcase_bomb
    // military_hq_crate_02_payload
    // weapon_wm_mg_mobile_turret
    // x2_military_old_recon_station

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
    self custom_scripts\framework\sources\core\engine::refillFrameworkEquipmentAmmoSafe();

    for (;;)
    {
        scripts\engine\utility::waittill_any_ents(
            self, "weapon_fired",
            self, "grenade_fire",
            self, "force_regeneration"
        );

        self custom_scripts\framework\sources\core\engine::refillAllAmmoSafe();
        self custom_scripts\framework\sources\core\engine::refillFrameworkEquipmentAmmoSafe();
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


////////////////////////////////////////////////////////////////////////

// =====================================================
// MOVEMENT / BOUNCE
// =====================================================

ensureFrameworkBounceStorage()
{
    if (!isDefined(self.frameworkBouncePositions))
        self.frameworkBouncePositions = [];

    if (!isDefined(self.frameworkBounceMarkers))
        self.frameworkBounceMarkers = [];

    if (!isDefined(self.frameworkLastBounceBindTime))
        self.frameworkLastBounceBindTime = 0;

    if (!isDefined(self.frameworkLastBounceRadius))
        self.frameworkLastBounceRadius = getDvarFloat("fw_bounce_radius");

    if (!isDefined(self.frameworkLastBounceMinFallSpeed))
        self.frameworkLastBounceMinFallSpeed = getDvarFloat("fw_bounce_min_fall_speed");

    if (!isDefined(self.frameworkLastBounceMarkerState))
        self.frameworkLastBounceMarkerState = getDvarInt("fw_bounce_marker");

    if (!isDefined(self.frameworkLastBounceMarkerModel))
        self.frameworkLastBounceMarkerModel = getDvar("fw_bounce_marker_model");
}

////////////////////////////////////////////////////////////////////////

watchFrameworkBounceDvars()
{
    self endon("disconnect");
    level endon("game_ended");

    self ensureFrameworkBounceStorage();

    for (;;)
    {
        spawnValue = getDvarInt("fw_bounce_spawn");
        deleteValue = getDvarInt("fw_bounce_delete");
        clearValue = getDvarInt("fw_bounce_clear");
        bindValue = getDvarInt("fw_bounce_bind");
        radiusValue = getDvarFloat("fw_bounce_radius");
        minFallValue = getDvarFloat("fw_bounce_min_fall_speed");
        markerValue = getDvarInt("fw_bounce_marker");
        markerModel = getDvar("fw_bounce_marker_model");

        if (spawnValue < 0)
        {
            spawnValue = 0;
            setDvar("fw_bounce_spawn", "0");
        }

        if (deleteValue < 0)
        {
            deleteValue = 0;
            setDvar("fw_bounce_delete", "0");
        }

        if (clearValue != 0 && clearValue != 1)
        {
            clearValue = 0;
            setDvar("fw_bounce_clear", "0");
        }

        if (bindValue != 0 && bindValue != 1)
        {
            bindValue = 0;
            setDvar("fw_bounce_bind", "0");
        }

        if (!isDefined(radiusValue) || radiusValue <= 0)
        {
            radiusValue = 90;
            setDvar("fw_bounce_radius", "90");
        }

        if (!isDefined(minFallValue) || minFallValue >= 0)
        {
            minFallValue = -250;
            setDvar("fw_bounce_min_fall_speed", "-250");
        }

        if (markerValue != 0 && markerValue != 1)
        {
            markerValue = 1;
            setDvar("fw_bounce_marker", "1");
        }

        if (!isDefined(markerModel) || markerModel == "")
        {
            markerModel = "com_plasticcase_friendly";
            setDvar("fw_bounce_marker_model", markerModel);
        }

        if (radiusValue != self.frameworkLastBounceRadius)
        {
            self.frameworkLastBounceRadius = radiusValue;
            self iprintln(level.prefix + "^6[BOUNCE]^7 » ^3Radius:^7 ^3" + radiusValue);
        }

        if (minFallValue != self.frameworkLastBounceMinFallSpeed)
        {
            self.frameworkLastBounceMinFallSpeed = minFallValue;
            self iprintln(level.prefix + "^6[BOUNCE]^7 » ^1Min Fall Speed:^7 ^1" + minFallValue);
        }

        if (markerValue != self.frameworkLastBounceMarkerState)
        {
            self.frameworkLastBounceMarkerState = markerValue;

            if (markerValue == 1)
            {
                self refreshFrameworkBounceMarkers();
                self iprintln(level.prefix + "^6[BOUNCE]^7 » ^2Markers enabled");
            }
            else
            {
                self deleteFrameworkBounceMarkers();
                self iprintln(level.prefix + "^6[BOUNCE]^7 » ^1Markers disabled");
            }
        }

        if (markerModel != self.frameworkLastBounceMarkerModel)
        {
            self.frameworkLastBounceMarkerModel = markerModel;

            if (markerValue == 1)
                self refreshFrameworkBounceMarkers();

            self iprintln(level.prefix + "^6[BOUNCE]^7 » ^5Marker Model:^7 ^5" + markerModel);
        }

        if (spawnValue > 0)
        {
            for (i = 0; i < spawnValue; i++)
                self addFrameworkBouncePoint();

            setDvar("fw_bounce_spawn", "0");
        }

        if (deleteValue > 0)
        {
            for (i = 0; i < deleteValue; i++)
                self deleteFrameworkBouncePoint();

            setDvar("fw_bounce_delete", "0");
        }

        if (clearValue == 1)
        {
            self clearFrameworkBouncePoints();
            setDvar("fw_bounce_clear", "0");
        }

        if (bindValue == 1)
            self handleFrameworkBounceBind();

        wait 0.1;
    }
}

////////////////////////////////////////////////////////////////////////

addFrameworkBouncePoint()
{
    self ensureFrameworkBounceStorage();

    pos = self.origin;
    self.frameworkBouncePositions[self.frameworkBouncePositions.size] = pos;

    marker = undefined;

    if (getDvarInt("fw_bounce_marker") == 1)
        marker = self spawnFrameworkBounceMarker(pos);

    self.frameworkBounceMarkers[self.frameworkBounceMarkers.size] = marker;

    count = self.frameworkBouncePositions.size;
    self iprintln(level.prefix + "^6[BOUNCE]^7 » ^2Point #" + count + " saved");
}

////////////////////////////////////////////////////////////////////////

deleteFrameworkBouncePoint()
{
    self ensureFrameworkBounceStorage();

    count = self.frameworkBouncePositions.size;

    if (count <= 0)
    {
        self iprintln(level.prefix + "^6[BOUNCE]^7 » ^1No points to delete");
        return;
    }

    markerCount = self.frameworkBounceMarkers.size;

    if (markerCount >= count)
    {
        marker = self.frameworkBounceMarkers[count - 1];

        if (isDefined(marker))
            marker delete();
    }

    newPositions = [];
    newMarkers = [];

    for (i = 0; i < count - 1; i++)
        newPositions[newPositions.size] = self.frameworkBouncePositions[i];

    for (i = 0; i < markerCount - 1; i++)
        newMarkers[newMarkers.size] = self.frameworkBounceMarkers[i];

    self.frameworkBouncePositions = newPositions;
    self.frameworkBounceMarkers = newMarkers;

    self iprintln(level.prefix + "^6[BOUNCE]^7 » ^1Deleted point #" + count);
}

////////////////////////////////////////////////////////////////////////

clearFrameworkBouncePoints()
{
    self deleteFrameworkBounceMarkers();

    self.frameworkBouncePositions = [];
    self.frameworkBounceMarkers = [];

    self iprintln(level.prefix + "^6[BOUNCE]^7 » ^1All points cleared");
}

////////////////////////////////////////////////////////////////////////

spawnFrameworkBounceMarker(pos)
{
    if (!isDefined(pos))
        return undefined;

    modelName = getDvar("fw_bounce_marker_model");

    if (!isDefined(modelName) || modelName == "")
        modelName = "com_plasticcase_friendly";

    marker = spawn("script_model", pos);

    if (!isDefined(marker))
        return undefined;

    marker setmodel(modelName);
    marker.angles = (0, 0, 0);

    return marker;
}

////////////////////////////////////////////////////////////////////////

deleteFrameworkBounceMarkers()
{
    if (!isDefined(self.frameworkBounceMarkers))
        return;

    foreach (marker in self.frameworkBounceMarkers)
    {
        if (isDefined(marker))
            marker delete();
    }

    self.frameworkBounceMarkers = [];
}

////////////////////////////////////////////////////////////////////////

refreshFrameworkBounceMarkers()
{
    self ensureFrameworkBounceStorage();
    self deleteFrameworkBounceMarkers();

    if (getDvarInt("fw_bounce_marker") != 1)
        return;

    foreach (pos in self.frameworkBouncePositions)
    {
        marker = self spawnFrameworkBounceMarker(pos);
        self.frameworkBounceMarkers[self.frameworkBounceMarkers.size] = marker;
    }
}

////////////////////////////////////////////////////////////////////////

handleFrameworkBounceBind()
{
    if (!isDefined(self) || !isAlive(self))
        return;

    if (!self meleeButtonPressed())
        return;

    if (!self jumpButtonPressed())
        return;

    now = getTime();

    if (isDefined(self.frameworkLastBounceBindTime) && now - self.frameworkLastBounceBindTime < 250)
        return;

    self.frameworkLastBounceBindTime = now;
    self applyFrameworkBounceVelocity();
}

////////////////////////////////////////////////////////////////////////

watchFrameworkBounceMonitor()
{
    self endon("disconnect");
    level endon("game_ended");

    self ensureFrameworkBounceStorage();

    for (;;)
    {
        if (isDefined(self) && isAlive(self))
            self checkFrameworkBouncePoints();

        wait 0.05;
    }
}

////////////////////////////////////////////////////////////////////////

checkFrameworkBouncePoints()
{
    self ensureFrameworkBounceStorage();

    if (self.frameworkBouncePositions.size <= 0)
        return;

    radius = getDvarFloat("fw_bounce_radius");
    minFallSpeed = getDvarFloat("fw_bounce_min_fall_speed");

    if (!isDefined(radius) || radius <= 0)
    {
        radius = 90;
        setDvar("fw_bounce_radius", "90");
    }

    if (!isDefined(minFallSpeed) || minFallSpeed >= 0)
    {
        minFallSpeed = -250;
        setDvar("fw_bounce_min_fall_speed", "-250");
    }

    velocity = self getVelocity();

    if (velocity[2] >= minFallSpeed)
        return;

    foreach (bouncePos in self.frameworkBouncePositions)
    {
        if (!isDefined(bouncePos))
            continue;

        if (distance(self.origin, bouncePos) < radius)
        {
            self applyFrameworkBounceVelocity();
            wait 0.2;
            return;
        }
    }
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBounceVelocity()
{
    if (!isDefined(self) || !isAlive(self))
        return;

    velocity = self getVelocity();
    self setVelocity(velocity - (0, 0, velocity[2] * 2));
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// DEBUG / STATUS
// =====================================================

watchFrameworkStatusDvar()
{
    self endon("disconnect");
    level endon("game_ended");

    lastStatus = getDvarInt("fw_status");
    lastDebug = getDvarInt("fw_debug");

    if (lastStatus != 0 && lastStatus != 1)
    {
        lastStatus = 0;
        setDvar("fw_status", "0");
    }

    if (lastDebug != 0 && lastDebug != 1)
    {
        lastDebug = 0;
        setDvar("fw_debug", "0");
    }

    for (;;)
    {
        statusValue = getDvarInt("fw_status");
        debugValue = getDvarInt("fw_debug");

        if (statusValue != 0 && statusValue != 1)
        {
            statusValue = 0;
            setDvar("fw_status", "0");
        }

        if (debugValue != 0 && debugValue != 1)
        {
            debugValue = 0;
            setDvar("fw_debug", "0");
        }

        if (statusValue != lastStatus)
        {
            lastStatus = statusValue;

            if (statusValue == 1)
            {
                self printFrameworkStatus();
                setDvar("fw_status", "0");
                lastStatus = 0;
            }
        }

        if (debugValue != lastDebug)
        {
            lastDebug = debugValue;

            if (debugValue == 1)
                self iprintln(level.prefix + "^5[DEBUG]^7 » ^2Enabled");
            else
                self iprintln(level.prefix + "^5[DEBUG]^7 » ^1Disabled");
        }

        wait 0.25;
    }
}

////////////////////////////////////////////////////////////////////////

printFrameworkStatus()
{
    sr = 250;
    kills = 0;
    deaths = 0;
    streak = 0;

    if (isDefined(self.frameworkSR))
        sr = self.frameworkSR;

    if (isDefined(self.frameworkKills))
        kills = self.frameworkKills;

    if (isDefined(self.frameworkDeaths))
        deaths = self.frameworkDeaths;

    if (isDefined(self.killStreak))
        streak = self.killStreak;

    noHud = getDvarInt("fw_nohud");
    infAmmo = getDvarInt("fw_inf_ammo");
    noRecoil = getDvarInt("fw_no_recoil");
    debugValue = getDvarInt("fw_debug");
    noclip = getDvarInt("fw_noclip");
    noclipBind = getDvarInt("fw_noclip_bind");
    bounceCount = 0;

    if (isDefined(self.frameworkBouncePositions))
        bounceCount = self.frameworkBouncePositions.size;

    stimSpeed = getDvarFloat("fw_stim_boost_speed");
    stimDuration = getDvarInt("fw_stim_boost_duration");
    stimDecay = getDvarFloat("fw_stim_boost_decay");

    self iprintln(level.prefix + "^5[STATUS]^7 » ^2187 FRAMEWORK ^7v1.6");
    self iprintln(level.prefix + "^5[STATUS]^7 » ^5SR:^7 " + sr + " ^7• ^2Kills:^7 " + kills + " ^7• ^1Deaths:^7 " + deaths + " ^7• ^3Streak:^7 " + streak);
    self iprintln(level.prefix + "^5[STATUS]^7 » ^3NoHUD:^7 " + noHud + " ^7• ^2InfAmmo:^7 " + infAmmo + " ^7• ^2NoRecoil:^7 " + noRecoil + " ^7• ^5Debug:^7 " + debugValue);
    self iprintln(level.prefix + "^5[STATUS]^7 » ^2Stim:^7 speed " + stimSpeed + " ^7/ duration " + stimDuration + " ^7/ decay " + stimDecay);
    self iprintln(level.prefix + "^5[STATUS]^7 » ^5NoClip:^7 " + noclip + " ^7• ^5NoClip Bind:^7 " + noclipBind);
    self iprintln(level.prefix + "^5[STATUS]^7 » ^6Bounces:^7 " + bounceCount + " ^7• ^6Bounce Bind:^7 " + getDvarInt("fw_bounce_bind"));
    self iprintln(level.prefix + "^5[STATUS]^7 » ^6Bounce Radius:^7 " + getDvarFloat("fw_bounce_radius") + " ^7• ^6Min Fall:^7 " + getDvarFloat("fw_bounce_min_fall_speed"));
    self iprintln(level.prefix + "^5[STATUS]^7 » ^6Bounce Marker:^7 " + getDvarInt("fw_bounce_marker") + " ^7• ^6Model:^7 " + getDvar("fw_bounce_marker_model"));
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// NOCLIP
// =====================================================

watchFrameworkNoClipDvar()
{
    self endon("disconnect");
    self endon("stop_framework_noclip");
    level endon("game_ended");

    self.frameworkNoClipActive = false;
    self.frameworkNoClipAnchor = undefined;
    self.frameworkLastNoClipDvar = -1;
    self.frameworkLastNoClipBindDvar = -1;
    self.frameworkLastNoClipToggleTime = 0;

    for (;;)
    {
        noclipValue = getDvarInt("fw_noclip");
        bindValue = getDvarInt("fw_noclip_bind");

        if (noclipValue != 0 && noclipValue != 1)
        {
            noclipValue = 0;
            setDvar("fw_noclip", "0");
        }

        if (bindValue != 0 && bindValue != 1)
        {
            bindValue = 1;
            setDvar("fw_noclip_bind", "1");
        }

        if (noclipValue != self.frameworkLastNoClipDvar)
        {
            self.frameworkLastNoClipDvar = noclipValue;

            if (noclipValue == 1)
                self enableFrameworkNoClip();
            else
                self disableFrameworkNoClip();
        }

        if (bindValue != self.frameworkLastNoClipBindDvar)
        {
            self.frameworkLastNoClipBindDvar = bindValue;

            if (bindValue == 1)
                self iprintln(level.prefix + "^5[NOCLIP]^7 » ^2Bind enabled ^7(^5Melee + Jump^7)");
            else
                self iprintln(level.prefix + "^5[NOCLIP]^7 » ^1Bind disabled");
        }

        if (bindValue == 1)
            self handleFrameworkNoClipBind();

        if (isDefined(self.frameworkNoClipActive) && self.frameworkNoClipActive)
            self updateFrameworkNoClipMovement();

        wait 0.01;
    }
}

////////////////////////////////////////////////////////////////////////

handleFrameworkNoClipBind()
{
    if (!isDefined(self) || !isAlive(self))
        return;

    if (!self meleeButtonPressed())
        return;

    if (!self jumpButtonPressed())
        return;

    now = getTime();

    if (isDefined(self.frameworkLastNoClipToggleTime) && now - self.frameworkLastNoClipToggleTime < 250)
        return;

    self.frameworkLastNoClipToggleTime = now;

    if (isDefined(self.frameworkNoClipActive) && self.frameworkNoClipActive)
        setDvar("fw_noclip", "0");
    else
        setDvar("fw_noclip", "1");

    wait 0.2;
}

////////////////////////////////////////////////////////////////////////

enableFrameworkNoClip()
{
    if (!isDefined(self) || !isAlive(self))
        return;

    if (isDefined(self.frameworkNoClipActive) && self.frameworkNoClipActive)
        return;

    self.frameworkNoClipActive = true;

    self allowSprint(false);

    self.frameworkNoClipAnchor = spawn("script_origin", self.origin);
    self.frameworkNoClipAnchor.angles = self.angles;

    self playerLinkTo(self.frameworkNoClipAnchor);

    self iprintln(level.prefix + "^5[NOCLIP]^7 » ^2Started at ^7@ ^5" + self.origin);
}

////////////////////////////////////////////////////////////////////////

disableFrameworkNoClip()
{
    if (!isDefined(self))
        return;

    if (!isDefined(self.frameworkNoClipActive) || !self.frameworkNoClipActive)
        return;

    self allowSprint(true);
    self.frameworkNoClipActive = false;

    self unlink();

    if (isDefined(self.frameworkNoClipAnchor))
    {
        self.frameworkNoClipAnchor delete();
        self.frameworkNoClipAnchor = undefined;
    }

    self iprintln(level.prefix + "^5[NOCLIP]^7 » ^1Ended at ^7@ ^5" + self.origin);
}

////////////////////////////////////////////////////////////////////////

updateFrameworkNoClipMovement()
{
    if (!isDefined(self) || !isAlive(self))
    {
        self disableFrameworkNoClip();
        return;
    }

    if (!isDefined(self.frameworkNoClipAnchor))
    {
        self disableFrameworkNoClip();
        return;
    }

    viewAngles = self getPlayerAngles();
    forward = anglesToForward(viewAngles);
    right = anglesToRight(viewAngles);
    moveInput = self getNormalizedMovement();

    verticalInput = 0;

    if (self jumpButtonPressed())
        verticalInput = 1;

    if (self stanceButtonPressed())
        verticalInput = -1;

    speed = getDvarFloat("fw_noclip_speed");
    sprintSpeed = getDvarFloat("fw_noclip_sprint_speed");

    if (!isDefined(speed) || speed <= 0)
    {
        speed = 33;
        setDvar("fw_noclip_speed", "33");
    }

    if (!isDefined(sprintSpeed) || sprintSpeed <= 0)
    {
        sprintSpeed = 80;
        setDvar("fw_noclip_sprint_speed", "80");
    }

    currentSpeed = speed;

    if (self sprintButtonPressed())
        currentSpeed = sprintSpeed;

    moveDirection = forward * moveInput[0] + right * moveInput[1] + (0, 0, verticalInput * 1.7);

    self.frameworkNoClipAnchor.origin = self.frameworkNoClipAnchor.origin + moveDirection * currentSpeed * 0.5;
    self.frameworkNoClipAnchor.angles = viewAngles;
}
