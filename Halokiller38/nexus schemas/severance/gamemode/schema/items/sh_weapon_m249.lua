--[[
Name: "sh_weapon_m249.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.base = "weapon_base";
ITEM.name = "M249";
ITEM.model = "models/weapons/w_mach_m249para.mdl";
ITEM.weight = 4;
ITEM.uniqueID = "weapon_m249";
ITEM.weaponClass = "rcs_m249";
ITEM.description = "A very big machine gun - usually attached to a barricade.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.loweredAngles = Angle(-10, 40, -40);
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

nexus.item.Register(ITEM);