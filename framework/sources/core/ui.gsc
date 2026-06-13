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

/////////
// Temporarly Disabled — because we did a new watcher inside core/gameplay.gsc
/* getFrameworkOnlineMessage()
{
    online = getFrameworkOnlineCount();
    realPlayers = getFrameworkRealPlayerCount();
    bots = getFrameworkBotCount();

    return level.prefix + "^5Online:^7 " + online + " ^7• ^2Folks:^7 " + realPlayers + " ^7• ^3Bots:^7 " + bots;
} */
/////////

////////////////////////////////////////////////////////////////////////

startAnnouncer()
{
    self notify("stop_announcer");
    self endon("stop_announcer");
    self endon("disconnect");
    level endon("game_ended");

    messages = [];
    lastIndex = -1;

    // Updated 14.06.2026
    // 0:54 — Europe Timezone 
    // Framework Version: 1.8.8
    messages[messages.size] = level.prefix + "^2Welcome to ^5187-PROJECT^7 » Framework!";
    messages[messages.size] = level.prefix + "^3Get kills to earn ^2Perks ^7• ^3Plates ^7• ^1Stim boosts!";
    messages[messages.size] = level.prefix + "^1WARNING:^7 Stay inside the ^3Play Area^7 to survive!";

    messages[messages.size] = level.prefix + "^7Found a bug? Report it on ^2Discord:^7 @peaceofficial";
    messages[messages.size] = level.prefix + "^5Stay tuned^7 for more updates on ^2GitHub! — github.com/peace-csaba/187-FRAMEWORK";

    messages[messages.size] = level.prefix + "^2Framework Status:^7 Running on Release Version — ^5v1.8.8";

    messages[messages.size] = level.prefix + "^7Subscribe to ^5Blade^7: ^5youtube.com/@187blade";
    messages[messages.size] = level.prefix + "^7GSC created by ^2Peace";

    if (messages.size <= 0)
        return;

    for (;;)
    {

/////////
        // Temporarly Disabled — because we did a new watcher inside core/gameplay.gsc
        // Every announcer cycle has a chance to show live online count.
/*         if (randomInt(100) < 35)
        {
            self iprintln(getFrameworkOnlineMessage());
            wait 60;
            continue;
        } */
/////////

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