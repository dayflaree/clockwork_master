--[[
Name: "sh_weapon_m4a1.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.base = "weapon_base";
ITEM.name = "M4A1";
ITEM.model = "models/weapons/w_rif_m4a1.mdl";
ITEM.weight = 3;
ITEM.uniqueID = "weapon_m4a1";
ITEM.weaponClass = "rcs_m4a1";
ITEM.description = "A smooth black weapon with a shiny tint.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

nexus.item.Register(ITEM);