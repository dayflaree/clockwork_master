--[[
Name: "sh_chinese_takeout.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.name = "Chinese Takeout";
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.weight = 0.8;
ITEM.useText = "Eat";
ITEM.category = "Consumables"
ITEM.description = "A takeout carton, it's filled with cold noodles.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + 10, 0, player:GetMaxHealth() ) );
	
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 600);
	player:BoostAttribute(self.name, ATB_ACCURACY, 1, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

nexus.item.Register(ITEM);