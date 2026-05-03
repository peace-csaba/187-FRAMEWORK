// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: data.gsc

////////////////////////////////////////////////////////////////////////

// Framework player data layer
//
// Current storage backend:
// - runtime / self.pers fallback
//
// Notes:
// - self.pers is not guaranteed long-term persistence across full restart.
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
