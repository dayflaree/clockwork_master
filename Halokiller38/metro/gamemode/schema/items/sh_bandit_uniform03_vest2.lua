--[[
Name: "sh_ceda_uniform.lua".
Product: "Severance".
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.name = "Bandit Uniform03 - Vest2";
ITEM.weight = 2;
ITEM.runSound = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav"
};
ITEM.iconModel = "models/avoxgaming/mrp/jake/bandit_vest2.mdl";
ITEM.protection = 0.2;
ITEM.description = "A tactical uniform.";
ITEM.replacement = "models/avoxgaming/mrp/jake/bandit_vest2.mdl";
ITEM.pocketSpace = 2;
ITEM.batch = 1;
ITEM.cost = 1;
ITEM.access = "8";
ITEM.business = true;

openAura.item:Register(ITEM);