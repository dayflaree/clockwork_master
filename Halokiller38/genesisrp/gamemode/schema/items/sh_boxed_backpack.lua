--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Boxed Backpack";
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 2;
ITEM.useText = "Open";
ITEM.category = "Storage"
ITEM.description = "A brown box, open it to reveal its contents.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:HasItem("backpack") and player:HasItem("backpack") >= 1) then
		openAura.player:Notify(player, "You've hit the backpacks limit!");
		
		return false;
	end;
	
	player:UpdateInventory("backpack", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);