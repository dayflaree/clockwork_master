--[[
	Free Clockwork!
--]]

ITEM = Clockwork.item:New("custom_weapon");
ITEM.name = "Galil";
ITEM.cost = 4000;
ITEM.model = "models/weapons/w_rif_galil.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.batch = 1;
ITEM.access = "V";
ITEM.weaponClass = "rcs_galil";
ITEM.description = "An averaged sized firearm with an orange tint.\nThis firearm utilises 5.56x45mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

Clockwork.item:Register(ITEM);