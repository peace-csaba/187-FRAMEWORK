// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: smartbots.gsc

////////////////////////////////////////////////////////////////////////

// Framework smart bot systems — reworked v1.8.6
//
// Reworked from deobfuscated.gsc into the 187 FRAMEWORK style.
//
// Keeps / adds:
// - smart bot spawn ownership
// - jump while shooting
// - crouch/prone while shooting
// - fake rank/prestige metadata
// - boss bot metadata + boss skin pool
// - stuck fix
// - safe aggression loop
// - operatorSkins.csv bot skin system
//
// Avoids known risky 1681 calls:
// - setRank()
// - bot_set_difficulty()
// - botsetflag()
// - botclearscriptgoal()
// - botclearscriptenemy()
// - botsetscriptgoal()
// - botsetattacker()
// - getenemyinfo()
// - botgetimperfectenemyinfo()

////////////////////////////////////////////////////////////////////////

init()
{
    if (isDefined(level.frameworkSmartBotsReady))
        return;

    level.frameworkSmartBotsReady = true;

    // Core
    setDvarIfUninitialized("fw_smart_bots", 1);

    // Combat behavior
    setDvarIfUninitialized("fw_bot_jump_shoot", 1);
    setDvarIfUninitialized("fw_bot_action_cooldown", 1500);

    // Safe aggression
    setDvarIfUninitialized("fw_bot_aggressive", 0);
    setDvarIfUninitialized("fw_bot_aggressive_interval", 0);
    setDvarIfUninitialized("fw_bot_aggro_debug", 0);

    // Stuck fix
    setDvarIfUninitialized("fw_bot_stuck_fix", 1);
    setDvarIfUninitialized("fw_bot_stuck_check_delay", 12);

    // Boss bot
    setDvarIfUninitialized("fw_bot_boss", 0);

    // Fake rank metadata only
    setDvarIfUninitialized("fw_bot_fake_rank", 1);
    setDvarIfUninitialized("fw_bot_rank_min", 14);
    setDvarIfUninitialized("fw_bot_rank_max", 755);
    setDvarIfUninitialized("fw_bot_prestige_min", 1);
    setDvarIfUninitialized("fw_bot_prestige_max", 27);

    // Bot skins / operator customization
    //
    // Modes:
    // - sweat  = random skin from built-in sweat pool
    // - boss   = boss pool only
    // - custom = fw_bot_skin_id
    // - off    = disabled
    setDvarIfUninitialized("fw_bot_skins", 1);
    setDvarIfUninitialized("fw_bot_skin_mode", "sweat");
    setDvarIfUninitialized("fw_bot_skin_id", 0);
    setDvarIfUninitialized("fw_bot_skin_debug", 0);
    setDvarIfUninitialized("fw_bot_skin_debug_rate", 15000);
    setDvarIfUninitialized("fw_bot_skin_reroll", 0);

    level thread watchFrameworkBotSkinReroll();
    level thread watchFrameworkSmartBotBoss();
}

////////////////////////////////////////////////////////////////////////

onFrameworkPlayerConnected()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!isbot(self))
        return;

    self initFrameworkSmartBotIdentity();
    self thread watchFrameworkSmartBotSpawn();
}

////////////////////////////////////////////////////////////////////////

watchFrameworkSmartBotSpawn()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!isbot(self))
        return;

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_smartbot_spawn");
        self notify("stop_framework_bot_jump_shoot");
        self notify("stop_framework_bot_stuck_fix");
        self notify("stop_framework_bot_aggression_safe");

        if (getDvarInt("fw_smart_bots") != 1)
            continue;

        self thread setupFrameworkSmartBotSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

setupFrameworkSmartBotSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_smartbot_spawn");
    level endon("game_ended");

    wait 0.25;

    if (!isDefined(self))
        return;

    if (!isbot(self) || !isAlive(self))
        return;

    self frameworkSmartBotSafeReset();
    self applyFrameworkSmartBotRank();

    if (getDvarInt("fw_bot_skins") == 1)
        self thread applyFrameworkBotSkinDelayed();

    if (getDvarInt("fw_bot_jump_shoot") == 1)
        self thread frameworkBotJumpShootLoop();

    if (getDvarInt("fw_bot_stuck_fix") == 1)
        self thread frameworkBotStuckFixLoop();

    if (getDvarInt("fw_bot_aggressive") == 1)
        self thread frameworkBotAggressionSafeLoop();
}

////////////////////////////////////////////////////////////////////////

frameworkSmartBotSafeReset()
{
    if (!isDefined(self) || !isbot(self))
        return;

    self.frameworkBotTracking = 0;
    self.frameworkBotStuck = 0;
    self.is_currently_tracking = 0;
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// IDENTITY / FAKE RANK METADATA
// =====================================================

initFrameworkSmartBotIdentity()
{
    if (!isbot(self))
        return;

    if (isDefined(self.frameworkBotIdentityReady))
        return;

    self.frameworkBotIdentityReady = true;

    rankMin = getDvarInt("fw_bot_rank_min");
    rankMax = getDvarInt("fw_bot_rank_max");
    prestigeMin = getDvarInt("fw_bot_prestige_min");
    prestigeMax = getDvarInt("fw_bot_prestige_max");

    if (rankMin < 1)
        rankMin = 1;

    if (rankMax <= rankMin)
        rankMax = rankMin + 1;

    if (prestigeMin < 0)
        prestigeMin = 0;

    if (prestigeMax <= prestigeMin)
        prestigeMax = prestigeMin + 1;

    self.frameworkBotRank = randomIntRange(rankMin, rankMax);
    self.frameworkBotPrestige = randomIntRange(prestigeMin, prestigeMax);
}

////////////////////////////////////////////////////////////////////////

applyFrameworkSmartBotRank()
{
    if (!isbot(self))
        return;

    if (getDvarInt("fw_bot_fake_rank") != 1)
        return;

    if (!isDefined(self.frameworkBotRank) || !isDefined(self.frameworkBotPrestige))
        self initFrameworkSmartBotIdentity();

    // Metadata only.
    // Real setRank() removed because it can throw DEV ERROR 1681.
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// BOSS BOT
// =====================================================

watchFrameworkSmartBotBoss()
{
    level endon("game_ended");

    for (;;)
    {
        wait 5.0;

        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_boss") != 1)
            continue;

        bossExists = 0;

        foreach (player in level.players)
        {
            if (!isDefined(player))
                continue;

            if (isbot(player) && isDefined(player.frameworkBotBoss) && player.frameworkBotBoss)
            {
                bossExists = 1;
                break;
            }
        }

        if (bossExists)
            continue;

        bots = [];

        foreach (player in level.players)
        {
            if (isDefined(player) && isbot(player) && isAlive(player))
                bots[bots.size] = player;
        }

        if (bots.size <= 0)
            continue;

        chosen = bots[randomInt(bots.size)];

        if (isDefined(chosen))
            chosen thread turnFrameworkBotIntoBoss();
    }
}

////////////////////////////////////////////////////////////////////////

turnFrameworkBotIntoBoss()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    if (!isbot(self))
        return;

    self.frameworkBotBoss = 1;
    self.frameworkBotRank = 1055;
    self.frameworkBotPrestige = 29;

    self.maxhealth = 500;
    self.health = 500;

    if (!isDefined(self.frameworkBotSkinId))
    {
        bossPool = getFrameworkBossSkinPool();

        if (bossPool.size > 0)
            self.frameworkBotSkinId = bossPool[randomInt(bossPool.size)];
    }

    self applyFrameworkSmartBotRank();

    if (getDvarInt("fw_bot_skins") == 1)
        self thread applyFrameworkBotSkinDelayed();
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// JUMP / CROUCH / PRONE WHILE SHOOTING
// =====================================================

frameworkBotJumpShootLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_jump_shoot");
    level endon("game_ended");

    if (!isDefined(self.frameworkLastBotActionTime))
        self.frameworkLastBotActionTime = 0;

    for (;;)
    {
        self waittill("weapon_fired");

        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_jump_shoot") != 1)
            continue;

        if (!isAlive(self))
            return;

        if (!self frameworkBotCanDoAction())
            continue;

        roll = randomInt(100);

        if (roll < 15)
        {
            self botpressbutton("jump");
            wait randomFloatRange(0.35, 0.85);
            continue;
        }

        if (roll < 24)
        {
            self botsetstance("crouch");
            wait randomFloatRange(0.15, 0.25);
            self botsetstance("stand");
            wait randomFloatRange(0.25, 0.65);
            continue;
        }

        if (roll < 28)
        {
            self botsetstance("prone");
            wait randomFloatRange(0.25, 0.75);
            self botsetstance("stand");
        }
    }
}

////////////////////////////////////////////////////////////////////////

frameworkBotCanDoAction()
{
    cooldown = getDvarInt("fw_bot_action_cooldown");

    if (!isDefined(cooldown) || cooldown < 500)
    {
        cooldown = 1500;
        setDvar("fw_bot_action_cooldown", "1500");
    }

    if (!isDefined(self.frameworkLastBotActionTime))
        self.frameworkLastBotActionTime = 0;

    now = getTime();

    if (now - self.frameworkLastBotActionTime < cooldown)
        return false;

    self.frameworkLastBotActionTime = now;
    return true;
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// SAFE AGGRESSION
// =====================================================

frameworkBotAggressionSafeLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_aggression_safe");
    level endon("game_ended");

    lastPrint = 0;
    lastAggroAction = 0;

    for (;;)
    {
        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_aggressive") != 1)
        {
            wait 1.0;
            continue;
        }

        if (!isAlive(self))
            return;

        now = getTime();

        if (now - lastAggroAction > 2500)
        {
            lastAggroAction = now;

            if (randomInt(100) < 10)
                self botpressbutton("jump");
        }

        if (getDvarInt("fw_bot_aggro_debug") == 1 && getTime() - lastPrint > 5000)
        {
            lastPrint = getTime();

            foreach (player in level.players)
            {
                if (isDefined(player) && !isbot(player) && isAlive(player))
                    player iprintln(level.prefix + "^5[BOTS]^7 » ^2Safe aggression active");
            }
        }

        if (getDvarInt("fw_bot_aggressive_interval") == 1)
            wait 2.5;
        else
            wait 1.25;
    }
}

////////////////////////////////////////////////////////////////////////

// =====================================================
// STUCK FIX
// =====================================================

frameworkBotStuckFixLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_stuck_fix");
    level endon("game_ended");

    wait 5.0;

    lastOrigin = self.origin;
    strikes = 0;
    self.is_suspected_stuck = 0;

    for (;;)
    {
        delay = getDvarInt("fw_bot_stuck_check_delay");

        if (!isDefined(delay) || delay < 8)
        {
            delay = 12;
            setDvar("fw_bot_stuck_check_delay", "12");
        }

        wait delay;

        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_stuck_fix") != 1)
            continue;

        if (!isAlive(self))
            return;

        if (!self isOnGround() || isTrue(self.inlaststand) || isTrue(self.laststand))
        {
            lastOrigin = self.origin;
            strikes = 0;
            self.is_suspected_stuck = 0;
            continue;
        }

        dist = distance(self.origin, lastOrigin);

        if (dist < 25)
        {
            strikes++;
            self.is_suspected_stuck = 1;
        }
        else
        {
            strikes = 0;
            self.is_suspected_stuck = 0;
        }

        if (strikes >= 3)
        {
            self frameworkSmartBotSafeReset();

            // Safe unstuck action.
            // No nav queries, no script goal clearing.
            if (self frameworkBotCanDoAction())
                self botpressbutton("jump");

            strikes = 0;
            self.is_suspected_stuck = 0;
        }

        lastOrigin = self.origin;
    }
}

////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////

// =====================================================
// BOT SKIN REROLL COMMAND
// =====================================================

watchFrameworkBotSkinReroll()
{
    level endon("game_ended");

    for (;;)
    {
        wait 1.0;

        if (getDvarInt("fw_bot_skin_reroll") != 1)
            continue;

        rerollFrameworkBotSkins();
        setDvar("fw_bot_skin_reroll", "0");
    }
}

////////////////////////////////////////////////////////////////////////

rerollFrameworkBotSkins()
{
    count = 0;

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        if (!isbot(player))
            continue;

        if (!isAlive(player))
            continue;

        // Clear cached skin so the current skin mode can choose/apply again.
        player.frameworkBotSkinId = undefined;

        // Clear debug guards so debug can print once for the new skin if enabled.
        player.frameworkLastDebugSkinId = undefined;
        player.frameworkLastSkinDebugPrint = undefined;

        player thread applyFrameworkBotSkinDelayed();
        count++;
    }

    foreach (player in level.players)
    {
        if (isDefined(player) && !isbot(player))
            player iprintln(level.prefix + "^5[BOT SKIN]^7 » ^2Rerolled skins for ^5" + count + " ^2bot(s)");
    }
}

// =====================================================
// BOT SKINS / OPERATOR CUSTOMIZATION
// =====================================================

applyFrameworkBotSkinDelayed()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    wait randomFloatRange(0.5, 2.0);

    self applyFrameworkBotSkin();
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBotSkin()
{
    if (!isDefined(self))
        return;

    if (!isbot(self))
        return;

    if (!isAlive(self))
        return;

    if (getDvarInt("fw_bot_skins") != 1)
        return;

    mode = getDvar("fw_bot_skin_mode");

    if (!isDefined(mode) || mode == "")
        mode = "sweat";

    if (mode == "off")
        return;

    if (mode == "custom")
    {
        self applyFrameworkBotCustomSkin();
        return;
    }

    if (mode == "boss")
    {
        self applyFrameworkBotBossSkin();
        return;
    }

    // Default mode: sweat
    self applyFrameworkBotSweatSkin();
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBotCustomSkin()
{
    skinId = getDvarInt("fw_bot_skin_id");

    if (!isDefined(skinId) || skinId <= 0)
        return;

    self applyFrameworkBotSkinId(skinId);
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBotBossSkin()
{
    pool = getFrameworkBossSkinPool();

    if (pool.size <= 0)
        return;

    if (!isDefined(self.frameworkBotSkinId))
        self.frameworkBotSkinId = pool[randomInt(pool.size)];

    self applyFrameworkBotSkinId(self.frameworkBotSkinId);
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBotSweatSkin()
{
    if (!isDefined(self.frameworkBotSkinId))
    {
        pool = getFrameworkSweatSkinPool();

        if (pool.size <= 0)
            return;

        self.frameworkBotSkinId = pool[randomInt(pool.size)];
    }

    self applyFrameworkBotSkinId(self.frameworkBotSkinId);
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBotSkinId(skinId)
{
    if (!isDefined(skinId) || skinId <= 0)
        return;

    table = "operatorSkins.csv";

    body = tableLookup(table, 0, skinId, 4);
    head = tableLookup(table, 0, skinId, 5);

    if (!isDefined(body) || body == "")
    {
        stringId = "" + skinId;
        body = tableLookup(table, 0, stringId, 4);
        head = tableLookup(table, 0, stringId, 5);
    }

    if (!isDefined(body) || body == "")
        return;

    self setCustomization(body, head);

    finalBody = self getCustomizationBody();
    finalHead = self getCustomizationHead();
    finalViewmodel = self getCustomizationViewmodel();

    if (isDefined(self.headmodel))
        self detach(self.headmodel);

    self setModel(finalBody);
    self setViewModel(finalViewmodel);
    self attach(finalHead, "", 1);

    self.headmodel = finalHead;
    self.frameworkBotSkinId = skinId;

    if (getDvarInt("fw_bot_skin_debug") == 1)
        self printFrameworkBotSkinDebug(skinId, body, head);
}

////////////////////////////////////////////////////////////////////////

printFrameworkBotSkinDebug(skinId, body, head)
{
    if (getDvarInt("fw_bot_skin_debug") != 1)
        return;

    if (!isDefined(skinId) || skinId <= 0)
        return;

    // Print only once per bot/skin ID to prevent spawn/apply spam.
    if (isDefined(self.frameworkLastDebugSkinId) && self.frameworkLastDebugSkinId == skinId)
        return;

    now = getTime();
    rate = getDvarInt("fw_bot_skin_debug_rate");

    if (!isDefined(rate) || rate < 1000)
    {
        rate = 15000;
        setDvar("fw_bot_skin_debug_rate", "15000");
    }

    // Extra safety: per-bot rate limit.
    if (isDefined(self.frameworkLastSkinDebugPrint) && now - self.frameworkLastSkinDebugPrint < rate)
        return;

    self.frameworkLastDebugSkinId = skinId;
    self.frameworkLastSkinDebugPrint = now;

    foreach (player in level.players)
    {
        if (isDefined(player) && !isbot(player))
        {
            player iprintln(
                level.prefix +
                "^5[BOT SKIN]^7 » ^2" + self.name +
                " ^7• Skin ID ^5" + skinId
            );
        }
    }
}

////////////////////////////////////////////////////////////////////////

getFrameworkSweatSkinPool()
{
    return [
        2906, 906, 207, 1060, 1059, 1580, 2902, 1758, 2923, 2928,
        918, 994, 996, 1571, 796, 897, 2917, 2929, 1638, 995,
        912, 2840, 1803, 206, 1297, 1599, 2870, 2838, 2790, 768,
        2789, 2919, 2916, 2927, 2897, 2921, 2925, 2709, 205, 997,
        2401, 1094, 1363, 1499, 1473, 1457, 1667, 2078, 91, 143,
        232, 2973, 2077, 2952, 2954, 2898, 938, 936
    ];
}

////////////////////////////////////////////////////////////////////////

getFrameworkBossSkinPool()
{
    return [
        2881, 207, 768, 910, 1060, 1580, 1638
    ];
}
