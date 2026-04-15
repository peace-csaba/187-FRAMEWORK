// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: movement.gsc

////////////////////////////////////////////////////////////////////////

// Modularized gamemode file: gm_movement

watchmovespeedscale()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );

    if ( isbot( self ) )
        return;

    var_0 = getdvarfloat( "move_speed", 1.0 );

    if ( var_0 > 5.0 )
        thread superspeedloop();

    setdvar( "MNPNORMOMP", 1.0 / var_0 );

    for (;;)
    {
        var_1 = getdvarfloat( "move_speed", 1.0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_super_speed" );

            if ( var_1 != 0 )
                setdvar( "MNPNORMOMP", 1.0 / var_1 );

            if ( var_1 > 5.0 )
            {
                self setmovespeedscale( 5.0 );
                thread superspeedloop();
            }
            else
                self updatemovespeedscale();

            self iprintlnbold( "^4Movement Speed: ^7" + var_1 + var_1 > 5.0 ? " ^4(Custom)" : " ^4(Engine)" );
        }

        wait 0.1;
    }
}

superspeedloop()
{
    self endon( "disconnect" );
    self endon( "stop_super_speed" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvarfloat( "move_speed", 1.0 );
        var_1 = self getnormalizedmovement();

        if ( length( var_1 ) > 0 )
        {
            var_2 = self getplayerangles();
            var_3 = var_1[0] * anglestoforward( var_2 ) + var_1[1] * anglestoright( var_2 );
            var_4 = ( var_0 - 5.0 ) * 1.5;
            self setvelocity( self getvelocity() + var_3 * var_4 );
        }

        waitframe();
    }
}

updatemovespeedscale()
{
    var_0 = undefined;

    if ( isdefined( self.playerstreakspeedscale ) )
    {
        var_0 = 1.0;
        var_0 = var_0 + self.playerstreakspeedscale;
    }
    else
    {
        var_0 = scripts\mp\weapons::getplayerspeedbyweapon( self );

        if ( isdefined( self.overrideweaponspeed_speedscale ) )
            var_0 = self.overrideweaponspeed_speedscale;

        var_1 = self.chill_data;

        if ( isdefined( var_1 ) && isdefined( var_1.speedmod ) )
            var_0 = var_0 + var_1.speedmod;

        if ( isdefined( self.gasspeedmod ) )
            var_0 = var_0 + self.gasspeedmod;

        if ( isdefined( self.disabledspeedmod ) )
            var_0 = var_0 + self.disabledspeedmod;

        if ( isdefined( self.speedonkillmod ) )
            var_0 = var_0 + self.speedonkillmod;

        if ( isdefined( self.momentumspeedincrease ) )
            var_0 = var_0 + self.momentumspeedincrease;
    }

    self.weaponspeed = var_0;

    if ( !isdefined( self.combatspeedscalar ) )
        self.combatspeedscalar = 1;

    var_0 = var_0 + ( self.movespeedscaler - 1.0 );
    var_0 = var_0 + ( self.combatspeedscalar - 1.0 );

    if ( isdefined( self.fastcrouchspeedmod ) )
        var_0 = var_0 + self.fastcrouchspeedmod;

    if ( isplayer( self ) && !isbot( self ) )
        var_0 = var_0 * getdvarfloat( "move_speed", 1.0 );

    self setmovespeedscale( var_0 );
}

watchsuperjumpdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "super_jump", 0 );

    if ( var_0 == 1 )
        thread superjumploop();

    for (;;)
    {
        var_1 = getdvarint( "super_jump", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_super_jump" );

            if ( var_1 == 1 )
                thread superjumploop();

            self custom_scripts\framework\sources\core\shared::customprint( var_1 == 1 ? "^2Super Jump Activated" : "^1Super Jump Deactivated" );
        }

        wait 0.1;
    }
}

superjumploop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "stop_super_jump" );
    level endon( "game_ended" );
    self.superjump_lasttime = 0;
    self.superjump_canuse = 1;
    self.superjump_wasinair = 0;

    for (;;)
    {
        var_0 = getdvarfloat( "jump_height", 150.0 );
        var_1 = getdvarfloat( "jump_cooldown", 0.3 );
        var_2 = getdvarfloat( "jump_multi", 1.5 );
        var_3 = getdvarint( "jump_mode", 1 );
        var_4 = gettime();
        var_5 = self isonground();

        if ( var_3 == 0 )
        {
            if ( var_4 - self.superjump_lasttime >= var_1 * 1000 )
                self.superjump_canuse = 1;
        }
        else if ( var_5 && self.superjump_wasinair )
            self.superjump_canuse = 1;

        if ( !var_5 )
            self.superjump_wasinair = 1;
        else if ( var_5 && self.superjump_wasinair )
            self.superjump_wasinair = 0;

        if ( self jumpbuttonpressed() && self.superjump_canuse )
        {
            var_6 = self getvelocity();
            self setvelocity( ( var_6[0] * var_2, var_6[1] * var_2, var_6[2] + var_0 ) );
            self.superjump_canuse = 0;
            self.superjump_lasttime = var_4;
        }

        waitframe();
    }
}

watchslidespeeddvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarfloat( "slide_speed", 0 );

    if ( var_0 > 0 )
        thread slidespeedloop();

    for (;;)
    {
        var_1 = getdvarfloat( "slide_speed", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_slide_speed" );

            if ( var_1 > 0 )
            {
                thread slidespeedloop();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Slide Speed Boost: ^7" + var_1 );
            }
            else
                self custom_scripts\framework\sources\core\shared::customprint( "^1Slide Speed Boost: ^7Disabled" );
        }

        wait 0.1;
    }
}

slidespeedloop()
{
    self endon( "disconnect" );
    self endon( "stop_slide_speed" );
    level endon( "game_ended" );
    self.was_sliding = 0;
    self.initial_slide_speed = undefined;

    for (;;)
    {
        var_0 = getdvarfloat( "slide_speed", 0 );

        if ( var_0 <= 0 )
        {
            waitframe();
            continue;
        }

        if ( self issprintsliding() )
        {
            var_1 = self getvelocity();
            var_2 = ( var_1[0], var_1[1], 0 );
            var_3 = length( var_2 );

            if ( !self.was_sliding )
            {
                self.initial_slide_speed = max( var_3, 100 );
                self.was_sliding = 1;
            }

            var_4 = self.initial_slide_speed * ( 1.0 + var_0 );

            if ( var_3 < var_4 )
            {
                var_5 = self getplayerangles();
                var_6 = anglestoforward( var_5 );
                var_7 = self.initial_slide_speed * var_0 * 0.001;
                var_8 = var_6 * var_7;
                var_9 = ( var_1[0] + var_8[0], var_1[1] + var_8[1], var_1[2] );
                var_10 = ( var_9[0], var_9[1], 0 );
                var_11 = length( var_10 );

                if ( var_11 > var_4 )
                {
                    var_12 = var_4 / var_11;
                    var_9 = ( var_9[0] * var_12, var_9[1] * var_12, var_9[2] );
                }

                self setvelocity( var_9 );
            }
        }
        else
        {
            self.was_sliding = 0;
            self.initial_slide_speed = undefined;
        }

        waitframe();
    }
}

watchgravitydvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarfloat( "gravity", 1.0 );

    if ( var_0 != 1.0 )
        thread customgravityloop();

    for (;;)
    {
        var_1 = getdvarfloat( "gravity", 1.0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_custom_gravity" );

            if ( var_1 != 1.0 )
            {
                thread customgravityloop();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Custom Gravity: ^7" + var_1 + "x" );
            }
            else
                self custom_scripts\framework\sources\core\shared::customprint( "^1Gravity: ^7Default (1.0x)" );
        }

        wait 0.1;
    }
}

customgravityloop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "stop_custom_gravity" );
    level endon( "game_ended" );

    for (;;)
    {
        if ( self isparachuting() || self isinfreefall() )
        {
            waitframe();
            continue;
        }

        if ( !self isonground() )
        {
            var_0 = self getvelocity();
            var_1 = getdvarfloat( "gravity", 1.0 );
            var_2 = 30;
            var_3 = ( var_1 - 1.0 ) * var_2;
            self setvelocity( ( var_0[0], var_0[1], var_0[2] - var_3 ) );
        }

        waitframe();
    }
}

watchscaletimedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarfloat( "scaletime", 1.0 );

    for (;;)
    {
        var_1 = getdvarfloat( "scaletime", 1.0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1 >= 0.1 && var_1 <= 20.0 ? var_1 : var_0;

            if ( var_1 >= 0.1 && var_1 <= 20.0 )
            {
                setslowmotion( 1, var_1, 1 );
                self custom_scripts\framework\sources\core\shared::customprint( "^2timescale set to: ^7" + var_1 );
            }
            else
            {
                self custom_scripts\framework\sources\core\shared::customprint( "^1timescale must be between 0.1 and 20.0" );
                setdvar( "scaletime", var_0 );
            }
        }

        wait 0.1;
    }
}

watchcrosshairtp()
{
    self endon( "disconnect" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvarint( "crosshair_tp", 0 );

        if ( var_0 == 1 )
        {
            if ( self attackbuttonpressed() )
            {
                self crosshairtp();
                wait 0.05;
            }
        }
        else if ( var_0 == 2 )
        {
            if ( self meleebuttonpressed() )
            {
                self crosshairtp();
                wait 0.05;
            }
        }
        else if ( var_0 == 3 )
        {
            if ( self meleebuttonpressed() && self adsbuttonpressed() )
            {
                self crosshairtp();
                wait 0.05;
            }
        }

        wait 0.05;
    }
}

crosshairtp()
{
    var_0 = self geteye();
    var_1 = self getplayerangles();
    var_2 = anglestoforward( var_1 );
    var_3 = var_0 + var_2 * 10000;
    var_4 = scripts\engine\trace::_bullet_trace( var_0, var_3, 1, self );

    if ( isdefined( var_4["position"] ) )
        self setorigin( var_4["position"] );

    wait 0.05;
}

watchspinmode()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "spin_mode", 0 );

    if ( var_0 == 1 )
        thread spinmodeloop();

    for (;;)
    {
        var_1 = getdvarint( "spin_mode", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_spin_mode" );

            if ( var_1 == 1 )
            {
                thread spinmodeloop();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Spin Mode Enabled" );
            }
            else
                self custom_scripts\framework\sources\core\shared::customprint( "^1Spin Mode Disabled" );
        }

        wait 0.1;
    }
}

spinmodeloop()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "stop_spin_mode" );
    level endon( "game_ended" );

    for (;;)
    {
        var_0 = getdvarfloat( "spin_speed", -600 );
        var_1 = self getplayerangles();
        var_2 = var_0 * 0.05;
        var_3 = var_1[1] + var_2;

        if ( var_3 >= 360 )
            var_3 = var_3 - 360;

        if ( var_3 < 0 )
            var_3 = var_3 + 360;

        self setplayerangles( ( var_1[0], var_3, var_1[2] ) );
        waitframe();
    }
}

watchheadtilt()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarfloat( "head_tilt", 0 );

    for (;;)
    {
        var_1 = getdvarfloat( "head_tilt", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            var_2 = self getplayerangles();
            self setplayerangles( ( var_2[0], var_2[1], var_1 ) );
            self custom_scripts\framework\sources\core\shared::customprint( "^2Head Tilt: ^7" + var_1 + " degrees" );
        }

        wait 0.1;
    }
}

watchupsidedown()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "upside_down", 0 );

    for (;;)
    {
        var_1 = getdvarint( "upside_down", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            var_2 = self getplayerangles();

            if ( var_1 == 1 )
            {
                self setplayerangles( ( var_2[0], var_2[1], 180 ) );
                self custom_scripts\framework\sources\core\shared::customprint( "^2Upside Down View Enabled" );
            }
            else
            {
                self setplayerangles( ( var_2[0], var_2[1], 0 ) );
                self custom_scripts\framework\sources\core\shared::customprint( "^1Upside Down View Disabled" );
            }
        }

        wait 0.1;
    }
}
