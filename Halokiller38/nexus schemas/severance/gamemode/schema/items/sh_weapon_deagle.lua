--[[
Name: "sh_weapon_deagle.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.base = "weapon_base";
ITEM.name = "Desert Eagle";
ITEM.model = "models/weapons/w_pist_deagle.mdl";
ITEM.weight = 1.5;
ITEM.uniqueID = "rcs_deagle";
ITEM.description = "A small silver pistol that packs a lot of punch.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(-180, 180, 90);
ITEM.attachmentOffsetVector = Vector(-4.19, 0, -8.54);

nexus.item.Register(ITEM);