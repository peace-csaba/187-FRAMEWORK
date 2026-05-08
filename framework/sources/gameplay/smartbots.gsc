///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// ========================================================================================================================

// Original credits preserved below.
// Clean pass: decoded string concatenation, removed no-op obfuscation lines,
// normalized formatting, and disabled the malicious infinite bot-spawn trap against 187 framework.

// ========================================================================================================================

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Developed by cilism and enviuz

// Credits:
// Elbasedd - His "bot sauce" helped with bot ranks.
// RyGuy2Cool - Inspired me to actually study GSC.
// The Community - For inspiring me to make a GSC that solves a problem everyone has wanted a fix to.
// Testers! - Eeffoc, AKAJay, Vanguard, AceAdxm, JoelCantCode, Laura, and everyone who played it.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: smartbots.gsc

////////////////////////////////////////////////////////////////////////

// Framework smart bot systems
//
// DVARs:
// - fw_smart_bots
// - fw_bot_jump_shoot
// - fw_bot_aggressive
// - fw_bot_aggressive_interval
// - fw_bot_aggro_debug
// - fw_bot_stuck_fix
// - fw_bot_realistic_difficulty
// - fw_bot_boss
// - fw_bot_fake_rank
// - fw_bot_rank_min
// - fw_bot_rank_max
// - fw_bot_prestige_min
// - fw_bot_prestige_max

////////////////////////////////////////////////////////////////////////

init()
{
    if (isDefined(level.frameworkSmartBotsReady))
        return;

    level.frameworkSmartBotsReady = true;

    setDvarIfUninitialized("fw_smart_bots", 1);
    setDvarIfUninitialized("fw_bot_jump_shoot", 1);
    setDvarIfUninitialized("fw_bot_aggressive", 1);
    setDvarIfUninitialized("fw_bot_aggressive_interval", 0);
    setDvarIfUninitialized("fw_bot_aggro_debug", 0);
    setDvarIfUninitialized("fw_bot_stuck_fix", 1);
    setDvarIfUninitialized("fw_bot_realistic_difficulty", 0);
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

    self thread watchFrameworkSmartBotSpawn();
}

////////////////////////////////////////////////////////////////////////

watchFrameworkSmartBotSpawn()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!isbot(self))
        return;

    self initFrameworkSmartBotIdentity();

    for (;;)
    {
        self waittill("spawned_player");

        if (getDvarInt("fw_smart_bots") != 1)
            continue;

        self notify("stop_framework_smartbot_spawn");
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

    wait 0.15;

    if (!isbot(self) || !isAlive(self))
        return;

    self botsetstance("stand");
    self botclearscriptgoal();
    self botclearscriptenemy();

    self.frameworkBotTracking = 0;
    self.frameworkBotStuck = 0;

    self applyFrameworkSmartBotRank();
    self applyFrameworkSmartBotDifficulty();

    self notify("stop_framework_bot_jump_shoot");
    self notify("stop_framework_bot_aggro");
    self notify("stop_framework_bot_stuck_fix");

    if (getDvarInt("fw_bot_jump_shoot") == 1)
        self thread frameworkBotJumpShootLoop();

    if (getDvarInt("fw_bot_aggressive") == 1)
        self thread frameworkBotAggroLoop();

    if (getDvarInt("fw_bot_stuck_fix") == 1)
        self thread frameworkBotStuckFixLoop();
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

    if (isDefined(self.frameworkBotRank) && isDefined(self.frameworkBotPrestige))
        self setRank(self.frameworkBotRank, self.frameworkBotPrestige);
}

////////////////////////////////////////////////////////////////////////

applyFrameworkSmartBotDifficulty()
{
    if (!isbot(self))
        return;

    if (isDefined(self.frameworkBotBoss) && self.frameworkBotBoss)
    {
        self scripts\mp\bots\bots_util::bot_set_difficulty("veteran");
        self botsetdifficultysetting("fireFromHipDist", 150);
        self botsetdifficultysetting("minInaccuracy", 0.05);
        self botsetdifficultysetting("maxInaccuracy", 0.20);
        self botsetdifficultysetting("reactionTime", 50);
        self botsetdifficultysetting("yawSpeed", 12);
        self botsetdifficultysetting("pitchSpeed", 12);
        self botsetdifficultysetting("yawSpeedAds", 12);
        self botsetdifficultysetting("pitchSpeedAds", 12);
        self botsetdifficultysetting("meleeReactAllowed", 0);
        self botsetdifficultysetting("throwKnifeChance", 0.01);
        self botsetdifficultysetting("minTimeBetweenBursts", 0);
        return;
    }

    if (getDvarInt("fw_bot_realistic_difficulty") == 1)
    {
        self scripts\mp\bots\bots_util::bot_set_difficulty("hardened");
        self botsetdifficultysetting("fireFromHipDist", 150);
        self botsetdifficultysetting("minInaccuracy", 0.25);
        self botsetdifficultysetting("maxInaccuracy", 0.75);
        self botsetdifficultysetting("reactionTime", 150);
        self botsetdifficultysetting("yawSpeed", 8);
        self botsetdifficultysetting("pitchSpeed", 8);
        self botsetdifficultysetting("yawSpeedAds", 8);
        self botsetdifficultysetting("pitchSpeedAds", 8);
        self botsetdifficultysetting("meleeReactAllowed", 0);
        self botsetdifficultysetting("throwKnifeChance", 0.01);
        self botsetdifficultysetting("minTimeBetweenBursts", 0);
        return;
    }

    difficulty = getDvar("fw_bot_difficulty");

    if (!isDefined(difficulty) || difficulty == "")
        difficulty = "regular";

    self scripts\mp\bots\bots_util::bot_set_difficulty(difficulty);
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
            if (isDefined(player) && isbot(player))
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

    self applyFrameworkSmartBotRank();
    self applyFrameworkSmartBotDifficulty();
}

////////////////////////////////////////////////////////////////////////

frameworkBotJumpShootLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_jump_shoot");
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired");

        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_jump_shoot") != 1)
            continue;

        if (randomInt(100) < 25)
        {
            self botpressbutton("jump");
            wait randomFloatRange(0.5, 1.5);
        }

        if (randomInt(100) < 15)
        {
            self botsetstance("crouch");
            wait randomFloatRange(0.15, 0.25);
            self botsetstance("stand");
            wait randomFloatRange(0.15, 0.25);
            self botsetstance("crouch");
            wait randomFloatRange(0.15, 0.25);
            self botsetstance("stand");
            wait randomFloatRange(0.5, 1.5);
        }

        if (randomInt(100) < 5)
        {
            self botsetstance("prone");
            wait randomFloatRange(0.25, 1.5);
            self botsetstance("stand");
            wait 0.25;
            self botpressbutton("jump");
            wait randomFloatRange(0.5, 1.5);
        }
    }
}

////////////////////////////////////////////////////////////////////////

frameworkBotAggroLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_aggro");
    level endon("game_ended");

    self.frameworkBotTracking = 0;

    for (;;)
    {
        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_aggressive") != 1)
        {
            self frameworkBotAggroOff();
            wait 1.0;
            continue;
        }

        target = self findFrameworkSmartBotTarget();

        if (!isDefined(target) || !isAlive(target))
        {
            self frameworkBotAggroOff();
            wait 1.0;
            continue;
        }

        shouldTrack = 1;

        if (getDvarInt("fw_bot_aggressive_interval") == 1)
        {
            phase = int(getTime() / 1000) % 25;

            if (phase >= 15)
                shouldTrack = 0;
        }

        if (shouldTrack)
        {
            if (!isDefined(self.frameworkBotTracking) || !self.frameworkBotTracking)
            {
                self.frameworkBotTracking = 1;

                if (getDvarInt("fw_bot_aggro_debug") == 1)
                    target iprintln(level.prefix + "^5[BOTS]^7 » ^1Smart bots tracked your position");
            }

            self botsetflag("force_sprint", 1);
            self botsetflag("frozen", 0);
            self freezecontrols(0);
            self.ignoreall = 0;
            self getenemyinfo(target);
            self botgetimperfectenemyinfo(target, target.origin);
            self botsetscriptgoal(target.origin, 64, "critical");
            self botsetattacker(target);
        }
        else
        {
            self frameworkBotAggroOff();
        }

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

frameworkBotAggroOff()
{
    self.frameworkBotTracking = 0;
    self botsetflag("force_sprint", 0);
    self botclearscriptgoal();
    self botclearscriptenemy();

    if (isDefined(self.enemy))
        self.enemy = undefined;

    if (isDefined(self.attacker))
        self.attacker = undefined;
}

////////////////////////////////////////////////////////////////////////

findFrameworkSmartBotTarget()
{
    bestTarget = undefined;
    bestScore = -999999;

    foreach (candidate in level.players)
    {
        if (!isDefined(candidate))
            continue;

        if (candidate == self)
            continue;

        if (!isAlive(candidate))
            continue;

        if (isDefined(level.teambased) && level.teambased && isDefined(self.team) && isDefined(candidate.team) && self.team == candidate.team)
            continue;

        dist = distance(self.origin, candidate.origin);
        score = 10000 - dist;

        if (isTrue(candidate.inlaststand) || isTrue(candidate.laststand))
            score -= 8000;

        if (isDefined(self.bot_last_attacker) && candidate == self.bot_last_attacker)
        {
            if (getTime() - self.bot_last_attack_time < 3000)
                score += 3000;
        }

        if (isbot(candidate))
            score -= 500;

        if (score > bestScore)
        {
            bestScore = score;
            bestTarget = candidate;
        }
    }

    return bestTarget;
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
    self.frameworkBotStuck = 0;

    for (;;)
    {
        wait 8.0;

        if (getDvarInt("fw_smart_bots") != 1 || getDvarInt("fw_bot_stuck_fix") != 1)
            continue;

        if (!isAlive(self) || !self isOnGround() || isTrue(self.inlaststand) || isTrue(self.laststand))
        {
            lastOrigin = self.origin;
            strikes = 0;
            self.frameworkBotStuck = 0;
            continue;
        }

        dist = distance(self.origin, lastOrigin);

        if (dist < 25)
        {
            strikes++;
            self.frameworkBotStuck = 1;

            if (strikes >= 3)
            {
                self frameworkSmartBotScatterTeleport();
                self botclearscriptgoal();
                self botclearscriptenemy();
                strikes = 0;
                self.frameworkBotStuck = 0;
                lastOrigin = self.origin;
                continue;
            }
        }
        else
        {
            strikes = 0;
            self.frameworkBotStuck = 0;
        }

        lastOrigin = self.origin;
    }
}

////////////////////////////////////////////////////////////////////////

frameworkSmartBotScatterTeleport()
{
    if (!isDefined(self) || !isAlive(self))
        return;

    anchor = getFrameworkRandomHumanPlayer();

    if (!isDefined(anchor))
        anchor = self getFrameworkAliveTeammate();

    anchorOrigin = self.origin;

    if (isDefined(anchor) && isDefined(anchor.origin))
        anchorOrigin = anchor.origin;

    minSpread = 750;
    maxSpread = 6000;

    if (minSpread >= maxSpread)
    {
        minSpread = 250;
        maxSpread = 3000;
    }

    teleportSpot = undefined;

    for (i = 0; i < 12; i++)
    {
        angle = randomInt(360);
        spread = randomFloatRange(minSpread, maxSpread);
        dir = anglesToForward((0, angle, 0));
        point = anchorOrigin + (dir * spread);
        point = (point[0], point[1], point[2] + 500);

        floor = botGetClosestNavigablePoint(point, 1500);

        if (isDefined(floor))
        {
            teleportSpot = floor;
            break;
        }

        wait 0.05;
    }

    if (!isDefined(teleportSpot))
    {
        fallback = (self.origin[0], self.origin[1], self.origin[2] + 500);
        teleportSpot = botGetClosestNavigablePoint(fallback, 5000);
    }

    if (!isDefined(teleportSpot))
        return;

    self setOrigin((teleportSpot[0], teleportSpot[1], teleportSpot[2] + 20));
    self botsetscriptgoal(teleportSpot, 128, "critical");
}

////////////////////////////////////////////////////////////////////////

getFrameworkRandomHumanPlayer()
{
    humans = [];

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        if (!isAlive(player))
            continue;

        if (isbot(player))
            continue;

        humans[humans.size] = player;
    }

    if (humans.size <= 0)
        return undefined;

    return humans[randomInt(humans.size)];
}

////////////////////////////////////////////////////////////////////////

getFrameworkAliveTeammate()
{
    teammates = [];

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        if (player == self)
            continue;

        if (!isAlive(player))
            continue;

        if (!isDefined(self.team) || !isDefined(player.team))
            continue;

        if (self.team != player.team)
            continue;

        teammates[teammates.size] = player;
    }

    if (teammates.size <= 0)
        return undefined;

    return teammates[randomInt(teammates.size)];
}
