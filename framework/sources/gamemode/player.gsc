// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: player.gsc

////////////////////////////////////////////////////////////////////////

// Modularized gamemode file: gm_player

watchnoclipbind()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 = getdvarint( "nc_enabled", 0 );

    if ( var_0 == 1 )
        thread noclipbindloop();

    for (;;)
    {
        var_1 = getdvarint( "nc_enabled", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;

            if ( var_1 == 1 )
            {
                self notify( "stop_noclip_bind" );
                thread noclipbindloop();
            }
            else
            {
                self notify( "stop_noclip_bind" );
                noclip_disable();
            }
        }

        wait 0.1;
    }
}

noclipbindloop()
{
    self endon( "disconnect" );
    self endon( "stop_noclip_bind" );
    level endon( "game_ended" );
    self.noclip_held = 0;
    self.noclip_lastpress = 0;

    for (;;)
    {
        if ( isdefined( self.noclip_obj ) && self scripts\cp_mp\utility\player_utility::isinvehicle() )
            noclip_disable();

        var_0 = gettime();
        var_1 = self jumpbuttonpressed();
        var_2 = self meleebuttonpressed();
        var_3 = var_1 && var_2;

        if ( var_3 && !self.noclip_held )
        {
            if ( var_0 - self.noclip_lastpress > 500 )
            {
                self.noclip_held = 1;
                self.noclip_lastpress = var_0;

                if ( !self scripts\cp_mp\utility\player_utility::isinvehicle() )
                {
                    if ( !isdefined( self.noclip_obj ) )
                        noclip_enable();
                    else
                        noclip_disable();
                }
            }
        }
        else if ( !var_3 )
            self.noclip_held = 0;

        if ( isdefined( self.noclip_obj ) )
            noclip_movement( var_1, var_2 );

        waitframe();
    }
}

noclip_enable()
{
    self.noclip_obj = spawn( "script_origin", self.origin );
    self.noclip_obj.angles = self.angles;
    self playerlinkto( self.noclip_obj, undefined, 0 );
    var_0 = getdvar( "god_mode", "0" ) == "1";

    if ( getdvarint( "nc_godmode", 1 ) == 1 && !var_0 )
    {
        self.noclip_autogod = 1;
        setdvar( "god_mode", "1" );
        self custom_scripts\framework\sources\core\shared::customprint( "^2Noclip + Auto Godmode Activated" );
    }
    else
        self custom_scripts\framework\sources\core\shared::customprint( "^2Noclip Activated" );

    self custom_scripts\framework\sources\gamemode\movement::updatemovespeedscale();
}

noclip_disable()
{
    if ( !isdefined( self.noclip_obj ) )
        return;

    self unlink();
    self.noclip_obj delete();
    self.noclip_obj = undefined;

    if ( isdefined( self.noclip_autogod ) )
    {
        self.noclip_autogod = undefined;
        setdvar( "god_mode", "0" );
        self custom_scripts\framework\sources\core\shared::customprint( "^1Noclip + Auto Godmode Deactivated" );
    }
    else
        self custom_scripts\framework\sources\core\shared::customprint( "^1Noclip Deactivated" );

    self custom_scripts\framework\sources\gamemode\movement::updatemovespeedscale();
}

noclip_movement( var_0, var_1 )
{
    self.noclip_obj.angles = self getplayerangles();
    var_2 = self getplayerangles();
    var_3 = anglestoforward( var_2 );
    var_4 = anglestoright( var_2 );
    var_5 = self getnormalizedmovement();
    var_6 = 0;

    if ( var_0 && !var_1 )
        var_6 = 1;
    else if ( self crouchbuttonpressed() )
        var_6 = -1;

    var_7 = var_5[0] * var_3 + var_5[1] * var_4 + var_6 * ( 0, 0, 1 );
    var_8 = 8.0;

    if ( self sprintbuttonpressed() )
    {
        if ( self secondaryoffhandbuttonpressed() )
            var_8 = var_8 * 12.5;
        else
            var_8 = var_8 * 3.125;
    }

    var_9 = getdvarfloat( "nc_speed", 1.0 );
    var_9 = clamp( var_9, 0.1, 20.0 );
    var_8 = var_8 * var_9;
    self.noclip_obj.origin = self.origin + var_7 * var_8;
}

watchgodmode()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 = getdvarint( "god_mode", 0 );

    if ( var_0 == 1 )
        thread godmodeloop();

    for (;;)
    {
        var_1 = getdvarint( "god_mode", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;

            if ( var_1 == 1 )
            {
                self notify( "stop_godmode" );
                thread godmodeloop();

                if ( !isdefined( self.noclip_autogod ) )
                    self custom_scripts\framework\sources\core\shared::customprint( "^2Godmode Activated" );
            }
            else
            {
                self notify( "stop_godmode" );
                godmode_disable();

                if ( !isdefined( self.noclip_autogod ) )
                    self custom_scripts\framework\sources\core\shared::customprint( "^1Godmode Deactivated" );
            }
        }

        wait 0.1;
    }
}

godmodeloop()
{
    self endon( "disconnect" );
    self endon( "stop_godmode" );
    level endon( "game_ended" );

    if ( !isdefined( self.god_fallheight ) )
        self.god_fallheight = getdvarfloat( "NKTQRKRMTS", 200.0 );

    setdvar( "NKTQRKRMTS", 10000.0 );
    self.maxhealth = 999999;
    self.health = 999999;
    self.godmode_active = 1;

    for (;;)
    {
        self waittill( "damage", var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 );

        if ( isdefined( self.godmode_active ) && self.godmode_active )
            self.health = self.maxhealth;
    }
}

godmode_disable()
{
    self.godmode_active = undefined;
    self.maxhealth = 100;
    self.health = 100;

    if ( isdefined( self.god_fallheight ) )
    {
        setdvar( "NKTQRKRMTS", self.god_fallheight );
        self.god_fallheight = undefined;
    }
}
