--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "alcohol_base";
ITEM.cost = 50;
ITEM.name = "Beer";
ITEM.model = "models/props_junk/garbage_glassbottle001a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.25;
ITEM.business = true;
ITEM.access = "T";
ITEM.description = "A glass bottle filled with liquid, it has a funny smell.";

-- Called when a player drinks the item.
function ITEM:OnDrink(player)
	player:UpdateInventory("empty_beer_bottle", 1, true);
end;

openAura.item:Register(ITEM);