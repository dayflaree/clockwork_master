--[[
Name: "sh_ammo_sniper.lua".
Product: "Severance".
--]]

local ITEM = {};

ITEM.base = "ammo_base";
ITEM.name = "7.65x59mm Rounds";
ITEM.model = "models/items/redammo.mdl";
ITEM.weight = 0.35;
ITEM.uniqueID = "ammo_sniper";
ITEM.ammoClass = "ar2";
ITEM.ammoAmount = 8;
ITEM.description = "A red container with 7.65x59mm on the side.";

nexus.item.Register(ITEM);