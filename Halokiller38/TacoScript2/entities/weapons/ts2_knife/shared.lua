if ( SERVER ) then 
   
 	AddCSLuaFile( "shared.lua" ) 
 
end 

 	SWEP.HoldType = "pistol";
 
if( CLIENT ) then
	
	SWEP.DrawCrosshair = false;

end

SWEP.Base = "ts2_base";
   
SWEP.Spawnable			= false 
SWEP.AdminSpawnable		= true 

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"; --model
SWEP.WorldModel = "models/weapons/w_knife_ct.mdl";

SWEP.PrintName = "Knife";
SWEP.TS2Desc = "A sharp and deadly knife";

SWEP.Price = 550;

SWEP.Primary.Delay = .09;
SWEP.Primary.Damage = 10;
SWEP.IsMelee = true;
SWEP.IsKnife = true;
 
SWEP.TS2HoldType = "PISTOL";

SWEP.Primary.HolsteredPos = Vector( 2.8, -2.0, -2.0 );
SWEP.Primary.HolsteredAng = Vector( -15.0, 15.0, 0.0 );
   
SWEP.ItemWidth = 1;
SWEP.ItemHeight = 1;

SWEP.IconCamPos = Vector( 14, -50, 7 )  
SWEP.IconLookAt = Vector( 3, 8, 0 )
SWEP.IconFOV = 22

SWEP.SwipeSounds = {
	
	"weapons/iceaxe/iceaxe_swing1.wav",
	"weapons/iceaxe/iceaxe_swing1.wav",
	
}

SWEP.HitSounds = {

	"weapons/knife/knife_hit1.wav",
	"weapons/knife/knife_hit2.wav",

}