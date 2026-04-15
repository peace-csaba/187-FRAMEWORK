// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: weapons.gsc

////////////////////////////////////////////////////////////////////////

// Weapon gameplay systems
//
// Contains:
// - weapon-based movement speed boosts
// - custom weapon damage overrides

////////////////////////////////////////////////////////////////////////

// ==============================
// MOVE SPEED SYSTEM
// ==============================

weaponSpeedBoost()
{
    self endon("disconnect");
    level endon("game_ended");

    for (;;)
    {
        self waittill("spawned_player");

        self notify("stop_weaponSpeedBoost");

        self.weaponBoost = 1.0;
        self.weaponBoostMessage = "";

        if (isAlive(self))
            self setmovespeedscale(1.0);

        self thread weaponSpeedBoostWorker();
    }
}

////////////////////////////////////////////////////////////////////////

weaponSpeedBoostWorker()
{
    self endon("disconnect");
    self endon("death");
    self endon("stop_weaponSpeedBoost");
    level endon("game_ended");

    lastBoost = -1;
    lastMessage = "__none__";

    for (;;)
    {
        if (!isAlive(self))
        {
            wait 0.05;
            continue;
        }

        weapon = self getcurrentweapon();
        root = scripts\mp\utility\weapon::getweaponrootname(weapon);

        boost = getWeaponMoveSpeedBoost(root);
        message = getWeaponMoveSpeedMessage(root);

        if (boost != lastBoost)
        {
            self setmovespeedscale(boost);
            self.weaponBoost = boost;
            lastBoost = boost;
        }

        if (message != lastMessage)
        {
            if (message != "")
                self iprintlnbold(message);

            lastMessage = message;
            self.weaponBoostMessage = message;
        }

        wait 0.25;
    }
}

////////////////////////////////////////////////////////////////////////

getWeaponMoveSpeedBoost(root)
{
    if (!isDefined(root) || root == "")
        return 1.0;

    if (isSmgSpeedWeapon(root))
        return 1.12;

    if (isRifleSpeedWeapon(root))
        return 1.08;

    if (isSniperSpeedWeapon(root))
        return 1.04;

    return 1.0;
}

////////////////////////////////////////////////////////////////////////

getWeaponMoveSpeedMessage(root)
{
    if (!isDefined(root) || root == "")
        return "";

    if (isSmgSpeedWeapon(root))
        return "^5SMG SPEED ACTIVE (1.12x)";

    if (isRifleSpeedWeapon(root))
        return "^3RIFLE SPEED ACTIVE (1.08x)";

    if (isSniperSpeedWeapon(root))
        return "^7SNIPER SPEED ACTIVE (1.04x)";

    return "^7Weapon Speed Reset";
}

////////////////////////////////////////////////////////////////////////

isSmgSpeedWeapon(root)
{
    if (!isDefined(root) || root == "")
        return false;

    return
        root == "iw8_sm_t9fastfire" ||  // FFAR 1 (SMG-class internal)
        root == "iw8_sm_t9cqb" ||       // MAC-10
        root == "s4_sm_mpapa40" ||      // MP40
        root == "iw8_sm_mpapa5" ||      // MP5
        root == "s4_sm_stango5" ||      // Sten
        root == "iw8_sm_secho" ||       // Striker 45
        root == "iw8_sm_uzulu" ||       // Uzi
        root == "iw8_sm_t9capacity" ||  // PPSH-41
        root == "iw8_sm_t9accurate" ||  // LC10
        root == "s4_sm_guniform45" ||   // M1928 / Tommy Gun
        root == "s4_sm_salpha26" ||     // Type 100
        root == "s4_sm_fromeo57";       // H4 Blixen
}

////////////////////////////////////////////////////////////////////////

isRifleSpeedWeapon(root)
{
    if (!isDefined(root) || root == "")
        return false;

    return
        root == "iw8_ar_t9fastfire" ||  // FFAR 1 (AR-class internal)
        root == "iw8_ar_mike4" ||       // M4A1
        root == "s4_ar_hyankee44";      // STG44
}

////////////////////////////////////////////////////////////////////////

isSniperSpeedWeapon(root)
{
    if (!isDefined(root) || root == "")
        return false;

    return
        root == "iw8_sn_kilo98" ||         // Kar98
        root == "iw8_sn_t9quickscope" ||   // Swiss K31
        root == "iw8_sn_t9standard" ||     // Pelington 703
        root == "iw8_sn_t9accurate" ||     // Tundra
        root == "iw8_sn_golf28" ||         // HDR
        root == "iw8_sn_alpha50" ||        // AX-50
        root == "iw8_sn_t9cannon" ||       // M82
        root == "s4_mr_kalpha98" ||        // Kar98k
        root == "iw8_sn_hdromeo" ||        // Rytec
        root == "iw8_sn_t9precisionsemi";  // Type 63
}

////////////////////////////////////////////////////////////////////////

// ==============================
// DAMAGE SYSTEM
// ==============================

modifyPlayerDamage(var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9)
{
    root = scripts\mp\utility\weapon::getweaponrootname(var_5);

    baseDamage = scripts\mp\damage::gamemodemodifyplayerdamage(
        var_0,
        var_1,
        var_2,
        var_3,
        var_4,
        var_5,
        var_6,
        var_7,
        var_8,
        var_9
    );

    if (isOneShotWeapon(root))
    {
        if (isPlayer(var_1))
            var_1 iprintlnbold("^1Downed and killed in 1 shot");

        return 999;
    }

    override = getWeaponDamageOverride(root);

    if (isDefined(override))
        return override;

    return int(baseDamage);
}

////////////////////////////////////////////////////////////////////////

isOneShotWeapon(root)
{
    if (!isDefined(root) || root == "")
        return false;

    return
        root == "iw8_sn_kilo98" ||         // Kar98
        root == "iw8_sn_t9quickscope" ||   // Swiss K31
        root == "iw8_sn_t9standard" ||     // Pelington 703
        root == "iw8_sn_t9accurate" ||     // Tundra
        root == "iw8_sn_golf28" ||         // HDR
        root == "iw8_sn_alpha50" ||        // AX-50
        root == "iw8_sn_t9cannon" ||       // M82
        root == "s4_mr_kalpha98" ||        // Kar98k
        root == "iw8_sn_hdromeo" ||        // Rytec
        root == "iw8_sn_t9precisionsemi";  // Type 63
}

////////////////////////////////////////////////////////////////////////

getWeaponDamageOverride(root)
{
    if (!isDefined(root) || root == "")
        return undefined;

    if (root == "s4_sm_mpapa40")
        return 25; // MP40 (Vanguard)

    if (root == "s4_ar_hyankee44")
        return 19; // STG44 (Vanguard)

    if (root == "iw8_ar_mike4")
        return 33; // M4A1 (Modern Warfare)

    if (root == "iw8_sm_mpapa5")
        return 25; // MP5 (Modern Warfare)

    if (root == "s4_sm_stango5")
        return 22; // Sten (Vanguard)

    if (root == "iw8_sm_t9fastfire")
        return 32; // FFAR 1 (Cold War - SMG build)

    if (root == "iw8_sm_secho")
        return 26; // Striker 45 (Modern Warfare)

    if (root == "iw8_sm_uzulu")
        return 31; // Uzi (Modern Warfare)

    if (root == "iw8_sm_t9capacity")
        return 27; // PPSH-41 (Cold War)

    if (root == "iw8_sm_t9cqb")
        return 13; // MAC-10 (Cold War)

    if (root == "iw8_pi_t9semiauto")
        return 50; // 1911 (Cold War Pistol)

    if (root == "iw8_ar_t9fastfire")
        return 31; // FFAR 1 (Cold War - AR build)

    if (root == "iw8_sm_t9accurate")
        return 24; // LC10 (Cold War)

    if (root == "s4_sm_guniform45")
        return 33; // M1928 / Tommy Gun (Vanguard)

    if (root == "s4_sm_salpha26")
        return 29; // Type 100 (Vanguard)

    if (root == "s4_sm_fromeo57")
        return 43; // H4 Blixen (Vanguard)

    return undefined;
}