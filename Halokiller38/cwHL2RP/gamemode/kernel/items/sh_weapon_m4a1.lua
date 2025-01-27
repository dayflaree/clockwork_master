--[[
	Free Clockwork!
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "M4A1";
ITEM.cost = 4800;
ITEM.model = "models/weapons/w_rif_m4a1.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.batch = 1;
ITEM.access = "V";
ITEM.weaponClass = "rcs_m4a1";
ITEM.description = "A smooth black firearm with a shiny tint.\nThis firearm utilises 5.56x45mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

Clockwork.item:Register(ITEM);