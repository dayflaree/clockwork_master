--[[
	Free Clockwork!
--]]

Clockwork.faction = Clockwork:NewLibrary("Faction");
Clockwork.faction.stored = {};
Clockwork.faction.buffer = {};

FACTION_CITIZENS_FEMALE = {
	"models/humans/group01/female_01.mdl",
	"models/humans/group01/female_02.mdl",
	"models/humans/group01/female_03.mdl",
	"models/humans/group01/female_04.mdl",
	"models/humans/group01/female_06.mdl",
	"models/humans/group01/female_07.mdl"
};

FACTION_CITIZENS_MALE = {
	"models/humans/group01/male_01.mdl",
	"models/humans/group01/male_02.mdl",
	"models/humans/group01/male_03.mdl",
	"models/humans/group01/male_04.mdl",
	"models/humans/group01/male_05.mdl",
	"models/humans/group01/male_06.mdl",
	"models/humans/group01/male_07.mdl",
	"models/humans/group01/male_08.mdl",
	"models/humans/group01/male_09.mdl"
};

-- A function to register a new faction.
function Clockwork.faction:Register(data, name)
	if (data.models) then
		data.models.female = data.models.female or FACTION_CITIZENS_FEMALE;
		data.models.male = data.models.male or FACTION_CITIZENS_MALE;
	else
		data.models = {
			female = FACTION_CITIZENS_FEMALE,
			male = FACTION_CITIZENS_MALE
		};
	end;
	
	for k, v in pairs(data.models.female) do
		util.PrecacheModel(v);
	end;
	
	for k, v in pairs(data.models.male) do
		util.PrecacheModel(v);
	end;
	
	data.limit = data.limit or 128;
	data.index = Clockwork:GetShortCRC(name);
	data.name = data.name or name;
	
	self.buffer[data.index] = data;
	self.stored[data.name] = data;
	
	if (SERVER and data.material) then
		resource.AddFile("materials/"..data.material..".vtf");
		resource.AddFile("materials/"..data.material..".vmt");
	end;
	
	return data.name;
end;

-- A function to get the faction limit.
function Clockwork.faction:GetLimit(name)
	local faction = self:Get(name);
	
	if (faction) then
		if (faction.limit != 128) then
			return math.ceil(faction.limit / (128 / #_player.GetAll()));
		else
			return MaxPlayers();
		end;
	else
		return 0;
	end;
end;

-- A function to get whether a gender is valid.
function Clockwork.faction:IsGenderValid(faction, gender)
	local factionTable = self:Get(faction);
	
	if (factionTable and (gender == GENDER_MALE or gender == GENDER_FEMALE)) then
		if (!factionTable.singleGender or gender == factionTable.singleGender) then
			return true;
		end;
	end;
end;

-- A function to get whether a model is valid.
function Clockwork.faction:IsModelValid(faction, gender, model)
	if (gender and model) then
		local factionTable = self:Get(faction);
		
		if (factionTable and table.HasValue(factionTable.models[string.lower(gender)], model)) then
			return true;
		end;
	end;
end;

-- A function to get a faction.
function Clockwork.faction:Get(name)
	if (name) then
		if (tonumber(name)) then
			return self.buffer[tonumber(name)];
		else
			return self.stored[name];
		end;
	end;
end;

-- A function to get all factions.
function Clockwork.faction:GetAll()
	return self.stored;
end;

-- A function to get each player in a faction.
function Clockwork.faction:GetPlayers(faction)
	local players = {};
	
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (v:GetFaction() == faction) then
				players[#players + 1] = v;
			end;
		end;
	end;
	
	return players;
end;

if (SERVER) then
	function Clockwork.faction:HasReachedMaximum(player, faction)
		local factionTable = self:Get(faction);
		local characters = player:GetCharacters();
		
		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0;
			
			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1;
				end;
			end;
			
			if (totalCharacters >= factionTable.maximum) then
				return true;
			end;
		end;
	end;
else
	function Clockwork.faction:HasReachedMaximum(faction)
		local factionTable = self:Get(faction);
		local characters = Clockwork.character:GetAll();
		
		if (factionTable and factionTable.maximum) then
			local totalCharacters = 0;
			
			for k, v in pairs(characters) do
				if (v.faction == factionTable.name) then
					totalCharacters = totalCharacters + 1;
				end;
			end;
			
			if (totalCharacters >= factionTable.maximum) then
				return true;
			end;
		end;
	end;
end;