--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "P90";
ITEM.cost = 4200;
ITEM.model = "models/weapons/w_smg_p90.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.access = "T";
ITEM.weaponClass = "rcs_p90";
ITEM.description = "A grey firearm with a large magazine.\nThis firearm utilises 5.7x28mm ammunition.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);

openAura.item:Register(ITEM);