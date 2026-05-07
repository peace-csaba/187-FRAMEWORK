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
    return isFrameworkSupportedMode() && isWarzone() && level.fwcfg_plates;
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

// Generic framework broadcast helper
frameworkBroadcastMessage(text)
{
    foreach (player in level.players)
    {
        if (isDefined(player))
            player iprintln(text);
    }
}

////////////////////////////////////////////////////////////////////////

// Generic DVAR change broadcast helper
frameworkBroadcastSettingChange(label, value, color)
{
    level frameworkBroadcastMessage(level.prefix + "^1[DVAR]^7 » " + color + label + ":^7 " + color + value + " ^7(updated)");
}

////////////////////////////////////////////////////////////////////////

// Safe float DVAR helper
getFrameworkFloatDvar(name, fallback)
{
    value = getDvarFloat(name);

    if (!isDefined(value))
        return fallback;

    return value;
}

////////////////////////////////////////////////////////////////////////

// Safe int DVAR helper
getFrameworkIntDvar(name, fallback)
{
    value = getDvarInt(name);

    if (!isDefined(value))
        return fallback;

    return value;
}

////////////////////////////////////////////////////////////////////////

// Safe string DVAR helper
getFrameworkStringDvar(name, fallback)
{
    value = getDvar(name);

    if (!isDefined(value) || value == "")
        return fallback;

    return value;
}