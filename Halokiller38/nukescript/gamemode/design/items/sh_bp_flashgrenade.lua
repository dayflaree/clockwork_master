--[[
Name: "sh_bp_flashgrenade.lua".
Product: "Day One".
--]]

local ITEM = {};

ITEM.base = "grenade_base";
ITEM.cost = 40;
ITEM.name = "M84-SG";
ITEM.model = "models/items/grenadeammo.mdl";
ITEM.batch = 1;
ITEM.weight = 0.3;
ITEM.access = "T";
ITEM.business = true;
ITEM.uniqueID = "bp_flashgrenade";
ITEM.description = "A dusty tube with something engraved on to it.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(90, 180, 0);
ITEM.attachmentOffsetVector = Vector(0, 6.55, 8.72);

blueprint.item.Register(ITEM);