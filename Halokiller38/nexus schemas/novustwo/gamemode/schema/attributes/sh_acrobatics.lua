--[[
Name: "sh_acrobatics.lua".
Product: "Novus Two".
--]]

local ATTRIBUTE = {};

ATTRIBUTE.name = "Acrobatics";
ATTRIBUTE.maximum = 75;
ATTRIBUTE.uniqueID = "acr";
ATTRIBUTE.description = "Affects the overall height at which you can jump.";
ATTRIBUTE.characterScreen = true;

ATB_ACROBATICS = nexus.attribute.Register(ATTRIBUTE);