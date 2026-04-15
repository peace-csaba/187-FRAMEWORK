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
customprint(text)
{
    mode = getDvarInt("prints");

    if (!isDefined(mode))
        mode = 1;

    switch (mode)
    {
        case 0:
            break;

        case 1:
            self iprintln(text);
            break;

        case 2:
            self iprintlnbold(text);
            break;

        default:
            self iprintln(text);
            break;
    }
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

    // =========================
    // SAFE DEFAULTS
    // =========================
    if (getDvarFloat("stim_boost_speed") <= 0)
        setDvar("stim_boost_speed", "1.05");

    if (getDvarInt("stim_boost_duration") <= 0)
        setDvar("stim_boost_duration", "10");

    if (getDvarFloat("stim_boost_decay") < 0)
        setDvar("stim_boost_decay", "0.1");

    // =========================
    // INITIAL CACHE
    // =========================
    level.stim_speed_host = getDvarFloat("stim_boost_speed");
    level.stim_duration_host = getDvarInt("stim_boost_duration");
    level.stim_decay_host = getDvarFloat("stim_boost_decay");

    level.last_speed = level.stim_speed_host;
    level.last_duration = level.stim_duration_host;
    level.last_decay = level.stim_decay_host;

    for (;;)
    {
        wait 1;

        newSpeed = getDvarFloat("stim_boost_speed");
        newDuration = getDvarInt("stim_boost_duration");
        newDecay = getDvarFloat("stim_boost_decay");

        // =========================
        // CLAMP BAD VALUES
        // =========================
        if (newSpeed <= 0)
        {
            newSpeed = level.last_speed;
            setDvar("stim_boost_speed", "" + newSpeed);
        }

        if (newDuration <= 0)
        {
            newDuration = level.last_duration;
            setDvar("stim_boost_duration", "" + newDuration);
        }

        if (newDecay < 0)
        {
            newDecay = level.last_decay;
            setDvar("stim_boost_decay", "" + newDecay);
        }

        // =========================
        // DETECT CHANGES
        // =========================
        if (newSpeed != level.last_speed)
        {
            level.last_speed = newSpeed;

            foreach (p in level.players)
            {
                if (isDefined(p))
                    p iprintln(level.prefix + "^1[DVAR]^7 » ^2Stim Speed:^7 ^2" + newSpeed + " ^7(updated)");
            }
        }

        if (newDuration != level.last_duration)
        {
            level.last_duration = newDuration;

            foreach (p in level.players)
            {
                if (isDefined(p))
                    p iprintln(level.prefix + "^1[DVAR]^7 » ^3Stim Duration:^7 ^3" + newDuration + " ^7(updated)");
            }
        }

        if (newDecay != level.last_decay)
        {
            level.last_decay = newDecay;

            foreach (p in level.players)
            {
                if (isDefined(p))
                    p iprintln(level.prefix + "^1[DVAR]^7 » ^1Stim Decay:^7 ^1" + newDecay + " ^7(updated)");
            }
        }

        // =========================
        // UPDATE MASTER VALUES
        // =========================
        level.stim_speed_host = newSpeed;
        level.stim_duration_host = newDuration;
        level.stim_decay_host = newDecay;

        // =========================
        // FORCE LOCK / SYNC
        // =========================
        if (getDvarFloat("stim_boost_speed") != level.stim_speed_host)
            setDvar("stim_boost_speed", "" + level.stim_speed_host);

        if (getDvarInt("stim_boost_duration") != level.stim_duration_host)
            setDvar("stim_boost_duration", "" + level.stim_duration_host);

        if (getDvarFloat("stim_boost_decay") != level.stim_decay_host)
            setDvar("stim_boost_decay", "" + level.stim_decay_host);
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