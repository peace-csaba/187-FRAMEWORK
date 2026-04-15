// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: perks.gsc

////////////////////////////////////////////////////////////////////////

// Perk systems
//
// Contains:
// - random reward perk pool
// - specialist bonus grant
// - perk splash mapping

////////////////////////////////////////////////////////////////////////

buildPerkList()
{
    level.perkList = [];
    level.perkUiMap = [];
    level.perkNames = [];

    // Standard reward perks
    addRewardPerk("specialty_warhead",          "specialty_quickswap",        "Amped");
    addRewardPerk("specialty_tac_resist",       "specialty_selectivehearing", "Battle Hardened");
    addRewardPerk("specialty_tactical_recon",   "specialty_tactical_recon",   "Engineer");
    addRewardPerk("specialty_extra_shrapnel",   "specialty_boom",             "Shrapnel");
    addRewardPerk("specialty_tune_up",          "specialty_tune_up",          "Tune Up");
    addRewardPerk("specialty_huntmaster",       "specialty_huntmaster",       "Tracker");
    addRewardPerk("specialty_guerrilla",        "specialty_guerrilla",        "Ghost");
    addRewardPerk("specialty_hardline",         "specialty_hardline",         "Hardline");
    addRewardPerk("specialty_surveillance",     "specialty_surveillance",     "High Alert");
    addRewardPerk("specialty_strategist",       "specialty_strategist",       "Pointman");
    addRewardPerk("specialty_restock",          "specialty_restock",          "Restock");
    addRewardPerk("specialty_quick_fix",        "specialty_quick_fix",        "Quick Fix");
    addRewardPerk("specialty_covert_ops",       "specialty_covert_ops",       "Cold-Blooded");
    addRewardPerk("specialty_hustle",           "specialty_lightweight",      "Double Time");
    addRewardPerk("specialty_eod",              "specialty_blastshield",      "E.O.D.");
    addRewardPerk("specialty_heavy_metal",      "specialty_heavy_metal",      "Kill Chain");
    addRewardPerk("specialty_scavenger_plus",   "specialty_scavenger_plus",   "Scavenger");

    // Custom BR reward perks
    addRewardPerk("specialty_br_reinforced",    "specialty_specialist_bonus", "Tempered");
    addRewardPerk("specialty_br_advancedscout", "specialty_specialist_bonus", "Combat Scout");
    addRewardPerk("specialty_br_serpentine",    "specialty_specialist_bonus", "Serpentine");

    level.perkNames["specialty_specialist_bonus"] = "Specialist Bonus";
}

////////////////////////////////////////////////////////////////////////

addRewardPerk(gameplayPerk, uiPerk, name)
{
    level.perkList[level.perkList.size] = gameplayPerk;
    level.perkUiMap[gameplayPerk] = uiPerk;
    level.perkNames[gameplayPerk] = name;
}

////////////////////////////////////////////////////////////////////////

initPerkNames()
{
    if (!isDefined(level.perkNames))
        level.perkNames = [];

    if (!isDefined(level.perkUiMap))
        level.perkUiMap = [];

    level.perkNames["specialty_specialist_bonus"] = "Specialist Bonus";
}

////////////////////////////////////////////////////////////////////////

getUiPerk(perk)
{
    if (!isDefined(perk) || perk == "")
        return "";

    if (isDefined(level.perkUiMap) && isDefined(level.perkUiMap[perk]))
        return level.perkUiMap[perk];

    return perk;
}

////////////////////////////////////////////////////////////////////////

isCustomBrPerk(perk)
{
    if (!isDefined(perk) || perk == "")
        return false;

    return
        perk == "specialty_br_reinforced" ||
        perk == "specialty_br_advancedscout" ||
        perk == "specialty_br_serpentine";
}

////////////////////////////////////////////////////////////////////////

// Top / mapped splash
getMappedPerkSplash(perk)
{
    if (!isDefined(perk) || perk == "")
        return "";

    switch (perk)
    {
        case "specialty_warhead":
            return "specialty_warhead";

        case "specialty_tac_resist":
            return "specialty_tac_resist";

        case "specialty_tactical_recon":
            return "specialty_tactical_recon";

        case "specialty_extra_shrapnel":
            return "specialty_extra_shrapnel";

        case "specialty_tune_up":
            return "specialty_tune_up";

        case "specialty_huntmaster":
            return "specialty_huntmaster";

        case "specialty_guerrilla":
            return "specialty_guerrilla";

        case "specialty_hardline":
            return "specialty_hardline";

        case "specialty_surveillance":
            return "specialty_surveillance";

        case "specialty_strategist":
            return "specialty_strategist";

        case "specialty_restock":
            return "specialty_restock";

        case "specialty_quick_fix":
            return "specialty_quick_fix";

        case "specialty_covert_ops":
            return "specialty_covert_ops";

        case "specialty_hustle":
            return "specialty_hustle";

        case "specialty_eod":
            return "specialty_eod";

        case "specialty_heavy_metal":
            return "specialty_heavy_metal";

        case "specialty_scavenger_plus":
            return "specialty_scavenger_plus";

        case "specialty_br_reinforced":
            return "specialist_perk_bonus";

        case "specialty_br_advancedscout":
            return "specialist_perk_bonus";

        case "specialty_br_serpentine":
            return "specialist_perk_bonus";

        default:
            return "";
    }
}

////////////////////////////////////////////////////////////////////////

// Lower / old normal splash
getUiPerkSplash(perk)
{
    switch (perk)
    {
        case "specialty_blastshield":
            return "specialty_blastshield";

        case "specialty_lightweight":
            return "specialty_lightweight";

        case "specialty_marathon":
            return "specialty_marathon";

        case "specialty_quieter":
            return "specialty_quieter";

        case "specialty_quickswap":
            return "specialty_quickswap";

        case "specialty_fastreload":
            return "specialty_fastreload";

        case "specialty_boom":
            return "specialty_boom";

        case "specialty_selectivehearing":
            return "specialty_selectivehearing";

        case "specialty_holdbreath":
            return "specialty_holdbreath";

        case "specialty_quickdraw":
            return "specialty_quickdraw";

        case "specialty_steadyaimpro":
            return "specialty_steadyaimpro";

        case "specialty_specialist_bonus":
            return "";

        default:
            return "";
    }
}

////////////////////////////////////////////////////////////////////////

// Lower / old BR splash
getUiPerkSecondSplash(perk)
{
    switch (perk)
    {
        case "specialty_blastshield":
            return "br_specialty_blastshield";

        case "specialty_lightweight":
            return "br_specialty_lightweight";

        case "specialty_marathon":
            return "br_specialty_marathon";

        case "specialty_quieter":
            return "br_specialty_quieter";

        case "specialty_quickswap":
            return "br_specialty_quickswap";

        case "specialty_fastreload":
            return "br_specialty_fastreload";

        case "specialty_boom":
            return "br_specialty_boom";

        case "specialty_selectivehearing":
            return "br_specialty_selectivehearing";

        case "specialty_holdbreath":
            return "br_specialty_holdbreath";

        case "specialty_quickdraw":
            return "br_specialty_quickdraw";

        case "specialty_steadyaimpro":
            return "br_specialty_steadyaim";

        case "specialty_specialist_bonus":
            return "";

        default:
            return "";
    }
}

////////////////////////////////////////////////////////////////////////

showPerkSplashes(perk)
{
    mappedSplash = getMappedPerkSplash(perk);
    uiPerk = getUiPerk(perk);
    uiSplash = getUiPerkSplash(uiPerk);
    uiSecondSplash = getUiPerkSecondSplash(uiPerk);

    if (isDefined(mappedSplash) && mappedSplash != "")
        self thread scripts\mp\hud_message::showsplash(mappedSplash);

    if (isDefined(uiSplash) && uiSplash != "")
    {
        wait 0.01;
        self thread scripts\mp\hud_message::showsplash(uiSplash);
    }

    if (isDefined(uiSecondSplash) && uiSecondSplash != "")
    {
        wait 0.01;
        self thread scripts\mp\hud_message::showsplash(uiSecondSplash);
    }

    if (isCustomBrPerk(perk))
        self custom_scripts\framework\sources\core\ui::prefixPrintBold("^5PERK ^7» ^2" + self getPerkName(perk));
}

////////////////////////////////////////////////////////////////////////

giveRandomPerk()
{
    if (!isDefined(self) || !isAlive(self))
        return undefined;

    if (!isDefined(level.perkList) || level.perkList.size <= 0)
        return undefined;

    perk = level.perkList[randomint(level.perkList.size)];

    if (!isDefined(perk) || perk == "")
        return undefined;

    self scripts\mp\utility\perk::giveperk(perk);
    self showPerkSplashes(perk);

    return perk;
}

////////////////////////////////////////////////////////////////////////

// Real Specialist grant path
//
// Based on engine perk-table logic.
bears()
{
    foreach (perkData in level.perktable)
    {
        shouldGive = scripts\engine\utility::ter_op(
            scripts\mp\utility\game::getgametype() == "br",
            isTrue(perkData._id_136D1),
            isTrue(perkData.specialist)
        );

        if (!shouldGive)
            continue;

        if (equipmentIsRestricted(perkData.ref))
            continue;

        scripts\mp\utility\perk::giveperk(perkData.ref);
    }

    scripts\mp\utility\perk::giveperk("specialty_specialist_bonus");

    if (scripts\mp\utility\game::getgametype() == "br")
        return;

    scripts\mp\utility\perk::giveperk("specialty_lightweight");
    scripts\mp\utility\perk::giveperk("specialty_fastreload");

    if (!scripts\mp\utility\game::isAnyMlgMatch())
    {
        scripts\mp\utility\perk::giveperk("specialty_ammo_disabling");
        scripts\mp\utility\perk::giveperk("specialty_delayhealing");
        scripts\mp\utility\perk::giveperk("specialty_armorpiercing");
        scripts\mp\utility\perk::giveperk("specialty_hardmelee");
        scripts\mp\utility\perk::giveperk("specialty_marksman");
        scripts\mp\utility\perk::giveperk("specialty_gunperk_xp");
    }
}

////////////////////////////////////////////////////////////////////////

giveSpecialistBonus()
{
    if (!isDefined(self) || !isAlive(self))
        return 0;

    self playsoundtoplayer("br_legendary_loot_pickup", self);
    self.should_enter_combat_after_checking_decoy_grenade = 1;
    self bears();
    self thread scripts\mp\hud_message::showsplash("specialist_perk_bonus");
    self custom_scripts\framework\sources\core\ui::prefixPrintBold("^5SPECIALIST ^7» ^2BONUS UNLOCKED");

    return 1;
}

////////////////////////////////////////////////////////////////////////

// Legacy alias
giveAllPerks()
{
    return self giveSpecialistBonus();
}

////////////////////////////////////////////////////////////////////////

getPerkName(perk)
{
    if (!isDefined(perk))
        return "Unknown";

    key = "" + perk;

    if (isDefined(level.perkNames) && isDefined(level.perkNames[key]))
        return level.perkNames[key];

    return key;
}