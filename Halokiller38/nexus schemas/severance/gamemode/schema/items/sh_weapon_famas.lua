--[[
Name: "sh_weapon_famas.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.base = "weapon_base";
ITEM.name = "Famas";
ITEM.model = "models/weapons/w_rif_famas.mdl";
ITEM.weight = 3;
ITEM.uniqueID = "rcs_famas";
ITEM.description = "A long grey weapon with burst fire.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

nexus.item.Register(ITEM);