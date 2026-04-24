// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: data.gsc

////////////////////////////////////////////////////////////////////////

// Framework player data layer
//
// Current storage backend:
// - runtime / self.pers fallback
//
// Experimental backend test:
// - scripts\mp\playerstats_interface
//
// Notes:
// - self.pers is not guaranteed long-term persistence across full restart.
// - playerstats may be restart-safe if enabled and writable on this build.
// - This file keeps save/load ownership in one place for future upgrades.

////////////////////////////////////////////////////////////////////////

getFrameworkDefaultSR()
{
    return 250;
}

////////////////////////////////////////////////////////////////////////

loadFrameworkPlayerData()
{
    if (!isDefined(self))
        return;

    if (isDefined(self.pers) && isDefined(self.pers["frameworkSR"]))
        self.frameworkSR = self.pers["frameworkSR"];
    else if (!isDefined(self.frameworkSR))
        self.frameworkSR = getFrameworkDefaultSR();

    if (isDefined(self.pers) && isDefined(self.pers["frameworkKills"]))
        self.frameworkKills = self.pers["frameworkKills"];
    else if (!isDefined(self.frameworkKills))
        self.frameworkKills = 0;

    if (isDefined(self.pers) && isDefined(self.pers["frameworkDeaths"]))
        self.frameworkDeaths = self.pers["frameworkDeaths"];
    else if (!isDefined(self.frameworkDeaths))
        self.frameworkDeaths = 0;

    if (!isDefined(self.killStreak))
        self.killStreak = 0;

    if (!isDefined(self.specialistActive))
        self.specialistActive = false;
}

////////////////////////////////////////////////////////////////////////

saveFrameworkPlayerData()
{
    if (!isDefined(self))
        return;

    if (!isDefined(self.frameworkSR))
        self.frameworkSR = getFrameworkDefaultSR();

    if (!isDefined(self.frameworkKills))
        self.frameworkKills = 0;

    if (!isDefined(self.frameworkDeaths))
        self.frameworkDeaths = 0;

    if (isDefined(self.pers))
    {
        self.pers["frameworkSR"] = self.frameworkSR;
        self.pers["frameworkKills"] = self.frameworkKills;
        self.pers["frameworkDeaths"] = self.frameworkDeaths;
    }
}

////////////////////////////////////////////////////////////////////////

// Full wipe including SR
resetFrameworkPlayerData()
{
    if (!isDefined(self))
        return;

    self.frameworkSR = getFrameworkDefaultSR();
    self.frameworkKills = 0;
    self.frameworkDeaths = 0;
    self.killStreak = 0;
    self.specialistActive = false;

    self saveFrameworkPlayerData();
}

////////////////////////////////////////////////////////////////////////

// Match-only wipe, keeps SR
resetFrameworkMatchData()
{
    if (!isDefined(self))
        return;

    if (!isDefined(self.frameworkSR))
        self.frameworkSR = getFrameworkDefaultSR();

    self.frameworkKills = 0;
    self.frameworkDeaths = 0;
    self.killStreak = 0;
    self.specialistActive = false;

    self saveFrameworkPlayerData();
}

////////////////////////////////////////////////////////////////////////

showFrameworkSavedDataDebug()
{
    if (!isDefined(self.frameworkSR))
        self.frameworkSR = getFrameworkDefaultSR();

    if (!isDefined(self.frameworkKills))
        self.frameworkKills = 0;

    if (!isDefined(self.frameworkDeaths))
        self.frameworkDeaths = 0;

    self iprintln("^2[DATA-SAVE]^7 SR: ^5" + self.frameworkSR + " ^7• Kills: ^5" + self.frameworkKills + " ^7• Deaths: ^5" + self.frameworkDeaths);
}

////////////////////////////////////////////////////////////////////////

// Playerstats backend test
//
// WARNING:
// This temporarily edits the real combatStats kills stat by +1.
// Use only for testing whether playerstats writes work on this build.
testFrameworkPlayerStatsBackend()
{
    if (!isDefined(self))
        return;

    if (!scripts\mp\playerstats_interface::areplayerstatsenabled())
    {
        self iprintln("^1[DATA-STATS]^7 PlayerStats disabled");
        return;
    }

    oldValue = scripts\mp\playerstats_interface::getplayerstat("combatStats", "kills");

    if (!isDefined(oldValue))
        oldValue = 0;

    testValue = oldValue + 1;

    scripts\mp\playerstats_interface::setplayerstat(testValue, "combatStats", "kills");

    wait 0.05;

    newValue = scripts\mp\playerstats_interface::getplayerstat("combatStats", "kills");

    if (!isDefined(newValue))
        newValue = -1;

    self iprintln("^2[DATA-STATS]^7 combatStats/kills: ^5" + oldValue + " ^7-> ^5" + newValue);
}