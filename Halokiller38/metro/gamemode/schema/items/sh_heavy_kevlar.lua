--[[
Name: "sh_heavy_kevlar.lua".
Product: "Phase Four".
--]]

ITEM = openAura.item:New();
ITEM.name = "Heavy Kevlar";
ITEM.model = "models/weapons/w_suitcase_passenger.mdl";
ITEM.weight = 1;
ITEM.useText = "Wear";
ITEM.category = "Clothing";
ITEM.batch = 1;
ITEM.cost = 6;
ITEM.access = "U";
ITEM.business = true;
ITEM.description = "A kevlar vest that provides you with heavy bodyarmor.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine2";
ITEM.attachmentModel = "models/kevlarvest/kevlarhevy.mdl";
ITEM.attachmentOffsetAngles = Angle(0, 270, 90);
ITEM.attachmentOffsetVector = Vector(0, -3, -56);

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	local model = player:GetModel();
	
	if ( string.find(model, "group%d%d") or string.find(model, "tactical_rebel")
	or string.find(model, "male_experim") ) then
		if (player:Armor() > 0) then
			return true;
		end;
	end;
end;

-- Called when the attachment model scale is needed.
function ITEM:GetAttachmentModelScale(player, entity)
	if ( string.find(player:GetModel(), "female") ) then
		return Vector() * 0.9;
	end;
end;

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if ( string.find(player:GetModel(), "female") ) then
		info.offsetVector = Vector(0, -1.5, -52);
		info.offsetAngle = Angle(10, 270, 80);
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	openAura.player:CreateGear(player, "KevlarVest", self);

		player:SetArmor(200);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);