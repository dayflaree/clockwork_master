--[[
Name: "sh_empty_soda_bottle.lua".
Product: "Novus Two".
--]]

local ITEM = {};

ITEM.base = "junk_base";
ITEM.name = "Empty Soda Bottle";
ITEM.worth = 1;
ITEM.model = "models/props_junk/garbage_plasticbottle003a.mdl";
ITEM.weight = 0.1
ITEM.description = "An empty soda bottle.";

nexus.item.Register(ITEM);