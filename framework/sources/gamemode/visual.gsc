// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: visual.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned visual systems
//
// Rebuilt features:
// - nohud
// - hud
// - togglehud

init()
{
    level endon("game_ended");

    if (!isDefined(level.frameworkVisualReady))
        level.frameworkVisualReady = true;
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
        self thread visualSpawnLoop();
    }
}

////////////////////////////////////////////////////////////////////////

visualSpawnLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_visual_spawn");
    level endon("game_ended");

    wait 0.10;
    self applyFrameworkHudState();
}

////////////////////////////////////////////////////////////////////////

applyFrameworkHudState()
{
    if (!isDefined(self.frameworkHudHidden))
        self.frameworkHudHidden = false;

    if (self.frameworkHudHidden)
        self setclientdvar("cg_draw2D", "0");
    else
        self setclientdvar("cg_draw2D", "1");
}

////////////////////////////////////////////////////////////////////////

enableFrameworkNoHud()
{
    self.frameworkHudHidden = true;
    self applyFrameworkHudState();
    self iprintln(level.prefix + "^5[VISUAL]^7 » ^1No HUD:^7 ^2Enabled");
}

////////////////////////////////////////////////////////////////////////

disableFrameworkNoHud()
{
    self.frameworkHudHidden = false;
    self applyFrameworkHudState();
    self iprintln(level.prefix + "^5[VISUAL]^7 » ^1No HUD:^7 ^1Disabled");
}

////////////////////////////////////////////////////////////////////////

toggleFrameworkNoHud()
{
    if (!isDefined(self.frameworkHudHidden))
        self.frameworkHudHidden = false;

    if (self.frameworkHudHidden)
    {
        self disableFrameworkNoHud();
        return;
    }

    self enableFrameworkNoHud();
}

////////////////////////////////////////////////////////////////////////

handleVisualCommand(cmd, arg1, arg2)
{
    switch (cmd)
    {
        case "nohud":
            if (!isDefined(arg1))
            {
                self toggleFrameworkNoHud();
                return true;
            }

            if (arg1 == "1")
            {
                self enableFrameworkNoHud();
                return true;
            }

            if (arg1 == "0")
            {
                self disableFrameworkNoHud();
                return true;
            }

            self iprintln(level.prefix + "^5[VISUAL]^7 » Usage:^7 ^5nohud <0/1>");
            return true;

        case "hud":
            if (!isDefined(arg1))
            {
                self iprintln(level.prefix + "^5[VISUAL]^7 » Usage:^7 ^5hud <0/1>");
                return true;
            }

            if (arg1 == "0")
            {
                self enableFrameworkNoHud();
                return true;
            }

            if (arg1 == "1")
            {
                self disableFrameworkNoHud();
                return true;
            }

            self iprintln(level.prefix + "^5[VISUAL]^7 » Usage:^7 ^5hud <0/1>");
            return true;

        case "togglehud":
            self toggleFrameworkNoHud();
            return true;
    }

    return false;
}
