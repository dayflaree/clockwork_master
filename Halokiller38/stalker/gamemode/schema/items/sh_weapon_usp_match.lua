--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "weapon_base";
ITEM.name = "USP-M";
ITEM.cost = 1400;
ITEM.model = "models/weapons/w_pistol.mdl";
ITEM.weight = 1.5;
ITEM.business = true;
ITEM.weaponClass = "rcs_uspmatch";
ITEM.description = "A small, compact and accurate pistol.\nThis firearm utilises 9x19mm ammunition.";
ITEM.isAttachment = true;
ITEM.hasFlashlight = true;
ITEM.loweredOrigin = Vector(5, -4, -3);
ITEM.loweredAngles = Angle(0, 45, 0);
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
ITEM.attachmentOffsetAngles = Angle(0, 0, 90);
ITEM.attachmentOffsetVector = Vector(0, 4, -8);

openAura.item:Register(ITEM);