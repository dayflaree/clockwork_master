local ITEM = Clockwork.item:New("special_weapon");
	ITEM.name = "H&K USP-Match";
	ITEM.useSound = "items/gift_pickup.wav";
	ITEM.cost = 915;
	ITEM.batch = 3;
	ITEM.model = "models/weapons/w_pistol.mdl";
	ITEM.isRareSpawn = true;
	ITEM.spawnValue = 1;
	ITEM.weight = 1.5;
	ITEM.access = "MV";
	ITEM.uniqueID = "rcs_uspmatch";
	ITEM.business = true;
	ITEM.description = "Originally discontinued in 1999, this aftermarket USP-Match features a fixed compensator and barrel weighting, reducing recoil and allowing the user greater control over follow-up shots.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.loweredOrigin = Vector(3, 0, -4);
	ITEM.loweredAngles = Angle(0, 45, 0);
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 90);
	ITEM.attachmentOffsetVector = Vector(0, 4, -8);
ITEM:Register();