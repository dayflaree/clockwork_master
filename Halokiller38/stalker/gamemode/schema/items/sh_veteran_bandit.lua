--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "bandit_base";
ITEM.cost = 7500;
ITEM.name = "Veteran Bandit Armor";
ITEM.weight = 1;
ITEM.business = true;
ITEM.armorScale = 0.30;
ITEM.replacement = "models/stalkertnb/bandit2.mdl";
ITEM.description = "A Veteran Bandit Cloak. Gives 30% Bullet Protection";

openAura.item:Register(ITEM);