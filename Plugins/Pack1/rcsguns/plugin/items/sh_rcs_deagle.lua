local ITEM = Clockwork.item:New("special_weapon");
	ITEM.name = "IMI Desert Eagle";
	ITEM.useSound = "items/gift_pickup.wav";
	ITEM.cost = 3000;
	ITEM.batch = 3;
	ITEM.model = "models/weapons/w_pist_deagle.mdl";
	ITEM.weight = 1.5;
	ITEM.access = "MV";
	ITEM.uniqueID = "rcs_deagle";
	ITEM.business = true;
	ITEM.description = "The ubiquitously-known Desert Eagle, or 'Deagle', chambered in .357 Magnum rounds. A sleek, powerful weapon ideal for poppin' heads... just don't go too nuts, the recoil is quite intense.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.loweredOrigin = Vector(-5, -2, -8);
	ITEM.loweredAngles = Angle(0, 0, 270);
	ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis";
	ITEM.attachmentOffsetAngles = Angle(0, 0, 90);
	ITEM.attachmentOffsetVector = Vector(0, 4, -8);
ITEM:Register();