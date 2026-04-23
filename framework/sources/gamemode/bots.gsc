// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: bots.gsc

////////////////////////////////////////////////////////////////////////

// Framework bot systems
//
// DVARs:
// - fw_addbot
// - fw_kickbot
// - fw_bot_team
// - fw_bot_difficulty

init()
{
    level endon("game_ended");

    if (getDvarInt("fw_addbot") < 0)
        setDvar("fw_addbot", "0");

    if (getDvarInt("fw_kickbot") < 0)
        setDvar("fw_kickbot", "0");

    if (getDvar("fw_bot_team") == "")
        setDvar("fw_bot_team", "autoassign");

    if (getDvar("fw_bot_difficulty") == "")
        setDvar("fw_bot_difficulty", "regular");

    // Always start request counters from 0 so queued console values work
    level.frameworkLastAddBot = 0;
    level.frameworkLastKickBot = 0;

    level.frameworkLastBotTeam = "";
    level.frameworkLastBotDifficulty = "";

    level thread watchBotDvars();
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");
}

////////////////////////////////////////////////////////////////////////

resolveBotTeam(rawValue)
{
    if (!isDefined(rawValue) || rawValue == "")
        return "autoassign";

    value = toLower(rawValue);

    if (value == "auto" || value == "autoassign" || value == "random")
        return "autoassign";

    if (value == "allies" || value == "ally")
        return "allies";

    if (value == "axis" || value == "enemy")
        return "axis";

    return "autoassign";
}

////////////////////////////////////////////////////////////////////////

resolveBotDifficulty(rawValue)
{
    if (!isDefined(rawValue) || rawValue == "")
        return "regular";

    value = toLower(rawValue);

    if (value == "1" || value == "easy" || value == "recruit")
        return "recruit";

    if (value == "2" || value == "normal" || value == "regular")
        return "regular";

    if (value == "3" || value == "hard" || value == "hardened")
        return "hardened";

    if (value == "4" || value == "vet" || value == "veteran")
        return "veteran";

    return "regular";
}

////////////////////////////////////////////////////////////////////////

getBotTeamLabel(teamValue)
{
    if (!isDefined(teamValue) || teamValue == "autoassign")
        return "Autoassign";

    return teamValue;
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

broadcastBotMessage(text)
{
    foreach (player in level.players)
    {
        if (isDefined(player))
            player iprintln(level.prefix + "^5[BOTS]^7 » " + text);
    }
}

////////////////////////////////////////////////////////////////////////

watchBotDvars()
{
    level endon("game_ended");

    for (;;)
    {
        wait 0.25;

        addCount = getDvarInt("fw_addbot");
        kickCount = getDvarInt("fw_kickbot");
        teamRaw = getDvar("fw_bot_team");
        difficultyRaw = getDvar("fw_bot_difficulty");

        if (addCount < 0)
        {
            addCount = 0;
            setDvar("fw_addbot", "0");
        }

        if (kickCount < 0)
        {
            kickCount = 0;
            setDvar("fw_kickbot", "0");
        }

        teamValue = resolveBotTeam(teamRaw);
        difficultyValue = resolveBotDifficulty(difficultyRaw);

        if (teamValue != level.frameworkLastBotTeam)
        {
            level.frameworkLastBotTeam = teamValue;
            setDvar("fw_bot_team", teamValue);
            level broadcastBotMessage("^2Team:^7 " + getBotTeamLabel(teamValue));
        }

        if (difficultyValue != level.frameworkLastBotDifficulty)
        {
            level.frameworkLastBotDifficulty = difficultyValue;
            setDvar("fw_bot_difficulty", difficultyValue);
            level broadcastBotMessage("^2Difficulty:^7 " + difficultyValue);
        }

        if (addCount > 0)
        {
            level spawnFrameworkBots(addCount, teamValue, difficultyValue);
            level broadcastBotMessage("^2Spawned:^7 " + addCount + " ^2bot(s)^7 • ^2Team:^7 " + getBotTeamLabel(teamValue) + " ^7• ^2Difficulty:^7 " + difficultyValue);

            setDvar("fw_addbot", "0");
            level.frameworkLastAddBot = 0;
        }

        if (kickCount > 0)
        {
            removed = level removeFrameworkBots(kickCount, teamValue);
            level broadcastBotMessage("^1Kicked:^7 " + removed + " ^1bot(s)");

            setDvar("fw_kickbot", "0");
            level.frameworkLastKickBot = 0;
        }
    }
}