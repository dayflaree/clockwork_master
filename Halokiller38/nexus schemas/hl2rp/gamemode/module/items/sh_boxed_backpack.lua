--[[
Name: "sh_boxed_backpack.lua".
Product: "Half-Life 2".
--]]

local ITEM = {};

ITEM.name = "Boxed Backpack";
ITEM.cost = 25;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 2;
ITEM.access = "1v";
ITEM.useText = "Open";
ITEM.category = "Storage"
ITEM.business = true;
ITEM.description = "A brown box, open it to reveal its contents.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:HasItem("backpack") and player:HasItem("backpack") >= 1) then
		resistance.player.Notify(player, "You've hit the backpacks limit!");
		
		return false;
	end;
	
	player:UpdateInventory("backpack", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

resistance.item.Register(ITEM);