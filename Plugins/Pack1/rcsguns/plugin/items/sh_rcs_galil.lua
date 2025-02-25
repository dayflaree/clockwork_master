local ITEM = Clockwork.item:New("special_weapon");
	ITEM.name = "IMI Galil AR";
	ITEM.useSound = "items/gift_pickup.wav";
	ITEM.cost = 6000;
	ITEM.batch = 3;
	ITEM.model = "models/weapons/w_rif_galil.mdl";
	ITEM.weight = 3;
	ITEM.access = "MV";
	ITEM.uniqueID = "rcs_galil";
	ITEM.business = true;
	ITEM.description = "Heavily modified by Resistance members to chamber the much-more-common 4.6mm round, this restored Galil would feel right at home in Eridian's hands.";
	ITEM.isAttachment = true;
	ITEM.hasFlashlight = true;
	ITEM.loweredOrigin = Vector(-5, 4, 7);
	ITEM.loweredAngles = Angle(0, 45, 0);
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine4";
	ITEM.attachmentOffsetAngles = Angle(20, 5, 170);
	ITEM.attachmentOffsetVector = Vector(-12, -2, -10);
ITEM:Register();