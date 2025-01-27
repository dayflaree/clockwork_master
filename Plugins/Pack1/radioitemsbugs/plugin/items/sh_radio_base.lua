
local ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Radio Base";
ITEM.uniqueID = "radio_base";
ITEM.model = "models/deadbodies/dead_male_civilian_radio.mdl";
ITEM.weight = 1;
ITEM.category = "Communication";
ITEM.business = false;
ITEM.useText = "Toggle On/Off";
ITEM.description = "A shiny handheld radio with a frequency tuner.";
ITEM.customFunctions = {"Frequency"};
ITEM.stationaryCanAccess = true;

ITEM:AddData("On", true, true);
ITEM:AddData("frequency", "100.0", true);

function ITEM:GetFrequency()
	return "freq "..self:GetData("frequency");
end;

function ITEM:GetFrequencyID()
	local freq = "freq_"..self:GetData("frequency");
	freq = string.gsub(freq, "%p", "");

	return freq;
end;
ITEM:AddQueryProxy("frequency", ITEM.GetFrequency);
ITEM:AddQueryProxy("frequencyID", ITEM.GetFrequencyID);

function ITEM:OnUse(player, entity)
	self:SetData("On", not self:GetData("On"));
	Clockwork.radio:SetPlayerChannels(player);

	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

if (SERVER) then
	function ITEM:OnCustomFunction(player, name)
		if (name == "Frequency") then
			Clockwork.datastream:Start(player, "radio_frequency", {self("uniqueID"), tostring(self("itemID"), self:GetData("frequency", ""))});
		end;
	end;
else
	function ITEM:GetClientSideInfo()
		if (!self:IsInstance()) then return; end;

		local clientSideInfo = "";

		clientSideInfo = Clockwork.kernel:AddMarkupLine(clientSideInfo, "Frequency: "..self:GetFrequency());
		
		if (self:GetData("On")) then
			clientSideInfo = Clockwork.kernel:AddMarkupLine(clientSideInfo, "This radio is turned on.");
		else
			clientSideInfo = Clockwork.kernel:AddMarkupLine(clientSideInfo, "This radio is turned off.");
		end;
		
		return (clientSideInfo != "" and clientSideInfo);
	end;
end;

ITEM:Register();