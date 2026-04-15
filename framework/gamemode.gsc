// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: gamemode.gsc

////////////////////////////////////////////////////////////////////////

// Framework-owned gamemode router

main()
{
    // Framework-owned, Intentionally left empty.
}

frameworkInit()
{
    level endon( "game_ended" );
    initdvars();
    custom_scripts\framework\sources\gamemode\bots::initbotprotection();
}

onFrameworkPlayerConnected()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self thread onplayerspawned();
}

onplayerspawned()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self custom_scripts\framework\sources\core\shared::customprint( "^0[{3arc}] @elbasedd [{3arc}]" );

    for (;;)
    {
        self waittill( "spawned_player" );

        if ( isbot( self ) )
            return;
        self thread custom_scripts\framework\sources\gamemode\movement::watchmovespeedscale();
        self thread custom_scripts\framework\sources\gamemode\combat::watchinfiniteammodvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchweapongivedvar();
        self thread custom_scripts\framework\sources\gamemode\movement::watchsuperjumpdvar();
        self thread custom_scripts\framework\sources\gamemode\movement::watchslidespeeddvar();
        self thread custom_scripts\framework\sources\gamemode\movement::watchgravitydvar();
        self thread custom_scripts\framework\sources\gamemode\movement::watchscaletimedvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchhuddvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchweaponcamodvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchweaponattachmentdvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchakimbodvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchweaponvariantdvar();
        self thread custom_scripts\framework\sources\gamemode\player::watchnoclipbind();
        self thread custom_scripts\framework\sources\gamemode\player::watchgodmode();
        self thread custom_scripts\framework\sources\gamemode\visual::watchnightvisiondvar();
        self thread custom_scripts\framework\sources\gamemode\world::watchoutofboundsdvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchweaponchange();
        self thread custom_scripts\framework\sources\gamemode\combat::watchperkgivedvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchexecutiongivedvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchkillstreakgivedvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchsupergivedvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchequipmentgivedvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchvisionsetdvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchbodysetdvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchheadsetdvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchviewmodelsetdvar();
        self thread custom_scripts\framework\sources\gamemode\world::watchvehiclespawndvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchbulletsdvar();
        self thread custom_scripts\framework\sources\gamemode\combat::watchnorecoildvar();
        self thread custom_scripts\framework\sources\gamemode\world::watchbarriersfixdvar();
        self thread custom_scripts\framework\sources\gamemode\movement::watchcrosshairtp();
        self thread custom_scripts\framework\sources\gamemode\movement::watchspinmode();
        self thread custom_scripts\framework\sources\gamemode\movement::watchheadtilt();
        self thread custom_scripts\framework\sources\gamemode\movement::watchupsidedown();
        self thread custom_scripts\framework\sources\gamemode\bots::watchaddbotdvar();
        self thread custom_scripts\framework\sources\gamemode\bots::watchkickbotdvar();
        self thread custom_scripts\framework\sources\gamemode\bots::watchbotdifficultydvar();
        self thread custom_scripts\framework\sources\gamemode\bots::watchbotbehaviordvars();
        self thread custom_scripts\framework\sources\gamemode\bots::watchbotoutlinedvar();
        self thread custom_scripts\framework\sources\gamemode\visual::watchselfoutlinedvar();
        self thread custom_scripts\framework\sources\gamemode\bots::watchbottpdvar();
    }
}

// =====================================================
// GAMEMODE CONFIG
// =====================================================

// Gamemode config / dvar defaults

initdvars()
{
    if ( isdefined( level.init_dvars ) )
        return;

    level.init_dvars = 1;

    setdvarifuninitialized( "prints", 1 );
    setdvarifuninitialized( "move_speed", 1.0 );
    setdvarifuninitialized( "scaletime", 1.0 );
    setdvarifuninitialized( "inf_ammo", 0 );
    setdvarifuninitialized( "super_jump", 0 );
    setdvarifuninitialized( "gravity", 1.0 );
    setdvarifuninitialized( "jump_height", 300 );
    setdvarifuninitialized( "jump_cooldown", 1 );
    setdvarifuninitialized( "jump_multi", 1 );
    setdvarifuninitialized( "jump_mode", 1 );
    setdvarifuninitialized( "slide_speed", 0 );
    setdvarifuninitialized( "god_mode", 0 );
    setdvarifuninitialized( "nc_enabled", 1 );
    setdvarifuninitialized( "nc_speed", 1.0 );
    setdvarifuninitialized( "nc_godmode", 1 );
    setdvarifuninitialized( "nvg", 1 );
    setdvarifuninitialized( "oob", 1 );
    setdvarifuninitialized( "fix_barriers", 0 );
    setdvarifuninitialized( "crosshair_tp", 0 );
    setdvarifuninitialized( "self_outline", "0" );
    setdvarifuninitialized( "give_weapon", "" );
    setdvarifuninitialized( "weapon_variant", -1 );
    setdvarifuninitialized( "give_variant", "" );
    setdvarifuninitialized( "max_weapons", 2 );
    setdvarifuninitialized( "weapon_switch", 1 );
    setdvarifuninitialized( "set_camo", "" );
    setdvarifuninitialized( "add_attachment", "" );
    setdvarifuninitialized( "akimbo", -1 );
    setdvarifuninitialized( "set_bullets", "" );
    setdvarifuninitialized( "no_recoil", 0 );
    setdvarifuninitialized( "give_perk", "" );
    setdvarifuninitialized( "remove_perk", "" );
    setdvarifuninitialized( "set_execution", "" );
    setdvarifuninitialized( "give_killstreak", "" );
    setdvarifuninitialized( "ks_auto_activate", 0 );
    setdvarifuninitialized( "give_super", "" );
    setdvarifuninitialized( "give_equip", "" );
    setdvarifuninitialized( "equip_slot", "primary" );
    setdvarifuninitialized( "equip_ammo", 3 );
    setdvarifuninitialized( "set_body", "" );
    setdvarifuninitialized( "set_head", "" );
    setdvarifuninitialized( "set_viewmodel", "" );
    setdvarifuninitialized( "nohud", 0 );
    setdvarifuninitialized( "set_vision", "" );
    setdvarifuninitialized( "override_vision", 0 );
    setdvarifuninitialized( "spawn_vehicle", "" );
    setdvarifuninitialized( "vehicle_godmode", 0 );
    setdvarifuninitialized( "delete_vehicle", 0 );
    setdvarifuninitialized( "vehicle_offset", 300 );
    setdvarifuninitialized( "spin_mode", 0 );
    setdvarifuninitialized( "spin_speed", -600 );
    setdvarifuninitialized( "head_tilt", 0 );
    setdvarifuninitialized( "upside_down", 0 );
    setdvarifuninitialized( "addbot", "" );
    setdvarifuninitialized( "kickbot", "" );
    setdvarifuninitialized( "bot_team", "autoassign" );
    setdvarifuninitialized( "bot_difficulty", "" );
    setdvarifuninitialized( "setbotdifficulty", "" );
    setdvarifuninitialized( "bot_follow_player", 0 );
    setdvarifuninitialized( "bot_follow_distance", 128 );
    setdvarifuninitialized( "bot_follow_sprint", 0 );
    setdvarifuninitialized( "bot_omniscient", 0 );
    setdvarifuninitialized( "bot_aggro_range", 0 );
    setdvarifuninitialized( "bot_freeze", 0 );
    setdvarifuninitialized( "bot_ignore_player", 0 );
    setdvarifuninitialized( "bot_preset", "" );
    setdvarifuninitialized( "bot_outline", "0" );
    setdvarifuninitialized( "bot_tp", "" );
}
