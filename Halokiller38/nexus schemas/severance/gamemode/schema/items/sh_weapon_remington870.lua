--[[
Name: "sh_weapon_remington870.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.base = "weapon_base";
ITEM.name = "Remington .870";
ITEM.model = "models/weapons/w_remingt.mdl";
ITEM.weight = 4;
ITEM.uniqueID = "weapon_remington";
ITEM.weaponClass = "rcs_remington";
ITEM.description = "A perfect shotgun, it looks beautiful.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.loweredOrigin = Vector(3, 0, -4);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

nexus.item.Register(ITEM);