--[[ 
    � 2015 CloudSixteen.com do not share, re-distribute or modify
    without permission of its author (kurozael@gmail.com).

    Clockwork was created by Conna Wiles (also known as kurozael.)
    http://cloudsixteen.com/license/clockwork.html

    Atomic was developed by NightAngel, if you have any questions or
    wish to give any feedback whatsoever, please send a message to
    http://steamcommunity.com/id/NA1455.
--]]

local ITEM = Clockwork.item:New("weapon_base");
	ITEM.cost = 2200;
	ITEM.health = 300;
	ITEM.name = "Hunting Rifle";
	ITEM.category = "Small Guns";
	ITEM.model = "models/Halokiller38/fallout/weapons/Rifles/huntingrifleext.mdl";
	ITEM.batch = 1;
	ITEM.weight = 6;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.weaponClass = "weapon_huntingrifleext";
	ITEM.description = "A rusted looking rifle with an extended mag.\nThis firearm utilises .308 ammunition.";
	ITEM.isAttachment = true;
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 0);
	ITEM.attachmentOffsetVector = Vector(-3.96, 4.95, -2.97);
	ITEM.loweredAngles = Angle(-35, 10, -14);
ITEM:Register();