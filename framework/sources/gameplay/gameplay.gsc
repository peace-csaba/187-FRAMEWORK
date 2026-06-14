// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: gameplay.gsc

////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Message From Peace — to IW8MOD Community

// I've stayed quiet for a while, but I think it's time to address a few things regarding the 187-Framework.
// Over the past few months, there has been a lot of unnecessary drama, accusations, and negativity coming from certain members of the IW8Mod community. Some people have been quick to label everything as "AI slop" while at the same time taking inspiration from, reusing, or building upon systems, ideas, and concepts that originated from 187-framework project.
// Let's be real: you don't have to like me personally, and that's completely fine. But that doesn't change the amount of work, time, and effort that goes into building and maintaining a framework like this.

// Countless hours have gone into coding, testing, debugging, fixing crashes, reworking systems, and constantly improving the experience for the community.
// What I find disappointing is that instead of focusing on development and helping the modding scene grow, some people would rather spend their time spreading misinformation, creating drama, and turning communities against each other.
// 187-Framework has always been an open-source project. Like many projects in the Call of Duty modding scene, some systems are inspired by public resources and community work. The difference is that they are rewritten, expanded, improved, and integrated into something much larger.

// Taking inspiration is normal.
// Pretending other people's work doesn't exist is not.

// At the end of the day, I'm not interested in fighting with anyone from IW8Mod or any other community.
// I'm focused on moving forward.

// Major parts of the framework are currently being reworked, improved, optimized, and rebuilt from the ground up.
// Despite that, some people continue claiming that I'm "stealing code" while ignoring the work that is publicly available for everyone to see.

// If you don't like the project, that's completely fine.
// If you don't want to use it, that's your choice.

// But please stop the personal attacks, stop the misinformation, and stop turning development into community politics.
// The Call of Duty modding scene is already small enough. We should be building things together, sharing knowledge, and helping each other improve—not tearing each other down.

// — Best regards, ~ Peace, creator of the 187-Framework ->

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Entry point: initializes DVARs and starts all global Better Plunder threads.
init()
{

    if ( getdvar( "scr_br_gametype", "" ) != "dmz" )
    {
        return;
    }

    setdvarifuninitialized( "fw_movespeed", "1.0" );
    setdvarifuninitialized( "fw_inftacsprint", 0 );

    setdvarifuninitialized( "fw_playring", 1 );
    setdvarifuninitialized( "fw_ring_poi", "prison" );
    setdvarifuninitialized( "fw_ring_timer", "5" );

    setdvarifuninitialized( "fw_matchinfo_interval", "120" );
    setdvarifuninitialized( "fw_matchinfo_flags", "15" );
    setdvarifuninitialized( "fw_matchinfo_trigger", "0" );

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
    level thread monitorGameplayCommandMessages();
}

////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////

// Empty callback replacing normal time-limit behavior.
ignoreTimeLimitCallback()
{
    return;
}

////////////////////////////////////////////////////////////////////////

// Resets per-player state on every spawn and starts player-side systems.
playerSpawnLoop()
{

    self endon( "disconnect" );
    level endon( "game_ended" );
for (;;)
    {
        self waittill( "spawned_player" );

        self thread moveSpeedLoop();
        self setmovespeedscale( 1.0 );
        self.is_out_of_bounds = 0;
        self thread infiniteTacSprintLoop();
        self thread playRingMonitor();
        self thread deleteDroppedLootNearDeath();
        self thread initialPoiTeleport();
    }
}

////////////////////////////////////////////////////////////////////////

// Optional global move speed control through fw_movespeed.
moveSpeedLoop()
{
    self endon( "disconnect" );
    self endon( "death" );

    lastScale = undefined;

    for (;;)
    {
        scale = getdvarfloat( "fw_movespeed", 1.0 );

        if ( !isdefined( scale ) || scale <= 0 )
            scale = 1.0;

        if ( scale < 0.25 )
            scale = 0.25;

        if ( scale > 3.0 )
            scale = 3.0;

        if ( !isdefined( lastScale ) || lastScale != scale )
        {
            self setmovespeedscale( scale );
            lastScale = scale;
        }

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

// Optional global infinite tac sprint loop through fw_inftacsprint.
infiniteTacSprintLoop()
{
    self notify( "fw_supersprintloop" );
    self endon( "fw_supersprintloop" );
    self endon( "disconnect" );
    self endon( "death" );

    for (;;)
    {
        if ( getdvarint( "fw_inftacsprint", 0 ) == 1 )
        {
            self refreshsprinttime( 2.5 );
            wait 0.05;
        }
        else
        {
            wait 0.25;
        }
    }
}

////////////////////////////////////////////////////////////////////////

// Returns a clean display name for the configured play area.
getPoiDisplayName( var_poi )
{
    var_poi = tolower( var_poi );

    switch ( var_poi )
    {
        case "control":
            return "Control Center";

        case "factory":
            return "Factory";

        case "bio":
            return "Bio";

        case "tents":
            return "Tents";

        case "prison":
        default:
            return "Prison";
    }
}

////////////////////////////////////////////////////////////////////////

// Returns center coordinates for the configured play area POI.
getPoiCenter(  var_poi  )
{
    var_poi = tolower( getdvar( "fw_ring_poi", "prison" ) );

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

////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////

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
            player custom_scripts\framework\sources\core\ui::prefixPrintBold( "^7[Gameplay]^7 » ^3core/gameplay.gsc — activates in 15 seconds!" );
            player playlocalsound( "ui_mp_timer_countdown" );
        }
    }

    wait 15;

    level.infil_grace_period = 0;

    foreach ( player in level.players )
    {
        if ( isdefined( player ) && !isbot( player ) )
        {
            player custom_scripts\framework\sources\core\ui::prefixPrintBold( "^7[Gameplay]^7 » ^2core/gameplay.gsc — is active now!" );
            player playlocalsound( "br_circle_closing_warning" );
        }
    }
}

////////////////////////////////////////////////////////////////////////

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
        if ( getdvarint( "fw_playring", 1 ) == 0 )
        {
            if ( istrue( self.is_out_of_bounds ) )
            {
                self notify( "returned_to_play_area" );
        self.is_out_of_bounds = 0;
            }
            wait 1.0;
            continue;
        }

        var_poi = tolower( getdvar( "fw_ring_poi", "prison" ) );
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
                    self setorigin( var_target_pos + ( 0, 0, 150 ) );
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
                    self custom_scripts\framework\sources\core\ui::prefixPrintBold( "^5[AREA]^7 » ^2You returned to the play area." );
                }
            }
        }

        wait 0.25; 
    }
}

////////////////////////////////////////////////////////////////////////

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
            var_max_time = getdvarint( "fw_ring_timer", 5 );
            var_time_spent = 0;
            while ( istrue( self.is_out_of_bounds ) && isalive( self ) )
            {
                var_time_left = var_max_time - var_time_spent;
                self custom_scripts\framework\sources\core\ui::prefixPrintBold( "^5[Area]^7 » ^1Return to the play area:^7 " + var_time_left + "s" );

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

////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////

// Prints 187-style messages when gameplay commands are changed in-game.
monitorGameplayCommandMessages()
{
    level endon( "game_ended" );

    lastMoveSpeed = getdvar( "fw_movespeed", "1.0" );
    lastTacSprint = getdvarint( "fw_inftacsprint", 0 );
    lastPlayRing = getdvarint( "fw_playring", 1 );
    lastRingPoi = getdvar( "fw_ring_poi", "prison" );
    lastRingTimer = getdvar( "fw_ring_timer", "5" );
    lastMatchInfoInterval = getdvar( "fw_matchinfo_interval", "120" );
    lastMatchInfoFlags = getdvar( "fw_matchinfo_flags", "15" );

    for (;;)
    {
        wait 0.5;

        currentMoveSpeed = getdvar( "fw_movespeed", "1.0" );
        if ( currentMoveSpeed != lastMoveSpeed )
        {
            lastMoveSpeed = currentMoveSpeed;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                    player custom_scripts\framework\sources\core\ui::prefixPrint( "^5[GAMEPLAY]^7 » ^5Move Speed:^7 " + currentMoveSpeed );
            }
        }

        currentTacSprint = getdvarint( "fw_inftacsprint", 0 );
        if ( currentTacSprint != lastTacSprint )
        {
            lastTacSprint = currentTacSprint;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {
                    if ( currentTacSprint == 1 )
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^5[COMBAT]^7 » ^2Infinite Tactical Sprint:^7 ^2Enabled" );
                    else
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^5[COMBAT]^7 » ^2Infinite Tactical Sprint:^7 ^1Disabled" );
                }
            }
        }

        currentPlayRing = getdvarint( "fw_playring", 1 );
        if ( currentPlayRing != lastPlayRing )
        {
            lastPlayRing = currentPlayRing;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {
                    if ( currentPlayRing == 1 )
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^5[AREA]^7 » ^2Play Ring:^7 ^2Enabled" );
                    else
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^5[AREA]^7 » ^2Play Ring:^7 ^1Disabled" );
                }
            }
        }

        currentRingPoi = getdvar( "fw_ring_poi", "prison" );
        if ( currentRingPoi != lastRingPoi )
        {
            lastRingPoi = currentRingPoi;
            currentPoiName = getPoiDisplayName( currentRingPoi );

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {
                    player iprintln(
                        level.prefix +
                        "^1[DVAR]^7 » ^2Play Area:^7 ^3" +
                        currentPoiName +
                        " ^7(updated)"
                    );
                }
            }
        }

        currentRingTimer = getdvar( "fw_ring_timer", "5" );
        if ( currentRingTimer != lastRingTimer )
        {
            lastRingTimer = currentRingTimer;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {
                    player iprintln(
                        level.prefix +
                        "^1[DVAR]^7 » ^2Play Area Return Interval:^7 ^3" +
                        currentRingTimer +
                        "s ^7(updated)"
                    );
                }
            }
        }

        currentMatchInfoInterval = getdvar( "fw_matchinfo_interval", "120" );
        if ( currentMatchInfoInterval != lastMatchInfoInterval )
        {
            lastMatchInfoInterval = currentMatchInfoInterval;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {
                    player iprintln(
                        level.prefix +
                        "^1[DVAR]^7 » ^2Gameplay Messages Interval:^7 ^3" +
                        currentMatchInfoInterval +
                        "s ^7(updated)"
                    );
                }
            }
        }

        currentMatchInfoFlags = getdvar( "fw_matchinfo_flags", "15" );
        if ( currentMatchInfoFlags != lastMatchInfoFlags )
        {
            lastMatchInfoFlags = currentMatchInfoFlags;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {
                    player iprintln(
                        level.prefix +
                        "^1[DVAR]^7 » ^2Gameplay Info Flags:^7 ^3" +
                        currentMatchInfoFlags +
                        " ^7(updated)"
                    );
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////

// Match-info print by toggling fw_matchinfo_trigger.
monitorManualMatchInfoTrigger()
{
    level endon( "game_ended" );

    var_last_print_time = gettime();

    for (;;)
    {
        var_manual_trigger = getdvarint( "fw_matchinfo_trigger", 0 );
        var_interval = getdvarint( "fw_matchinfo_interval", 0 );
        var_should_print = 0;

        if ( var_manual_trigger == 1 )
        {
            setdvar( "fw_matchinfo_trigger", "0" );
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
            var_flags = getdvarint( "fw_matchinfo_flags", 15 );

            var_host = "Unknown";
            foreach ( player in level.players )
            {
                if ( isdefined( player ) && player ishost() )
                {
                    var_host = player.name;
                    break;
                }
            }

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

            var_time_sec = int( gettime() / 1000 );
            var_mins = int( var_time_sec / 60 );
            var_secs = var_time_sec % 60;

            var_sec_str = var_secs;
            if ( var_secs < 10 )
                var_sec_str = "0" + var_secs;

            var_real_players = 0;
            var_bots = 0;

            foreach ( player in level.players )
            {
                if ( isdefined( player ) )
                {
                    if ( isbot( player ) )
                        var_bots++;
                    else
                        var_real_players++;
                }
            }

            var_poi = tolower( getdvar( "fw_ring_poi", "prison" ) );
            var_poi_name = getPoiDisplayName( var_poi );

            foreach ( player in level.players )
            {
                if ( isdefined( player ) && !isbot( player ) )
                {

                    player custom_scripts\framework\sources\core\ui::prefixPrint( "^7[Area]^7 » ^2Current Play Area is ^7" + var_poi_name + "^2." );

                    if ( var_flags & 1 )
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^7[Host]^7 » ^3Owner:^7 " + var_host );

                    if ( var_flags & 4 )
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^7[Host]^7 » ^5Running since:^7 " + var_mins + "^3 - Minutes" );

                    if ( var_flags & 2 )
                    {
                        if ( isdefined( var_leader ) )
                            player custom_scripts\framework\sources\core\ui::prefixPrint( "^7[Host]^7 » ^1Kill Leader:^7 " + var_leader.name + " ^3(" + var_highest + " Kills)" );
                        else
                            player custom_scripts\framework\sources\core\ui::prefixPrint( "^7[Host]^7 » ^1Kill Leader:^7 None" );
                    }

                    if ( var_flags & 8 )
                        player custom_scripts\framework\sources\core\ui::prefixPrint( "^5[Online]^7 » ^2Players:^7 " + var_real_players + " ^7• ^3Bots:^7 " + var_bots );
                }
            }
        }

        wait 1.0;
    }
}

////////////////////////////////////////////////////////////////////////

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

    if ( getdvarint( "fw_playring", 1 ) == 1 )
    {
        var_poi = tolower( getdvar( "fw_ring_poi", "prison" ) );
        var_center = getPoiCenter( var_poi );
        var_poi_name = getPoiDisplayName( var_poi );
        var_offset_x = randomintrange( -1500, 1500 );
        var_offset_y = randomintrange( -1500, 1500 );
        var_teleport_pos = ( var_center[0] + var_offset_x, var_center[1] + var_offset_y, self.origin[2] );
        self setorigin( var_teleport_pos );

        //self custom_scripts\framework\sources\core\ui::prefixPrint( "^5[AREA]^7 » ^2Current Play Area is ^7" + var_poi_name + "^2." );

        self custom_scripts\framework\sources\core\ui::prefixPrintBold( "^5[AREA]^7 » ^2Current Play Area ^7 »" + var_poi_name + "^2." );
    }
}