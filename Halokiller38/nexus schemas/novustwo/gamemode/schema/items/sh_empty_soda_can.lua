--[[
Name: "sh_empty_soda_can.lua".
Product: "Novus Two".
--]]

local ITEM = {};

ITEM.base = "junk_base";
ITEM.name = "Empty Soda Can";
ITEM.worth = 1;
ITEM.model = "models/props_junk/popcan01a.mdl";
ITEM.weight = 0.1
ITEM.description = "An empty soda can.";

nexus.item.Register(ITEM);