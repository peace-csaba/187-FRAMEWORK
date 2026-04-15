// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: world.gsc

////////////////////////////////////////////////////////////////////////

// Modularized gamemode file: gm_world

watchoutofboundsdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "oob", 0 );

    if ( var_0 == 1 )
        thread disableoutofbounds();

    for (;;)
    {
        var_1 = getdvarint( "oob", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;

            if ( var_1 == 1 )
            {
                thread disableoutofbounds();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Out of Bounds Bypass Activated" );
            }
            else
            {
                thread enableoutofbounds();
                self custom_scripts\framework\sources\core\shared::customprint( "^1Out of Bounds Bypass Deactivated" );
            }
        }

        if ( var_1 == 1 )
        {
            if ( self scripts\mp\utility\entity::touchingoobtrigger() && !scripts\mp\utility\entity::istouchingboundsnullify( self ) )
            {
                self.allowedintrigger = 1;
                wait 0.5;
                self.allowedintrigger = 0;
            }

            if ( isdefined( self.vehicle ) && isdefined( self.vehicle.health ) && self.vehicle.health > 0 )
            {
                scripts\mp\outofbounds::clearoob( self.vehicle, 0 );
                self setclientomnvar( "ui_out_of_bounds_type", 0 );
                self setclientomnvar( "ui_out_of_bounds_countdown", 0 );
            }
        }

        wait 0.05;
    }
}

disableoutofbounds()
{
    scripts\mp\outofbounds::enableoobimmunity( self );
    self.allowedintrigger = 1;
    self.alreadytouchingtrigger = 0;

    if ( isdefined( self.vehicle ) && isdefined( self.vehicle.health ) && self.vehicle.health > 0 )
    {
        scripts\mp\outofbounds::clearoob( self.vehicle, 0 );
        self setclientomnvar( "ui_out_of_bounds_type", 0 );
        self setclientomnvar( "ui_out_of_bounds_countdown", 0 );
    }
}

enableoutofbounds()
{
    scripts\mp\outofbounds::disableoobimmunity( self );
    self.allowedintrigger = 0;

    if ( isdefined( self.alreadytouchingtrigger ) )
        self.alreadytouchingtrigger = undefined;
}

initvehiclesystem()
{
    level endon( "game_ended" );
    waittillframeend;

    if ( getdvarint( "scr_allow_vehicles", 0 ) <= 0 )
        setdvar( "scr_allow_vehicles", 1 );

    if ( !isdefined( level.vehicle ) )
    {
        level.vehicle = spawnstruct();
        level.vehicle.vehicledata = [];
    }

    enablevehicletype( "atv" );
    enablevehicletype( "little_bird" );
    enablevehicletype( "little_bird_mg" );
    enablevehicletype( "cargo_truck" );
    enablevehicletype( "cargo_truck_mg" );
    enablevehicletype( "pickup_truck" );
    enablevehicletype( "technical" );
    enablevehicletype( "tac_rover" );
    enablevehicletype( "cop_car" );
    enablevehicletype( "hoopty" );
    enablevehicletype( "jeep" );
    enablevehicletype( "van" );
    enablevehicletype( "motorcycle" );
    enablevehicletype( "apc_russian" );
    enablevehicletype( "light_tank" );
    enablevehicletype( "large_transport" );
    enablevehicletype( "medium_transport" );
}

enablevehicletype( var_0 )
{
    if ( getdvarint( "scr_allow_vehicle_" + var_0, 1 ) <= 0 )
        setdvar( "scr_allow_vehicle_" + var_0, 1 );
}

watchvehiclespawndvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 = getdvar( "spawn_vehicle", "" );
    var_1 = getdvarint( "delete_vehicle", 0 );

    for (;;)
    {
        var_2 = getdvar( "spawn_vehicle", "" );
        var_3 = getdvarint( "delete_vehicle", 0 );

        if ( var_2 != var_0 && var_2 != "" )
        {
            var_0 = var_2;
            self spawnvehicleviadvr( var_2 );
            setdvar( "spawn_vehicle", "" );
            var_0 = "";
        }

        if ( var_3 != var_1 && var_3 == 1 )
        {
            var_1 = var_3;
            self deletelastspawnedvehicle();
            setdvar( "delete_vehicle", 0 );
            var_1 = 0;
        }

        if ( var_3 != var_1 && var_3 == 2 )
        {
            var_1 = var_3;
            self deleteallspawnedvehicles();
            setdvar( "delete_vehicle", 0 );
            var_1 = 0;
        }

        wait 0.1;
    }
}

spawnvehicleviadvr( var_0 )
{
    if ( !isdefined( var_0 ) || var_0 == "" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid vehicle reference" );
        return;
    }

    if ( getdvarint( "scr_allow_vehicles", 0 ) <= 0 )
    {
        setdvar( "scr_allow_vehicles", 1 );
        wait 0.05;
    }

    if ( getdvarint( "scr_allow_vehicle_" + var_0, 1 ) <= 0 )
    {
        setdvar( "scr_allow_vehicle_" + var_0, 1 );
        wait 0.05;
    }

    var_1 = getdvarint( "vehicle_offset", 300 );
    var_2 = anglestoforward( self getplayerangles() );
    var_3 = self.origin + var_2 * var_1;
    var_4 = spawnstruct();
    var_4.origin = var_3;
    var_4.angles = self getplayerangles();
    var_4.owner = self;
    var_4.spawntype = "GAME_MODE";
    var_5 = scripts\cp_mp\vehicles\vehicle_spawn::vehicle_spawn_spawnvehicle( var_0, var_4 );

    if ( !isdefined( var_5 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Failed to spawn vehicle: ^7" + var_0 );
        self custom_scripts\framework\sources\core\shared::customprint( "^3Vehicle may not be available on this map" );
        self custom_scripts\framework\sources\core\shared::customprint( "^3Try: atv, cargo_truck, little_bird" );
        return;
    }

    var_5.maxhealth = 100000;
    var_5.health = var_5.maxhealth;
    var_6 = getdvarint( "vehicle_godmode", 0 );

    if ( var_6 == 1 )
    {
        var_5.godmode = 1;
        var_5 setcandamage( 0 );
    }

    if ( !isdefined( level.spawned_vehicles_list ) )
        level.spawned_vehicles_list = [];

    level.spawned_vehicles_list[level.spawned_vehicles_list.size] = var_5;
    self.last_spawned_vehicle = var_5;
    self custom_scripts\framework\sources\core\shared::customprint( "^2Vehicle Spawned: ^7" + var_0 );
    self playlocalsound( "ui_mp_flag_capture" );
    self thread monitorvehicle( var_5 );
}

monitorvehicle( var_0 )
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 endon( "death" );

    for (;;)
    {
        if ( !isdefined( var_0 ) )
            break;

        var_1 = getdvarint( "vehicle_godmode", 0 );

        if ( var_1 == 1 && isdefined( var_0.godmode ) && var_0.godmode )
        {
            if ( var_0.health < var_0.maxhealth )
                var_0.health = var_0.maxhealth;
        }

        wait 0.5;
    }
}

deletelastspawnedvehicle()
{
    if ( !isdefined( self.last_spawned_vehicle ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1No vehicle to delete" );
        return;
    }

    if ( isdefined( self.last_spawned_vehicle ) )
    {
        self.last_spawned_vehicle delete();
        self.last_spawned_vehicle = undefined;
        self custom_scripts\framework\sources\core\shared::customprint( "^2Vehicle Deleted" );
        self playlocalsound( "ui_mp_flag_lost" );
    }
}

deleteallspawnedvehicles()
{
    if ( !isdefined( level.spawned_vehicles_list ) || level.spawned_vehicles_list.size == 0 )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1No vehicles to delete" );
        return;
    }

    var_0 = 0;

    foreach ( var_2 in level.spawned_vehicles_list )
    {
        if ( isdefined( var_2 ) )
        {
            var_2 delete();
            var_0++;
        }
    }

    level.spawned_vehicles_list = [];
    self.last_spawned_vehicle = undefined;
    self custom_scripts\framework\sources\core\shared::customprint( "^2Deleted " + var_0 + " vehicle(s)" );
    self playlocalsound( "ui_mp_flag_lost" );
}

watchbarriersfixdvar()
{
    level endon( "game_ended" );

    if ( !isdefined( level.original_barriers ) )
    {
        level.original_barriers = spawnstruct();
        level.original_barriers.triggers = [];
        level.original_barriers.barriers = [];
        level.original_barriers.clips = [];
        level.original_barriers.oncetriggers = [];
        var_0 = getentarray( "trigger_hurt", "classname" );

        for ( var_1 = 0; var_1 < var_0.size; var_1++ )
        {
            level.original_barriers.triggers[var_1] = spawnstruct();
            level.original_barriers.triggers[var_1].entity = var_0[var_1];
            level.original_barriers.triggers[var_1].origin = var_0[var_1].origin;
        }

        var_2 = getentarray( "barrier", "targetname" );

        for ( var_1 = 0; var_1 < var_2.size; var_1++ )
        {
            level.original_barriers.barriers[var_1] = spawnstruct();
            level.original_barriers.barriers[var_1].entity = var_2[var_1];
            level.original_barriers.barriers[var_1].origin = var_2[var_1].origin;
        }

        var_3 = getentarray( "trigger_multiple", "classname" );

        for ( var_1 = 0; var_1 < var_3.size; var_1++ )
        {
            level.original_barriers.clips[var_1] = spawnstruct();
            level.original_barriers.clips[var_1].entity = var_3[var_1];
            level.original_barriers.clips[var_1].origin = var_3[var_1].origin;
        }

        var_4 = getentarray( "trigger_once", "classname" );

        for ( var_1 = 0; var_1 < var_4.size; var_1++ )
        {
            level.original_barriers.oncetriggers[var_1] = spawnstruct();
            level.original_barriers.oncetriggers[var_1].entity = var_4[var_1];
            level.original_barriers.oncetriggers[var_1].origin = var_4[var_1].origin;
        }
    }

    var_5 = getdvarint( "fix_barriers", 0 );

    if ( var_5 == 1 )
        disablebarriers();

    for (;;)
    {
        var_6 = getdvarint( "fix_barriers", 0 );

        if ( var_6 != var_5 )
        {
            var_5 = var_6;

            if ( var_6 == 1 )
            {
                disablebarriers();

                foreach ( var_8 in level.players )
                {
                    if ( isdefined( var_8 ) )
                        var_8 custom_scripts\framework\sources\core\shared::customprint( "^2Barriers Disabled" );
                }
            }
            else
            {
                restorebarriers();

                foreach ( var_8 in level.players )
                {
                    if ( isdefined( var_8 ) )
                        var_8 custom_scripts\framework\sources\core\shared::customprint( "^1Barriers Restored" );
                }
            }
        }

        wait 0.1;
    }
}

disablebarriers()
{
    foreach ( var_1 in level.original_barriers.triggers )
    {
        if ( isdefined( var_1.entity ) )
            var_1.entity.origin = ( 999999, 999999, 999999 );
    }

    foreach ( var_4 in level.original_barriers.barriers )
    {
        if ( isdefined( var_4.entity ) )
            var_4.entity.origin = ( 999999, 999999, 999999 );
    }

    foreach ( var_7 in level.original_barriers.clips )
    {
        if ( isdefined( var_7.entity ) )
            var_7.entity.origin = ( 999999, 999999, 999999 );
    }

    foreach ( var_10 in level.original_barriers.oncetriggers )
    {
        if ( isdefined( var_10.entity ) )
            var_10.entity.origin = ( 999999, 999999, 999999 );
    }
}

restorebarriers()
{
    foreach ( var_1 in level.original_barriers.triggers )
    {
        if ( isdefined( var_1.entity ) && isdefined( var_1.origin ) )
            var_1.entity.origin = var_1.origin;
    }

    foreach ( var_4 in level.original_barriers.barriers )
    {
        if ( isdefined( var_4.entity ) && isdefined( var_4.origin ) )
            var_4.entity.origin = var_4.origin;
    }

    foreach ( var_7 in level.original_barriers.clips )
    {
        if ( isdefined( var_7.entity ) && isdefined( var_7.origin ) )
            var_7.entity.origin = var_7.origin;
    }

    foreach ( var_10 in level.original_barriers.oncetriggers )
    {
        if ( isdefined( var_10.entity ) && isdefined( var_10.origin ) )
            var_10.entity.origin = var_10.origin;
    }
}
