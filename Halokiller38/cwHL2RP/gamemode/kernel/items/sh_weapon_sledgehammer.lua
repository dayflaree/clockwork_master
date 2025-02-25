--[[
	Free Clockwork!
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "Sledgehammer";
ITEM.cost = 350;

ITEM.model = "models/weapons/w_sledgehammer.mdl";
ITEM.weight = 2;
ITEM.business = true;
ITEM.batch = 1;
ITEM.access = "v";
ITEM.category = "Melee";
ITEM.weaponClass = "cw_sledgehammer";
ITEM.description = "A long and brutal sledgehammer with a bloody tip.";
ITEM.isMeleeWeapon = true;
ITEM.isAttachment = true;
ITEM.loweredOrigin = Vector(-12, 2, 0);
ITEM.loweredAngles = Angle(-25, 15, -80);
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 255, 0);
ITEM.attachmentOffsetVector = Vector(5, 5, -8);

Clockwork.item:Register(ITEM);