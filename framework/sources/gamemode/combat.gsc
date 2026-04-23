// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: combat.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned combat systems
//
// DVARs:
// - fw_inf_ammo
// - fw_no_recoil

////////////////////////////////////////////////////////////////////////

init()
{
    level endon("game_ended");

    if (getDvarInt("fw_inf_ammo") != 0 && getDvarInt("fw_inf_ammo") != 1)
        setDvar("fw_inf_ammo", "0");

    if (getDvarInt("fw_no_recoil") != 0 && getDvarInt("fw_no_recoil") != 1)
        setDvar("fw_no_recoil", "0");

    level.frameworkInfAmmoState = getDvarInt("fw_inf_ammo");
    level.frameworkLastInfAmmoState = -1;

    level.frameworkNoRecoilState = getDvarInt("fw_no_recoil");
    level.frameworkLastNoRecoilState = -1;

    level thread watchInfiniteAmmoDvar();
    level thread watchNoRecoilDvar();
}

////////////////////////////////////////////////////////////////////////

onPlayerConnected()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_framework_combat_spawn");
        self thread frameworkCombatSpawn();
    }
}

////////////////////////////////////////////////////////////////////////

onPlayerSpawned()
{
    self endon("disconnect");

    self notify("stop_framework_combat_spawn");
    self thread frameworkCombatSpawn();
}

////////////////////////////////////////////////////////////////////////

frameworkCombatSpawn()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_combat_spawn");
    level endon("game_ended");

    wait 0.15;

    if (level.frameworkInfAmmoState == 1)
    {
        self notify("stop_framework_inf_ammo");
        self thread runInfiniteAmmoLoop();
    }

    if (level.frameworkNoRecoilState == 1)
    {
        self notify("stop_framework_no_recoil");
        self thread runNoRecoilLoop();
    }
}

////////////////////////////////////////////////////////////////////////

// =========================
// INFINITE AMMO
// =========================

watchInfiniteAmmoDvar()
{
    level endon("game_ended");

    for (;;)
    {
        wait 0.25;

        newState = getDvarInt("fw_inf_ammo");

        if (newState != 0 && newState != 1)
        {
            newState = 0;
            setDvar("fw_inf_ammo", "0");
        }

        if (newState == level.frameworkLastInfAmmoState)
            continue;

        level.frameworkLastInfAmmoState = newState;
        level.frameworkInfAmmoState = newState;

        if (newState == 1)
        {
            foreach (player in level.players)
            {
                if (!isDefined(player) || !isPlayer(player))
                    continue;

                player notify("stop_framework_inf_ammo");

                if (isAlive(player))
                    player thread runInfiniteAmmoLoop();

                player iprintln(level.prefix + "^5[COMBAT]^7 » ^2Infinite Ammo:^7 ^2Enabled");
            }
        }
        else
        {
            foreach (player in level.players)
            {
                if (!isDefined(player) || !isPlayer(player))
                    continue;

                player notify("stop_framework_inf_ammo");
                player iprintln(level.prefix + "^5[COMBAT]^7 » ^2Infinite Ammo:^7 ^1Disabled");
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////

runInfiniteAmmoLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_combat_spawn");
    self endon("stop_framework_inf_ammo");
    level endon("game_ended");

    self refillAllAmmo();

    for (;;)
    {
        if (level.frameworkInfAmmoState != 1)
            return;

        if (!isAlive(self))
            return;

        scripts\engine\utility::waittill_any_ents(
            self, "weapon_fired",
            self, "grenade_fire",
            self, "force_regeneration"
        );

        if (!isAlive(self))
            return;

        self refillAllAmmo();
    }
}

////////////////////////////////////////////////////////////////////////

refillAllAmmo()
{
    if (!isDefined(self.equippedweapons))
        return;

    foreach (weapon in self.equippedweapons)
        self refillWeaponAmmo(weapon);
}

////////////////////////////////////////////////////////////////////////

refillWeaponAmmo(weapon)
{
    if (!isDefined(weapon))
        return;

    self givemaxammo(weapon);
    self setweaponammostock(weapon, 999);
    self setweaponammoclip(weapon, 999);
}

////////////////////////////////////////////////////////////////////////

// =========================
// NO RECOIL
// =========================

watchNoRecoilDvar()
{
    level endon("game_ended");

    for (;;)
    {
        wait 0.25;

        newState = getDvarInt("fw_no_recoil");

        if (newState != 0 && newState != 1)
        {
            newState = 0;
            setDvar("fw_no_recoil", "0");
        }

        if (newState == level.frameworkLastNoRecoilState)
            continue;

        level.frameworkLastNoRecoilState = newState;
        level.frameworkNoRecoilState = newState;

        if (newState == 1)
        {
            foreach (player in level.players)
            {
                if (!isDefined(player) || !isPlayer(player))
                    continue;

                player notify("stop_framework_no_recoil");

                if (isAlive(player))
                    player thread runNoRecoilLoop();

                player iprintln(level.prefix + "^5[COMBAT]^7 » ^2No Recoil:^7 ^2Enabled");
            }
        }
        else
        {
            foreach (player in level.players)
            {
                if (!isDefined(player) || !isPlayer(player))
                    continue;

                player notify("stop_framework_no_recoil");
                player player_recoilscaleoff();
                player.recoilscale = undefined;
                player iprintln(level.prefix + "^5[COMBAT]^7 » ^2No Recoil:^7 ^1Disabled");
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////

runNoRecoilLoop()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_framework_combat_spawn");
    self endon("stop_framework_no_recoil");
    level endon("game_ended");

    for (;;)
    {
        if (level.frameworkNoRecoilState != 1)
            return;

        if (!isAlive(self))
            return;

        self.recoilscale = 100;
        self player_recoilscaleon(0);

        wait 0.05;
    }
}