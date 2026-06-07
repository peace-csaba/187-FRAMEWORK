// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: rewards.gsc

////////////////////////////////////////////////////////////////////////

// Kill reward system
//
// Rank/SR system removed.
// This file now only handles:
// - kills
// - deaths
// - killstreak
// - reward grants

////////////////////////////////////////////////////////////////////////

// [Stats] line for kill-side stats
showKillStats()
{
    if (!isDefined(self.frameworkKills))
        self.frameworkKills = 0;

    if (!isDefined(self.killStreak))
        self.killStreak = 0;

    self custom_scripts\framework\sources\core\ui::prefixPrint(
        "^7[Stats]^7 • ^2Kills: " + self.frameworkKills + " ^7• ^3Killstreak: " + self.killStreak
    );
}

////////////////////////////////////////////////////////////////////////

// [Stats] line for death-side stats
showDeathStats()
{
    if (!isDefined(self.frameworkDeaths))
        self.frameworkDeaths = 0;

    self custom_scripts\framework\sources\core\ui::prefixPrint(
        "^7[Stats]^7 • ^1Deaths: " + self.frameworkDeaths + " ^7• ^3Killstreak Reset"
    );
}

////////////////////////////////////////////////////////////////////////

// [Rewards] line
getRewardsPlayer()
{
    if (!isDefined(self.killStreak))
        self.killStreak = 0;

    if (!isDefined(self.specialistActive))
        self.specialistActive = false;

    msg = "^7[Rewards]^7";

    // Random perk on streak 1-5
    if (!self.specialistActive && self.killStreak < 6)
    {
        perk = self custom_scripts\framework\sources\gameplay\perks::giveRandomPerk();
        wait 0.05;

        if (isDefined(perk))
        {
            name = custom_scripts\framework\sources\gameplay\perks::getPerkName(perk);
            msg += " ^7• ^2+" + name + " Perk";
        }
    }
    // Real Specialist Bonus at 6 streak
    else if (!self.specialistActive && self.killStreak >= 6)
    {
        count = self custom_scripts\framework\sources\gameplay\perks::giveSpecialistBonus();
        wait 0.05;

        if (count > 0)
        {
            self.specialistActive = true;
            msg += " ^7• ^5Specialist Bonus";
        }
    }

    plates = self custom_scripts\framework\sources\core\engine::giveArmorPlates(3);
    wait 0.05;

    if (plates > 0)
        msg += " ^7• ^3+" + plates + " Plates";

    stim = self custom_scripts\framework\sources\gameplay\stim::giveStimReward(2);
    wait 0.05;

    if (stim > 0)
    {
        if (stim == 1)
            msg += " ^7• ^1+1 Stim";
        else
            msg += " ^7• ^1+" + stim + " Stims";
    }

    self custom_scripts\framework\sources\core\ui::prefixPrint(msg);
}

////////////////////////////////////////////////////////////////////////

// Death watcher
watchFrameworkDeaths()
{
    self endon("disconnect");
    self endon("stop_framework_death_watch");
    level endon("game_ended");

    for (;;)
    {
        self waittill("death");

        if (!isDefined(self.frameworkDeaths))
            self.frameworkDeaths = 0;

        if (!isDefined(self.killStreak))
            self.killStreak = 0;

        if (!isDefined(self.specialistActive))
            self.specialistActive = false;

        self.frameworkDeaths++;
        self.killStreak = 0;
        self.specialistActive = false;

        self showDeathStats();
    }
}

////////////////////////////////////////////////////////////////////////

// Kill watcher
killRewards()
{
    self endon("disconnect");
    self endon("stop_killRewards");
    level endon("game_ended");

    if (!isDefined(self.frameworkKills))
        self.frameworkKills = 0;

    if (!isDefined(self.frameworkDeaths))
        self.frameworkDeaths = 0;

    if (!isDefined(self.killStreak))
        self.killStreak = 0;

    if (!isDefined(self.specialistActive))
        self.specialistActive = false;

    self notify("stop_framework_death_watch");
    self thread watchFrameworkDeaths();

    for (;;)
    {
        self waittill("got_a_kill");
        wait 0.05;

        if (!isAlive(self))
            continue;

        self.frameworkKills++;
        self.killStreak++;

        self getRewardsPlayer();
        self showKillStats();
    }
}
