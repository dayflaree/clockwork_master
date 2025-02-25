--[[
	Free Clockwork!
--]]

ITEM = Clockwork.item:New();
ITEM.batch = 5;
ITEM.name = "Bandage";
ITEM.cost = 20;
ITEM.model = "models/props_wasteland/prison_toiletchunk01f.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Apply";
ITEM.category = "Medical"
ITEM.business = true;
ITEM.description = "A bandage roll, there isn't much so use it wisely.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + Clockwork.schema:GetHealAmount(player), 0, player:GetMaxHealth()));
	Clockwork.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Give") then
		Clockwork.player:RunClockworkCommand(player, "CharHeal", "bandage");
	end;
end;

Clockwork.item:Register(ITEM);