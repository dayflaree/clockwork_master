--[[
Name: "sh_weapon_ump45.lua".
Product: "Novus Two".
--]]

local ITEM = {};

ITEM.base = "weapon_base";
ITEM.cost = 500;
ITEM.name = "UMP9";
ITEM.model = "models/weapons/w_smg_ump45.mdl";
ITEM.weight = 3;
ITEM.uniqueID = "rcs_ump";
ITEM.description = "A dark grey firearm with a large magazine.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

nexus.item.Register(ITEM);