// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: engine.gsc

////////////////////////////////////////////////////////////////////////

// Engine wrappers / risky calls isolated here

////////////////////////////////////////////////////////////////////////

giveArmorPlates(amount)
{
    if (!custom_scripts\framework\sources\core\shared::isWarzone())
        return 0;

    if (!level.enablePlateRewards)
        return 0;

    if (!isDefined(self) || !isAlive(self))
        return 0;

    if (!isDefined(amount) || amount <= 0)
        return 0;

    given = 0;

    for (i = 0; i < amount; i++)
    {
        if (!isAlive(self))
            return given;

        self _encstr_8331245636CB3BEB9417AAA00397416342DF4DDB4A12D7F86A3B21400FF318B33BC2E86C62AA::
            br_forcegivecustompickupitem(self, "_encstr_82A813C6133837A275F7C7F3EB903B4F8078BECB69", 1, 1, 0);

        given++;
        wait 0.12;
    }

    return given;
}

////////////////////////////////////////////////////////////////////////

// Bot spawn wrapper
spawnBotsSafe(amount, teamValue, difficultyValue)
{
    if (!isDefined(amount) || amount < 1)
        amount = 1;

    if (amount > 64)
        amount = 64;

    if (!isDefined(teamValue) || teamValue == "")
        teamValue = "autoassign";

    if (!isDefined(difficultyValue) || difficultyValue == "")
        difficultyValue = "regular";

    scripts\mp\bots\bots::spawn_bots(amount, teamValue, undefined, undefined, undefined, difficultyValue);
}

////////////////////////////////////////////////////////////////////////

// Bot removal wrapper
removeBotsSafe(amount, teamValue)
{
    removed = 0;

    if (!isDefined(amount) || amount < 1)
        amount = 1;

    if (!isDefined(teamValue) || teamValue == "")
        teamValue = "autoassign";

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

// Weapon ammo refill wrapper
refillWeaponAmmoSafe(weapon)
{
    if (!isDefined(self))
        return;

    if (!isDefined(weapon))
        return;

    self givemaxammo(weapon);
    self setweaponammostock(weapon, 999);
    self setweaponammoclip(weapon, 999);
    self setweaponammoclip(weapon, 999, "left");
    self setweaponammoclip(weapon, 999, "_encstr_A5AD056A019C63");
    self setweaponammoclip(weapon, 999, "_encstr_B1AD05C65666E8");
    self setweaponammoclip(weapon, 999, "right");
    self setweaponammoclip(weapon, 999, "_encstr_8253060E2B5FE330");
    self setweaponammoclip(weapon, 999, "_encstr_9353062E718710C9");
}

////////////////////////////////////////////////////////////////////////

// Full inventory ammo refill wrapper
refillAllAmmoSafe()
{
    if (!isDefined(self))
        return;

    if (!isDefined(self.equippedweapons))
        return;

    foreach (weapon in self.equippedweapons)
    {
        if (!isDefined(weapon))
            continue;

        self refillWeaponAmmoSafe(weapon);
    }
}

////////////////////////////////////////////////////////////////////////

// Recoil wrappers
enableNoRecoilSafe()
{
    if (!isDefined(self))
        return;

    self.recoilscale = 100;
    self player_recoilscaleon(0);
}

////////////////////////////////////////////////////////////////////////

disableNoRecoilSafe()
{
    if (!isDefined(self))
        return;

    self player_recoilscaleoff();
    self.recoilscale = undefined;
}