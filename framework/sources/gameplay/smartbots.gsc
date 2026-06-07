// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: smartbots.gsc

////////////////////////////////////////////////////////////////////////

// Framework smart bot systems — fixed v1.8.5
//
// Keeps:
// - jump while shooting
// - crouch/prone while shooting
// - fake rank metadata
// - boss identity metadata
// - stuck fix
//
// Removed risky 1681 calls:
// - setRank()
// - bot_set_difficulty()
// - botsetflag()
// - botclearscriptgoal()
// - botclearscriptenemy()

////////////////////////////////////////////////////////////////////////

init()
{
    if (isDefined(level.frameworkSmartBotsReady))
        return;

    level.frameworkSmartBotsReady = true;

    setDvarIfUninitialized("fw_smart_bots", 1);
    setDvarIfUninitialized("fw_bot_jump_shoot", 1);
    setDvarIfUninitialized("fw_bot_aggressive", 0);
    setDvarIfUninitialized("fw_bot_aggressive_interval", 0);
    setDvarIfUninitialized("fw_bot_aggro_debug", 0);
    setDvarIfUninitialized("fw_bot_stuck_fix", 1);
    setDvarIfUninitialized("fw_bot_boss", 0);
    setDvarIfUninitialized("fw_bot_fake_rank", 1);
    setDvarIfUninitialized("fw_bot_rank_min", 14);
    setDvarIfUninitialized("fw_bot_rank_max", 755);
    setDvarIfUninitialized("fw_bot_prestige_min", 1);
    setDvarIfUninitialized("fw_bot_prestige_max", 27);

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

    if (!isbot(self) || !isAlive(self))
        return;

    self frameworkSmartBotSafeReset();
    self applyFrameworkSmartBotRank();

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
}

////////////////////////////////////////////////////////////////////////

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
            if (isDefined(player) && isbot(player) && isDefined(player.frameworkBotBoss) && player.frameworkBotBoss)
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

    self applyFrameworkSmartBotRank();
}

////////////////////////////////////////////////////////////////////////

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

        now = getTime();

        // cooldown to prevent stance/jump spam and frame drops
        if (now - self.frameworkLastBotActionTime < 1500)
            continue;

        self.frameworkLastBotActionTime = now;

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

frameworkBotStuckFixLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_stuck_fix");
    level endon("game_ended");

    wait 5.0;

    lastOrigin = self.origin;
    strikes = 0;

    for (;;)
    {
        wait 12.0;

        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_stuck_fix") != 1)
            continue;

        if (!isAlive(self))
            return;

        dist = distance(self.origin, lastOrigin);

        if (dist < 25)
            strikes++;
        else
            strikes = 0;

        if (strikes >= 3)
        {
            self frameworkSmartBotSafeReset();

            if (randomInt(100) < 50)
                self botpressbutton("jump");

            strikes = 0;
        }

        lastOrigin = self.origin;
    }
}