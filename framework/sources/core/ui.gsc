// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: ui.gsc

////////////////////////////////////////////////////////////////////////

// UI / print helpers

prefixPrint(msg)
{
    self iprintln(level.prefix + msg);
}

prefixPrintBold(msg)
{
    self iprintlnbold(level.prefix + msg);
}

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

    if (messages.size <= 0)
        return;

    for (;;)
    {
        if (messages.size == 1)
            index = 0;
        else
        {
            do
            {
                index = randomint(messages.size);
            }
            while (index == lastIndex);
        }

        lastIndex = index;
        self iprintln(messages[index]);
        wait 60;
    }
}
