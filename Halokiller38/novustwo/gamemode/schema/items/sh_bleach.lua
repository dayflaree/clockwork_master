--[[
Name: "sh_bleach.lua".
Product: "Novus Two".
--]]

local ITEM = {};

ITEM.base = "junk_base";
ITEM.name = "Bleach";
ITEM.model = "models/props_junk/garbage_plasticbottle001a.mdl";
ITEM.plural = "Bleaches";
ITEM.worth = 1;
ITEM.weight = 0.1;
ITEM.description = "A bottle of bleach, this is dangerous stuff.";

nexus.item.Register(ITEM);