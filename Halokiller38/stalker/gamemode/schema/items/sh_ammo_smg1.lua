--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.cost = 550;
ITEM.name = "5.56x45mm Rounds";
ITEM.batch = 1;
ITEM.model = "models/stalker/ammo/556x45.mdl";
ITEM.weight = 1;
ITEM.business = true;
ITEM.access = "T";
ITEM.uniqueID = "ammo_smg1";
ITEM.ammoClass = "smg1";
ITEM.ammoAmount = 60;
ITEM.description = "A large green container with 5.56x45mm on the side.";

openAura.item:Register(ITEM);