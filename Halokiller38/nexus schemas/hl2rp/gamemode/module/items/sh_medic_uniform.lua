--[[
Name: "sh_medic_uniform.lua".
Product: "Half-Life 2".
--]]

local ITEM = {};

ITEM.base = "clothes_base";
ITEM.name = "Medic Uniform";
ITEM.group = "group03m";
ITEM.weight = 3;
ITEM.access = "m";
ITEM.business = true;
ITEM.protection = 0.1;
ITEM.description = "A resistance uniform with a medical insignia on the sleeve.";

-- Called when a replacement is needed for a player.
function ITEM:GetReplacement(player)
	if (string.lower( player:GetModel() ) == "models/humans/group01/jasona.mdl") then
		return "models/humans/group03m/male_02.mdl";
	end;
end;

resistance.item.Register(ITEM);