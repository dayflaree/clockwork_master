--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Chinese Takeout";
ITEM.cost = 75;
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.35;
ITEM.business = true;
ITEM.access = "T";
ITEM.useText = "Eat";
ITEM.business = true;
ITEM.useSound = "npc/barnacle/barnacle_crunch2.wav";
ITEM.category = "Consumables"
ITEM.description = "A takeout carton, it's filled with cold noodles.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + 8, 0, player:GetMaxHealth() ) );
	player:UpdateInventory("empty_takeout_carton", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);