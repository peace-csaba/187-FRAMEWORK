// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: ui.gsc

////////////////////////////////////////////////////////////////////////

// UI / print helpers

prefixPrint(msg)
{
    self iprintln(level.prefix + msg);
}

////////////////////////////////////////////////////////////////////////

prefixPrintBold(msg)
{
    self iprintlnbold(level.prefix + msg);
}

////////////////////////////////////////////////////////////////////////

// Counts all connected players
getFrameworkOnlineCount()
{
    count = 0;

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        count++;
    }

    return count;
}

////////////////////////////////////////////////////////////////////////

// Counts real players only
getFrameworkRealPlayerCount()
{
    count = 0;

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        if (isbot(player))
            continue;

        count++;
    }

    return count;
}

////////////////////////////////////////////////////////////////////////

// Counts bots only
getFrameworkBotCount()
{
    count = 0;

    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        if (!isbot(player))
            continue;

        count++;
    }

    return count;
}

////////////////////////////////////////////////////////////////////////

getFrameworkOnlineMessage()
{
    online = getFrameworkOnlineCount();
    realPlayers = getFrameworkRealPlayerCount();
    bots = getFrameworkBotCount();

    return level.prefix + "^5Online:^7 " + online + " ^7• ^2Folks:^7 " + realPlayers + " ^7• ^3Bots:^7 " + bots;
}

////////////////////////////////////////////////////////////////////////

startAnnouncer()
{
    self notify("stop_announcer");
    self endon("stop_announcer");
    self endon("disconnect");
    level endon("game_ended");

    messages = [];
    lastIndex = -1;

    messages[messages.size] = level.prefix + "^2Welcome to ^5187-PROJECT^7 » Framework!";
    messages[messages.size] = level.prefix + "^3Get kills to earn ^2Perks ^7• ^3Plates ^7• ^1Stim boosts!";
    messages[messages.size] = level.prefix + "^7GSC created by ^2Peace";
    messages[messages.size] = level.prefix + "^5Stay tuned ^7for more updates on ^2GitHub!";
    messages[messages.size] = level.prefix + "^7Subscribe on ^5Blade ^7: ^5youtube.com/@187blade";

    if (messages.size <= 0)
        return;

    for (;;)
    {
        // Every announcer cycle has a chance to show live online count.
        if (randomInt(100) < 35)
        {
            self iprintln(getFrameworkOnlineMessage());
            wait 60;
            continue;
        }

        if (messages.size == 1)
            index = 0;
        else
        {
            do
            {
                index = randomInt(messages.size);
            }
            while (index == lastIndex);
        }

        lastIndex = index;
        self iprintln(messages[index]);
        wait 60;
    }
}