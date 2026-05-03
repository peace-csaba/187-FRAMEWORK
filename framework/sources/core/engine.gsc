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

        if (!isDefined(weapon.basename))
            continue;

        if (weapon.basename == "" || weapon.basename == "none")
            continue;

        self refillWeaponAmmoSafe(weapon);
    }
}

////////////////////////////////////////////////////////////////////////

// Weapon ammo refill wrapper
refillWeaponAmmoSafe(weapon)
{
    if (!isDefined(self))
        return;

    if (!isDefined(weapon))
        return;

    if (!isDefined(weapon.basename))
        return;

    if (weapon.basename == "" || weapon.basename == "none")
        return;

    self givemaxammo(weapon);
    self setweaponammostock(weapon, 999);
    self setweaponammoclip(weapon, 999);
}

// Extra clip-channel writes are intentionally disabled because they can crash on some weapon states.

////////////////////////////////////////////////////////////////////////

// Weapon ammo refill wrapper (current)
refillCurrentWeaponAmmoSafe()
{
    if (!isDefined(self))
        return;

    weapon = self getcurrentweapon();

    if (!isDefined(weapon))
        return;

    if (!isDefined(weapon.basename))
        return;

    if (weapon.basename == "" || weapon.basename == "none")
        return;

    self refillWeaponAmmoSafe(weapon);
}

////////////////////////////////////////////////////////////////////////

// Equipment refill helper
refillEquipmentByNameSafe(equipName, slotName)
{
    if (!isDefined(self) || !isAlive(self))
        return 0;

    if (!isDefined(equipName) || equipName == "")
        return 0;

    if (!isDefined(slotName) || slotName == "")
        return 0;

    current = self scripts\mp\equipment::getequipmentammo(equipName);
    max = self scripts\mp\equipment::getequipmentmaxammo(equipName);

    if (!isDefined(current) || current < 0)
        current = 0;

    if (!isDefined(max) || max <= 0)
        return 0;

    if (current >= max)
        return 0;

    self scripts\mp\equipment::incrementequipmentslotammo(slotName, (max - current));
    return 1;
}

////////////////////////////////////////////////////////////////////////

// Framework equipment refill helper
//
// secondary = tactical / stim on your build
// primary   = lethal / claymore slot on most builds
refillFrameworkEquipmentAmmoSafe()
{
    if (!isDefined(self) || !isAlive(self))
        return;

    // Tactical
    self refillEquipmentByNameSafe("equip_adrenaline", "secondary");

    // Lethal examples / common mine-style slot
    self refillEquipmentByNameSafe("equip_claymore", "primary");
    self refillEquipmentByNameSafe("equip_frag", "primary");
    self refillEquipmentByNameSafe("equip_semtex", "primary");
    self refillEquipmentByNameSafe("equip_throwingknife", "primary");
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