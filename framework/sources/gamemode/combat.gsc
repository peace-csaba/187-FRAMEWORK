// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: combat.gsc

////////////////////////////////////////////////////////////////////////

// Modularized gamemode file: gm_combat

watchinfiniteammodvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "inf_ammo", 0 );

    for (;;)
    {
        var_1 = getdvarint( "inf_ammo", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_infinite_ammo" );

            if ( var_1 > 0 )
            {
                self thread custominfiniteammoloop();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Infinite Ammo Activated" );
            }
            else
                self custom_scripts\framework\sources\core\shared::customprint( "^1Infinite Ammo Deactivated" );
        }

        wait 0.1;
    }
}

custominfiniteammoloop()
{
    self endon( "disconnect" );
    self endon( "stop_infinite_ammo" );
    level endon( "game_ended" );
    self refill_all_ammo();

    for (;;)
    {
        scripts\engine\utility::waittill_any_ents( self, "weapon_fired", self, "grenade_fire", self, "force_regeneration" );
        self refill_all_ammo();
    }
}

refill_all_ammo()
{
    var_0 = self.equippedweapons;

    foreach ( var_2 in var_0 )
    {
        self givemaxammo( var_2 );
        self setweaponammostock( var_2, 999 );
        self setweaponammoclip( var_2, 999 );
        self setweaponammoclip( var_2, 999, "left" );
        self setweaponammoclip( var_2, 999, "_encstr_A5AD056A019C63" );
        self setweaponammoclip( var_2, 999, "_encstr_B1AD05C65666E8" );
        self setweaponammoclip( var_2, 999, "right" );
        self setweaponammoclip( var_2, 999, "_encstr_8253060E2B5FE330" );
        self setweaponammoclip( var_2, 999, "_encstr_9353062E718710C9" );
    }
}

refillweaponammo( var_0 )
{
    self givemaxammo( var_0 );
    self setweaponammostock( var_0, 999 );
    self setweaponammoclip( var_0, 999 );
    self setweaponammoclip( var_0, 999, "left" );
    self setweaponammoclip( var_0, 999, "_encstr_A5AD056A019C63" );
    self setweaponammoclip( var_0, 999, "_encstr_B1AD05C65666E8" );
    self setweaponammoclip( var_0, 999, "right" );
    self setweaponammoclip( var_0, 999, "_encstr_8253060E2B5FE330" );
    self setweaponammoclip( var_0, 999, "_encstr_9353062E718710C9" );
}

watchweapongivedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "give_weapon", "" );

    for (;;)
    {
        var_1 = getdvar( "give_weapon", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self giveweaponviadvr( var_1 );
            setdvar( "give_weapon", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

giveweaponviadvr( var_0 )
{
    var_1 = getdvarint( "weapon_variant", -1 );
    var_2 = [ "camo_11c", "camo_11d", "camo_11a", "camo_11b" ];
    var_3 = var_2[randomint( var_2.size )];
    var_4 = var_3;
    var_5 = undefined;

    if ( isstring( var_0 ) )
    {
        if ( var_1 >= 0 )
        {
            var_6 = scripts\mp\class::buildweapon( var_0, [], "none", "none", var_1, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap() );

            if ( isdefined( var_6 ) )
            {
                var_5 = var_6;
                self custom_scripts\framework\sources\core\shared::customprint( "^6Using variant: ^7" + var_1 );
            }
        }

        if ( !isdefined( var_5 ) )
        {
            var_6 = scripts\mp\class::buildweapon( var_0, [], var_3, "none", -1, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap() );

            if ( isdefined( var_6 ) )
                var_5 = var_6;
            else
                var_5 = getcompleteweaponname( var_0 );
        }
    }

    if ( !isdefined( var_5 ) || var_5.basename == "none" )
        self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid Weapon: ^7" + var_0 );
    else
    {
        if ( self hasweapon( var_5 ) )
        {
            self custom_scripts\framework\sources\core\shared::customprint( "^3Already Have: ^7" + var_0 );
            return;
        }

        var_7 = self scripts\cp_mp\utility\inventory_utility::getcurrentprimaryweaponsminusalt();
        var_8 = getdvarint( "max_weapons", 2 );

        if ( var_7.size >= var_8 )
        {
            var_9 = self getcurrentweapon();

            if ( isdefined( var_9 ) && var_9.basename != "none" )
                self scripts\cp_mp\utility\inventory_utility::_takeweapon( var_9 );
        }

        self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_5 );

        if ( getdvarint( "weapon_switch", 1 ) > 0 )
            self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_5 );

        self refillweaponammo( var_5 );
        self playlocalsound( "ui_mp_weapon_pickup" );
        scripts\mp\weapons::fixupplayerweapons( self, var_5 );

        if ( var_1 >= 0 )
        {
            self custom_scripts\framework\sources\core\shared::customprint( "^2Weapon Given: ^7" + var_0 + " ^6(Variant " + var_1 + ")" );
            return;
        }

        self custom_scripts\framework\sources\core\shared::customprint( "^2Weapon Given: ^7" + var_0 + " ^6(" + var_4 + ")" );
    }
}

watchweaponchange()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = self getcurrentweapon();

    for (;;)
    {
        var_1 = self getcurrentweapon();

        if ( !isdefined( var_0 ) || var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "weapon_changed" );
            wait 0.05;
            var_2 = getdvarfloat( "move_speed", 1.0 );

            if ( var_2 != 1.0 )
            {
                if ( var_2 > 5.0 )
                {
                    self setmovespeedscale( 5.0 );
                    self notify( "stop_super_speed" );
                    self thread custom_scripts\framework\sources\gamemode\movement::superspeedloop();
                }
                else
                    self setmovespeedscale( var_2 );
            }
        }

        wait 0.05;
    }
}

watchperkgivedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "give_perk", "" );
    var_1 = getdvar( "remove_perk", "" );

    for (;;)
    {
        var_2 = getdvar( "give_perk", "" );
        var_3 = getdvar( "remove_perk", "" );

        if ( var_2 != var_0 && var_2 != "" )
        {
            var_0 = var_2;
            self giveperkviadvr( var_2 );
            setdvar( "give_perk", "" );
            var_0 = "";
        }

        if ( var_3 != var_1 && var_3 != "" )
        {
            var_1 = var_3;
            self removeperkviadvr( var_3 );
            setdvar( "remove_perk", "" );
            var_1 = "";
        }

        wait 0.1;
    }
}

giveperkviadvr( var_0 )
{
    if ( scripts\mp\utility\perk::_hasperk( var_0 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^3Already Have: ^7" + var_0 );
        return;
    }

    scripts\mp\utility\perk::giveperk( var_0 );
    self playlocalsound( "ui_perk_purchase" );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Perk Given: ^7" + var_0 );
}

removeperkviadvr( var_0 )
{
    if ( !scripts\mp\utility\perk::_hasperk( var_0 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^3Don't Have: ^7" + var_0 );
        return;
    }

    scripts\mp\utility\perk::removeperk( var_0 );
    self playlocalsound( "ui_perk_deny" );
    self custom_scripts\framework\sources\core\shared::customprint( "^1Perk Removed: ^7" + var_0 );
}

watchexecutiongivedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "set_execution", "" );

    for (;;)
    {
        var_1 = getdvar( "set_execution", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self giveexecutionviadvar( var_1 );
            setdvar( "set_execution", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

giveexecutionviadvar( var_0 )
{
    scripts\cp_mp\execution::_giveexecution( var_0 );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Execution Set: ^7" + var_0 );
    self playlocalsound( "ui_mp_achieve_challenge" );
}

watchkillstreakgivedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "give_killstreak", "" );

    for (;;)
    {
        var_1 = getdvar( "give_killstreak", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self givekillstreakviadvr( var_1 );
            setdvar( "give_killstreak", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

givekillstreakviadvr( var_0 )
{
    var_1 = strtok( var_0, " " );
    var_2 = var_1[0];
    var_3 = 0;

    if ( var_1.size > 1 && var_1[1] == "1" )
        var_3 = 1;
    else if ( getdvarint( "ks_auto_activate", 1 ) > 0 )
        var_3 = 1;

    var_4 = scripts\mp\killstreaks\killstreaks::createstreakitemstruct( var_2 );

    if ( !isdefined( var_4 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid Killstreak: ^7" + var_2 );
        return;
    }

    scripts\mp\killstreaks\killstreaks::awardkillstreakfromstruct( var_4, "other" );

    if ( istrue( var_3 ) )
    {
        wait 0.1;
        self notify( "ks_action_4" );
    }

    self playlocalsound( "ui_killstreak_select" );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Killstreak Given: ^7" + var_2 + var_3 ? " ^4(Auto)" : "" );
}

watchsupergivedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "give_super", "" );

    for (;;)
    {
        var_1 = getdvar( "give_super", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self givesuperviadvr( var_1 );
            setdvar( "give_super", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

givesuperviadvr( var_0 )
{
    if ( !isdefined( var_0 ) || var_0 == "" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid super name" );
        return;
    }

    var_1 = level.superglobals.staticsuperdata[var_0];

    if ( !isdefined( var_1 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid super: ^7" + var_0 );
        return;
    }

    self thread scripts\mp\supers::givesuper( var_0, self, 1 );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Super Given: ^7" + var_0 );
}

watchequipmentgivedvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "give_equip", "" );

    for (;;)
    {
        var_1 = getdvar( "give_equip", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self giveequipmentviadvr( var_1 );
            setdvar( "give_equip", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

giveequipmentviadvr( var_0 )
{
    var_1 = getdvar( "equip_slot", "primary" );
    var_2 = getdvarint( "equip_ammo", 3 );
    var_3 = "primary";

    if ( var_1 == "secondary" || var_1 == "2" )
        var_3 = "secondary";
    else if ( var_1 == "primary" || var_1 == "1" )
        var_3 = "primary";

    scripts\mp\equipment::giveequipment( var_0, var_3 );
    wait 0.05;
    scripts\mp\equipment::setequipmentammo( var_0, var_2 );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Equipment Given: ^7" + var_0 + " ^3(" + var_3 + ") ^6x" + var_2 );
}

setequipmentammo( var_0, var_1 )
{
    var_2 = scripts\mp\equipment::getequipmenttableinfo( var_0 );

    if ( !isdefined( var_2.objweapon ) )
        return;

    self setweaponammoclip( var_2.objweapon, var_1 );
    scripts\mp\equipment::updateuiammocount( scripts\mp\equipment::findequipmentslot( var_0 ) );
}

watchbulletsdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "set_bullets", "" );
    var_1 = 0;

    for (;;)
    {
        var_2 = getdvar( "set_bullets", "" );

        if ( var_2 != var_0 )
        {
            var_0 = var_2;

            if ( var_2 == "" )
            {
                if ( var_1 )
                {
                    self notify( "stop_modded_bullets" );
                    var_1 = 0;
                    self custom_scripts\framework\sources\core\shared::customprint( "^1Modded Bullets Disabled" );
                }
            }
            else
            {
                if ( var_1 )
                    self notify( "stop_modded_bullets" );

                self thread moddedbulletsloop( var_2 );
                var_1 = 1;
                self custom_scripts\framework\sources\core\shared::customprint( "^2Modded Bullets: ^7" + var_2 );
            }
        }

        wait 0.1;
    }
}

moddedbulletsloop( var_0 )
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "stop_modded_bullets" );
    level endon( "game_ended" );
    var_1 = getcompleteweaponname( var_0 );

    if ( !isdefined( var_1 ) || var_1.basename == "none" )
        self custom_scripts\framework\sources\core\shared::customprint( "^1Invalid Projectile: ^7" + var_0 );

    for (;;)
    {
        self waittill( "weapon_fired" );
        var_2 = self geteye();
        var_3 = anglestoforward( self getplayerangles() );
        var_4 = var_2 + var_3 * 50;
        var_5 = var_2 + var_3 * 1000000;
        var_6 = scripts\cp_mp\utility\weapon_utility::_magicbullet( var_1, var_4, var_5, self );

        if ( isdefined( var_6 ) )
            var_6 thread handleprojectileeffects( var_0 );

        wait 0.05;
    }
}

handleprojectileeffects( var_0 )
{
    level endon( "game_ended" );
    self endon( "death" );

    switch ( var_0 )
    {
        case "emp_drone_proj_mp":
            playfxontag( scripts\engine\utility::getfx( "vfx/iw8/level/safehouse/vfx_safehouse_finale_drone_wingtip_red_lit.vfx" ), self, "tag_origin" );
            playfxontag( scripts\engine\utility::getfx( "vfx/iw8/level/safehouse/vfx_safehouse_finale_drone_contrails.vfx" ), self, "tag_origin" );
            self playloopsound( "iw8_rc_plane_engine" );
            self thread handleprojectileimpact( var_0 );
            break;
        case "ac130_105mm_mp":
            earthquake( 0.2, 1, self.origin, 1000 );
            self thread handleprojectileimpact( var_0 );
            break;
        case "ac130_40mm_mp":
            earthquake( 0.1, 0.5, self.origin, 1000 );
            self thread handleprojectileimpact( var_0 );
            break;
        default:
            self thread handleprojectileimpact( var_0 );
            break;
    }
}

handleprojectileimpact( var_0 )
{
    level endon( "game_ended" );
    self endon( "death" );
    self scripts\engine\utility::waittill_any_return( "missile_stuck", "collision", "explode", "death" );

    switch ( var_0 )
    {
        case "emp_drone_proj_mp":
            self playsound( "iw8_rc_plane_engine_exp" );
            playfx( scripts\engine\utility::getfx( "vfx/iw8_mp/perk/vfx_emp_drone_exp_fieldupgrades.vfx" ), self.origin, anglestoforward( self.angles ) );
            self radiusdamage( self.origin, 80, 120, 80, self.owner, "MOD_EXPLOSIVE", getcompleteweaponname( "emp_drone_player_mp" ) );
            earthquake( 0.3, 1, self.origin, 2000 );
            self stoploopsound( "iw8_rc_plane_engine" );
            break;
        case "white_phosphorus_proj_mp":
            self radiusdamage( self.origin, 512, 500, 500, self.owner, "MOD_EXPLOSIVE", getcompleteweaponname( var_0 ) );
            earthquake( 0.5, 1, self.origin, 3000 );
            break;
        case "cruise_proj_mp":
            self radiusdamage( self.origin, 600, 1000, 1000, self.owner, "MOD_EXPLOSIVE", getcompleteweaponname( var_0 ) );
            earthquake( 0.5, 1, self.origin, 3000 );
            playfxontag( scripts\engine\utility::getfx( "predator_pod_break" ), self, "tag_missile" );
            break;
    }

    wait 0.1;
}

watchnorecoildvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "no_recoil", 0 );

    if ( var_0 == 1 )
        thread applynorecoil();

    for (;;)
    {
        var_1 = getdvarint( "no_recoil", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self notify( "stop_no_recoil" );

            if ( var_1 == 1 )
            {
                thread applynorecoil();
                self custom_scripts\framework\sources\core\shared::customprint( "^2No Recoil Activated" );
            }
            else
            {
                self player_recoilscaleoff();
                self.recoilscale = undefined;
                self custom_scripts\framework\sources\core\shared::customprint( "^1No Recoil Deactivated" );
            }
        }

        wait 0.1;
    }
}

applynorecoil()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "stop_no_recoil" );
    level endon( "game_ended" );

    for (;;)
    {
        self.recoilscale = 100;
        self player_recoilscaleon( 0 );
        wait 0.05;
    }
}
