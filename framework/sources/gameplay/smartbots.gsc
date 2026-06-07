// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: smartbots.gsc

////////////////////////////////////////////////////////////////////////

// Framework smart bot systems — optimized v1.8.5
//
// Focus:
// - less frame drops
// - less bot-native call spam
// - safer timing
// - no boss system
// - no rank system
//
// Keeps:
// - jump while shooting
// - crouch/prone chance while shooting
// - stuck fix
//
// Removed:
// - boss watcher
// - rank/prestige metadata
// - aggressive loop by default
// - repeated high-frequency DVAR checks

////////////////////////////////////////////////////////////////////////

init()
{
    if (isDefined(level.frameworkSmartBotsReady))
        return;

    level.frameworkSmartBotsReady = true;

    setDvarIfUninitialized("fw_smart_bots", 1);
    setDvarIfUninitialized("fw_bot_jump_shoot", 1);
    setDvarIfUninitialized("fw_bot_stuck_fix", 1);

    // Action cooldown in milliseconds.
    // Higher = less spam / better FPS.
    setDvarIfUninitialized("fw_bot_action_cooldown", 1250);

    level thread watchFrameworkSmartBotsLite();
}

////////////////////////////////////////////////////////////////////////

watchFrameworkSmartBotsLite()
{
    level endon("game_ended");

    for (;;)
    {
        if (getDvarInt("fw_smart_bots") == 1)
        {
            foreach (player in level.players)
            {
                if (!isDefined(player))
                    continue;

                if (!isbot(player))
                    continue;

                if (!isDefined(player.frameworkSmartBotConnected))
                {
                    player.frameworkSmartBotConnected = true;
                    player thread onFrameworkSmartBotConnected();
                }
            }
        }

        wait 2.0;
    }
}

////////////////////////////////////////////////////////////////////////

onFrameworkSmartBotConnected()
{
    self endon("disconnect");
    level endon("game_ended");

    if (!isbot(self))
        return;

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_bot_jump_shoot");
        self notify("stop_framework_bot_stuck_fix");

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
    level endon("game_ended");

    wait 0.35;

    if (!isDefined(self))
        return;

    if (!isbot(self))
        return;

    if (!isAlive(self))
        return;

    self.frameworkLastBotActionTime = 0;

    if (getDvarInt("fw_bot_jump_shoot") == 1)
        self thread frameworkBotJumpShootLoopOptimized();

    if (getDvarInt("fw_bot_stuck_fix") == 1)
        self thread frameworkBotStuckFixLoopOptimized();
}

////////////////////////////////////////////////////////////////////////

frameworkBotCanDoAction()
{
    cooldown = getDvarInt("fw_bot_action_cooldown");

    if (!isDefined(cooldown) || cooldown < 500)
        cooldown = 1250;

    if (!isDefined(self.frameworkLastBotActionTime))
        self.frameworkLastBotActionTime = 0;

    now = getTime();

    if (now - self.frameworkLastBotActionTime < cooldown)
        return false;

    self.frameworkLastBotActionTime = now;
    return true;
}

////////////////////////////////////////////////////////////////////////

frameworkBotJumpShootLoopOptimized()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_jump_shoot");
    level endon("game_ended");

    for (;;)
    {
        self waittill("weapon_fired");

        if (getDvarInt("fw_smart_bots") != 1)
            return;

        if (getDvarInt("fw_bot_jump_shoot") != 1)
            return;

        if (!isAlive(self))
            return;

        if (!self frameworkBotCanDoAction())
            continue;

        roll = randomInt(100);

        // Lower chances = less native-call spam.
        if (roll < 14)
        {
            self botpressbutton("jump");
            wait randomFloatRange(0.45, 0.85);
            continue;
        }

        if (roll < 24)
        {
            self botsetstance("crouch");
            wait randomFloatRange(0.20, 0.35);
            self botsetstance("stand");
            continue;
        }

        if (roll < 28)
        {
            self botsetstance("prone");
            wait randomFloatRange(0.35, 0.70);
            self botsetstance("stand");
        }
    }
}

////////////////////////////////////////////////////////////////////////

frameworkBotStuckFixLoopOptimized()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_bot_stuck_fix");
    level endon("game_ended");

    wait 8.0;

    lastOrigin = self.origin;
    strikes = 0;

    for (;;)
    {
        wait 15.0;

        if (getDvarInt("fw_smart_bots") != 1)
            return;

        if (getDvarInt("fw_bot_stuck_fix") != 1)
            return;

        if (!isAlive(self))
            return;

        dist = distance(self.origin, lastOrigin);

        if (dist < 35)
            strikes++;
        else
            strikes = 0;

        if (strikes >= 2)
        {
            if (self frameworkBotCanDoAction())
                self botpressbutton("jump");

            strikes = 0;
        }

        lastOrigin = self.origin;
    }
}