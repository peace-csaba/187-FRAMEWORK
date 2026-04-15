// 📌 187 — FRAMEWORK

////////////////////////////////////////////////////////////////////////

// File: visual.gsc

////////////////////////////////////////////////////////////////////////

// Modularized gamemode file: gm_visual

watchhuddvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "nohud", 0 );

    for (;;)
    {
        var_1 = getdvarint( "nohud", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            self setclientomnvar( "ui_hide_full_hud", var_1 );
            setdvar( "LOPKSRNTTS", var_1 == 1 ? 0 : 1 );
        }

        wait 0.2;
    }
}

watchweaponcamodvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "set_camo", "" );

    for (;;)
    {
        var_1 = getdvar( "set_camo", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self addcamotocurrentweapon( var_1 );
            setdvar( "set_camo", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

addcamotocurrentweapon( var_0 )
{
    var_1 = self getcurrentweapon();

    if ( !isdefined( var_1 ) || var_1.basename == "none" )
        return;

    var_2 = isdefined( var_1.variantid ) ? var_1.variantid : -1;
    var_3 = scripts\mp\class::buildweapon( scripts\mp\utility\weapon::getweaponrootname( var_1 ), var_1.attachments, var_0, "none", var_2, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap() );

    if ( !isdefined( var_3 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Failed to apply camo: ^7" + var_0 );
        return;
    }

    self scripts\cp_mp\utility\inventory_utility::_takeweapon( var_1 );
    wait 0.05;
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_3 );
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_3 );
    self custom_scripts\framework\sources\gamemode\combat::refillweaponammo( var_3 );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Camo Applied: ^7" + var_0 + var_2 >= 0 ? " ^6(Variant " + var_2 + " preserved)" : "" );
}

watchweaponattachmentdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "add_attachment", "" );

    for (;;)
    {
        var_1 = getdvar( "add_attachment", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self addattachmenttocurrentweapon( var_1 );
            setdvar( "add_attachment", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

addattachmenttocurrentweapon( var_0 )
{
    var_1 = self getcurrentweapon();

    if ( !isdefined( var_1 ) || var_1.basename == "none" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1No weapon equipped" );
        return;
    }

    var_2 = isdefined( var_1.variantid ) ? var_1.variantid : -1;
    var_3 = isdefined( var_1.camo ) ? var_1.camo : "none";
    var_4 = scripts\mp\weapons::addattachmenttoweapon( var_1, var_0 );

    if ( !isdefined( var_4 ) )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Failed to add attachment: ^7" + var_0 );
        return;
    }

    self scripts\cp_mp\utility\inventory_utility::_takeweapon( var_1 );
    wait 0.05;
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_4 );
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_4 );
    self custom_scripts\framework\sources\gamemode\combat::refillweaponammo( var_4 );
    var_5 = "^2Attachment Added: ^7" + var_0;

    if ( var_2 >= 0 )
        var_5 = var_5 + ( " ^6(Variant " + var_2 + ")" );

    if ( var_3 != "none" )
        var_5 = var_5 + ( " ^6(" + var_3 + ")" );

    self custom_scripts\framework\sources\core\shared::customprint( var_5 );
}

watchakimbodvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = 0;

    for (;;)
    {
        var_1 = getdvarint( "akimbo", -1 );
        var_2 = gettime();

        if ( var_1 != -1 && var_2 - var_0 > 500 )
        {
            var_0 = var_2;

            if ( var_1 == 0 )
                self applyakimbotocurrentweapon( 0 );
            else if ( var_1 == 1 )
                self applyakimbotocurrentweapon( 1 );

            setdvar( "akimbo", -1 );
        }

        wait 0.1;
    }
}

applyakimbotocurrentweapon( var_0 )
{
    var_1 = self getcurrentweapon();

    if ( !isdefined( var_1 ) || !isdefined( var_1.basename ) || var_1.basename == "none" || var_1.basename == "" || var_1.basename == "iw8_me_fists" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Cannot apply akimbo to current weapon" );
        return;
    }

    var_2 = isdefined( var_1.attachments ) ? var_1.attachments : [];
    var_3 = isdefined( var_1.camo ) ? var_1.camo : "none";
    var_4 = isdefined( var_1.variantid ) ? var_1.variantid : -1;
    var_5 = scripts\mp\utility\weapon::getweaponrootname( var_1 );

    if ( !isdefined( var_5 ) )
        var_5 = var_1.basename;

    var_6 = scripts\mp\class::buildweapon( var_5, var_2, var_3, "none", var_4, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap() );

    if ( !isdefined( var_6 ) || var_6.basename == "none" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Failed to build weapon" );
        return;
    }

    self scripts\cp_mp\utility\inventory_utility::_takeweapon( var_1 );
    wait 0.1;
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_6, undefined, var_0, 1 );
    wait 0.05;
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_6 );
    wait 0.05;
    self custom_scripts\framework\sources\gamemode\combat::refillweaponammo( var_6 );
    self custom_scripts\framework\sources\core\shared::customprint( var_0 ? "^2Enabled" : "^1Disabled" + " ^7akimbo: ^3" + var_5 + var_4 >= 0 ? " ^6(Variant " + var_4 + ")" : "" );
}

watchweaponvariantdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "give_variant", "" );

    for (;;)
    {
        var_1 = getdvar( "give_variant", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self applyvarianttocurrentweapon( int( var_1 ) );
            setdvar( "give_variant", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

applyvarianttocurrentweapon( var_0 )
{
    var_1 = self getcurrentweapon();

    if ( !isdefined( var_1 ) || var_1.basename == "none" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1No weapon equipped" );
        return;
    }

    var_2 = isdefined( var_1.attachments ) ? var_1.attachments : [];
    var_3 = isdefined( var_1.camo ) ? var_1.camo : "none";
    var_4 = scripts\mp\utility\weapon::getweaponrootname( var_1 );

    if ( !isdefined( var_4 ) )
        var_4 = var_1.basename;

    var_5 = scripts\mp\class::buildweapon( var_4, var_2, var_3, "none", var_0, undefined, undefined, undefined, scripts\cp_mp\utility\game_utility::isnightmap() );

    if ( !isdefined( var_5 ) || var_5.basename == "none" )
    {
        self custom_scripts\framework\sources\core\shared::customprint( "^1Failed to apply variant: ^7" + var_0 );
        return;
    }

    self scripts\cp_mp\utility\inventory_utility::_takeweapon( var_1 );
    wait 0.05;
    self scripts\cp_mp\utility\inventory_utility::_giveweapon( var_5 );
    self scripts\cp_mp\utility\inventory_utility::_switchtoweaponimmediate( var_5 );
    self custom_scripts\framework\sources\gamemode\combat::refillweaponammo( var_5 );
    var_6 = "^2Variant Applied: ^7" + var_0;

    if ( var_3 != "none" )
        var_6 = var_6 + ( " ^6(Camo: " + var_3 + ")" );

    if ( var_2.size > 0 )
        var_6 = var_6 + ( " ^3(" + var_2.size + " attachments)" );

    self custom_scripts\framework\sources\core\shared::customprint( var_6 );
    self playlocalsound( "ui_mp_weapon_pickup" );
}

watchnightvisiondvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvarint( "nvg", 0 );

    if ( var_0 == 1 )
        thread enablenightvision();

    for (;;)
    {
        var_1 = getdvarint( "nvg", 0 );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;

            if ( var_1 == 1 )
            {
                thread enablenightvision();
                self custom_scripts\framework\sources\core\shared::customprint( "^2Night Vision Activated" );
            }
            else
            {
                thread disablenightvision();
                self custom_scripts\framework\sources\core\shared::customprint( "^1Night Vision Deactivated" );
            }
        }

        wait 0.1;
    }
}

enablenightvision()
{
    thread scripts\mp\equipment\nvg::runnvg();
}

disablenightvision()
{
    self nightvisionviewoff();
    self notify( "nvg_monitor" );
    scripts\mp\equipment\nvg::clearnvg( 1 );
}

watchvisionsetdvar()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    var_0 = getdvar( "set_vision", "" );

    for (;;)
    {
        var_1 = getdvar( "set_vision", "" );

        if ( var_0 != var_1 )
        {
            var_2 = getdvarint( "override_vision", 0 );

            if ( var_2 == 1 || var_1 != "" )
            {
                foreach ( var_4 in level.players )
                    var_4 scripts\cp_mp\utility\game_utility::_visionsetnakedforplayer( "", 0 );

                wait 0.2;
            }

            if ( var_1 != "" )
            {
                foreach ( var_4 in level.players )
                {
                    var_4 scripts\cp_mp\utility\game_utility::_visionsetnakedforplayer( var_1, 0.5 );
                    var_4 custom_scripts\framework\sources\core\shared::customprint( "^2Visionset Applied: ^7" + var_1 );
                }
            }
            else
            {
                foreach ( var_4 in level.players )
                {
                    var_4 scripts\cp_mp\utility\game_utility::_visionsetnakedforplayer( "", 0 );
                    var_4 custom_scripts\framework\sources\core\shared::customprint( "^1Visionset Cleared" );
                }
            }

            setdvar( "set_vision", "" );
            var_0 = "";
        }

        wait 0.05;
    }
}

watchbodysetdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "set_body", "" );

    for (;;)
    {
        var_1 = getdvar( "set_body", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self setbodyviadvar( var_1 );
            setdvar( "set_body", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

setbodyviadvar( var_0 )
{
    if ( isdefined( self.headmodel ) )
    {
        self detach( self.headmodel );
        self.headmodel = undefined;
    }

    self setmodel( var_0 );
    var_1 = self getcustomizationhead();

    if ( isdefined( var_1 ) && var_1 != "" )
    {
        self attach( var_1, "", 1 );
        self.headmodel = var_1;
    }

    self custom_scripts\framework\sources\core\shared::customprint( "^2Body Model Set: ^7" + var_0 );
    self playlocalsound( "ui_mp_achieve_challenge" );
}

watchheadsetdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "set_head", "" );

    for (;;)
    {
        var_1 = getdvar( "set_head", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self setheadviadvar( var_1 );
            setdvar( "set_head", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

setheadviadvar( var_0 )
{
    if ( isdefined( self.headmodel ) )
    {
        self detach( self.headmodel );
        self.headmodel = undefined;
    }

    self attach( var_0, "", 1 );
    self.headmodel = var_0;
    self custom_scripts\framework\sources\core\shared::customprint( "^2Head Model Set: ^7" + var_0 );
    self playlocalsound( "ui_mp_achieve_challenge" );
}

watchviewmodelsetdvar()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    var_0 = getdvar( "set_viewmodel", "" );

    for (;;)
    {
        var_1 = getdvar( "set_viewmodel", "" );

        if ( var_1 != var_0 && var_1 != "" )
        {
            var_0 = var_1;
            self setviewmodelviadvar( var_1 );
            setdvar( "set_viewmodel", "" );
            var_0 = "";
        }

        wait 0.1;
    }
}

setviewmodelviadvar( var_0 )
{
    self setviewmodel( var_0 );
    self custom_scripts\framework\sources\core\shared::customprint( "^2Viewmodel Set: ^7" + var_0 );
    self playlocalsound( "ui_mp_achieve_challenge" );
}

watchselfoutlinedvar()
{
    self endon( "disconnect" );
    level endon( "game_ended" );
    var_0 = "0";

    for (;;)
    {
        var_1 = tolower( getdvar( "self_outline", "0" ) );

        if ( var_1 != var_0 )
        {
            var_0 = var_1;
            scripts\mp\utility\outline::_hudoutlineviewmodeldisable();
            wait 0.05;

            if ( var_1 == "0" || var_1 == "off" || var_1 == "" )
                self custom_scripts\framework\sources\core\shared::customprint( "^2Viewmodel outline: ^7Disabled" );
            else
            {
                var_2 = custom_scripts\framework\sources\gamemode\bots::parse_outline_input( var_1 );
                self custom_scripts\framework\sources\core\shared::customprint( "^2Viewmodel outline: ^7" + var_2 );
                scripts\mp\utility\outline::_hudoutlineviewmodelenable( var_2, 0 );
            }
        }

        wait 0.5;
    }
}

get_player_by_entnum( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( var_2 getentitynumber() == var_0 )
            return var_2;
    }

    return undefined;
}
