// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: betterplunder.gsc

////////////////////////////////////////////////////////////////////////

// Better Plunder — framework-owned gameplay module
//
// Reworked from betterplunder.gsc into the 187 FRAMEWORK structure.
//
// Goals:
// - Plunder/DMZ rule control
// - optional custom play area / POI ring
// - optional kill rewards
// - optional infinite equipment
// - match info prints
// - safer match-end prevention
//
// Safety changes from the source script:
// - no custom level.ontimelimit function pointer override
// - no botGetClosestNavigablePoint()
// - less frequent timer/ring loops
// - risky cleanup/super systems are DVAR-gated

////////////////////////////////////////////////////////////////////////

init()
{
    if (isDefined(level.frameworkBetterPlunderReady))
        return;

    level.frameworkBetterPlunderReady = true;

    setupBetterPlunderDvars();

    if (getDvarInt("bp_enable") != 1)
        return;

    if (getDvar("scr_br_gametype", "") != "dmz" && getDvarInt("bp_force_enable") != 1)
        return;

    if (isDefined(level.script))
        level.bp_is_escape_map = (level.script == "mp_escape2" || level.script == "mp_escape3" || level.script == "mp_escape4");
    else
        level.bp_is_escape_map = 0;

    level thread setupBetterPlunderRulesLoop();
    level thread betterPlunderMatchEndProtectionLoop();
    level thread betterPlunderMatchInfoLoop();
    level thread betterPlunderManualMatchInfoTrigger();
    level thread betterPlunderRingActivationWatcher();
    level thread betterPlunderSupersLoop();
}

////////////////////////////////////////////////////////////////////////

setupBetterPlunderDvars()
{
    setDvarIfUninitialized("bp_enable", 1);
    setDvarIfUninitialized("bp_force_enable", 0);

    // Rules / match end
    setDvarIfUninitialized("bp_prevent_match_end", 1);
    setDvarIfUninitialized("bp_timer_minutes", 999);
    setDvarIfUninitialized("bp_timer_refresh", 10);

    // Kill reward systems
    setDvarIfUninitialized("bp_rewardspeed", 0);
    setDvarIfUninitialized("bp_rewardspeed_speed", "1.35");
    setDvarIfUninitialized("bp_rewardspeed_length", "5");
    setDvarIfUninitialized("bp_movespeed", "1.0");
    setDvarIfUninitialized("bp_rewardperks", 0);
    setDvarIfUninitialized("bp_rewardperks_maxperks", "4");
    setDvarIfUninitialized("bp_rewardperks_specialist", 1);

    // Movement / equipment
    setDvarIfUninitialized("bp_inftacsprint", 0);
    setDvarIfUninitialized("bp_infequip", 1);
    setDvarIfUninitialized("bp_infequip_delay", "5");
    setDvarIfUninitialized("bp_inf_guns", 1);
    setDvarIfUninitialized("bp_inf_lethals", 1);
    setDvarIfUninitialized("bp_inf_tac", 1);
    setDvarIfUninitialized("bp_inf_plates", 1);

    // Play ring / POI
    setDvarIfUninitialized("bp_playring", 1);
    setDvarIfUninitialized("bp_ring_poi", "prison");
    setDvarIfUninitialized("bp_ring_timer", "5");
    setDvarIfUninitialized("bp_initial_teleport", 1);

    // Optional / risky helpers
    setDvarIfUninitialized("bp_delete_dropped_loot", 0);
    setDvarIfUninitialized("bp_blocksupers", 0);
    setDvarIfUninitialized("bp_allowsupers", 0);

    // Match info
    setDvarIfUninitialized("bp_matchinfo_interval", "120");
    setDvarIfUninitialized("bp_matchinfo_flags", "15");
    setDvarIfUninitialized("bp_matchinfo_trigger", "0");
}

////////////////////////////////////////////////////////////////////////

onFrameworkPlayerConnected()
{
    self endon("disconnect");
    level endon("game_ended");

    if (getDvarInt("bp_enable") != 1)
        return;

    self thread betterPlunderPlayerSpawnLoop();
}

////////////////////////////////////////////////////////////////////////

betterPlunderPlayerSpawnLoop()
{
    self endon("disconnect");
    level endon("game_ended");

    self thread betterPlunderKillRewardLoop();

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_bp_speed_loop");
        self notify("stop_bp_tac_sprint");
        self notify("stop_bp_ring_monitor");
        self notify("stop_bp_inf_equipment");

        self.bp_total_kills = 0;
        self.bp_has_specialist = 0;
        self.bp_earned_perks = [];
        self.bp_speed_buff_end_time = 0;
        self.bp_is_out_of_bounds = 0;

        if (isAlive(self))
            self setmovespeedscale(getDvarFloat("bp_movespeed", 1.0));

        self thread betterPlunderSpeedBuffWatcher();
        self thread betterPlunderInfiniteTacSprintLoop();
        self thread betterPlunderPlayRingMonitor();
        self thread betterPlunderInfiniteEquipmentLoop();

        if (getDvarInt("bp_delete_dropped_loot") == 1)
            self thread betterPlunderDeleteDroppedLootNearDeath();

        if (getDvarInt("bp_initial_teleport") == 1)
            self thread betterPlunderInitialPoiTeleport();
    }
}

////////////////////////////////////////////////////////////////////////

setupBetterPlunderRulesLoop()
{
    level endon("game_ended");

    for (;;)
    {
        if (getDvarInt("bp_enable") != 1)
        {
            wait 5.0;
            continue;
        }

        setDvar("scr_dmz_win_cost", "2000000");
        setDvar("scr_br_scorelimit", "2000000000");
        setDvar("scr_bmo_eom_ot_timer", "0");
        setDvar("scr_bmo_useMilestonePhases", "0");
        setDvar("scr_dmz_lc_active", "0");
        setDvar("br_min_plunder_extractions", "0");
        setDvar("br_max_plunder_extractions", "0");
        setDvar("scr_bmo_disable_win_on_score", "1");
        setDvar("scr_bmo_disable_one_mil_announce", "1");
        setDvar("scr_bmo_score_requires_banking", "1");
        setDvar("scr_bmo_eom_bank_to_end", "0");

        wait 30.0;
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderMatchEndProtectionLoop()
{
    level endon("game_ended");

    wait 2.0;

    for (;;)
    {
        if (getDvarInt("bp_enable") != 1 || getDvarInt("bp_prevent_match_end") != 1)
        {
            wait 5.0;
            continue;
        }

        betterPlunderApplyMatchEndProtection();
        wait getBetterPlunderTimerRefresh();
    }
}

////////////////////////////////////////////////////////////////////////

getBetterPlunderTimerRefresh()
{
    refresh = getDvarInt("bp_timer_refresh");

    if (!isDefined(refresh) || refresh < 3)
    {
        refresh = 10;
        setDvar("bp_timer_refresh", "10");
    }

    if (refresh > 60)
        refresh = 60;

    return refresh;
}

////////////////////////////////////////////////////////////////////////

betterPlunderApplyMatchEndProtection()
{
    minutes = getDvarInt("bp_timer_minutes");

    if (!isDefined(minutes) || minutes < 1)
    {
        minutes = 999;
        setDvar("bp_timer_minutes", "999");
    }

    // Safer than assigning custom level.ontimelimit.
    level.timelimitoverride = true;

    if (!isDefined(level.discardtime))
        level.discardtime = 0;

    if (!isDefined(level.starttime))
        level.starttime = getTime();

    setDvar("scr_br_timelimit", "" + minutes);
    setDvar("scr_br_rebirth_timelimit", "" + minutes);
    setDvar("scr_br_match_timelimit", "" + minutes);
    setDvar("scr_bmo_exfil_timer", "0");
    setDvar("scr_bmo_squad_wiped_stream_time", "0");
    setDvar("scr_bmo_respawn_predict_hint_time", "0");
    setDvar("scr_bmo_respawn_intermission_time", "0");
    setDvar("scr_br_extract_spawn_wait", "0");
    setDvar("timelimit", "" + minutes);

    level.lootcontentsadjusteconomy_bottomtier = 999999999;
    level.scorelimit = 999999999;
    level.make_bomb_detonator_interact = 0;
    level.checkpoint_objective_id = 0;
    level.start_persistent_turbulence = 0;

    seconds = minutes * 60;
    setGameEndTime(getTime() + int(seconds * 1000));
}

////////////////////////////////////////////////////////////////////////

betterPlunderKillRewardLoop()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("got_a_kill");

        if (isTrue(level.infil_grace_period))
            continue;

        if (getDvarInt("bp_rewardspeed") == 1)
        {
            length = getDvarInt("bp_rewardspeed_length");

            if (!isDefined(length) || length < 1)
                length = 5;

            self.bp_speed_buff_end_time = getTime() + (length * 1000);
        }

        if (getDvarInt("bp_rewardperks") == 1)
            self betterPlunderHandleRewardPerks();
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderHandleRewardPerks()
{
    if (isTrue(self.bp_has_specialist))
        return;

    if (!isDefined(self.bp_total_kills))
        self.bp_total_kills = 0;

    self.bp_total_kills++;

    maxPerks = getDvarInt("bp_rewardperks_maxperks");

    if (!isDefined(maxPerks) || maxPerks < 1)
        maxPerks = 4;

    allowSpecialist = getDvarInt("bp_rewardperks_specialist");

    if (allowSpecialist == 1 && self.bp_total_kills > maxPerks)
    {
        self.bp_has_specialist = 1;
        self iprintlnbold("^2Specialist Bonus Received!");
        self thread betterPlunderGiveSpecialistBonus();
        return;
    }

    self thread betterPlunderGiveRandomRewardPerk();
}

////////////////////////////////////////////////////////////////////////

betterPlunderSpeedBuffWatcher()
{
    self notify("stop_bp_speed_loop");
    self endon("stop_bp_speed_loop");
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    for (;;)
    {
        baseSpeed = getDvarFloat("bp_movespeed");

        if (!isDefined(baseSpeed) || baseSpeed <= 0)
            baseSpeed = 1.0;

        if (self islinked() || self isparachuting() || self isinfreefall() || getTime() > self.bp_speed_buff_end_time)
        {
            if (!isDefined(self.bp_current_speed_scale) || self.bp_current_speed_scale != baseSpeed)
            {
                self setmovespeedscale(baseSpeed);
                self.bp_current_speed_scale = baseSpeed;
            }

            wait 0.25;
            continue;
        }

        rewardTarget = getDvarFloat("bp_rewardspeed_speed");

        if (!isDefined(rewardTarget) || rewardTarget <= 0)
            rewardTarget = 1.35;

        buffSpeed = baseSpeed + (rewardTarget - 1.0);
        self setmovespeedscale(buffSpeed);
        self.bp_current_speed_scale = buffSpeed;
        self refreshsprinttime(2.5);

        wait 0.1;
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderGiveRandomRewardPerk()
{
    pool = betterPlunderGetPerkPool();
    available = [];

    foreach (perk in pool)
    {
        if (!self scripts\mp\utility\perk::_hasperk(perk))
            available[available.size] = perk;
    }

    if (available.size <= 0)
        return;

    chosen = available[randomInt(available.size)];

    self scripts\mp\utility\perk::giveperk(chosen);
    self thread scripts\mp\hud_message::showsplash(chosen);

    if (!isDefined(self.bp_earned_perks))
        self.bp_earned_perks = [];

    self.bp_earned_perks[self.bp_earned_perks.size] = chosen;

    self iprintlnbold("^3STREAK:^7 Bonus Perk Acquired!");
    self playsoundtoplayer("ui_select_purchase_confirm", self);
}

////////////////////////////////////////////////////////////////////////

betterPlunderGiveSpecialistBonus()
{
    pool = betterPlunderGetPerkPool();

    foreach (perk in pool)
    {
        if (!self scripts\mp\utility\perk::_hasperk(perk))
            self scripts\mp\utility\perk::giveperk(perk);
    }

    self thread scripts\mp\hud_message::showsplash("specialist_perk_bonus");
    self playsoundtoplayer("br_legendary_loot_drop_stinger", self);
}

////////////////////////////////////////////////////////////////////////

betterPlunderGetPerkPool()
{
    return [
        "specialty_br_serpentine", "specialty_br_advancedscout", "specialty_br_reinforced",
        "specialty_coldblooded", "specialty_quick_fix", "specialty_eod",
        "specialty_scavenger", "specialty_hustle", "specialty_warhead",
        "specialty_surveillance", "specialty_recharge_equipment", "specialty_tac_resist",
        "specialty_shrapnel", "specialty_tune_up", "specialty_br_cheaper_kiosk",
        "specialty_br_better_mission_rewards", "specialty_huntmaster"
    ];
}

////////////////////////////////////////////////////////////////////////

betterPlunderInfiniteTacSprintLoop()
{
    self notify("stop_bp_tac_sprint");
    self endon("stop_bp_tac_sprint");
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    for (;;)
    {
        if (getDvarInt("bp_inftacsprint") == 1)
            self refreshsprinttime(2.5);

        wait 0.5;
    }
}

////////////////////////////////////////////////////////////////////////

getBetterPlunderPoiCenter(poi)
{
    switch (poi)
    {
        case "control":
            return (-2182.73, 6071.29, 747.426);

        case "factory":
            return (-1403.69, 2419.5, 917.824);

        case "bio":
            return (-2115.12, 10644.8, 664.055);

        case "tents":
            return (-907.435, -5728.5, 686.595);

        case "prison":
        default:
            return (203, -1326, 1392);
    }
}

////////////////////////////////////////////////////////////////////////

getBetterPlunderPoiRadius(poi)
{
    switch (poi)
    {
        case "control":
            return 2000;

        case "factory":
            return 2000;

        case "bio":
            return 1600;

        case "tents":
            return 1900;

        case "prison":
        default:
            return 2950;
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderRingActivationWatcher()
{
    level endon("game_ended");

    level.infil_grace_period = 1;

    if (!scripts\mp\flags::gameflag("prematch_done"))
        level waittill("prematch_done");

    host = undefined;

    while (!isDefined(host))
    {
        foreach (player in level.players)
        {
            if (isDefined(player) && player ishost())
            {
                host = player;
                break;
            }
        }

        wait 0.5;
    }

    host waittill("infil_jump_done");

    foreach (player in level.players)
    {
        if (isDefined(player) && !isbot(player))
        {
            player iprintlnbold("^3HOST DEPLOYED:^7 Ring activates in 15 seconds!");
            player playlocalsound("ui_mp_timer_countdown");
        }
    }

    wait 15.0;

    level.infil_grace_period = 0;

    foreach (player in level.players)
    {
        if (isDefined(player) && !isbot(player))
        {
            player iprintlnbold("^1THE PLAY AREA IS NOW ACTIVE!");
            player playlocalsound("br_circle_closing_warning");
        }
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderPlayRingMonitor()
{
    self notify("stop_bp_ring_monitor");
    self endon("stop_bp_ring_monitor");
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    for (;;)
    {
        if (getDvarInt("bp_playring") == 0)
        {
            if (isTrue(self.bp_is_out_of_bounds))
            {
                self notify("bp_returned_to_play_area");
                self.bp_is_out_of_bounds = 0;
            }

            wait 1.0;
            continue;
        }

        poi = toLower(getDvar("bp_ring_poi", "prison"));
        center = getBetterPlunderPoiCenter(poi);
        radius = getBetterPlunderPoiRadius(poi);

        pos2d = (self.origin[0], self.origin[1], 0);
        center2d = (center[0], center[1], 0);
        dist = distance(pos2d, center2d);

        if (dist > radius)
            self betterPlunderHandleOutsideRing(center);
        else
            self betterPlunderHandleInsideRing();

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderHandleOutsideRing(center)
{
    if (isTrue(level.infil_grace_period) || self isparachuting() || self isinfreefall())
    {
        if (isTrue(self.bp_is_out_of_bounds))
        {
            self notify("bp_returned_to_play_area");
            self.bp_is_out_of_bounds = 0;
        }

        return;
    }

    if (isbot(self))
    {
        randomX = randomIntRange(-1000, 1000);
        randomY = randomIntRange(-1000, 1000);
        target = (center[0] + randomX, center[1] + randomY, center[2] + 150);
        self setOrigin(target);
        return;
    }

    if (!isTrue(self.bp_is_out_of_bounds))
    {
        self.bp_is_out_of_bounds = 1;
        self thread betterPlunderOutsideRingCountdown();
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderHandleInsideRing()
{
    if (!isTrue(self.bp_is_out_of_bounds))
        return;

    self notify("bp_returned_to_play_area");
    self.bp_is_out_of_bounds = 0;

    if (!isbot(self))
        self iprintlnbold("^2You have returned to the play area.");
}

////////////////////////////////////////////////////////////////////////

betterPlunderOutsideRingCountdown()
{
    self endon("disconnect");
    self endon("death");
    self endon("bp_returned_to_play_area");
    level endon("game_ended");

    maxTime = getDvarInt("bp_ring_timer");

    if (!isDefined(maxTime) || maxTime < 1)
        maxTime = 5;

    timeSpent = 0;

    while (isTrue(self.bp_is_out_of_bounds) && isAlive(self))
    {
        timeLeft = maxTime - timeSpent;
        self iprintlnbold("^1RETURN TO THE PLAY AREA:^7 " + timeLeft + "s");

        wait 1.0;
        timeSpent++;

        if (timeSpent >= maxTime)
        {
            self suicide();
            break;
        }
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderInfiniteEquipmentLoop()
{
    self notify("stop_bp_inf_equipment");
    self endon("stop_bp_inf_equipment");
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    nextLethalTime = 0;
    nextTacTime = 0;

    for (;;)
    {
        if (getDvarInt("bp_infequip") == 0)
        {
            wait 1.0;
            continue;
        }

        if (getDvarInt("bp_inf_guns") == 1)
        {
            guns = self getweaponslistprimaries();

            foreach (weapon in guns)
                self givemaxammo(weapon);
        }

        if (getDvarInt("bp_inf_plates") == 1)
        {
            if (isDefined(self.equipment) && !isDefined(self.equipment["health"]))
                self scripts\mp\equipment::giveequipment("equip_armorplate", "health");

            self scripts\mp\equipment::incrementequipmentammo("equip_armorplate", 99);
        }

        delay = getDvarInt("bp_infequip_delay") * 1000;

        if (!isDefined(delay) || delay < 0)
            delay = 5000;

        if (isDefined(self.equipment))
        {
            if (getDvarInt("bp_inf_lethals") == 1 && getTime() >= nextLethalTime)
            {
                self scripts\mp\equipment::incrementequipmentslotammo("primary", 1);
                nextLethalTime = getTime() + delay;
            }

            if (getDvarInt("bp_inf_tac") == 1 && getTime() >= nextTacTime)
            {
                self scripts\mp\equipment::incrementequipmentslotammo("secondary", 1);
                nextTacTime = getTime() + delay;
            }
        }

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderDeleteDroppedLootNearDeath()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("death");
        deathPos = self.origin;
        wait 0.1;

        if (!isDefined(level.br_pickups) || !isDefined(level.br_pickups.scriptables))
            continue;

        foreach (item in level.br_pickups.scriptables)
        {
            if (!isDefined(item) || !isDefined(item.origin))
                continue;

            if (distance(item.origin, deathPos) >= 200)
                continue;

            if (isEnt(item))
                item delete();
            else
                item freeScriptable();
        }
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderManualMatchInfoTrigger()
{
    level endon("game_ended");

    lastPrintTime = getTime();

    for (;;)
    {
        manualTrigger = getDvarInt("bp_matchinfo_trigger");
        interval = getDvarInt("bp_matchinfo_interval");
        shouldPrint = 0;

        if (manualTrigger == 1)
        {
            setDvar("bp_matchinfo_trigger", "0");
            shouldPrint = 1;
            lastPrintTime = getTime();
        }
        else if (interval > 0 && (getTime() - lastPrintTime) >= (interval * 1000))
        {
            shouldPrint = 1;
            lastPrintTime = getTime();
        }

        if (shouldPrint)
            betterPlunderPrintMatchInfo();

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderMatchInfoLoop()
{
    // Reserved for future use.
    // Manual/interval prints are handled by betterPlunderManualMatchInfoTrigger().
}

////////////////////////////////////////////////////////////////////////

betterPlunderPrintMatchInfo()
{
    flags = getDvarInt("bp_matchinfo_flags");

    if (flags & 1)
    {
        host = "Unknown";

        foreach (player in level.players)
        {
            if (isDefined(player) && player ishost())
            {
                host = player.name;
                break;
            }
        }

        iPrintln("^3MATCH HOST:^7 " + host);
    }

    if (flags & 2)
    {
        leader = undefined;
        highest = -1;

        foreach (player in level.players)
        {
            if (!isDefined(player))
                continue;

            kills = 0;

            if (isDefined(player.frameworkKills))
                kills = player.frameworkKills;
            else if (isDefined(player.kills))
                kills = player.kills;

            if (kills > highest)
            {
                highest = kills;
                leader = player;
            }
        }

        if (isDefined(leader))
            iPrintln("^1KILL LEADER:^7 " + leader.name + " ^3(" + highest + " Kills)");
    }

    if (flags & 4)
    {
        runtime = int(getTime() / 1000);
        mins = int(runtime / 60);
        secs = runtime % 60;

        secStr = secs;

        if (secs < 10)
            secStr = "0" + secs;

        iPrintln("^5SERVER RUNTIME:^7 " + mins + ":" + secStr);
    }

    if (flags & 8)
    {
        realPlayers = 0;
        bots = 0;

        foreach (player in level.players)
        {
            if (!isDefined(player))
                continue;

            if (isbot(player))
                bots++;
            else
                realPlayers++;
        }

        msg = "^6LOBBY SIZE:^7 There are " + realPlayers + " players";

        if (bots > 0)
            msg += " and " + bots + " bots.";
        else
            msg += ".";

        iPrintln(msg);
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderInitialPoiTeleport()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (isTrue(level.infil_grace_period))
        return;

    wait 0.5;

    if (getDvarInt("bp_playring") != 1)
        return;

    poi = toLower(getDvar("bp_ring_poi", "prison"));
    center = getBetterPlunderPoiCenter(poi);
    name = betterPlunderGetPoiName(poi);

    offsetX = randomIntRange(-1500, 1500);
    offsetY = randomIntRange(-1500, 1500);
    teleportPos = (center[0] + offsetX, center[1] + offsetY, self.origin[2]);

    self setOrigin(teleportPos);

    if (!isbot(self))
        self iprintln("^2The current Play Area is ^7" + name + "^2.");
}

////////////////////////////////////////////////////////////////////////

betterPlunderGetPoiName(poi)
{
    switch (poi)
    {
        case "control":
            return "Control Center";

        case "factory":
            return "Factory";

        case "bio":
            return "Bio";

        case "tents":
            return "Tents";

        case "prison":
        default:
            return "Prison";
    }
}

////////////////////////////////////////////////////////////////////////

betterPlunderSupersLoop()
{
    level endon("game_ended");

    wasDisabled = 0;

    for (;;)
    {
        if (getDvarInt("bp_blocksupers") != 1)
        {
            wait 5.0;
            continue;
        }

        allow = getDvarInt("bp_allowsupers");

        if (allow == 0)
        {
            level.allowsupers = 0;

            foreach (player in level.players)
            {
                if (!isDefined(player))
                    continue;

                player scripts\common\utility::allow_supers(0);
                player scripts\mp\equipment::takeequipment("super");
                player scripts\mp\supers::clearsuper();
            }

            wasDisabled = 1;
        }
        else if (wasDisabled == 1 && allow == 1)
        {
            level.allowsupers = 1;

            foreach (player in level.players)
            {
                if (isDefined(player))
                    player scripts\common\utility::allow_supers(1);
            }

            wasDisabled = 0;
        }

        wait 5.0;
    }
}
