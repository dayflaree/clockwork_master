--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "BioVial";
ITEM.model = "models/healthvial.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Drink";
ITEM.category = "Medical"
ITEM.useSound = "items/medshot4.wav";
ITEM.uniqueID = "health_vial";
ITEM.description = "A strange vial filled with green liquid, be careful.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth( math.Clamp( player:Health() + openAura.schema:GetHealAmount(player, 1.5), 0, player:GetMaxHealth() ) );
	
	openAura.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Give") then
			openAura.player:RunOpenAuraCommand(player, "CharHeal", "health_vial");
		end;
	end;
end;

openAura.item:Register(ITEM);