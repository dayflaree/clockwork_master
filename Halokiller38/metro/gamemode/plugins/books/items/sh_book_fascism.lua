--[[
Name: "sh_book_tfw.lua".
Product: "Infusion".
--]]

ITEM = openAura.item:New();

ITEM.base = "book_base";
ITEM.name = "Facism.";
ITEM.model = "models/avoxgaming/mrp/jake/props/book2.mdl";
ITEM.cost = 11;
ITEM.uniqueID = "book_fascism";
ITEM.description = "A blood about fascism.";
ITEM.bookInformation = [[

]];

openAura.item:Register(ITEM);