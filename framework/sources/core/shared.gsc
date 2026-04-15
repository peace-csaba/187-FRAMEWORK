// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: shared.gsc

////////////////////////////////////////////////////////////////////////

// Shared helpers used across the framework

////////////////////////////////////////////////////////////////////////

// Framework-supported modes
//
// Block modes that are not verified yet.
// Fresno is disabled for now because it throws script/drop errors
// with framework startup on this build.
isFrameworkSupportedMode()
{
    if (!isDefined(level.gametype))
        return false;

    if (level.gametype == "fresno")
        return false;

    return true;
}

////////////////////////////////////////////////////////////////////////

// Warzone-style mode check
isWarzone()
{
    return isDefined(level.gametype) && (level.gametype == "br" || level.gametype == "brtdm");
}

////////////////////////////////////////////////////////////////////////

// Generic player validity
isValidPlayer(player)
{
    return isDefined(player) && isPlayer(player);
}

////////////////////////////////////////////////////////////////////////

// Generic alive-player validity
isAlivePlayer(player)
{
    return isDefined(player) && isPlayer(player) && isAlive(player);
}

////////////////////////////////////////////////////////////////////////

// Plate reward gate
canUsePlateRewards()
{
    return isFrameworkSupportedMode() && isWarzone() && level.enablePlateRewards;
}

////////////////////////////////////////////////////////////////////////

// Generic framework print helper
frameworkPrint(text)
{
    mode = getDvarInt("prints");

    if (!isDefined(mode))
        mode = 1;

    if (mode <= 0)
        return;

    if (mode == 2)
    {
        self iprintlnbold(text);
        return;
    }

    self iprintln(text);
}

////////////////////////////////////////////////////////////////////////

// Legacy alias
customprint(text)
{
    self frameworkPrint(text);
}

////////////////////////////////////////////////////////////////////////

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
    speed = getDvarFloat("stim_boost_speed");
    duration = getDvarInt("stim_boost_duration");
    decay = getDvarFloat("stim_boost_decay");

    if (!isDefined(speed) || speed <= 0)
    {
        speed = 1.05;
        setDvar("stim_boost_speed", "" + speed);
    }

    if (!isDefined(duration) || duration <= 0)
    {
        duration = 10;
        setDvar("stim_boost_duration", "" + duration);
    }

    if (!isDefined(decay) || decay < 0)
    {
        decay = 0.1;
        setDvar("stim_boost_decay", "" + decay);
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
    speed = getDvarFloat("stim_boost_speed");
    duration = getDvarInt("stim_boost_duration");
    decay = getDvarFloat("stim_boost_decay");

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
    if (getDvarFloat("stim_boost_speed") != level.frameworkStimSpeed)
        setDvar("stim_boost_speed", "" + level.frameworkStimSpeed);

    if (getDvarInt("stim_boost_duration") != level.frameworkStimDuration)
        setDvar("stim_boost_duration", "" + level.frameworkStimDuration);

    if (getDvarFloat("stim_boost_decay") != level.frameworkStimDecay)
        setDvar("stim_boost_decay", "" + level.frameworkStimDecay);
}

////////////////////////////////////////////////////////////////////////

// DVAR sync / protection
//
// Handles:
// - stim_boost_speed
// - stim_boost_duration
// - stim_boost_decay
//
// This is the ONLY place that prints global update messages.
initDvarsProtection()
{
    level endon("game_ended");

    frameworkEnsureStimDvars();
    frameworkCacheStimDvars();

    for (;;)
    {
        wait 1;
        frameworkCheckStimDvarChanges();
        frameworkEnforceStimDvars();
    }
}

////////////////////////////////////////////////////////////////////////

// Ingame command handler
//
// Commands:
// - stimbase <float>
// - stimduration <int>
// - stimdecay <float>
//
// This function only sets DVARs.
// Global feedback is printed by initDvarsProtection().
handleFrameworkHostCommand(cmd, arg1)
{
    switch (cmd)
    {
        case "stimbase":
            if (!isDefined(arg1))
            {
                self iprintln(level.prefix + "^1[DVAR]^7 » Usage:^7 ^5stimbase <float>");
                return true;
            }

            setDvar("stim_boost_speed", "" + arg1);
            return true;

        case "stimduration":
            if (!isDefined(arg1))
            {
                self iprintln(level.prefix + "^1[DVAR]^7 » Usage:^7 ^5stimduration <int>");
                return true;
            }

            setDvar("stim_boost_duration", "" + arg1);
            return true;

        case "stimdecay":
            if (!isDefined(arg1))
            {
                self iprintln(level.prefix + "^1[DVAR]^7 » Usage:^7 ^5stimdecay <float>");
                return true;
            }

            setDvar("stim_boost_decay", "" + arg1);
            return true;
    }

    return false;
}
