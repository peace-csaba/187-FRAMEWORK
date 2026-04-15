// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: rewards.gsc

////////////////////////////////////////////////////////////////////////

// Kill reward system

getRewardRankName(sr)
{
    if (!isDefined(sr))
        sr = 250;

    if (sr < 300)
        return "^3Bronze";

    if (sr < 350)
        return "^7Silver";

    if (sr < 400)
        return "^3Gold";

    if (sr < 450)
        return "^5Platinum";

    if (sr < 500)
        return "^2Diamond";

    return "^1Crimson";
}

////////////////////////////////////////////////////////////////////////

// Returns:
// <sr> / <rank>
getCurrentSRText()
{
    if (!isDefined(self.frameworkSR))
        self.frameworkSR = 250;

    rank = getRewardRankName(self.frameworkSR);
    return "^5" + self.frameworkSR + " ^7/ " + rank;
}

////////////////////////////////////////////////////////////////////////

// Adds SR
addPlayerSR(amount)
{
    if (!isDefined(self.frameworkSR))
        self.frameworkSR = 250;

    self.frameworkSR += amount;
}

////////////////////////////////////////////////////////////////////////

// Removes SR and clamps at 0
removePlayerSR(amount)
{
    if (!isDefined(self.frameworkSR))
        self.frameworkSR = 250;

    self.frameworkSR -= amount;

    if (self.frameworkSR < 0)
        self.frameworkSR = 0;
}

////////////////////////////////////////////////////////////////////////

// [Ranks] line for kill-side SR gain
showSRGain(amount)
{
    self custom_scripts\framework\sources\core\ui::prefixPrint(
        "^7[Ranks]^7 • ^2+" + amount + " SR ^7• " + self getCurrentSRText()
    );
}

////////////////////////////////////////////////////////////////////////

// [Ranks] line for death-side SR loss
showSRLoss(amount)
{
    self custom_scripts\framework\sources\core\ui::prefixPrint(
        "^7[Ranks]^7 • ^1-" + amount + " SR ^7• " + self getCurrentSRText()
    );
}

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
//
// Order on kill is intentionally printed last in code so it appears
// below Stats and Ranks in chat.
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
//
// Chat order appears as:
// [Stats]
// [Ranks]
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

        self removePlayerSR(5);
        wait 0.05;

        // printed in reverse so Stats appears above Ranks in chat
        self showSRLoss(5);
        self showDeathStats();
    }
}

////////////////////////////////////////////////////////////////////////

// Kill watcher
//
// Chat order appears as:
// [Stats]
// [Ranks]
// [Rewards]
killRewards()
{
    self endon("disconnect");
    self endon("stop_killRewards");
    level endon("game_ended");

    if (!isDefined(self.frameworkSR))
        self.frameworkSR = 250;

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
        self addPlayerSR(10);
        self.killStreak++;

        // printed in reverse so final chat stack becomes:
        // [Stats]
        // [Ranks]
        // [Rewards]
        self getRewardsPlayer();
        self showSRGain(10);
        self showKillStats();
    }
}