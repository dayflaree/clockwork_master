--[[
Name: "sh_melon.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.name = "Melon";
ITEM.model = "models/props_junk/watermelon01.mdl";
ITEM.weight = 1;
ITEM.useText = "Eat";
ITEM.category = "Consumables"
ITEM.description = "A green fruit, it has a hard outer shell.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp(player:Health() + 10, 0, 100) );
	
	player:BoostAttribute(self.name, ATB_ACROBATICS, 2, 600);
	player:BoostAttribute(self.name, ATB_AGILITY, 2, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

nexus.item.Register(ITEM);