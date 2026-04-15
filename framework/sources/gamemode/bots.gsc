// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: bots.gsc

////////////////////////////////////////////////////////////////////////

// Modularized gamemode file: gm_bots

watchaddbotdvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvar( "addbot", "" );

        if ( var_0 != "" )
        {
            setdvar( "addbot", "" );

            if ( !self ishost() )
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1Host only" );
                continue;
            }

            var_1 = int( var_0 );
            var_2 = tolower( getdvar( "bot_team", "autoassign" ) );
            var_3 = parse_team_input( var_2, self );
            var_4 = parse_difficulty_input( getdvar( "bot_difficulty", "" ) );

            if ( var_1 < 1 )
                var_1 = 1;

            if ( var_1 > 100 )
                var_1 = 100;

            scripts\mp\bots\bots::spawn_bots( var_1, var_3, undefined, undefined, undefined, var_4 );
            var_5 = "";

            if ( isdefined( var_4 ) )
                var_5 = " ^2at difficulty: ^7" + var_4;

            var_6 = get_team_display_name( var_3, self );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Spawning ^7" + var_1 + " ^2bot(s) on team: ^7" + var_6 + var_5 );
        }

        wait 0.25;
    }
}

watchkickbotdvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvar( "kickbot", "" );

        if ( var_0 != "" )
        {
            setdvar( "kickbot", "" );

            if ( !self ishost() )
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1Host only" );
                continue;
            }

            var_1 = int( var_0 );
            var_2 = tolower( getdvar( "bot_team", "autoassign" ) );
            var_3 = parse_team_input( var_2, self );
            var_4 = 0;

            if ( var_1 < 1 )
                var_1 = 1;

            foreach ( var_6 in level.players )
            {
                if ( var_4 >= var_1 )
                    break;

                if ( !isbot( var_6 ) )
                    continue;

                if ( var_3 != "autoassign" && var_6.team != var_3 )
                    continue;

                kick( var_6 getentitynumber(), "EXE/PLAYERKICKED" );
                var_4++;
                wait 0.1;
            }

            self custom_scripts\framework\sources\core\shared::customprint( "^2Kicked ^7" + var_4 + " ^2bot(s)" );
        }

        wait 0.25;
    }
}

watchbotdifficultydvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvar( "setbotdifficulty", "" );

        if ( var_0 != "" )
        {
            setdvar( "setbotdifficulty", "" );

            if ( !self ishost() )
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1Host only" );
                continue;
            }

            var_1 = parse_difficulty_input( var_0 );

            if ( !isdefined( var_1 ) )
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid difficulty. Use: recruit, regular, hardened, or veteran" );
                continue;
            }

            var_2 = tolower( getdvar( "bot_team", "autoassign" ) );
            var_3 = parse_team_input( var_2, self );
            var_4 = 0;

            foreach ( var_6 in level.players )
            {
                if ( !isbot( var_6 ) )
                    continue;

                if ( var_3 != "autoassign" && var_6.team != var_3 )
                    continue;

                var_6 scripts\mp\bots\bots_util::bot_set_difficulty( var_1 );
                var_6.pers["botDifficulty"] = var_1;
                var_4++;
            }

            self custom_scripts\framework\sources\core\shared::customprint( "^2Changed difficulty to ^7" + var_1 + " ^2for ^7" + var_4 + " ^2bot(s)" );
        }

        wait 0.25;
    }
}

parse_team_input( var_0, var_1 )
{
    if ( !isdefined( var_1 ) || !isdefined( var_1.team ) )
        return "autoassign";

    var_2 = var_1.team;

    if ( var_0 == "allies" || var_0 == "ally" || var_0 == "friend" || var_0 == "same" )
        return var_2;

    if ( var_0 == "axis" || var_0 == "enemy" || var_0 == "enemies" )
    {
        if ( var_2 == "allies" )
            return "axis";
        else if ( var_2 == "axis" )
            return "allies";
    }

    if ( var_0 == "autoassign" || var_0 == "auto" )
        return "autoassign";

    return "autoassign";
}

get_team_display_name( var_0, var_1 )
{
    if ( !isdefined( var_1 ) || !isdefined( var_1.team ) )
        return var_0;

    if ( var_0 == var_1.team )
        return var_0 + " (Allies/Same Team)";
    else if ( var_0 == "autoassign" )
        return "Autoassign";
    else
        return var_0 + " (Enemies/Opposite Team)";
}

parse_difficulty_input( var_0 )
{
    var_0 = tolower( var_0 );

    if ( var_0 == "recruit" || var_0 == "easy" || var_0 == "1" )
        return "recruit";

    if ( var_0 == "regular" || var_0 == "normal" || var_0 == "2" )
        return "regular";

    if ( var_0 == "hardened" || var_0 == "hard" || var_0 == "3" )
        return "hardened";

    if ( var_0 == "veteran" || var_0 == "vet" || var_0 == "4" )
        return "veteran";

    return undefined;
}

initbotprotection()
{
    level.bots_disable_team_switching = 1;
    level notify( "bot_connect_monitor" );
    level.pausing_bot_connect_monitor = 1;
    level notify( "bot_monitor_team_limits" );
}

watchbotbehaviordvars()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvar( "bot_preset", "" );

        if ( var_0 != "" )
        {
            setdvar( "bot_preset", "" );

            if ( !self ishost() )
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1Host only" );
                wait 0.25;
                continue;
            }

            apply_bot_preset( var_0 );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Applied bot preset: ^7" + var_0 );
        }

        var_1 = getdvarint( "bot_follow_player", 0 );

        if ( var_1 )
        {
            if ( !isdefined( level.bot_follow_active ) || !level.bot_follow_active )
            {
                level.bot_follow_active = 1;
                level notify( "start_bot_follow" );
                thread manage_bot_follow_behavior();

                if ( self ishost() )
                    self custom_scripts\framework\sources\core\shared::customprint( "^2Bots now following player" );
            }
        }
        else if ( isdefined( level.bot_follow_active ) && level.bot_follow_active )
        {
            level.bot_follow_active = 0;
            level notify( "stop_bot_follow" );

            if ( self ishost() )
                self custom_scripts\framework\sources\core\shared::customprint( "^2Bots stopped following" );
        }

        var_2 = getdvarint( "bot_omniscient", 0 );

        if ( var_2 )
        {
            if ( !isdefined( level.bot_omniscient_active ) || !level.bot_omniscient_active )
            {
                level.bot_omniscient_active = 1;
                thread manage_bot_omniscient();

                if ( self ishost() )
                    self custom_scripts\framework\sources\core\shared::customprint( "^2Bots now omniscient (always know player location)" );
            }
        }
        else if ( isdefined( level.bot_omniscient_active ) && level.bot_omniscient_active )
        {
            level.bot_omniscient_active = 0;
            level notify( "stop_bot_omniscient" );

            if ( self ishost() )
                self custom_scripts\framework\sources\core\shared::customprint( "^2Bots no longer omniscient" );
        }

        var_3 = getdvarint( "bot_freeze", 0 );

        if ( var_3 )
        {
            if ( !isdefined( level.bots_frozen ) || !level.bots_frozen )
            {
                level.bots_frozen = 1;
                freeze_all_bots( 1 );
                level thread monitor_new_bots_freeze();

                if ( self ishost() )
                    self custom_scripts\framework\sources\core\shared::customprint( "^2Bots frozen" );
            }
        }
        else if ( isdefined( level.bots_frozen ) && level.bots_frozen )
        {
            level.bots_frozen = 0;
            level notify( "stop_monitor_new_bots" );
            freeze_all_bots( 0 );

            if ( self ishost() )
                self custom_scripts\framework\sources\core\shared::customprint( "^2Bots unfrozen" );
        }

        var_4 = getdvarint( "bot_ignore_player", 0 );

        if ( var_4 )
        {
            if ( !isdefined( level.bots_ignore_player ) || !level.bots_ignore_player )
            {
                level.bots_ignore_player = 1;
                thread make_bots_ignore_player();

                if ( self ishost() )
                    self custom_scripts\framework\sources\core\shared::customprint( "^2Bots now ignoring player" );
            }
        }
        else if ( isdefined( level.bots_ignore_player ) && level.bots_ignore_player )
        {
            level.bots_ignore_player = 0;
            level notify( "stop_bot_ignore" );

            if ( self ishost() )
                self custom_scripts\framework\sources\core\shared::customprint( "^2Bots no longer ignoring player" );
        }

        wait 0.5;
    }
}

manage_bot_follow_behavior()
{
    level endon( "game_ended" );
    level endon( "stop_bot_follow" );

    for (;;)
    {
        level waittill( "start_bot_follow" );

        foreach ( var_1 in level.players )
        {
            if ( !isdefined( var_1 ) || !isbot( var_1 ) )
                continue;

            if ( !isalive( var_1 ) )
                continue;

            var_1 thread bot_follow_player_thread();
        }

        wait 0.1;
    }
}

bot_follow_player_thread()
{
    self notify( "bot_follow_player_thread" );
    self endon( "bot_follow_player_thread" );
    self endon( "death_or_disconnect" );
    level endon( "game_ended" );
    level endon( "stop_bot_follow" );

    for (;;)
    {
        if ( !getdvarint( "bot_follow_player", 0 ) )
            break;

        var_0 = get_nearest_human_player();

        if ( isdefined( var_0 ) && isalive( var_0 ) && isalive( self ) )
        {
            var_1 = getdvarint( "bot_follow_distance", 128 );
            var_2 = getdvarint( "bot_follow_sprint", 0 );
            self botclearscriptgoal();
            self botsetscriptgoal( var_0.origin, var_1, "critical" );

            if ( var_2 )
                self botsetflag( "force_sprint", 1 );
            else
                self botsetflag( "force_sprint", 0 );
        }

        wait 0.25;
    }
}

manage_bot_omniscient()
{
    level endon( "game_ended" );
    level endon( "stop_bot_omniscient" );

    for (;;)
    {
        if ( !getdvarint( "bot_omniscient", 0 ) )
            break;

        var_0 = get_nearest_human_player();

        if ( !isdefined( var_0 ) || !isalive( var_0 ) )
        {
            wait 0.5;
            continue;
        }

        foreach ( var_2 in level.players )
        {
            if ( !isdefined( var_2 ) || !isbot( var_2 ) )
                continue;

            if ( !isalive( var_2 ) )
                continue;

            var_2 getenemyinfo( var_0 );
            var_2 botgetimperfectenemyinfo( var_0, var_0.origin );
            var_3 = getdvarint( "bot_aggro_range", 0 );

            if ( var_3 > 0 )
            {
                var_4 = distance( var_2.origin, var_0.origin );

                if ( var_4 <= var_3 )
                {
                    var_2 botsetscriptgoal( var_0.origin, 64, "critical" );
                    var_2 botsetattacker( var_0 );
                }
            }
        }

        wait 0.1;
    }
}

freeze_all_bots( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( !isdefined( var_2 ) || !isbot( var_2 ) )
            continue;

        if ( var_0 )
        {
            var_2.bot_frozen = 1;

            if ( isalive( var_2 ) )
            {
                var_2 botsetflag( "frozen", 1 );
                var_2 botclearscriptgoal();
                var_2 freezecontrols( 1 );
            }

            var_2 thread monitor_bot_freeze_respawn();
            continue;
        }

        var_2.bot_frozen = undefined;
        var_2 notify( "stop_freeze_monitor" );

        if ( isalive( var_2 ) )
        {
            var_2 botsetflag( "frozen", 0 );
            var_2 freezecontrols( 0 );
        }
    }
}

monitor_bot_freeze_respawn()
{
    self notify( "stop_freeze_monitor" );
    self endon( "stop_freeze_monitor" );
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "spawned_player" );

        if ( isdefined( self.bot_frozen ) && self.bot_frozen )
        {
            wait 0.1;

            if ( isalive( self ) )
            {
                self botsetflag( "frozen", 1 );
                self botclearscriptgoal();
                self freezecontrols( 1 );
            }
        }
    }
}

monitor_new_bots_freeze()
{
    level notify( "stop_monitor_new_bots" );
    level endon( "stop_monitor_new_bots" );
    level endon( "game_ended" );

    for (;;)
    {
        wait 1.0;

        if ( !getdvarint( "bot_freeze", 0 ) )
            break;

        foreach ( var_1 in level.players )
        {
            if ( !isdefined( var_1 ) || !isbot( var_1 ) )
                continue;

            if ( !isalive( var_1 ) )
                continue;

            if ( !isdefined( var_1.bot_frozen ) || !var_1.bot_frozen )
            {
                var_1.bot_frozen = 1;
                var_1 botsetflag( "frozen", 1 );
                var_1 botclearscriptgoal();
                var_1 freezecontrols( 1 );
                var_1 thread monitor_bot_freeze_respawn();
            }
        }
    }
}

make_bots_ignore_player()
{
    level endon( "game_ended" );
    level endon( "stop_bot_ignore" );

    for (;;)
    {
        if ( !getdvarint( "bot_ignore_player", 0 ) )
            break;

        var_0 = get_nearest_human_player();

        if ( !isdefined( var_0 ) )
        {
            wait 0.5;
            continue;
        }

        foreach ( var_2 in level.players )
        {
            if ( !isdefined( var_2 ) || !isbot( var_2 ) )
                continue;

            if ( !isalive( var_2 ) )
                continue;

            var_2 botclearscriptenemy();

            if ( isdefined( var_2.enemy ) && var_2.enemy == var_0 )
                var_2.enemy = undefined;

            var_2.attacker = undefined;
            var_2 getenemyinfo( var_0 );
            var_2.ignoreall = 1;
        }

        wait 0.1;
    }

    foreach ( var_2 in level.players )
    {
        if ( isdefined( var_2 ) && isbot( var_2 ) && isalive( var_2 ) )
            var_2.ignoreall = 0;
    }
}

get_nearest_human_player()
{
    var_0 = undefined;
    var_1 = 999999;

    foreach ( var_3 in level.players )
    {
        if ( !isdefined( var_3 ) || isbot( var_3 ) )
            continue;

        if ( !isalive( var_3 ) )
            continue;

        if ( !isdefined( var_0 ) )
        {
            var_0 = var_3;
            continue;
        }

        var_4 = distance( self.origin, var_3.origin );

        if ( var_4 < var_1 )
        {
            var_0 = var_3;
            var_1 = var_4;
        }
    }

    return var_0;
}

apply_bot_preset( var_0 )
{
    var_0 = tolower( var_0 );

    switch ( var_0 )
    {
        case "default":
            setdvar( "bot_follow_player", 0 );
            setdvar( "bot_follow_distance", 128 );
            setdvar( "bot_follow_sprint", 0 );
            setdvar( "bot_omniscient", 0 );
            setdvar( "bot_freeze", 0 );
            setdvar( "bot_ignore_player", 0 );
            setdvar( "bot_aggro_range", 0 );
            freeze_all_bots( 0 );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Bot preset: ^7Default (All values reset)" );
            break;
        case "aggro":
            setdvar( "bot_follow_player", 1 );
            setdvar( "bot_follow_distance", 99999 );
            setdvar( "bot_follow_sprint", 1 );
            setdvar( "bot_omniscient", 1 );
            setdvar( "bot_freeze", 0 );
            setdvar( "bot_ignore_player", 0 );
            setdvar( "bot_aggro_range", 99999 );
            freeze_all_bots( 0 );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Bot preset: ^7Aggro (Max follow + Sprint + Omniscient)" );
            break;
        case "freeze":
        case "stop":
            setdvar( "bot_follow_player", 0 );
            setdvar( "bot_omniscient", 0 );
            setdvar( "bot_freeze", 1 );
            setdvar( "bot_ignore_player", 0 );
            setdvar( "bot_aggro_range", 0 );
            setdvar( "bot_follow_sprint", 0 );
            freeze_all_bots( 1 );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Bot preset: ^7Freeze (All movement disabled)" );
            break;
        default:
            self custom_scripts\framework\sources\core\shared::customprint( "^1Unknown preset: ^7" + var_0 );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Available presets:" );
            self custom_scripts\framework\sources\core\shared::customprint( "^7  default ^2- Reset all to default" );
            self custom_scripts\framework\sources\core\shared::customprint( "^7  aggro ^2- Max follow + Sprint + Omniscient" );
            self custom_scripts\framework\sources\core\shared::customprint( "^7  freeze ^2- Disable all and freeze bots" );
            break;
    }
}

watchbotoutlinedvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    if ( !isdefined( self.bot_outline_ids ) )
        self.bot_outline_ids = [];

    var_0 = "0";
    var_1 = 0;

    for (;;)
    {
        var_2 = getdvar( "bot_outline", "0" );
        var_3 = tolower( var_2 );

        if ( var_2 != var_0 )
        {
            var_0 = var_2;
            self notify( "stop_bot_outline" );
            clear_all_bot_outlines();
            wait 0.1;

            if ( var_3 == "0" || var_3 == "off" || var_3 == "disable" || var_2 == "" )
            {
                var_1 = 0;
                self custom_scripts\framework\sources\core\shared::customprint( "^2Bot outlines: ^7Disabled" );
            }
            else
            {
                var_4 = parse_outline_input( var_3 );
                var_1 = 1;
                self custom_scripts\framework\sources\core\shared::customprint( "^2Bot outlines enabled: ^7" + var_4 );
                self thread outline_all_bots_continuous( var_4 );
            }
        }

        wait 0.5;
    }
}

parse_outline_input( var_0 )
{
    var_0 = tolower( var_0 );

    switch ( var_0 )
    {
        case "white":
            return "outline_nodepth_white";
        case "red":
            return "outline_nodepth_red";
        case "green":
            return "outline_nodepth_green";
        case "cyan":
            return "outline_nodepth_cyan";
        case "orange":
            return "outline_nodepth_orange";
        default:
            return var_0;
    }
}

outline_all_bots_continuous( var_0 )
{
    self endon( "disconnect" );
    self endon( "stop_bot_outline" );
    level endon( "game_ended" );

    if ( !isdefined( self.bot_outline_ids ) )
        self.bot_outline_ids = [];

    thread apply_bot_outlines( var_0 );

    for (;;)
    {
        wait 1.0;
        thread apply_bot_outlines( var_0 );
    }
}

apply_bot_outlines( var_0 )
{
    if ( !isdefined( self.bot_outline_ids ) )
        self.bot_outline_ids = [];

    foreach ( var_2 in level.players )
    {
        if ( !isdefined( var_2 ) )
            continue;

        if ( !isbot( var_2 ) )
            continue;

        if ( !isalive( var_2 ) )
            continue;

        var_3 = var_2 getentitynumber();

        if ( isdefined( self.bot_outline_ids[var_3] ) )
            continue;

        var_4 = scripts\mp\utility\outline::outlineenableforplayer( var_2, self, var_0, "killstreak" );

        if ( isdefined( var_4 ) )
        {
            self.bot_outline_ids[var_3] = var_4;
            var_2 thread monitor_bot_outline_death( self, var_3 );
        }
    }
}

monitor_bot_outline_death( var_0, var_1 )
{
    self endon( "disconnect" );
    var_0 endon( "disconnect" );
    var_0 endon( "stop_bot_outline" );
    self waittill( "death" );

    if ( isdefined( var_0.bot_outline_ids ) && isdefined( var_0.bot_outline_ids[var_1] ) )
        var_0.bot_outline_ids[var_1] = undefined;
}

clear_all_bot_outlines()
{
    if ( !isdefined( self.bot_outline_ids ) )
        return;

    foreach ( var_3, var_1 in self.bot_outline_ids )
    {
        var_2 = custom_scripts\framework\sources\gamemode\visual::get_player_by_entnum( var_3 );

        if ( isdefined( var_2 ) && isdefined( var_1 ) )
            scripts\mp\utility\outline::outlinedisable( var_1, var_2 );
    }

    self.bot_outline_ids = [];
}

watchbottpdvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvar( "bot_tp", "" );

        if ( var_0 != "" )
        {
            setdvar( "bot_tp", "" );

            if ( !self ishost() )
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1Host only" );
                wait 0.25;
                continue;
            }

            var_1 = tolower( var_0 );

            if ( var_1 == "me" || var_1 == "player" || var_1 == "here" )
            {
                var_2 = teleport_all_bots_to_player();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Teleported ^7" + var_2 + " ^2bot(s) to your location" );
            }
            else if ( var_1 == "spread" || var_1 == "scatter" )
            {
                var_2 = teleport_bots_spread_around_player();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Spread ^7" + var_2 + " ^2bot(s) around you" );
            }
            else
                self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid option. Use: ^7me, spread" );
        }

        wait 0.25;
    }
}

teleport_all_bots_to_player()
{
    var_0 = 0;
    var_1 = self.origin;
    var_2 = self.angles;

    foreach ( var_4 in level.players )
    {
        if ( !isdefined( var_4 ) || !isbot( var_4 ) )
            continue;

        if ( !isalive( var_4 ) )
            continue;

        var_4 setorigin( var_1 );
        var_4 setplayerangles( var_2 );
        var_0++;
    }

    return var_0;
}

teleport_bots_spread_around_player()
{
    var_0 = [];

    foreach ( var_2 in level.players )
    {
        if ( !isdefined( var_2 ) || !isbot( var_2 ) )
            continue;

        if ( !isalive( var_2 ) )
            continue;

        var_0[var_0.size] = var_2;
    }

    if ( var_0.size == 0 )
        return 0;

    var_4 = 150;
    var_5 = 360.0 / var_0.size;
    var_6 = 0;

    foreach ( var_2 in var_0 )
    {
        var_8 = var_6;
        var_9 = anglestoforward( ( 0, var_8, 0 ) );
        var_10 = var_9 * var_4;
        var_11 = self.origin + var_10;
        var_12 = botgetclosestnavigablepoint( var_11, 150 );

        if ( isdefined( var_12 ) )
            var_11 = var_12;
        else
            var_11 = ( var_11[0], var_11[1], self.origin[2] );

        var_2 setorigin( var_11 );
        var_13 = self.origin - var_11;
        var_14 = vectortoangles( var_13 );
        var_2 setplayerangles( ( 0, var_14[1], 0 ) );
        var_6 = var_6 + var_5;
    }

    return var_0.size;
}
