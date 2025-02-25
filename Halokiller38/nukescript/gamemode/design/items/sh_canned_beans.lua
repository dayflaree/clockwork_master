--[[
Name: "sh_canned_beans.lua".
Product: "Day One".
--]]

local ITEM = {};

ITEM.name = "Canned Beans";
ITEM.cost = 6;
ITEM.model = "models/props_lab/jar01b.mdl";
ITEM.batch = 1;
ITEM.weight = 0.3;
ITEM.access = "T";
ITEM.useText = "Eat";
ITEM.business = true;
ITEM.useSound = "npc/barnacle/barnacle_crunch2.wav";
ITEM.category = "Consumables";
ITEM.description = "A tinned can, it slushes when you shake it.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + 4, 0, player:GetMaxHealth() ) );
	player:UpdateInventory("empty_plastic_jar", 1, true);
	player:BoostAttribute("Hunger", ATB_ENDURANCE, 30, 3600);
	player:BoostAttribute("Hunger", ATB_STRENGTH, 30, 3600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

blueprint.item.Register(ITEM);