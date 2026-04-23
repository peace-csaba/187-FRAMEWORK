// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: bots.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned bot systems
//
// Rebuilt features:
// - addbot
// - kickbot
// - setbotdifficulty

init()
{
    level endon("game_ended");

    if (!isDefined(level.frameworkBotsReady))
        level.frameworkBotsReady = true;
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");
}

////////////////////////////////////////////////////////////////////////

resolveBotTeam(rawValue, player)
{
    if (!isDefined(rawValue) || rawValue == "")
        return "autoassign";

    value = toLower(rawValue);

    if (value == "auto" || value == "autoassign" || value == "random")
        return "autoassign";

    if (value == "allies" || value == "ally" || value == "same")
    {
        if (isDefined(player) && isDefined(player.team))
            return player.team;

        return "allies";
    }

    if (value == "axis" || value == "enemy" || value == "opposite")
    {
        if (isDefined(player) && isDefined(player.team))
        {
            if (player.team == "allies")
                return "axis";

            if (player.team == "axis")
                return "allies";
        }

        return "axis";
    }

    return "autoassign";
}

////////////////////////////////////////////////////////////////////////

getBotTeamLabel(teamValue)
{
    if (!isDefined(teamValue) || teamValue == "autoassign")
        return "Autoassign";

    return teamValue;
}

////////////////////////////////////////////////////////////////////////

resolveBotDifficulty(rawValue)
{
    if (!isDefined(rawValue) || rawValue == "")
        return undefined;

    value = toLower(rawValue);

    if (value == "1" || value == "easy" || value == "recruit")
        return "recruit";

    if (value == "2" || value == "normal" || value == "regular")
        return "regular";

    if (value == "3" || value == "hard" || value == "hardened")
        return "hardened";

    if (value == "4" || value == "vet" || value == "veteran")
        return "veteran";

    return undefined;
}

////////////////////////////////////////////////////////////////////////

spawnFrameworkBots(amount, teamValue, difficultyValue)
{
    if (!isDefined(amount) || amount < 1)
        amount = 1;

    if (amount > 64)
        amount = 64;

    scripts\mp\bots\bots::spawn_bots(amount, teamValue, undefined, undefined, undefined, difficultyValue);
}

////////////////////////////////////////////////////////////////////////

removeFrameworkBots(amount, teamValue)
{
    removed = 0;

    if (!isDefined(amount) || amount < 1)
        amount = 1;

    foreach (player in level.players)
    {
        if (removed >= amount)
            break;

        if (!isbot(player))
            continue;

        if (teamValue != "autoassign" && player.team != teamValue)
            continue;

        kick(player getentitynumber(), "EXE/PLAYERKICKED");
        removed++;
        wait 0.10;
    }

    return removed;
}

////////////////////////////////////////////////////////////////////////

applyFrameworkBotDifficulty(teamValue, difficultyValue)
{
    changed = 0;

    if (!isDefined(difficultyValue))
        return 0;

    foreach (player in level.players)
    {
        if (!isbot(player))
            continue;

        if (teamValue != "autoassign" && player.team != teamValue)
            continue;

        player scripts\mp\bots\bots_util::bot_set_difficulty(difficultyValue);
        player.pers["botDifficulty"] = difficultyValue;
        changed++;
    }

    return changed;
}

////////////////////////////////////////////////////////////////////////

handleAddBotCommand(arg1, arg2)
{
    count = 1;
    if (isDefined(arg1) && arg1 != "")
        count = int(arg1);

    teamValue = resolveBotTeam(arg2, self);
    difficultyValue = resolveBotDifficulty(getDvarString("bot_difficulty"));

    self spawnFrameworkBots(count, teamValue, difficultyValue);

    message = level.prefix + "^5[BOTS]^7 » ^2Spawned:^7 " + count + " ^2bot(s)^7 • ^2Team:^7 " + getBotTeamLabel(teamValue);
    if (isDefined(difficultyValue))
        message += " ^7• ^2Difficulty:^7 " + difficultyValue;

    self iprintln(message);
}

////////////////////////////////////////////////////////////////////////

handleKickBotCommand(arg1, arg2)
{
    count = 1;
    if (isDefined(arg1) && arg1 != "")
        count = int(arg1);

    teamValue = resolveBotTeam(arg2, self);
    removed = self removeFrameworkBots(count, teamValue);

    self iprintln(level.prefix + "^5[BOTS]^7 » ^1Kicked:^7 " + removed + " ^1bot(s)");
}

////////////////////////////////////////////////////////////////////////

handleBotDifficultyCommand(arg1, arg2)
{
    difficultyValue = resolveBotDifficulty(arg1);

    if (!isDefined(difficultyValue))
    {
        self iprintln(level.prefix + "^5[BOTS]^7 » Usage:^7 ^5setbotdifficulty <recruit/regular/hardened/veteran>");
        return;
    }

    teamValue = resolveBotTeam(arg2, self);
    changed = self applyFrameworkBotDifficulty(teamValue, difficultyValue);

    self iprintln(level.prefix + "^5[BOTS]^7 » ^2Difficulty:^7 " + difficultyValue + " ^2applied to:^7 " + changed + " ^2bot(s)");
}

////////////////////////////////////////////////////////////////////////

handleBotCommand(cmd, arg1, arg2)
{
    switch (cmd)
    {
        case "addbot":
            self handleAddBotCommand(arg1, arg2);
            return true;

        case "kickbot":
            self handleKickBotCommand(arg1, arg2);
            return true;

        case "setbotdifficulty":
            self handleBotDifficultyCommand(arg1, arg2);
            return true;
    }

    return false;
}
