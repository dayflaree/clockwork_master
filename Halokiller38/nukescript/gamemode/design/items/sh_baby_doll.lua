--[[
Name: "sh_baby_doll.lua".
Product: "Day One".
--]]

local ITEM = {};

ITEM.base = "junk_base";
ITEM.name = "Baby Doll";
ITEM.worth = 1;
ITEM.model = "models/props_c17/doll01.mdl";
ITEM.weight = 0.1
ITEM.description = "An old baby doll, it's missing an eye.";

blueprint.item.Register(ITEM);