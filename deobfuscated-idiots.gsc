// ============================================================
// betterplunder_FULL_DECRYPTED.gsc
// Cleaned / reverse-engineered from uploaded betterplunder.gsc
//
// Notes:
// - Obfuscated local one-character string-builder variables were removed.
// - Event names, DVAR names, messages, map names and POI data were reconstructed.
// - Function names were renamed by inferred behavior.
// - Gameplay logic is preserved as closely as possible.
// - Added missing bp_movespeed default found during review.
// - This is intended for study/mod maintenance; test in your dev environment.
// ============================================================

// Entry point: initializes DVARs and starts all global Better Plunder threads.
init()
{

    if ( getdvar( "scr_br_gametype", "" ) != "dmz" )
    {
        return;
    }

    setdvarifuninitialized( "bp_rewardspeed", 0 );
    setdvarifuninitialized( "bp_rewardspeed_speed", "1.35" );
    setdvarifuninitialized( "bp_rewardspeed_length", "5" );
    setdvarifuninitialized( "bp_movespeed", "1.0" );
    setdvarifuninitialized( "bp_rewardperks", 0 );
    setdvarifuninitialized( "bp_rewardperks_maxperks", "4" );
    setdvarifuninitialized( "bp_rewardperks_specialist", 1 );
    setdvarifuninitialized( "bp_inftacsprint", 0 );

    setdvarifuninitialized( "bp_playring", 1 );
    setdvarifuninitialized( "bp_ring_poi", "prison" );
    setdvarifuninitialized( "bp_ring_timer", "5" );

    setdvarifuninitialized( "bp_infequip", 1 );
    setdvarifuninitialized( "bp_infequip_delay", "5" ); 
    setdvarifuninitialized( "bp_inf_guns", 1 );
    setdvarifuninitialized( "bp_inf_lethals", 1 );
    setdvarifuninitialized( "bp_inf_tac", 1 );
    setdvarifuninitialized( "bp_inf_plates", 1 );

    setdvarifuninitialized( "bp_allowsupers", 0 );
    setdvarifuninitialized( "bp_matchinfo_interval", "120" );
    setdvarifuninitialized( "bp_matchinfo_flags", "15" );
    setdvarifuninitialized( "bp_matchinfo_trigger", "0" );

    if ( isdefined( level.script ) )
    {
        level.is_escape_map = ( level.script == "mp_escape2" || level.script == "mp_escape3" || level.script == "mp_escape4" );
    }
    else
    {
        level.is_escape_map = 0; 
    }

    level thread monitorMatchInfo();
    level thread setupPlunderDvars();
    level thread preventMatchEndLoop();
    level thread onPlayerConnectedLoop();
    level thread monitorManualMatchInfoTrigger();
    level thread blockSupersLoop();
}

// Starts per-player spawn logic whenever a player connects.
onPlayerConnectedLoop()
{

    level endon( "game_ended" );

    for (;;)
    {
        level waittill( "connected", player );
        player thread playerSpawnLoop();
    }
}

// Sets Plunder/DMZ rule DVARs: high score limits, no overtime, no normal win condition.
setupPlunderDvars()
{
    setdvar( "scr_dmz_win_cost", 2000000 ); 
    setdvar( "scr_br_scorelimit", 2000000000 );
    setdvar( "scr_bmo_eom_ot_timer", 0 );
    setdvar( "scr_bmo_useMilestonePhases", 0 );
    setdvar( "scr_dmz_lc_active", 0 ); 
    setdvar( "br_min_plunder_extractions", 0 );
    setdvar( "br_max_plunder_extractions", 0 );
    setdvar( "scr_bmo_disable_win_on_score", 1 );
    setdvar( "scr_bmo_disable_one_mil_announce", 1 );
    setdvar( "scr_bmo_score_requires_banking", 1 );
    setdvar( "scr_bmo_eom_bank_to_end", 0 );
}

// Keeps the match timer paused/extended and prevents normal ending/exfil timing.
preventMatchEndLoop()
{

    level endon( "game_ended" );
    level.ontimelimit = ::ignoreTimeLimitCallback;

    for (;;)
    {
        scripts\mp\gamelogic::pausetimer();
        setgameendtime( gettime() + 3600000 );
        setdvar( "scr_br_timelimit", 0 );
        setdvar( "scr_bmo_exfil_timer", 0 );
        setdvar( "LKMOLLSKKO", 99999999 );
        level.lootcontentsadjusteconomy_bottomtier = 999999999; 
        level.scorelimit = 999999999;
        level.make_bomb_detonator_interact = 0; 
        level._id_12CB4 = 1; 
        level.checkpoint_objective_id = 0; 
        level.start_persistent_turbulence = 0; 
        setdvar( "scr_bmo_squad_wiped_stream_time", 0 );
        setdvar( "scr_bmo_respawn_predict_hint_time", 0 );
        setdvar( "scr_bmo_respawn_intermission_time", 0 );
        setdvar( "scr_br_extract_spawn_wait", 0 );
        wait 1.0; 
    }
}

// Empty callback replacing normal time-limit behavior.
ignoreTimeLimitCallback()
{
    return;
}

// Resets per-player state on every spawn and starts player-side systems.
playerSpawnLoop()
{

    self endon( "disconnect" );
    level endon( "game_ended" );
    self thread killRewardLoop();

    for (;;)
    {
        self waittill( "spawned_player" );
        self.loaded_total_kills = 0;
        self.has_specialist = 0;
        self.loaded_earned_perks = [];
        self.speed_buff_end_time = 0;
        self setmovespeedscale( 1.0 );
        self.is_bp_speed_normalized = 1;
        self.is_out_of_bounds = 0;
        self thread speedBuffWatcher();
        self thread infiniteTacSprintLoop();
        self thread playRingMonitor();
        self thread infiniteEquipmentLoop();
        self thread deleteDroppedLootNearDeath();
        self thread initialPoiTeleport();
    }
}

// Optional kill rewards: movement speed buff, random perks, and Specialist Bonus.
killRewardLoop()
{

    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "got_a_kill" );
        if ( istrue( level.infil_grace_period ) )
        {
            continue; 
        }
        if ( getdvarint( "bp_rewardspeed", 0 ) == 1 )
        {
            var_length = getdvarint( "bp_rewardspeed_length", 5 );
            self.speed_buff_end_time = gettime() + ( var_length * 1000 );
        }
        if ( getdvarint( "bp_rewardperks", 0 ) == 1 )
        {
            if ( !istrue( self.has_specialist ) )
            {
                self.loaded_total_kills++;
                var_max_perks = getdvarint( "bp_rewardperks_maxperks", 4 );
                var_allow_spec = getdvarint( "bp_rewardperks_specialist", 1 );
                if ( var_allow_spec == 1 )
                {
                    if ( self.loaded_total_kills <= var_max_perks )
                    {
                        self thread giveRandomRewardPerk();
                    }
                    else 
                    {
                        self.has_specialist = 1;
                        self iprintlnbold( "^2Specialist Bonus Received!" );
                        self thread giveSpecialistBonus();
                    }
                }
                else
                {
                    self thread giveRandomRewardPerk();
                }
            }
        }
    }
}

// Applies temporary movement speed boost after kills when bp_rewardspeed is enabled.
speedBuffWatcher()
{

    self notify( "new_bp_sprfast_loop" );
    self endon( "new_bp_sprfast_loop" );
    self endon( "disconnect" );
    self endon( "death" ); 

    for (;;)
    {
        var_base_speed = getdvarfloat( "bp_movespeed", 1.0 );
        if ( self islinked() || self isparachuting() || self isinfreefall() || gettime() > self.speed_buff_end_time )
        {
            if ( !isdefined( self.current_speed_scale ) || self.current_speed_scale != var_base_speed )
            {
                self setmovespeedscale( var_base_speed );
                self.current_speed_scale = var_base_speed;
            }
            wait 0.1; 
            continue; 
        }
        var_reward_target = getdvarfloat( "bp_rewardspeed_speed", 1.35 );
        var_bonus = var_reward_target - 1.0; 
        var_buff_speed = var_base_speed + var_bonus;
        self setmovespeedscale( var_buff_speed );
        self.current_speed_scale = var_buff_speed; 

        self refreshsprinttime( 2.5 ); 

        wait 0.05;
    }
}

// Gives one random perk from the reward pool, avoiding duplicates.
giveRandomRewardPerk()
{

    var_perk_pool = [
        "specialty_br_serpentine", "specialty_br_advancedscout", "specialty_br_reinforced",
        "specialty_coldblooded", "specialty_quick_fix", "specialty_eod", 
        "specialty_scavenger", "specialty_hustle", "specialty_warhead", 
        "specialty_surveillance", "specialty_recharge_equipment", "specialty_tac_resist", 
        "specialty_shrapnel", "specialty_tune_up", "specialty_br_cheaper_kiosk", 
        "specialty_br_better_mission_rewards", "specialty_huntmaster"
    ];

    var_available = [];

    foreach ( perk in var_perk_pool )
    {
        if ( !self scripts\mp\utility\perk::_hasperk( perk ) )
        {
            var_available[ var_available.size ] = perk;
        }
    }

    if ( var_available.size > 0 )
    {
        var_chosen = var_available[ randomint( var_available.size ) ];

        self scripts\mp\utility\perk::giveperk( var_chosen );
        self thread scripts\mp\hud_message::showsplash( var_chosen );
        self.loaded_earned_perks[ self.loaded_earned_perks.size ] = var_chosen;

        self iprintlnbold( "^3STREAK: ^7Bonus Perk Acquired!" );
        self playsoundtoplayer( "ui_select_purchase_confirm", self );
    }
}

// Grants the full Specialist perk set.
giveSpecialistBonus()
{

    var_perk_pool = [
        "specialty_br_serpentine", "specialty_br_advancedscout", "specialty_br_reinforced",
        "specialty_coldblooded", "specialty_quick_fix", "specialty_eod", 
        "specialty_scavenger", "specialty_hustle", "specialty_warhead", 
        "specialty_surveillance", "specialty_recharge_equipment", "specialty_tac_resist", 
        "specialty_shrapnel", "specialty_tune_up", "specialty_br_cheaper_kiosk", 
        "specialty_br_better_mission_rewards", "specialty_huntmaster"
    ];

    foreach( perk in var_perk_pool )
    {
        if ( !self scripts\mp\utility\perk::_hasperk( perk ) )
        {
            self scripts\mp\utility\perk::giveperk( perk );
        }
    }
    self thread scripts\mp\hud_message::showsplash( "specialist_perk_bonus" );
    self playsoundtoplayer( "br_legendary_loot_pickup", self );
}

// Restores earned random perks/Specialist after a delay. Note: original script defines this but does not appear to thread it.
restoreEarnedPerksAfterSpawn()
{

    self endon( "disconnect" );
    self endon( "death" );

    wait 2.5; 
    if ( istrue( self.has_specialist ) )
    {
        self thread giveSpecialistBonus();
    }
    else if ( isdefined( self.loaded_earned_perks ) && self.loaded_earned_perks.size > 0 )
    {
        foreach ( perk in self.loaded_earned_perks )
        {
            if ( !self scripts\mp\utility\perk::_hasperk( perk ) )
            {
                self scripts\mp\utility\perk::giveperk( perk );
            }
        }
        self iprintln( "^2Earned Perks Restored: ^7" + self.loaded_earned_perks.size + "/4" );
    }
}

// Optional infinite tactical sprint loop.
infiniteTacSprintLoop()
{

    self notify( "bp_supersprintloop" );
    self endon( "bp_supersprintloop" );
    self endon( "disconnect" );
    self endon( "death" ); 
    for (;;)
    {
        if ( getdvarint ( "bp_inftacsprint", 0 ) == 1 )
        {
        self refreshsprinttime( 2.5 ); 
        }
        wait 0.05;
    }
}

// Returns center coordinates for the configured play area POI.
getPoiCenter(  var_poi  )
{
    var_poi = tolower( getdvar( "bp_ring_poi", "prison" ) );

    switch ( var_poi )
    {
        case "control":
            return ( -3197.04, -3169.5, 681.125 );

        case "factory":
            return ( 3802.05, -1786.36, 280.122 );

        case "bio":
            return ( -2115.12, 10644.8, 664.055 );

        case "tents":
            return ( -907.435, -5728.5, 686.595 );

        case "prison":
        default:
            return ( 203, -1326, 1392 );
    }
}

// Returns ring radius for the configured play area POI.
getPoiRadius(  var_poi  )
{
    switch ( var_poi )
    {
        case "control":
            return 2000;

        case "factory":
            return 2000;

        case "bio":
            return 1600;

        case "tents":
        return 1900;

        case "prison":
        default:
            return 2950;
    }
}

// Handles ring activation after host deploys, then periodically prints match info.
monitorMatchInfo()
{

    level endon( "game_ended" );

    level.infil_grace_period = 1;
    if ( !scripts\mp\flags::gameflag( "prematch_done" ) )
    {
        level waittill( "prematch_done" );
    }
    var_host = undefined;
    while ( !isdefined( var_host ) )
    {
        foreach ( player in level.players )
        {
            if ( isdefined( player ) && player ishost() )
            {
                var_host = player;
                break;
            }
        }
        wait 0.5;
    }
    var_host waittill( "infil_jump_done" );
    foreach ( player in level.players )
    {
        if ( isdefined( player ) && !isbot( player ) )
        {
            player iprintlnbold( "^3HOST DEPLOYED: ^7Ring activates in 15 seconds!" );
            player playlocalsound( "ui_mp_timer_countdown" );
        }
    }

    wait 15;

    level.infil_grace_period = 0;

    foreach ( player in level.players )
    {
        if ( isdefined( player ) && !isbot( player ) )
        {
            player iprintlnbold( "^1THE PLAY AREA IS NOW ACTIVE!" );
            player playlocalsound( "br_circle_closing_warning" );
        }
    }
}

// Custom play-zone/ring monitor. Kills humans outside; teleports bots back.
playRingMonitor()
{

    self notify( "new_ring_monitor" );
    self endon( "new_ring_monitor" );
    self endon( "disconnect" );
    self endon( "death" ); 
    level endon( "game_ended" );

    for (;;)
    {
        if ( getdvarint( "bp_playring", 1 ) == 0 )
        {
            if ( istrue( self.is_out_of_bounds ) )
            {
                self notify( "returned_to_play_area" );
                self.is_out_of_bounds = 0;
            }
            wait 1.0;
            continue;
        }

        var_poi = tolower( getdvar( "bp_ring_poi", "prison" ) );
        var_center = getPoiCenter( var_poi );
        var_radius = getPoiRadius( var_poi );

        var_player_pos_2d = ( self.origin[0], self.origin[1], 0 );
        var_center_pos_2d = ( var_center[0], var_center[1], 0 );
        var_dist = distance( var_player_pos_2d, var_center_pos_2d );

        if ( var_dist > var_radius )
        {
            if ( istrue( level.infil_grace_period ) || self isparachuting() || self isinfreefall() )
            {
                if ( istrue( self.is_out_of_bounds ) )
                {
                    self notify( "returned_to_play_area" ); 
                    self.is_out_of_bounds = 0;
                }
            }
            else 
            {
                if ( isbot( self ) )
                {
                    var_random_x = randomintrange( -1000, 1000 );
                    var_random_y = randomintrange( -1000, 1000 );
                    var_target_pos = ( var_center[0] + var_random_x, var_center[1] + var_random_y, var_center[2] );
                    var_safe_pos = botgetclosestnavigablepoint( var_target_pos, 500 );

                    if ( isdefined( var_safe_pos ) )
                    {
                        self setorigin( var_safe_pos );
                    }
                    else
                    {
                        self setorigin( var_target_pos + ( 0, 0, 150 ) );
                    }
                }
                else
                {
                    if ( !istrue( self.is_out_of_bounds ) )
                    {
                        self.is_out_of_bounds = 1;
                        self thread outsideRingCountdown();
                    }
                }
            }
        }
        else
        {
            if ( istrue( self.is_out_of_bounds ) )
            {
                self notify( "returned_to_play_area" );
                self.is_out_of_bounds = 0;
                if ( !isbot( self ) )
                {
                    self iprintlnbold( "^2You have returned to the play area." );
                }
            }
        }

        wait 0.25; 
    }
}

// Countdown shown to players outside the configured play area before death.
outsideRingCountdown()
{

    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        if ( istrue( self.is_out_of_bounds ) )
        {
            var_max_time = getdvarint( "bp_ring_timer", 5 );
            var_time_spent = 0;
            while ( istrue( self.is_out_of_bounds ) && isalive( self ) )
            {
                var_time_left = var_max_time - var_time_spent;
                self iprintlnbold( "^1RETURN TO THE PLAY AREA: ^7" + var_time_left + "s" );

                wait 1.0;
                var_time_spent++;
                if ( var_time_spent >= var_max_time )
                {
                    self suicide();
                    break;
                }
            }
        }
        wait 0.5;
    }
}
// Refills ammo, armor plates, lethals, and tacticals based on bp_inf_* DVARs.
infiniteEquipmentLoop()
{

    self notify( "bp_inf_reserve_loop" );
    self endon( "bp_inf_reserve_loop" );
    self endon( "disconnect" );
    self endon( "death" ); 

    var_next_lethal_time = 0;
    var_next_tac_time = 0;
    for (;;)
    {
        if ( getdvarint( "bp_infequip", 1 ) == 0 )
        {
            wait 1.0;
            continue;
        }
        if ( getdvarint( "bp_inf_guns", 1 ) == 1 )
        {
            var_guns = self getweaponslistprimaries();
            foreach ( var_wep in var_guns )
            {
                self givemaxammo( var_wep );
            }
        }
        if ( getdvarint( "bp_inf_plates", 1 ) == 1 )
        {
            if ( isdefined( self.equipment ) && !isdefined( self.equipment["health"] ) )
            {
                self scripts\mp\equipment::giveequipment( "equip_armorplate", "health" );
            }
            self scripts\mp\equipment::incrementequipmentammo( "equip_armorplate", 99 );
        }
        var_delay = getdvarint( "bp_infequip_delay", 0 ) * 1000;

        if ( isdefined( self.equipment ) )
        {
            if ( getdvarint( "bp_inf_lethals", 1 ) == 1 )
            {
                if ( gettime() >= var_next_lethal_time )
                {
                    self scripts\mp\equipment::incrementequipmentslotammo( "primary", 1 );
                    var_next_lethal_time = gettime() + var_delay;
                }
            }
            if ( getdvarint( "bp_inf_tac", 1 ) == 1 )
            {
                if ( gettime() >= var_next_tac_time )
                {
                    self scripts\mp\equipment::incrementequipmentslotammo( "secondary", 1 );
                    var_next_tac_time = gettime() + var_delay;
                }
            }
        }

        wait 1.0; 
    }
}

// Removes loot dropped near the player death position.
deleteDroppedLootNearDeath()
{

    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "death" );
        var_death_pos = self.origin;
        wait 0.1;
        if ( isdefined( level.br_pickups ) && isdefined( level.br_pickups.scriptables ) )
        {
            foreach ( var_item in level.br_pickups.scriptables )
            {
                if ( isdefined( var_item ) && isdefined( var_item.origin ) )
                {
                    if ( distance( var_item.origin, var_death_pos ) < 200 )
                    {
                        if ( isent( var_item ) )
                        {
                            var_item delete();
                        }
                        else
                        {
                            var_item freescriptable();
                        }
                    }
                }
            }
        }
    }
}

// Lets host/admin force match-info print by toggling bp_matchinfo_trigger.
monitorManualMatchInfoTrigger()
{

    level endon( "game_ended" );

    var_last_print_time = gettime();
    for (;;)
    {
        var_manual_trigger = getdvarint( "bp_matchinfo_trigger", 0 );
        var_interval = getdvarint( "bp_matchinfo_interval", 0 );
        var_should_print = 0;

        if ( var_manual_trigger == 1 )
        {
            setdvar( "bp_matchinfo_trigger", "0" ); 
            var_should_print = 1;
            var_last_print_time = gettime(); 
        }
        else if ( var_interval > 0 )
        {
            if ( ( gettime() - var_last_print_time ) >= ( var_interval * 1000 ) )
            {
                var_should_print = 1;
                var_last_print_time = gettime();
            }
        }

        if ( var_should_print )
        {
            var_flags = getdvarint( "bp_matchinfo_flags", 15 );
            if ( var_flags & 1 ) 
            {
                var_host = "Unknown";
                foreach( player in level.players )
                {
                    if ( player ishost() )
                    {
                        var_host = player.name;
                        break;
                    }
                }
                iprintln( "^3MATCH HOST: ^7" + var_host );
            }
            if ( var_flags & 2 ) 
            {
                var_leader = undefined;
                var_highest = -1;
                foreach ( player in level.players )
                {
                    if ( isdefined( player.kills ) && player.kills > var_highest )
                    {
                        var_highest = player.kills;
                        var_leader = player;
                    }
                }
                if ( isdefined( var_leader ) )
                {
                    iprintln( "^1KILL LEADER: ^7" + var_leader.name + " ^3(" + var_highest + " Kills)" );
                }
            }
            if ( var_flags & 4 ) 
            {
                var_time_sec = int( gettime() / 1000 );
                var_mins = int( var_time_sec / 60 );
                var_secs = var_time_sec % 60;

                var_sec_str = var_secs;
                if ( var_secs < 10 ) 
                {
                    var_sec_str = "0" + var_secs;
                }

                iprintln( "^5SERVER RUNTIME: ^7" + var_mins + ":" + var_sec_str );
            }
            if ( var_flags & 8 )
            {
                var_real_players = 0;
                var_bots = 0;

                foreach ( player in level.players )
                {
                    if ( isdefined( player ) )
                    {
                        if ( isbot( player ) )
                        {
                            var_bots++;
                        }
                        else
                        {
                            var_real_players++;
                        }
                    }
                }
                var_count_msg = "^6LOBBY SIZE: ^7There are " + var_real_players + " players";

                if ( var_bots > 0 )
                {
                    var_count_msg = var_count_msg + " and " + var_bots + " bots.";
                }
                else
                {
                    var_count_msg = var_count_msg + ".";
                }

                iprintln( var_count_msg );
            }
        }
        wait 1.0;
    }
}

// After spawn/deployment, teleports player near selected POI if play ring is active.
initialPoiTeleport()
{

    self endon( "disconnect" );
    self endon( "death" );

    if ( istrue( level.infil_grace_period ) )
    {
        return; 
    }
    while ( !self isinfreefall() )
    {
        if ( self isonground() && !self islinked() )
        {
            break;
        }
        wait 0.1;
    }

    if ( getdvarint( "bp_playring", 1 ) == 1 )
    {
        var_poi = tolower( getdvar( "bp_ring_poi", "prison" ) );
        var_center = getPoiCenter( var_poi );
        var_poi_name = "Prison"; 

        switch ( var_poi )
        {
            case "control":
                var_poi_name = "Control Center";
                break;
            case "factory":
                var_poi_name = "Factory";
                break;
            case "bio":
                var_poi_name = "Bio";
                break;
            case "tents":
                var_poi_name = "Tents";
                break;
            case "prison":
            default:
                var_poi_name = "Prison";
                break;
        }
        var_offset_x = randomintrange( -1500, 1500 );
        var_offset_y = randomintrange( -1500, 1500 );
        var_teleport_pos = ( var_center[0] + var_offset_x, var_center[1] + var_offset_y, self.origin[2] );
        self setorigin( var_teleport_pos );

        self iprintln( "^2The current Play Area is ^7" + var_poi_name + "^2." );
    }
}

// Removes super abilities unless bp_allowsupers is enabled.
blockSupersLoop()
{

    level endon( "game_ended" );

    var_was_disabled = 0;

    for (;;)
    {
        var_allow = getdvarint( "bp_allowsupers", 0 );
        if ( var_allow == 0 )
        {
            level.allowsupers = 0;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) )
                {
                    player scripts\common\utility::allow_supers( 0 );
                    player scripts\mp\equipment::takeequipment( "super" );
                    player scripts\mp\supers::clearsuper();
                }
            }
            var_was_disabled = 1;
        }
        else if ( var_was_disabled == 1 && var_allow == 1 )
        {
            level.allowsupers = 1;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) )
                {
                    player scripts\common\utility::allow_supers( 1 );
                }
            }
            var_was_disabled = 0;
        }
        wait 1.0;
    }
}
