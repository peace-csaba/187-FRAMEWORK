// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: smartbots.gsc

////////////////////////////////////////////////////////////////////////

// Smart Bot System — Safe Baseline
//
// Stable v1.8.2 version
//
// Removed risky native bot calls:
// - botpressbutton
// - botsetstance
// - bot_set_difficulty
// - setRank
// - botsetflag
// - botsetscriptgoal
// - botsetattacker
// - botGetClosestNavigablePoint
//
// Safe systems retained:
// - boss bot support
// - fake rank metadata
// - safe stuck reset
// - aggro debug
// - framework-owned DVAR handling

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    initSmartBotDvars();

    level thread watchSmartBots();
}

////////////////////////////////////////////////////////////////////////

initSmartBotDvars()
{
    setDvarIfUninitialized("fw_smart_bots", 1);

    setDvarIfUninitialized("fw_bot_boss", 0);

    setDvarIfUninitialized("fw_bot_fake_rank", 1);
    setDvarIfUninitialized("fw_bot_rank_min", 1);
    setDvarIfUninitialized("fw_bot_rank_max", 55);

    setDvarIfUninitialized("fw_bot_prestige_min", 0);
    setDvarIfUninitialized("fw_bot_prestige_max", 10);

    setDvarIfUninitialized("fw_bot_aggro_debug", 0);

    setDvarIfUninitialized("fw_bot_stuck_fix", 1);
}

////////////////////////////////////////////////////////////////////////

watchSmartBots()
{
    level endon("game_ended");

    for (;;)
    {
        foreach (player in level.players)
        {
            if (!isDefined(player))
                continue;

            if (!isbot(player))
                continue;

            if (!isDefined(player.frameworkSmartBotInit))
            {
                player.frameworkSmartBotInit = true;
                player thread setupSmartBot();
            }
        }

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

setupSmartBot()
{
    self endon("disconnect");
    level endon("game_ended");

    self.frameworkFakeRank = randomIntRange(
        getDvarInt("fw_bot_rank_min"),
        getDvarInt("fw_bot_rank_max") + 1
    );

    self.frameworkFakePrestige = randomIntRange(
        getDvarInt("fw_bot_prestige_min"),
        getDvarInt("fw_bot_prestige_max") + 1
    );

    if (getDvarInt("fw_bot_boss") == 1)
        self thread frameworkBossBotLoop();

    if (getDvarInt("fw_bot_stuck_fix") == 1)
        self thread frameworkSafeBotResetLoop();

    if (getDvarInt("fw_bot_aggro_debug") == 1)
        self thread frameworkBotDebugLoop();
}

////////////////////////////////////////////////////////////////////////

// Safe boss bot system
frameworkBossBotLoop()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    self.maxhealth = 350;
    self.health = self.maxhealth;

    for (;;)
    {
        if (!isAlive(self))
            return;

        if (self.health < self.maxhealth)
            self.health += 2;

        if (self.health > self.maxhealth)
            self.health = self.maxhealth;

        wait 0.25;
    }
}

////////////////////////////////////////////////////////////////////////

// Safe stuck reset
//
// No nav calls.
// No script-goal calls.
frameworkSafeBotResetLoop()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");

    lastOrigin = self.origin;
    stuckTime = 0;

    for (;;)
    {
        wait 3.0;

        if (!isAlive(self))
            continue;

        dist = distance(lastOrigin, self.origin);

        if (dist < 25)
            stuckTime++;
        else
            stuckTime = 0;

        if (stuckTime >= 3)
        {
            teammate = undefined;

            foreach (player in level.players)
            {
                if (!isDefined(player))
                    continue;

                if (!isAlive(player))
                    continue;

                if (!isbot(player))
                {
                    teammate = player;
                    break;
                }
            }

            if (isDefined(teammate))
            {
                self setOrigin(teammate.origin + (0, 0, 20));
            }

            stuckTime = 0;
        }

        lastOrigin = self.origin;
    }
}

////////////////////////////////////////////////////////////////////////

// Safe debug loop
frameworkBotDebugLoop()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        wait 10.0;

        if (!isAlive(self))
            continue;

        iprintln(
            "^5[SMARTBOT]^7 " +
            self.name +
            " ^7• Rank: ^2" + self.frameworkFakeRank +
            " ^7• Prestige: ^3" + self.frameworkFakePrestige
        );
    }
}