

SWEP.PrintName			= "5.56MM M4A1"					// 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 3							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot

// Override this in your SWEP to set the icon in the weapon selection
if (file.Exists("../materials/weapons/weapon_mad_m4.vmt")) then
	SWEP.WepSelectIcon	= surface.GetTextureID("weapons/weapon_mad_m4")
end
