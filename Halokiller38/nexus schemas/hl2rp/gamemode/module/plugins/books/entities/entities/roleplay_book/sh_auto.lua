--[[
Name: "sh_auto.lua".
Product: "Kyron".
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "Dazzle Modifications";
ENT.PrintName = "Book";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

-- Called when the entity initializes.
function ENT:SharedInitialize()
	resistance.entity.RegisterSharedVars( self, {
		{"sh_Index", NWTYPE_NUMBER},
	} );
end;