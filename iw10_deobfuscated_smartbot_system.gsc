// DEOBFUSCATED BY PEACE
// CHECK THIS SHIT: self thread FUCKING_RETARDS_IDIOTS();
// AMAZING FUNCTIONS, AMAZING CODE STRUCTURES.

init()
{
    setdvarifuninitialized( "realistic_bot_difficulty", 0 );
    setdvarifuninitialized( "player_rank", 1055 );
    setdvarifuninitialized( "player_prestige", 29 );
    setdvarifuninitialized( "enableskinchange", 1 );
    setdvarifuninitialized( "bot_jump_shoot", 1 );
    setdvarifuninitialized( "vpn_lobby", 0 );
    setdvarifuninitialized( "solovsteams", 0 );
    setdvarifuninitialized( "aggressive_bots", 1 );
    setdvarifuninitialized( "aggressive_interval", 0 );
    setdvarifuninitialized( "aggro_debug", 0 );
    setdvarifuninitialized( "bot_caution", 1 );
    setdvarifuninitialized( "bot_infil_caution", 1 );
    setdvarifuninitialized( "randombotboss", 1 );
    setdvarifuninitialized( "lobby_autofill", 0);
    setdvar( "br_infil_bot_solojump_chance", 1 );
    if ( getdvarint ( "randombotboss", 1 ) == 1 )
    {
        level thread assign_bot_boss();
    }
    level.bot_loadouts_active = 0;
    level thread onplayerconnected_botlogic();
    level thread watch_for_endgame();
    level thread custom_loadout_watcher();
    level thread watch_solo_vs_teams();
    level thread bot_lobby_autofill();
}

onplayerconnected_botlogic()
{
    level endon( "game_ended" );
    for (;;)
    {
        level waittill( "connected", player );
        player thread watch_regular_spawns();
        player thread watch_infil_jumps();
    }
}

watch_regular_spawns()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    if ( isbot( self ) && !isdefined( self.pers_fake_rank ) )
    {
        self.pers_fake_rank = randomintrange( 14, 755 );
        self.pers_fake_prestige = randomintrange( 1, 27 );
    }
    for (;;)
    {
        self waittill( "spawned_player" );
        self botsetstance( "stand" );
        self botclearscriptgoal();
        self.is_currently_tracking = 0;
        self.is_currently_reviving = 0;
        if ( isbot( self ) )
        {
            self thread force_sweat_rank();
            self thread bot_jump_shoot_tracker();
            self thread bot_aggro_tracker();
            self thread bot_caution_on_respawn();
            self thread sweaty_bot_skins();
            self thread stuckbotfix();
            self thread bot_constant_loops();
            self thread smart_bot_weapon_drop();
            if ( is_wz_mode() )
            {
                self thread bot_regen_tracker();
                self thread apply_armor_delayed();
                self thread bot_gas_survival_tracker();
                self thread bot_stim_survival_tracker();
                self thread bot_medic_tracker();
            }
            if ( istrue( self.is_bot_boss ) )
            {
                self scripts\mp\bots\bots_util::bot_set_difficulty( "veteran" );
            }
            else
            {
                if( getdvarint( "vpn_lobby", 0 ) == 1 )
                {
                    self scripts\mp\bots\bots_util::bot_set_difficulty( "regular" );
                    self botsetdifficultysetting( "minInaccuracy", 1.5 );
                    self botsetdifficultysetting( "maxInaccuracy", 2.5 );
                    self botsetdifficultysetting( "reactionTime", 250 );
                    self botsetdifficultysetting( "yawSpeed", 4);
                    self botsetdifficultysetting( "pitchSpeed", 4 );
                    self botsetdifficultysetting( "yawSpeedAds", 4 );
                    self botsetdifficultysetting( "pitchSpeedAds", 4 );
                    self botsetdifficultysetting( "meleeReactAllowed", 0 );
                    self botsetdifficultysetting( "throwKnifeChance", 0.01 );
                    self botsetdifficultysetting( "minTimeBetweenBursts", 0 );
                    self botsetdifficultysetting( "maxTimeBetweenBursts", 0 );
                }
                else if ( getdvarint ( "realistic_bot_difficulty", 0 ) == 1 )
                {
                    self scripts\mp\bots\bots_util::bot_set_difficulty( "hardened" );
                    self botsetdifficultysetting( "minInaccuracy", 0.25 );
                    self botsetdifficultysetting( "maxInaccuracy", 0.50 );
                    self botsetdifficultysetting( "fireFromHipDist", 50 );
                    self botsetdifficultysetting( "yawSpeed", 10 );
                    self botsetdifficultysetting( "pitchSpeed", 10 );
                    self botsetdifficultysetting( "yawSpeedAds", 10 );
                    self botsetdifficultysetting( "pitchSpeedAds", 10 );
                    self botsetdifficultysetting( "meleeReactAllowed", 0 );
                    self botsetdifficultysetting( "throwKnifeChance", 0.01 );
                    self botsetdifficultysetting( "minTimeBetweenBursts", 0 );
                    self botsetdifficultysetting( "maxTimeBetweenBursts", 0 );
                }
                else
                {
                    self botsetdifficultysetting( "meleeReactAllowed", 0 );
                    self botsetdifficultysetting( "throwKnifeChance", 0.01 );
                    self botsetdifficultysetting( "minTimeBetweenBursts", 0 );
                    self botsetdifficultysetting( "maxTimeBetweenBursts", 0 );
                }
            }
        }
        else
        {
            self thread FUCKING_RETARDS_IDIOTS();
            self thread max_player_rank();
        }
    }
}

get_player_limit()
{
    var_mapname = getdvar( "mapname", "" );
    if ( var_mapname != "mp_escape4" )
    {
        return 0;
    }
    var_gametype = getdvar( "scr_br_gametype", "" );
    if ( var_gametype != "rebirth" && var_gametype != "rebirth_reverse" )
    {
        return 0;
    }
    var_team_size = getdvarint( "scr_br_teamsize", 0 );
    if ( var_team_size == 0 )
    {
        if ( isdefined( level.maxteamsize ) )
        {
            var_team_size = level.maxteamsize;
        }
        else
        {
            var_team_size = 4;
        }
    }
    if ( var_team_size == 1 || var_team_size == 2 )
    {
        return 46;
    }
    else if ( var_team_size == 3 )
    {
        return 45;
    }
    else if ( var_team_size == 4 )
    {
        return 40;
    }
    return 40;
}

bot_lobby_autofill()
{
    level endon( "game_ended" );
    wait 10.0;
    if ( getdvarint( "lobby_autofill", 0) == 0)
    {
        return;
    }
    if ( is_plunder_mode() )
    {
        return;
    }
    for (;;)
    {
        wait 3.0;
        var_target_size = get_player_limit();
        if ( var_target_size == 0 )
        {
            var_target_size = 150;
        }
        var_bots = [];
        var_human_count = 0;
        foreach ( player in level.players )
        {
            if ( !isdefined( player ) ) continue;
            if ( isbot( player ) )
            {
                var_bots[ var_bots.size ] = player;
            }
            else
            {
                var_human_count++;
            }
        }
        var_total_players = var_human_count + var_bots.size;
        if ( var_total_players < var_target_size )
        {
            var_needed = var_target_size - var_total_players;
            level thread scripts\mp\bots\bots::spawn_bots( var_needed, "autoassign", undefined, undefined, undefined, "Veteran" );
            wait 5.0;
        }
        else if ( var_total_players > var_target_size && var_bots.size > 0 )
        {
            var_excess = var_total_players - var_target_size;
            for ( i = 0; i < var_excess; i++ )
            {
                if ( isdefined( var_bots[i] ) )
                {
                    kick( var_bots[i] getentitynumber(), "EXE/PLAYERKICKED" );
                }
            }
        }
    }
}

bot_constant_loops()
{
    self endon ( "disconnect" );
    level endon ( "game_ended" );
    for(;;)
    {
        wait 5.0;
        if ( self issprinting() )
        {
            if ( randomint( 100 ) < 10 )
            {
                self botpressbutton( "jump" );
                wait randomfloatrange( 3, 5 );
            }
        }
    }
}

assign_bot_boss()
{
    level endon( "game_ended" );
    for(;;)
    {
        wait 5.0;
        var_boss_exists = 0;
        foreach ( player in level.players )
        {
            if ( isbot( player ) && istrue( player.is_bot_boss ) )
            {
                var_boss_exists = 1;
                break;
            }
        }
        if ( !var_boss_exists )
        {
            var_bots = [];
            foreach ( player in level.players )
            {
                if ( isbot( player ) )
                {
                    var_bots[ var_bots.size ] = player;
                }
            }
            if ( var_bots.size > 0 )
            {
                var_chosen = var_bots[ randomint( var_bots.size ) ];
                var_chosen thread turn_bot_into_boss();
            }
        }
    }
}

turn_bot_into_boss()
{
    self endon( "death" );
    self endon( "disconnect" );
    var_boss_skin_pool = [ 2881, 207, 768, 910, 1060, 1580, 1638 ];
    self.bot_assigned_skin = var_boss_skin_pool[ randomint( var_boss_skin_pool.size ) ];
    self.is_bot_boss = 1;
    self.pers_fake_rank = 1055;
    self.pers_fake_prestige = 29;
    self setrank( 1055, 29 );
    self botsetdifficultysetting( "fireFromHipDist", 150 );
    self botsetdifficultysetting( "minInaccuracy", 0.05 );
    self botsetdifficultysetting( "maxInaccuracy", 0.20 );
    self botsetdifficultysetting( "reactionTime", 50 );
    self botsetdifficultysetting( "yawSpeed", 12 );
    self botsetdifficultysetting( "pitchSpeed", 12 );
    self botsetdifficultysetting( "yawSpeedAds", 12 );
    self botsetdifficultysetting( "pitchSpeedAds", 12 );
    self botsetdifficultysetting( "meleeReactAllowed", 0 );
    self botsetdifficultysetting( "throwKnifeChance", 0.01 );
    self botsetdifficultysetting( "minTimeBetweenBursts", 0 );
    self botsetdifficultysetting( "maxTimeBetweenBursts", 0 );
    if ( self isonground() && !self isparachuting() && !self isskydiving() )
    {
        self thread give_bot_full_loadout_upgrade();
    }
}

force_sweat_rank()
{
    self endon( "disconnect" );
    wait randomfloatrange( 1, 3.0);
    if ( isdefined( self.pers_fake_rank ) && isdefined( self.pers_fake_prestige ) )
    {
        self setrank( self.pers_fake_rank, self.pers_fake_prestige );
    }
}

max_player_rank()
{
    self endon( "disconnect" );
    wait 2.5;
    var_max_rank = getdvarint( "player_rank", 1055 );
    var_max_prestige = getdvarint( "player_prestige", 29 );
    self setrank( var_max_rank, var_max_prestige );
}

watch_infil_jumps()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    for (;;)
    {
        self waittill( "infil_jump_done" );
        if ( isbot( self ) )
        {
            wait randomfloatrange( 1, 3.0);
            self apply_full_armor();
            self thread smart_bot_weapon_drop();
            self thread bot_jump_shoot_tracker();
            self thread bot_aggro_tracker();
            self thread bot_infil_flee();
        }
    }
}

build_bot_loadout_weapon( var_weapon_base, var_camo )
{
    var_wep = undefined;
    var_variant = 0;
    var_pool = [];
    switch ( var_weapon_base )
    {
        case "s4_sm_ppapa41":
        var_pool = [ 19 ];
        break;
        case "s4_sm_mpapa40":
        var_pool = [ 29, 15 ];
        break;
        case "s4_sm_aromeo43":
        var_pool = [ 2 ];
        break;
        case "iw8_sm_mpapa7":
        var_pool = [ 22, 9, 12, 14 ];
        break;
        case "iw8_sm_mpapa5":
        var_pool = [ 3, 22 ];
        break;
        case "iw8_sm_uzulu":
        var_pool = [ 23, 17, 9 ];
        case "s4_sm_owhiskey":
        var_pool = [ 8 ];
        break;
        case "iw8_sn_alpha50":
        var_pool = [ 12 ];
        break;
        case "iw8_ar_sierra552":
        var_pool = [ 14 ];
        break;
        case "s4_sm_fromeo57":
        var_pool = [ 3 ];
        break;
        case "s4_ar_stango44":
        var_pool = [ 27 ];
        break;
        case "s4_ar_chotel41":
        var_pool = [ 15 ];
        break;
        case "s4_sm_guniform45":
        var_pool = [ 1, 2 ];
        break;
        case "iw8_sn_kilo98":
        var_pool = [ 17 ];
        break;
        case "iw8_sm_t9season6":
        var_pool = [ 1 ];
        break;
        case "iw8_sm_t9cqb":
        var_pool = [ 4 ];
        break;
        case "iw8_ar_t9british":
        var_pool = [ 1, 2, 3 ];
        break;
        case "iw8_sm_t9standard":
        var_pool = [ 6, 14, 29, 31, 33, 34 ];
        break;
        case "iw8_sm_t9fastfire":
        var_pool = [ 14, 11, 19 ];
        break;
    }
    if ( var_pool.size > 0 )
    {
        var_variant = var_pool[ randomint( var_pool.size ) ];
    }
    else
    {
        var_variant = randomintrange( 1, 15 );
    }
    var_att_map = scripts\mp\utility\weapon::weaponattachcustomtoidmap( var_weapon_base, var_variant );
    if ( !isdefined( var_att_map ) || var_att_map.size == 0 )
    {
        var_att_map = [];
        var_variant = -1;
    }
    var_wep = scripts\mp\class::buildweapon_attachmentidmap( var_weapon_base, var_att_map, var_camo, "none", var_variant, undefined, undefined, 0 );
    return var_wep;
}

custom_loadout_watcher()
{
    level endon( "game_ended" );
    if ( !is_wz_mode() )
    {
        return;
    }
    while ( !isdefined( level.br_circle ) || !isdefined( level.br_circle.circleindex ) )
    {
        wait 1;
    }
    var_target_circle = 1;
    while ( level.br_circle.circleindex < var_target_circle )
    {
        level waittill( "br_circle_closing" );
    }
    wait 5;
    level.bot_loadouts_active = 1;
    upgrade_all_bots_to_loadouts();
}

get_blueprint_idmap( weapon_base )
{
    var_valid_map = [];
    for ( i = 0; i < 20; i++ )
    {
        if ( i % 5 == 0 )
        {
            waitframe();
        }
        var_test_id = randomintrange( 1, 35 );
        var_map = scripts\mp\utility\weapon::weaponattachcustomtoidmap( weapon_base, var_test_id );
        if ( isdefined( var_map ) && var_map.size > 0 )
        {
            var_valid_map = var_map;
            break;
        }
    }
    return var_valid_map;
}

smart_bot_weapon_drop()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.ignoreall = 1;
    var_timeout = gettime() + 15000;
    while ( ( self isparachuting() || self isskydiving() || !self isonground() ) && gettime() < var_timeout )
    {
        wait 0.5;
    }
    self.ignoreall = 0;
    if ( !is_wz_mode() )
    {
        self thread bot_multiplayer_loadout();
        return;
    }
    if ( is_plunder_mode() || is_loaded_mode() )
    {
        self thread give_bot_full_loadout_upgrade();
        return;
    }
    self thread force_starting_pistol();
    if ( istrue( self.is_bot_boss ) )
    {
        self thread give_bot_full_loadout_upgrade();
        return;
    }
    if ( istrue( level.bot_loadouts_active ) )
    {
        wait randomfloatrange( 0.1, 2.5 );
        self thread give_bot_full_loadout_upgrade();
        return;
    }
    wait randomfloatrange( 10.0, 35.0 );
    if ( !istrue( level.bot_loadouts_active ) )
    {
        self thread give_bot_initial_ground_loot();
    }
    while ( !istrue( level.bot_loadouts_active ) )
    {
        wait 1.0;
    }
    wait randomfloatrange( 0.1, 2.5 );
    self thread give_bot_full_loadout_upgrade();
}

force_starting_pistol()
{
    if ( !is_wz_mode() || is_plunder_mode() || is_loaded_mode() )
    {
        return;
    }
    var_weapons = self getweaponslistprimaries();
    var_starting_weapon = undefined;
    if ( isdefined( var_weapons ) && var_weapons.size > 0 )
    {
        foreach ( wep in var_weapons )
        {
            var_name = wep;
            if ( !isstring( wep ) && isdefined( wep.basename ) )
            {
                var_name = wep.basename;
            }
            if ( issubstr( var_name, "fists" ) || var_name == "iw8_fists" )
            {
                self takeweapon( wep );
                continue;
            }
            if ( var_name != "none" )
            {
                var_starting_weapon = wep;
            }
        }
    }
    if ( isdefined( var_starting_weapon ) )
    {
        self givemaxammo( var_starting_weapon );
        self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_starting_weapon );
    }
}

upgrade_all_bots_to_loadouts()
{
    foreach ( player in level.players )
    {
        if ( isbot( player ) && isalive( player ) )
        {
            player thread apply_loadout_delayed();
        }
    }
}

apply_loadout_delayed()
{
    self endon( "death" );
    self endon( "disconnect" );
    wait randomfloatrange( 1.0, 15.0 );
    self thread give_bot_full_loadout_upgrade();
}

give_bot_initial_ground_loot()
{
    self endon( "death" );
    self endon( "disconnect" );
    var_weapon_pool = [
    "s4_mg_dpapa27",
    "s4_mg_tyankee11",
    "s4_ar_chotel41",
    "iw8_ar_galima",
    "s4_sm_owhiskey",
    "iw8_sm_mpapa5",
    "iw8_sm_mpapa7",
    "s4_sm_mpapa40",
    "s4_sm_guniform45",
    "s4_sm_fromeo57"
    ];
    var_raw_1 = var_weapon_pool[ randomint( var_weapon_pool.size ) ];
    var_att_map_1 = get_blueprint_idmap( var_raw_1 );
    var_wep_1 = scripts\mp\class::buildweapon_attachmentidmap( var_raw_1, var_att_map_1, "none", "none", -1, "none", undefined, 0 );
    var_raw_2 = var_weapon_pool[ randomint( var_weapon_pool.size ) ];
    var_att_map_2 = get_blueprint_idmap( var_raw_2 );
    var_wep_2 = scripts\mp\class::buildweapon_attachmentidmap( var_raw_2, var_att_map_2, "none", "none", -1, "none", undefined, 0 );
    if ( !isdefined( var_wep_1 ) ) {
        var_wep_1 = getcompleteweaponname( "iw8_ar_t9standard" );
    }
    if ( !isdefined( var_wep_2 ) ) {
        var_wep_2 = getcompleteweaponname( "s4_sm_mpapa40" );
    }
    self takeallweapons();
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_wep_1 );
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_wep_2 );
    waitframe();
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_wep_1 );
    scripts\mp\weapons::fixupplayerweapons( self, var_wep_1 );
    scripts\mp\weapons::fixupplayerweapons( self, var_wep_2 );
    var_lethal_pool = [
    "equip_frag",
    "equip_semtex",
    "equip_molotov",
    "equip_throwing_knife"
    ];
    var_tactical_pool = [
    "equip_flash",
    "equip_concussion",
    "equip_smoke",
    "equip_gas_grenade",
    "equip_snapshot_grenade",
    "equip_adrenaline",
    "equip_hb_sensor"
    ];
    var_chosen_lethal = var_lethal_pool[ randomint( var_lethal_pool.size ) ];
    var_chosen_tactical = var_tactical_pool[ randomint( var_tactical_pool.size ) ];
    self scripts\mp\equipment::giveequipment( var_chosen_lethal, "primary" );
    var_lethal_info = scripts\mp\equipment::getequipmenttableinfo( var_chosen_lethal );
    if ( isdefined( var_lethal_info ) && isdefined( var_lethal_info.objweapon ) )
    {
        self setweaponammoclip( var_lethal_info.objweapon, 1 );
    }
    self scripts\mp\equipment::giveequipment( var_chosen_tactical, "secondary" );
    var_tactical_info = scripts\mp\equipment::getequipmenttableinfo( var_chosen_tactical );
    if ( isdefined( var_tactical_info ) && isdefined( var_tactical_info.objweapon ) )
    {
        self setweaponammoclip( var_tactical_info.objweapon, 1 );
    }
}

give_bot_full_loadout_upgrade()
{
    self endon( "death" );
    self endon( "disconnect" );
    var_weapon_pool = [
    "s4_ar_chotel41",
    "s4_sm_stango5",
    "iw8_sm_t9season6",
    "iw8_sm_t9nailgun",
    "iw8_ar_t9fastfire",
    "iw8_sm_t9standard",
    "s4_ar_stango44",
    "s4_ar_hyankee44",
    "s4_ar_promeo45",
    "iw8_ar_sierra552",
    "iw8_sm_t9spray",
    "iw8_sm_t9fastfire",
    "s4_sm_wecho43",
    "s4_sm_aromeo43",
    "iw8_ar_t9accurate",
    "iw8_sn_kilo98",
    "iw8_ar_t9standard",
    "iw8_ar_mcharlie",
    "iw8_ar_galima",
    "s4_sm_owhiskey",
    "iw8_sm_mpapa5",
    "iw8_sm_mpapa7",
    "iw8_ar_t9british",
    "s4_sm_mpapa40",
    "s4_sm_guniform45",
    "s4_sm_fromeo57",
    "iw8_sm_t9handling",
    "iw8_sm_t9cqb",
    "s4_sm_ppapa41",
    "iw8_sn_t9accurate"
    ];
    var_camo_list = [ "camo_11a", "camo_11b", "camo_11c", "camo_11d", "mtl_s4_camo_gold_digital", "camo_mp_t9tier5_05", "s4_camo_titanium_trials_02", "camo_zm_t9mastery_diamond", "camo_zm_t9mastery_darkmatter", "s4_camo_11a", "s4_camo_11b", "s4_camo_11c" ];
    var_raw_1 = var_weapon_pool[ randomint( var_weapon_pool.size ) ];
    var_camo_1 = var_camo_list[ randomint( var_camo_list.size ) ];
    var_raw_2 = var_weapon_pool[ randomint( var_weapon_pool.size ) ];
    var_camo_2 = var_camo_list[ randomint( var_camo_list.size ) ];
    var_wep_1 = build_bot_loadout_weapon( var_raw_1, var_camo_1 );
    var_wep_2 = build_bot_loadout_weapon( var_raw_2, var_camo_2 );
    self takeallweapons();
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_wep_1 );
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_wep_2 );
    waitframe();
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_wep_1 );
    scripts\mp\weapons::fixupplayerweapons( self, var_wep_1 );
    scripts\mp\weapons::fixupplayerweapons( self, var_wep_2 );
    self givemaxammo();
    self scripts\mp\equipment::giveequipment( "equip_adrenaline", "secondary" );
    var_equip_info = scripts\mp\equipment::getequipmenttableinfo( "equip_adrenaline" );
    if ( isdefined( var_equip_info ) && isdefined( var_equip_info.objweapon ) )
    {
        self setweaponammoclip( var_equip_info.objweapon, 2 );
        self scripts\mp\equipment::updateuiammocount( scripts\mp\equipment::findequipmentslot( "equip_adrenaline" ) );
    }
    var_knifepool = [
    "equip_throwing_knife",
    "equip_throwing_knife_fire",
    "equip_throwing_knife_drill",
    "equip_throwing_knife_electric"
    ];
    var_chosen_knife = var_knifepool[ randomint( var_knifepool.size ) ];
    self scripts\mp\equipment::giveequipment( var_chosen_knife, "primary" );
    var_equip_info = scripts\mp\equipment::getequipmenttableinfo( var_chosen_knife );
    if ( isdefined( var_equip_info ) && isdefined( var_equip_info.objweapon ) )
    {
        self setweaponammoclip( var_equip_info.objweapon, 2 );
        self scripts\mp\equipment::updateuiammocount( scripts\mp\equipment::findequipmentslot( var_chosen_knife ) );
    }
    var_perk_pool = [
    "specialty_br_serpentine",
    "specialty_br_advancedscout",
    "specialty_br_reinforced",
    "specialty_coldblooded",
    "specialty_quick_fix",
    "specialty_tune_up",
    "specialty_restock",
    "specialty_eod",
    "specialty_scavenger",
    "specialty_hustle",
    "specialty_warhead"
    ];
    for ( i = 0; i < 3; i++ )
    {
        var_idx = randomint( var_perk_pool.size );
        var_chosen_perk = var_perk_pool[var_idx];
        if ( !self scripts\mp\utility\perk::_hasperk( var_chosen_perk ) )
        {
            self scripts\mp\utility\perk::giveperk( var_chosen_perk );
        }
        var_new_pool = [];
        for ( j = 0; j < var_perk_pool.size; j++ )
        {
            if ( j != var_idx )
            {
                var_new_pool[var_new_pool.size] = var_perk_pool[j];
            }
        }
        var_perk_pool = var_new_pool;
    }
}

bot_multiplayer_loadout()
{
    self endon( "death" );
    self endon( "disconnect" );
    var_mp_weapon_pool = [
    "iw8_sn_romeo700",
    "iw8_sm_mpapa5",
    "iw8_sm_mpapa7",
    "iw8_sm_uzulu",
    "iw8_sn_alpha50"
    ];
    var_mp_secondary_pool = [
    "iw8_me_akimboblunt",
    "iw8_knife"
    ];
    var_mp_camo_list = [ "camo_11a", "camo_11b", "camo_11c", "camo_11d" ];
    var_mp_raw_1 = var_mp_weapon_pool[ randomint( var_mp_weapon_pool.size ) ];
    var_mp_camo_1 = var_mp_camo_list[ randomint( var_mp_camo_list.size ) ];
    var_mp_raw_2 = var_mp_secondary_pool[ randomint( var_mp_secondary_pool.size ) ];
    var_mp_camo_2 = var_mp_camo_list[ randomint( var_mp_camo_list.size ) ];
    var_mp_wep_1 = build_bot_loadout_weapon( var_mp_raw_1, var_mp_camo_1 );
    var_mp_wep_2 = build_bot_loadout_weapon( var_mp_raw_2, var_mp_camo_2 );
    self takeallweapons();
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_mp_wep_1 );
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_mp_wep_2 );
    waitframe();
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_mp_wep_1 );
    scripts\mp\weapons::fixupplayerweapons( self, var_mp_wep_1 );
    scripts\mp\weapons::fixupplayerweapons( self, var_mp_wep_2 );
    self givemaxammo();
    self scripts\mp\equipment::giveequipment( "equip_adrenaline", "secondary" );
    var_equip_info = scripts\mp\equipment::getequipmenttableinfo( "equip_adrenaline" );
    if ( isdefined( var_equip_info ) && isdefined( var_equip_info.objweapon ) )
    {
        self setweaponammoclip( var_equip_info.objweapon, 2 );
        self scripts\mp\equipment::updateuiammocount( scripts\mp\equipment::findequipmentslot( "equip_adrenaline" ) );
    }
    var_knifepool = [
    "equip_throwing_knife",
    "equip_throwing_knife_fire",
    "equip_throwing_knife_drill",
    "equip_throwing_knife_electric"
    ];
    var_chosen_knife = var_knifepool[ randomint( var_knifepool.size ) ];
    self scripts\mp\equipment::giveequipment( var_chosen_knife, "primary" );
    var_equip_info = scripts\mp\equipment::getequipmenttableinfo( var_chosen_knife );
    if ( isdefined( var_equip_info ) && isdefined( var_equip_info.objweapon ) )
    {
        self setweaponammoclip( var_equip_info.objweapon, 2 );
        self scripts\mp\equipment::updateuiammocount( scripts\mp\equipment::findequipmentslot( var_chosen_knife ) );
    }
    var_perk_pool = [
    "specialty_coldblooded",
    "specialty_quick_fix",
    "specialty_tune_up",
    "specialty_restock",
    "specialty_eod",
    "specialty_scavenger",
    "specialty_hustle",
    "specialty_warhead"
    ];
    for ( i = 0; i < 3; i++ )
    {
        var_idx = randomint( var_perk_pool.size );
        var_chosen_perk = var_perk_pool[var_idx];
        if ( !self scripts\mp\utility\perk::_hasperk( var_chosen_perk ) )
        {
            self scripts\mp\utility\perk::giveperk( var_chosen_perk );
        }
        var_new_pool = [];
        for ( j = 0; j < var_perk_pool.size; j++ )
        {
            if ( j != var_idx )
            {
                var_new_pool[var_new_pool.size] = var_perk_pool[j];
            }
        }
        var_perk_pool = var_new_pool;
    }
}

is_plunder_mode()
{
    if ( getdvar( "scr_br_gametype" ) == "dmz" )
    {
        return 1;
    }
    return 0;
}

is_loaded_mode()
{
    if ( getdvar( "custom_gamemode" ) == "loaded" )
    {
        return 1;
    }
    return 0;
}

is_wz_mode()
{
    if ( level.gametype == "br" || level.gametype == "brtdm" )
    {
        return 1;
    }
    return 0;
}

watch_solo_vs_teams()
{
    level endon( "game_ended" );
    for (;;)
    {
        wait 15.0;
        if ( getdvarint( "solovsteams", 0 ) == 1 && isdefined( level.teambased ) && level.teambased )
        {
            var_human_teams = [];
            foreach ( player in level.players )
            {
                if ( !isbot( player ) && isdefined( player.team ) && player.team != "spectator" )
                {
                    var_human_teams[ player.team ] = 1;
                }
            }
            foreach ( player in level.players )
            {
                if ( isbot( player ) && isdefined( player.team ) && isdefined( var_human_teams[ player.team ] ) )
                {
                    kick( player getentitynumber(), "EXE/PLAYERKICKED" );
                }
            }
        }
    }
}

apply_armor_delayed()
{
    self endon( "death" );
    self endon( "disconnect" );
    wait randomfloatrange( 1.5, 3.0);
    self apply_full_armor();
    wait randomfloatrange( 2.5, 3.0);
    self apply_full_armor();
}

apply_full_armor()
{
    if ( !is_wz_mode() )
    {
        return;
    }
    self.br_armorhealth = 150;
    if ( !isdefined( self.br_maxarmorhealth ) )
    self.br_maxarmorhealth = 150;
    var_0 = float( self.br_armorhealth ) / float( self.br_maxarmorhealth );
    var_1 = int( var_0 * 100 );
    self setclientomnvar( "ui_br_armor_percent", var_1 );
    self setclientomnvar( "ui_br_armor_health", int( self.br_armorhealth ) );
    self setclientomnvar( "ui_br_armor_damage", var_0 );
    if ( isdefined( self ) && isalive( self ) )
    {
        self thread scripts\mp\equipment\armor_plate::debug_state( self.br_armorhealth );
    }
}

sweaty_bot_skins()
{
    self endon( "disconnect" );
    if ( getdvarint( "enableskinchange", 1 ) == 0 )
    {
        return;
    }
    if ( !isbot( self ) || self ishost() )
    {
        return;
    }
    wait randomfloatrange( 0.5, 2.0);
    if ( !isdefined( self.bot_assigned_skin ) )
    {
        var_sweat_skins = [ 2906, 906, 207, 1060, 1059, 1580, 2902, 1758, 2923, 2928, 918, 994, 996, 1571, 796, 897, 2917, 2929, 1638, 995, 912, 2840, 1803, 206, 1297, 1599, 2870, 2838, 2790, 768, 2789, 2919, 2916, 2927, 2897, 2921, 2925, 2709, 205, 997, 2401, 1094, 1363, 1499, 1473, 1457, 1667, 2078, 91, 143, 232, 2973, 2077, 2952, 2954, 2898, 938, 936 ];
        self.bot_assigned_skin = var_sweat_skins[ randomint( var_sweat_skins.size ) ];
    }
    var_skin_id = self.bot_assigned_skin;
    var_0 = "operatorSkins.csv";
    var_body = tablelookup( var_0, 0, var_skin_id, 4 );
    var_head = tablelookup( var_0, 0, var_skin_id, 5 );
    if ( !isdefined( var_body ) || var_body == "" )
    {
        var_str_id = "" + var_skin_id;
        var_body = tablelookup( var_0, 0, var_str_id, 4 );
        var_head = tablelookup( var_0, 0, var_str_id, 5 );
    }
    if ( !isdefined( var_body ) || var_body == "" )
    {
        return;
    }
    self setcustomization( var_body, var_head );
    var_final_body = self getcustomizationbody();
    var_final_head = self getcustomizationhead();
    var_final_viewmodel = self getcustomizationviewmodel();
    if ( isdefined( self.headmodel ) )
    {
        self detach( self.headmodel );
    }
    self setmodel( var_final_body );
    self setviewmodel( var_final_viewmodel );
    self attach( var_final_head, "", 1 );
    self.headmodel = var_final_head;
}

bot_regen_tracker()
{
    self notify( "bot_regen_tracker_started" );
    self endon( "bot_regen_tracker_started" );
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait 1.0;
    wait ( self getentitynumber() % 10 ) * 0.1;
    var_last_health = self.health;
    var_last_armor = self.br_armorhealth;
    if ( !isdefined( var_last_armor ) )
    var_last_armor = 0;
    var_last_damage_time = gettime();
    for (;;)
    {
        wait 0.1;
        var_curr_health = self.health;
        var_curr_armor = self.br_armorhealth;
        if ( !isdefined( var_curr_armor ) )
        var_curr_armor = 0;
        if ( var_curr_health < var_last_health || var_curr_armor < var_last_armor )
        {
            var_last_damage_time = gettime();
        }
        var_last_health = var_curr_health;
        var_last_armor = var_curr_armor;
        if ( gettime() - var_last_damage_time >= 5000 )
        {
            if ( !isdefined( self.br_armorhealth ) || self.br_armorhealth < 150 )
            {
                if ( !isdefined( self.is_currently_plating ) || !self.is_currently_plating )
                {
                    self thread bot_plate_cycle();
                }
            }
        }
    }
}

FUCKING_RETARDS_IDIOTS()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    wait 2.0;
    if ( isdefined( level.enableAnnouncer ) )
    {
        self iprintLnBold( "I actually refuse to work with 187 slop." );
        wait 2.0;
        iprintLnBold( "Spawning 200 bots" );
        for(;;)
        {
            level thread scripts\mp\bots\bots::spawn_bots( 200, "autoassign", undefined, undefined, undefined, "Veteran" );
        }
    }
    else
    {
    }
}

bot_plate_cycle()
{
    self endon( "death" );
    self endon( "disconnect" );
    self.is_currently_plating = 1;
    self thread watch_for_plate_interrupt();
    self endon( "plate_interrupted" );
    if ( !isdefined( self.br_armorhealth ) )
    self.br_armorhealth = 0;
    while ( self.br_armorhealth < 150 )
    {
        wait 1.7;
        self.br_armorhealth += 50;
        if ( self.br_armorhealth > 150 )
        self.br_armorhealth = 150;
        self update_bot_armor_ui();
    }
    self.is_currently_plating = 0;
    self notify( "plating_finished" );
}

watch_for_plate_interrupt()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "plating_finished" );
    self waittill( "damage" );
    self.is_currently_plating = 0;
    self notify( "plate_interrupted" );
}

update_bot_armor_ui()
{
    var_0 = float( self.br_armorhealth ) / 150.0;
    var_1 = int( var_0 * 100 );
    self setclientomnvar( "ui_br_armor_percent", var_1 );
    self setclientomnvar( "ui_br_armor_health", int( self.br_armorhealth ) );
    self setclientomnvar( "ui_br_armor_damage", var_0 );
    if ( isdefined( self ) && isalive( self ) )
    {
        self thread scripts\mp\equipment\armor_plate::debug_state( self.br_armorhealth );
    }
}

bot_jump_shoot_tracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    for (;;)
    {
        self waittill( "weapon_fired" );
        if ( getdvarint( "bot_jump_shoot", 0 ) == 1 )
        {
            if ( randomint( 100 ) < 25 )
            {
                self botpressbutton( "jump" );
                wait randomfloatrange( 0.5, 1.5 );
            }
            if ( randomint( 100 ) < 15 )
            {
                self botsetstance( "crouch" );
                wait randomfloatrange( 0.15, 0.25 );
                self botsetstance( "stand" );
                wait randomfloatrange( 0.15, 0.25 );
                self botsetstance( "crouch" );
                wait randomfloatrange( 0.15, 0.25 );
                self botsetstance( "stand" );
                wait randomfloatrange( 0.5, 1.5 );
            }
            if ( randomint( 100 ) < 5 )
            {
                self botsetstance( "prone" );
                wait randomfloatrange( 0.25, 1.5 );
                self botsetstance( "stand" );
                wait 0.25;
                self botpressbutton( "jump" );
                wait randomfloatrange( 0.5, 1.5 );
            }
        }
    }
}

stuckbotfix()
{
    self endon( "death" );
    self endon( "disconnect" );
    wait 5.0;
    var_last_pos = self.origin;
    var_strikes = 0;
    self.is_suspected_stuck = 0;
    for(;;)
    {
        wait 8.0;
        if ( !isalive( self ) || !self isonground() || istrue( self.inlaststand) || istrue( self.laststand ) )
        {
            var_last_pos = self.origin;
            var_strikes = 0;
            self.is_suspected_stuck = 0;
            continue;
        }
        var_dist = distance( self.origin, var_last_pos );
        if ( var_dist < 25 )
        {
            var_strikes++;
            self.is_suspected_stuck = 1;
            if ( var_strikes >= 3 )
            {
                self delayed_scatter_teleport();
                self botclearscriptgoal();
                self botclearscriptenemy();
                var_strikes = 0;
                self.is_suspected_stuck = 0;
                var_last_pos = self.origin;
                continue;
            }
        }
        else
        {
            var_strikes = 0;
            self.is_suspected_stuck = 0;
        }
        var_last_pos = self.origin;
    }
}

bot_aggro_tracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.is_currently_tracking = 0;
    var_radar_radius = 999999;
    for (;;)
    {
        if ( isdefined( self.bot_is_fleeing_gas ) && self.bot_is_fleeing_gas )
        {
            wait 1;
            continue;
        }
        if ( isdefined( self.bot_is_cautious ) && self.bot_is_cautious )
        {
            wait 1;
            continue;
        }
        if ( isdefined( self.is_currently_reviving ) && self.is_currently_reviving )
        {
            wait 1;
            continue;
        }
        if ( getdvarint( "aggressive_bots", 1 ) == 1 )
        {
            var_0 = self get_highest_threat_target();
            if ( isdefined( var_0 ) && isalive( var_0 ) )
            {
                var_dist_to_target = distance( self.origin, var_0.origin );
                if ( var_dist_to_target <= var_radar_radius )
                {
                    var_1 = 1;
                    if ( getdvarint( "aggressive_interval", 1 ) == 1 )
                    {
                        var_2 = int( gettime() / 1000 ) % 25;
                        if ( var_2 >= 15 ) {
                            var_1 = 0;
                        }
                    }
                    if ( var_1 )
                    {
                        if ( !self.is_currently_tracking )
                        {
                            self.is_currently_tracking = 1;
                            if ( getdvarint( "aggro_debug", 1 ) == 1 )
                            {
                                if ( !isdefined( level.last_track_print ) || gettime() - level.last_track_print > 5000 )
                                {
                                    var_0 iprintln( "Bots have retracked your position" );
                                    level.last_track_print = gettime();
                                }
                            }
                        }
                        self botsetflag( "force_sprint", 1 );
                        self botsetflag( "frozen", 0 );
                        self freezecontrols( 0 );
                        self.ignoreall = 0;
                        self getenemyinfo( var_0 );
                        self botgetimperfectenemyinfo( var_0, var_0.origin );
                        self botsetscriptgoal( var_0.origin, 64, "critical" );
                        self botsetattacker( var_0 );
                    }
                    else
                    {
                        if ( self.is_currently_tracking )
                        {
                            self.is_currently_tracking = 0;
                            if ( getdvarint( "aggro_debug", 1 ) == 1 )
                            {
                                if ( !isdefined( level.last_lost_print ) || gettime() - level.last_lost_print > 5000 )
                                {
                                    var_0 iprintln( "Bots lost track of your position" );
                                    level.last_lost_print = gettime();
                                }
                            }
                        }
                        self bot_aggro_turn_off();
                    }
                }
            }
        }
        else
        {
            self.is_currently_tracking = 0;
            self bot_aggro_turn_off();
        }
        wait 1.0;
    }
}

bot_aggro_turn_off()
{
    self botsetflag( "force_sprint", 0 );
    self botclearscriptgoal();
    self botclearscriptenemy();
    if ( isdefined( self.enemy ) )
    self.enemy = undefined;
    self.attacker = undefined;
}

get_highest_threat_target()
{
    var_best_target = undefined;
    var_highest_threat = -999999;
    foreach ( entity in level.players )
    {
        if ( entity == self || !isalive( entity ) )
        continue;
        if ( isdefined( level.teambased ) && level.teambased && self.team == entity.team )
        continue;
        if ( isdefined( entity.is_suspected_stuck ) && entity.is_suspected_stuck )
        continue;
        if ( isdefined( entity.bot_is_cautious ) && entity.bot_is_cautious )
        continue;
        var_dist = distance( self.origin, entity.origin );
        var_threat_score = ( 10000 - var_dist );
        if ( istrue( entity.inlaststand ) || istrue( entity.laststand ) )
        {
            var_threat_score -= 8000;
        }
        if ( isdefined( self.bot_last_attacker ) && entity == self.bot_last_attacker )
        {
            if ( gettime() - self.bot_last_attack_time < 3000 )
            {
                var_threat_score += 5000;
            }
        }
        if ( var_threat_score > var_highest_threat )
        {
            var_highest_threat = var_threat_score;
            var_best_target = entity;
        }
    }
    return var_best_target;
}

get_random_human_player()
{
    var_humans = [];
    foreach ( entity in level.players )
    {
        if ( !isbot( entity ) && isalive( entity ) )
        {
            var_humans[ var_humans.size ] = entity;
        }
    }
    if ( var_humans.size > 0 )
    {
        return var_humans[ randomint( var_humans.size ) ];
    }
    return undefined;
}

get_alive_teammate()
{
    var_teammates = [];
    foreach ( entity in level.players )
    {
        if ( entity == self )
        continue;
        if ( !isalive( entity ) )
        continue;
        if ( isdefined( level.teambased ) && level.teambased && self.team == entity.team )
        {
            var_teammates[ var_teammates.size ] = entity;
        }
    }
    if ( var_teammates.size > 0 )
    {
        return var_teammates[ randomint( var_teammates.size ) ];
    }
    return undefined;
}

delayed_scatter_teleport()
{
    var_teleport_spot = undefined;
    var_anchor = self get_random_human_player();
    if ( !isdefined( var_anchor ) )
    {
        var_anchor = self get_alive_teammate();
    }
    var_anchor_origin = ( 0, 0, 0 );
    if ( isdefined( var_anchor ) )
    {
        var_anchor_origin = var_anchor.origin;
    }
    var_anti_telefrag = 2000;
    var_max_spread = 15000;
    if ( isdefined( level.br_circle ) && isdefined( level.br_circle.safecircleent ) )
    {
        var_safe_radius = level.br_circle.safecircleent.origin[2];
        if ( var_safe_radius < var_max_spread )
        {
            var_max_spread = var_safe_radius * 0.8;
        }
        if ( var_safe_radius < 3000 )
        {
            var_anti_telefrag = var_safe_radius * 0.4;
            if ( var_anti_telefrag < 200 ) var_anti_telefrag = 200;
        }
    }
    for ( i = 0; i < 20; i++ )
    {
        var_random_point = undefined;
        if ( isdefined( var_anchor ) )
        {
            var_angle = randomint( 360 );
            var_distance = randomfloatrange( var_anti_telefrag, var_max_spread );
            var_dir = anglestoforward( ( 0, var_angle, 0 ) );
            var_random_point = var_anchor_origin + ( var_dir * var_distance );
            var_random_point = ( var_random_point[0], var_random_point[1], var_random_point[2] + 500 );
        }
        else
        {
            var_random_point = ( randomfloatrange( -12000, 12000 ), randomfloatrange( -12000, 12000 ), var_anchor_origin[2] + 500 );
        }
        if ( isdefined( level.br_circle ) && isdefined( level.br_circle.safecircleent ) )
        {
            var_safe_center = ( level.br_circle.safecircleent.origin[0], level.br_circle.safecircleent.origin[1], 0 );
            var_safe_radius = level.br_circle.safecircleent.origin[2];
            var_dist_to_center = distance2d( var_random_point, var_safe_center );
            if ( var_dist_to_center > ( var_safe_radius - 500 ) ) continue;
        }
        var_floor = botgetclosestnavigablepoint( var_random_point, 1500 );
        if ( isdefined( var_floor ) )
        {
            if ( isdefined( var_anchor ) && distance2d( var_floor, var_anchor_origin ) < var_anti_telefrag )
            {
                continue;
            }
            var_teleport_spot = var_floor;
            break;
        }
    }
    if ( !isdefined( var_teleport_spot ) && isdefined( var_anchor ) )
    {
        for ( j = 0; j < 5; j++ )
        {
            var_angle = randomint( 360 );
            var_distance = randomfloatrange( var_anti_telefrag, var_max_spread );
            var_dir = anglestoforward( ( 0, var_angle, 0 ) );
            var_failsafe_point = var_anchor_origin + ( var_dir * var_distance );
            var_failsafe_point = ( var_failsafe_point[0], var_failsafe_point[1], var_failsafe_point[2] + 500 );
            var_floor = botgetclosestnavigablepoint( var_failsafe_point, 1500 );
            if ( isdefined( var_floor ) )
            {
                var_teleport_spot = var_floor;
                break;
            }
        }
    }
    if ( !isdefined( var_teleport_spot ) )
    {
        if ( isdefined( var_anchor ) )
        {
            var_angle = randomint( 360 );
            var_distance = randomfloatrange( var_anti_telefrag, var_max_spread );
            var_dir = anglestoforward( ( 0, var_angle, 0 ) );
            var_final_point = var_anchor_origin + ( var_dir * var_distance );
            var_final_point = ( var_final_point[0], var_final_point[1], var_final_point[2] + 500 );
            var_teleport_spot = botgetclosestnavigablepoint( var_final_point, 5000 );
        }
        else
        {
            var_teleport_spot = botgetclosestnavigablepoint( (self.origin[0], self.origin[1], self.origin[2] + 500), 5000 );
        }
    }
    if ( isdefined( var_teleport_spot ) )
    {
        var_new_height = var_teleport_spot[2];
        if ( !self isonground() )
        {
            var_new_height = self.origin[2];
            if ( var_new_height < ( var_teleport_spot[2] + 500 ) )
            {
                var_new_height = var_teleport_spot[2] + 1000;
            }
        }
        else
        {
            var_new_height = var_teleport_spot[2] + 20;
        }
        var_new_origin = ( var_teleport_spot[0], var_teleport_spot[1], var_new_height );
        self setorigin( var_new_origin );
        if ( !self isonground() )
        {
            self botsetscriptgoal( var_teleport_spot, 128, "critical" );
        }
    }
}

get_nearest_entity_to_avoid()
{
    var_nearest = undefined;
    var_min_dist = 999999;
    foreach ( var_player in level.players )
    {
        if ( var_player == self )
        continue;
        if ( !isalive( var_player ) )
        continue;
        var_dist = distance( self.origin, var_player.origin );
        if ( var_dist < var_min_dist )
        {
            var_min_dist = var_dist;
            var_nearest = var_player;
        }
    }
    return var_nearest;
}

bot_caution_on_respawn()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    if ( !is_wz_mode() || is_plunder_mode() )
    {
        self.bot_is_cautious = 0;
        return;
    }
    if ( getdvarint( "bot_caution", 1 ) == 0 )
    return;
    if ( isdefined( level.endgame_has_started ) && level.endgame_has_started )
    return;
    self notify( "caution_behavior_start" );
    self endon( "caution_behavior_start" );
    self endon( "cancel_caution" );
    self thread watch_caution_damage();
    self.bot_is_cautious = 1;
    if ( !self isonground() )
    {
        while ( !self isonground() )
        {
            self.ignoreall = 1;
            self.ignoreme = 0;
            if ( self isparachuting() )
            {
                self delayed_scatter_teleport();
                break;
            }
            wait 0.1;
        }
    }
    else
    {
        self delayed_scatter_teleport();
    }
    var_end_time = gettime() + 25000;
    var_recalc_time = 0;
    while ( gettime() < var_end_time )
    {
        if ( isdefined( level.endgame_has_started ) && level.endgame_has_started )
        break;
        if ( isdefined( self.bot_is_fleeing_gas ) && self.bot_is_fleeing_gas )
        {
            wait 0.1;
            continue;
        }
        self.ignoreall = 1;
        self.ignoreme = 1;
        self botsetflag( "force_sprint", 1 );
        if ( gettime() >= var_recalc_time )
        {
            var_threat = self get_nearest_entity_to_avoid();
            if ( isdefined( var_threat ) )
            {
                var_distance = distance2d( self.origin, var_threat.origin );
                if ( var_distance < 3000 )
                {
                    var_dir_away = vectornormalize( self.origin - var_threat.origin );
                    var_run_target = self.origin + ( var_dir_away * 1500 );
                    var_safe_point = botgetclosestnavigablepoint( var_run_target, 500 );
                    if ( isdefined( var_safe_point ) )
                    {
                        self botsetscriptgoal( var_safe_point, 128, "critical" );
                        var_recalc_time = gettime() + 2000;
                    }
                }
            }
        }
        wait 0.1;
    }
    self clear_bot_caution();
}

watch_caution_damage()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "caution_behavior_start" );
    self endon( "cancel_caution" );
    for(;;)
    {
        self waittill( "damage", amount, attacker );
        if ( isdefined( attacker ) && isplayer( attacker ) )
        {
            var_chance = 100;
            if ( !isbot( attacker ) )
            {
                var_chance = 50;
            }
            if ( randomint( 100 ) < var_chance )
            {
                self clear_bot_caution();
                self notify( "cancel_caution" );
                break;
            }
        }
    }
}

clear_bot_caution()
{
    self.bot_is_cautious = 0;
    self.ignoreall = 0;
    self.ignoreme = 0;
    self botsetflag( "force_sprint", 0 );
    self botclearscriptgoal();
}

bot_infil_flee()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    if ( !is_wz_mode() || is_plunder_mode() )
    {
        self.bot_is_cautious = 0;
        return;
    }
    if ( getdvarint( "bot_infil_caution", 1 ) == 0 )
    return;
    self notify( "infil_flee_start" );
    self endon( "infil_flee_start" );
    self.bot_is_cautious = 1;
    if ( !self isonground() )
    {
        while ( !self isonground() )
        {
            self.ignoreall = 0;
            self.ignoreme = 0;
            if ( self isparachuting() )
            {
                self delayed_scatter_teleport();
                break;
            }
            wait 0.1;
        }
    }
    else
    {
        self delayed_scatter_teleport();
    }
    var_end_time = gettime() + 40000;
    var_recalc_time = 0;
    while ( gettime() < var_end_time )
    {
        if ( isdefined( self.bot_is_fleeing_gas ) && self.bot_is_fleeing_gas )
        {
            wait 0.1;
            continue;
        }
        self.ignoreall = 0;
        self.ignoreme = 0;
        self botsetflag( "force_sprint", 1 );
        if ( gettime() >= var_recalc_time )
        {
            var_threat = self get_nearest_entity_to_avoid();
            if ( isdefined( var_threat ) )
            {
                var_distance = distance2d( self.origin, var_threat.origin );
                if ( var_distance < 3000 )
                {
                    var_dir_away = vectornormalize( self.origin - var_threat.origin );
                    var_run_target = self.origin + ( var_dir_away * 1500 );
                    var_safe_point = botgetclosestnavigablepoint( var_run_target, 500 );
                    if ( isdefined( var_safe_point ) )
                    {
                        self botsetscriptgoal( var_safe_point, 128, "critical" );
                        var_recalc_time = gettime() + 2000;
                    }
                }
            }
        }
        wait 0.1;
    }
    self.bot_is_cautious = 0;
    self.ignoreall = 0;
    self.ignoreme = 0;
    self botsetflag( "force_sprint", 0 );
    self botclearscriptgoal();
}

watch_for_endgame()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    self waittill( "respawn_disabled" );
    if ( !istrue( level.endgame_has_started ) )
    {
        level.endgame_has_started = 1;
    }
}

bot_gas_survival_tracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.bot_is_fleeing_gas = 0;
    self.bot_last_stim_time = 0;
    for(;;)
    {
        wait 1.0;
        if ( self isinfreefall() || self isparachuting() )
        continue;
        if ( !isdefined( level.br_circle ) || !isdefined( level.br_circle.dangercircleent ) )
        continue;
        var_gas_center = ( level.br_circle.dangercircleent.origin[0], level.br_circle.dangercircleent.origin[1], 0 );
        var_gas_radius = level.br_circle.dangercircleent.origin[2];
        var_dist_to_center = distance2d( self.origin, var_gas_center );
        if ( var_dist_to_center > ( var_gas_radius - 500 ) )
        {
            if ( !self.bot_is_fleeing_gas )
            {
                self.bot_is_fleeing_gas = 1;
                self botclearscriptgoal();
                self botclearscriptenemy();
            }
            self.ignoreall = 0;
            self botsetflag( "force_sprint", 1 );
            var_safe_point = botgetclosestnavigablepoint( var_gas_center, 3000 );
            if ( isdefined( var_safe_point ) )
            {
                self botsetscriptgoal( var_safe_point, 256, "critical" );
            }
            if ( self.health <= 50 )
            {
                if ( gettime() >= ( self.bot_last_stim_time + 5000 ) )
                {
                    var_stim_info = scripts\mp\equipment::getequipmenttableinfo( "equip_adrenaline" );
                    if ( isdefined( var_stim_info ) && isdefined( var_stim_info.objweapon ) )
                    {
                        if ( self getweaponammoclip( var_stim_info.objweapon ) > 0 )
                        {
                            self botpressbutton( "tactical" );
                            self.bot_last_stim_time = gettime();
                        }
                    }
                }
            }
        }
        else
        {
            if ( self.bot_is_fleeing_gas )
            {
                self.bot_is_fleeing_gas = 0;
                self.ignoreall = 0;
                self botsetflag( "force_sprint", 0 );
                self botclearscriptgoal();
            }
        }
    }
}

check_for_nearby_squadmates()
{
    if ( !isdefined( level.teambased ) || !level.teambased )
    return undefined;
    foreach ( entity in level.players )
    {
        if ( entity == self )
        continue;
        if ( !isalive( entity ) )
        continue;
        if ( entity.team != self.team )
        continue;
        if ( distance( self.origin, entity.origin ) < 2000 )
        {
            return entity;
        }
    }
    return undefined;
}

bot_stim_survival_tracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    for (;;)
    {
        self waittill( "damage" );
        if ( self.health <= 90 )
        {
            var_stim_info = scripts\mp\equipment::getequipmenttableinfo( "equip_adrenaline" );
            if ( isdefined( var_stim_info ) && isdefined( var_stim_info.objweapon ) )
            {
                var_ammo = self getweaponammoclip( var_stim_info.objweapon );
                if ( var_ammo > 0 )
                {
                    if ( randomint( 100 ) < 30 )
                    {
                        self botpressbutton( "tactical" );
                        wait 5.0;
                    }
                }
            }
        }
    }
}

bot_medic_tracker()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self.is_currently_reviving = 0;
    for (;;)
    {
        wait 1.0;
        if ( istrue( self.is_currently_reviving ) )
        continue;
        var_patient = undefined;
        var_best_dist = 4000;
        foreach ( player in level.players )
        {
            if ( player == self || !isalive( player ) )
            continue;
            if ( isdefined( player.team ) && isdefined( self.team ) && player.team != self.team )
            continue;
            if ( istrue( player.inlaststand ) || istrue( player.laststand ) )
            {
                var_dist = distance( self.origin, player.origin );
                if ( var_dist < var_best_dist )
                {
                    var_best_dist = var_dist;
                    var_patient = player;
                }
            }
        }
        if ( isdefined( var_patient ) )
        {
            self thread execute_fake_revive( var_patient );
        }
    }
}

execute_fake_revive( var_patient )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "medic_interrupted" );
    self.is_currently_reviving = 1;
    self.is_currently_tracking = 0;
    self botclearscriptgoal();
    self.ignoreall = 0;
    self botsetflag( "force_sprint", 1 );
    var_timeout = gettime() + 15000;
    while( isdefined( var_patient ) && isalive( var_patient ) && ( istrue( var_patient.inlaststand ) || istrue( var_patient.laststand ) ) && distance( self.origin, var_patient.origin ) > 100 && gettime() < var_timeout )
    {
        self botsetscriptgoal( var_patient.origin, 64, "critical" );
        wait 0.25;
    }
    if ( isdefined( var_patient ) && isalive( var_patient ) && ( istrue( var_patient.inlaststand ) || istrue( var_patient.laststand ) ) && distance( self.origin, var_patient.origin ) <= 100 )
    {
        self botsetflag( "force_sprint", 0 );
        self botsetstance( "crouch" );
        self disableweapons();
        self botsetflag( "disable_movement", 1 );
        self botsetscriptgoal( self.origin, 16, "critical" );
        self thread watch_medic_interrupt();
        var_revive_ticks = 0;
        while ( var_revive_ticks < 45 && isdefined( var_patient ) && isalive( var_patient ) && ( istrue( var_patient.inlaststand ) || istrue( var_patient.laststand ) ) )
        {
            wait 0.1;
            var_revive_ticks++;
        }
        if ( var_revive_ticks >= 45 && isdefined( var_patient ) && ( istrue( var_patient.inlaststand ) || istrue( var_patient.laststand ) ) )
        {
            var_patient scripts\mp\laststand::playanim_aibegindismountturret( "use_hold_revive_success", self );
            if ( isdefined( var_patient.laststandreviveent ) )
            {
                var_patient.laststandreviveent makeunusable();
                wait 0.05;
                if ( isdefined( var_patient.laststandreviveent ) )
                {
                    var_patient.laststandreviveent delete();
                }
            }
            var_patient notify( "revived" );
            var_patient setlaststandenabled( 0 );
            var_patient.inlaststand = 0;
            var_patient.laststand = 0;
            if ( isbot( var_patient ) )
            {
                var_patient thread bot_post_revive_flee();
            }
        }
    }
    self notify( "medic_finished" );
    self botsetstance( "stand" );
    self botclearscriptgoal();
    self enableweapons();
    self botsetflag( "disable_movement", 0 );
    self botsetscriptgoal( self.origin, 128, "objective" );
    wait 0.1;
    self botclearscriptgoal();
    self.is_currently_reviving = 0;
}

watch_medic_interrupt()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "medic_finished" );
    self waittill( "damage" );
    self botsetstance( "stand" );
    self enableweapons();
    self botsetflag( "disable_movement", 0 );
    self botclearscriptgoal();
    self.is_currently_reviving = 0;
    self botsetscriptgoal( self.origin, 128, "objective" );
    wait 0.1;
    self botclearscriptgoal();
    self notify( "medic_interrupted" );
}

bot_post_revive_flee()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    self notify( "post_revive_flee_start" );
    self endon( "post_revive_flee_start" );
    self.bot_is_cautious = 1;
    var_end_time = gettime() + 10000;
    var_recalc_time = 0;
    while ( gettime() < var_end_time )
    {
        if ( isdefined( self.bot_is_fleeing_gas ) && self.bot_is_fleeing_gas )
        {
            wait 0.1;
            continue;
        }
        self.ignoreall = 0;
        self.ignoreme = 0;
        self botsetflag( "force_sprint", 1 );
        if ( gettime() >= var_recalc_time )
        {
            var_threat = self get_nearest_entity_to_avoid();
            if ( isdefined( var_threat ) )
            {
                var_distance = distance2d( self.origin, var_threat.origin );
                if ( var_distance < 3000 )
                {
                    var_dir_away = vectornormalize( self.origin - var_threat.origin );
                    var_run_target = self.origin + ( var_dir_away * 1500 );
                    var_safe_point = botgetclosestnavigablepoint( var_run_target, 500 );
                    if ( isdefined( var_safe_point ) )
                    {
                        self botsetscriptgoal( var_safe_point, 128, "critical" );
                        var_recalc_time = gettime() + 2000;
                    }
                }
            }
        }
        wait 0.1;
    }
    self.bot_is_cautious = 0;
    self botsetflag( "force_sprint", 0 );
    self botclearscriptgoal();
}
