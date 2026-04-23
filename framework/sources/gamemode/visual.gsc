// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: visual.gsc

////////////////////////////////////////////////////////////////////////

// Framework visual systems
//
// DVARs:
// - fw_nohud (0/1)

init()
{
    level endon("game_ended");

    if (getDvarInt("fw_nohud") != 0 && getDvarInt("fw_nohud") != 1)
        setDvar("fw_nohud", "0");

    level.frameworkNoHudState = getDvarInt("fw_nohud");
    level.frameworkLastNoHudState = level.frameworkNoHudState;

    level thread watchNoHudDvar();
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    if (!isDefined(self.frameworkHudHidden))
        self.frameworkHudHidden = false;

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_visual_spawn");
        self thread handleVisualSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

handleVisualSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_visual_spawn");
    level endon("game_ended");

    wait 0.10;
    self applyHudPreference();
}

////////////////////////////////////////////////////////////////////////

applyHudPreference()
{
    hidden = false;

    if (isDefined(self.frameworkHudHidden))
        hidden = self.frameworkHudHidden;

    if (hidden)
    {
        self setclientomnvar("ui_hide_full_hud", 1);
        setDvar("LOPKSRNTTS", "0");
    }
    else
    {
        self setclientomnvar("ui_hide_full_hud", 0);
        setDvar("LOPKSRNTTS", "1");
    }
}

////////////////////////////////////////////////////////////////////////

setHudHiddenState(state)
{
    self.frameworkHudHidden = state;
    self applyHudPreference();
}

////////////////////////////////////////////////////////////////////////

applyNoHudStateToAllPlayers(state)
{
    foreach (player in level.players)
    {
        if (!isDefined(player))
            continue;

        player.frameworkHudHidden = state;
        player applyHudPreference();
    }
}

////////////////////////////////////////////////////////////////////////

watchNoHudDvar()
{
    level endon("game_ended");

    for (;;)
    {
        wait 0.25;

        newState = getDvarInt("fw_nohud");

        if (newState != 0 && newState != 1)
        {
            newState = level.frameworkLastNoHudState;
            setDvar("fw_nohud", "" + newState);
        }

        if (newState == level.frameworkLastNoHudState)
            continue;

        level.frameworkLastNoHudState = newState;
        level.frameworkNoHudState = newState;

        stateText = "^1Disabled";
        if (newState == 1)
            stateText = "^2Enabled";

        level applyNoHudStateToAllPlayers(newState == 1);

        foreach (player in level.players)
        {
            if (isDefined(player))
                player iprintln(level.prefix + "^5[VISUAL]^7 » ^1No HUD:^7 " + stateText);
        }
    }
}