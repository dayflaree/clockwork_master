if( SERVER ) then
   
 	AddCSLuaFile( "shared.lua" ) 
 
 end
 
 
 
if( CLIENT ) then

	SWEP.ViewModelFlip		= true	
	SWEP.CSMuzzleFlashes	= true
	SWEP.MuzzleEffect		= "rg_muzzle_cmb"
	SWEP.DrawCrosshair = false;
 
end


 SWEP.Base = "ts2_base";
   
 SWEP.Spawnable			= false 
 SWEP.AdminSpawnable		= true 
   

SWEP.Primary.Sound = Sound( "Weapons/sg552/sg552-1.wav" );

SWEP.WorldModel = "models/weapons/w_snip_sg550.mdl";
SWEP.ViewModel = "models/weapons/v_snip_sg550.mdl";

SWEP.PrintName = "Sig SG550 Recon Rifle";
SWEP.TS2Desc = "Resistance Marksman Weapon";

SWEP.Price = 5500;


 SWEP.Primary.Recoil			= .2 
 SWEP.Primary.RecoilAdd			= .3
 SWEP.Primary.RecoilMin = .3
 SWEP.Primary.RecoilMax = .5
 
 SWEP.Primary.ViewPunchMul = 2;
 SWEP.Primary.Damage			= 25
 SWEP.Primary.NumShots		= 1 
 
 SWEP.TS2HoldType = "RIFLE";

SWEP.Primary.ClipSize = 20;
SWEP.Primary.DefaultClip = 60;
SWEP.Primary.Ammo = "smg1";
SWEP.Primary.Delay = .1;
SWEP.Primary.Automatic = false;
SWEP.Primary.SpreadCone = Vector( 0.01, 0.01, 0.01 );

 SWEP.Primary.IronSightPos = Vector( -6.4, 2.5, -9.0 );
 SWEP.Primary.IronSightAng = Vector( 0.0, 0.0, 0.0 );

SWEP.Primary.HolsteredPos = Vector( -0.8, -1.0, -10.0 );
SWEP.Primary.HolsteredAng = Vector( 0.0, -50.0, 0.0 );

SWEP.ItemWidth = 4;
SWEP.ItemHeight = 1;

SWEP.IconCamPos = Vector( 90, 0, 0 ) 
SWEP.IconLookAt = Vector( 0, -3, 1 ) 
SWEP.IconFOV = 11


function SWEP:HolsterToggle()

	self.Owner:ConCommand( "eng_seescope 0\n" );

end

if( CLIENT ) then

	SeeSniperScope = false;

	function SWEP:DrawHUD()

		if( math.floor( self.Primary.PositionMode ) == 1 and math.floor( self.Primary.PositionMul ) == 1 ) then 

			if( not SeeSniperScope ) then
			
				RunConsoleCommand( "eng_seescope", "1" );
				SeeSniperScope = true;

			end
			
			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetTexture(surface.GetTextureID("jaanus/ep2snip_parascope"))
			surface.DrawTexturedRect(self.ParaScopeTable.x,self.ParaScopeTable.y,self.ParaScopeTable.w,self.ParaScopeTable.h)
			
			-- Draw the lens
			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetTexture(surface.GetTextureID("overlays/scope_lens"))
			surface.DrawTexturedRect(self.LensTable.x,self.LensTable.y,self.LensTable.w,self.LensTable.h)

			-- Draw the scope
			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetTexture(surface.GetTextureID("jaanus/sniper_corner"))
			surface.DrawTexturedRectRotated(self.ScopeTable.x1,self.ScopeTable.y1,self.ScopeTable.l,self.ScopeTable.l,270)
			surface.DrawTexturedRectRotated(self.ScopeTable.x2,self.ScopeTable.y2,self.ScopeTable.l,self.ScopeTable.l,180)
			surface.DrawTexturedRectRotated(self.ScopeTable.x3,self.ScopeTable.y3,self.ScopeTable.l,self.ScopeTable.l,90)
			surface.DrawTexturedRectRotated(self.ScopeTable.x4,self.ScopeTable.y4,self.ScopeTable.l,self.ScopeTable.l,0)

			-- Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(self.QuadTable.x1,self.QuadTable.y1,self.QuadTable.w1,self.QuadTable.h1)
			surface.DrawRect(self.QuadTable.x2,self.QuadTable.y2,self.QuadTable.w2,self.QuadTable.h2)
			surface.DrawRect(self.QuadTable.x3,self.QuadTable.y3,self.QuadTable.w3,self.QuadTable.h3)
			surface.DrawRect(self.QuadTable.x4,self.QuadTable.y4,self.QuadTable.w4,self.QuadTable.h4)
			
			local rotatick = CurTime()*90/5
			surface.SetTexture(surface.GetTextureID("jaanus/rotatingthing"))
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawTexturedRectRotated(ScrW()/2, ScrH()/2,self.LensTable.w * 1.2, self.LensTable.h * 1.2, rotatick)
		
		else
		
			if( SeeSniperScope ) then
			
				RunConsoleCommand( "eng_seescope", "0" );
				SeeSniperScope = false;
				
			end
		
		end
		
	end
	
end