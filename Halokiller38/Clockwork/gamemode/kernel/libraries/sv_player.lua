--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.player = Clockwork:NewLibrary("Player");
Clockwork.player.property = {};

-- A function to run an inventory action for a player.
function Clockwork.player:InventoryAction(player, itemTable, action)
	return self:RunClockworkCommand(player, "InvAction", action, itemTable("uniqueID"), tostring(itemTable("itemID")));
end;

-- A function to get a player's gear.
function Clockwork.player:GetGear(player, class)
	if (player.cwGearTab and IsValid(player.cwGearTab[class])) then
		return player.cwGearTab[class];
	end;
end;

-- A function to create a character from data.
function Clockwork.player:CreateCharacterFromData(player, data)
	if (player.cwIsCreatingChar) then
		return;
	end;
	
	local minimumPhysDesc = Clockwork.config:Get("minimum_physdesc"):Get();
	local attributesTable = Clockwork.attribute:GetAll();
	local factionTable = Clockwork.faction:Get(data.faction);
	local attributes = nil;
	local info = {};
	
	if (table.Count(attributesTable) > 0) then
		for k, v in pairs(attributesTable) do
			if (v.characterScreen) then
				attributes = true;
				break;
			end;
		end;
	end;
	
	if (!factionTable) then
		return Clockwork.player:SetCreateFault(player, "You did not choose a faction, or the faction that you chose is not valid!");
	end;
	
	info.attributes = {};
	info.faction = factionTable.name;
	info.gender = data.gender;
	info.model = data.model;
	info.data = {};
	
	local classes = false;
	
	for k, v in pairs(Clockwork.class:GetAll()) do
		if (v.characterScreen and (v.factions and table.HasValue(v.factions, factionTable.name))) then
			classes = true;
		end;
	end;
	
	if (classes) then
		local classTable = Clockwork.class:Get(data.class);
		
		if (!classTable) then
			return Clockwork.player:SetCreateFault(player, "You did not choose a class, or the class that you chose is not valid!");
		else
			info.data["class"] = classTable.name;
		end;
	end;
	
	if (attributes and type(data.attributes) == "table") then
		local maximumPoints = Clockwork.config:Get("default_attribute_points"):Get();
		local pointsSpent = 0;
		
		if (factionTable.attributePointsScale) then
			maximumPoints = math.Round(maximumPoints * factionTable.attributePointsScale);
		end;
		
		if (factionTable.maximumAttributePoints) then
			maximumPoints = factionTable.maximumAttributePoints;
		end;
		
		for k, v in pairs(data.attributes) do
			local attributeTable = Clockwork.attribute:Get(k);
			
			if (attributeTable and attributeTable.characterScreen) then
				local uniqueID = attributeTable.uniqueID;
				local amount = math.Clamp(v, 0, attributeTable.maximum);
				
				info.attributes[uniqueID] = {
					amount = amount,
					progress = 0
				};
				
				pointsSpent = pointsSpent + amount;
			end;
		end;
		
		if (pointsSpent > maximumPoints) then
			return Clockwork.player:SetCreateFault(player, "You have chosen more "..Clockwork.option:GetKey("name_attribute", true).." points than you can afford to spend!");
		end;
	elseif (attributes) then
		return Clockwork.player:SetCreateFault(player, "You did not choose any "..Clockwork.option:GetKey("name_attributes", true).." or the ones that you did are not valid!");
	end;
	
	if (!factionTable.GetName) then
		if (!factionTable.useFullName) then
			if (data.forename and data.surname) then
				data.forename = string.gsub(data.forename, "^.", string.upper);
				data.surname = string.gsub(data.surname, "^.", string.upper);
				
				if (string.find(data.forename, "[%p%s%d]") or string.find(data.surname, "[%p%s%d]")) then
					return Clockwork.player:SetCreateFault(player, "Your forename and surname must not contain punctuation, spaces or digits!");
				end;
				
				if (!string.find(data.forename, "[aeiou]") or !string.find(data.surname, "[aeiou]")) then
					return Clockwork.player:SetCreateFault(player, "Your forename and surname must both contain at least one vowel!");
				end;
				
				if (string.len(data.forename) < 2 or string.len(data.surname) < 2) then
					return Clockwork.player:SetCreateFault(player, "Your forename and surname must both be at least 2 characters long!");
				end;
				
				if (string.len(data.forename) > 16 or string.len(data.surname) > 16) then
					return Clockwork.player:SetCreateFault(player, "Your forename and surname must not be greater than 16 characters long!");
				end;
			else
				return Clockwork.player:SetCreateFault(player, "You did not choose a name, or the name that you chose is not valid!");
			end;
		elseif (!data.fullName or data.fullName == "") then
			return Clockwork.player:SetCreateFault(player, "You did not choose a name, or the name that you chose is not valid!");
		end;
	end;
	
	if (Clockwork.command:Get("CharPhysDesc") != nil) then
		if (type(data.physDesc) != "string") then
			return Clockwork.player:SetCreateFault(player, "You did not enter a physical description!");
		elseif (string.len(data.physDesc) < minimumPhysDesc) then
			return Clockwork.player:SetCreateFault(player, "The physical description must be at least "..minimumPhysDesc.." characters long!");
		end;
		
		info.data["PhysDesc"] = Clockwork:ModifyPhysDesc(data.physDesc);
	end;
	
	if (!factionTable.GetModel and !info.model) then
		return Clockwork.player:SetCreateFault(player, "You did not choose a model, or the model that you chose is not valid!");
	end;
	
	if (!Clockwork.faction:IsGenderValid(info.faction, info.gender)) then
		return Clockwork.player:SetCreateFault(player, "You did not choose a gender, or the gender that you chose is not valid!");
	end;
	
	if (factionTable.whitelist and !Clockwork.player:IsWhitelisted(player, info.faction)) then
		return Clockwork.player:SetCreateFault(player, "You are not on the "..info.faction.." whitelist!");
	elseif (Clockwork.faction:IsModelValid(factionTable.name, info.gender, info.model) or (factionTable.GetModel and !info.model)) then
		local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
		local schemaFolder = Clockwork:GetSchemaFolder();
		local characterID = nil;
		local characters = player:GetCharacters();
		
		if (Clockwork.faction:HasReachedMaximum(player, factionTable.name)) then
			return Clockwork.player:SetCreateFault(player, "You cannot create any more characters in this faction.");
		end;
		
		for i = 1, Clockwork.player:GetMaximumCharacters(player) do
			if (!characters[i]) then
				characterID = i;
				break;
			end;
		end;
		
		if (characterID) then
			if (factionTable.GetName) then
				info.name = factionTable:GetName(player, info, data);
			elseif (!factionTable.useFullName) then
				info.name = data.forename.." "..data.surname;
			else
				info.name = data.fullName;
			end;
			
			if (factionTable.GetModel) then
				info.model = factionTable:GetModel(player, info, data);
			else
				info.model = data.model;
			end;
			
			if (factionTable.OnCreation) then
				local fault = factionTable:OnCreation(player, info);
				
				if (fault == false or type(fault) == "string") then
					return Clockwork.player:SetCreateFault(player, fault or "There was an error creating this character!");
				end;
			end;
			
			for k, v in pairs(characters) do
				if (v.name == info.name) then
					return Clockwork.player:SetCreateFault(player, "You already have a character with the name '"..info.name.."'!");
				end;
			end;
			
			local fault = Clockwork.plugin:Call("PlayerAdjustCharacterCreationInfo", player, info, data);
			
			if (fault == false or type(fault) == "string") then
				return Clockwork.player:SetCreateFault(player, fault or "There was an error creating this character!");
			end;
			
			tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _Name = \""..tmysql.escape(info.name).."\"", function(result)
				if (IsValid(player)) then
					if (result and type(result) == "table" and #result > 0) then
						Clockwork.player:SetCreateFault(player, "A character with the name '"..info.name.."' already exists!");
						player.cwIsCreatingChar = nil;
					else
						Clockwork.player:LoadCharacter(player, characterID, {
							attributes = info.attributes,
							faction = info.faction,
							gender = info.gender,
							model = info.model,
							name = info.name,
							data = info.data
						}, function()
							Clockwork:PrintLog(LOGTYPE_MINOR, player:SteamName().." has created a "..info.faction.." character called '"..info.name.."'.");
							
							umsg.Start("cwCharacterFinish", player)
								umsg.Bool(true);
							umsg.End();
							
							player.cwIsCreatingChar = nil;
						end);
					end;
				end;
			end, 1);
			
			player.cwIsCreatingChar = true;
		else
			return Clockwork.player:SetCreateFault(player, "You cannot create any more characters!");
		end;
	else
		return Clockwork.player:SetCreateFault(player, "You did not choose a model, or the model that you chose is not valid!");
	end;
end;

-- A function to open the character menu.
function Clockwork.player:SetCharacterMenuOpen(player, bReset)
	if (player:HasInitialized()) then
		umsg.Start("cwCharacterOpen", player);
			umsg.Bool(bReset == true);
		umsg.End();
		
		if (bReset) then
			player.cwCharMenuReset = true;
			player:KillSilent();
		end;
	end;
end;

-- A function to start a sound for a player.
function Clockwork.player:StartSound(player, uniqueID, sound)
	if (!player.cwSoundsPlaying) then
		player.cwSoundsPlaying = {};
	end;
	
	if (!player.cwSoundsPlaying[uniqueID] or player.cwSoundsPlaying[uniqueID] != sound) then
		player.cwSoundsPlaying[uniqueID] = sound;
		
		umsg.Start("cwStartSound", player);
			umsg.String(uniqueID);
			umsg.String(sound);
		umsg.End();
	end;
end;

-- A function to stop a sound for a player.
function Clockwork.player:StopSound(player, uniqueID, iFadeOut)
	if (!player.cwSoundsPlaying) then
		player.cwSoundsPlaying = {};
	end;
	
	if (player.cwSoundsPlaying[uniqueID]) then
		player.cwSoundsPlaying[uniqueID] = nil;
		
		umsg.Start("cwStopSound", player);
			umsg.String(uniqueID);
			umsg.Float(iFadeOut or 0);
		umsg.End();
	end;
end;

-- A function to create a player's gear.
function Clockwork.player:CreateGear(player, class, itemTable)
	if (!player.cwGearTab) then
		player.cwGearTab = {};
	end;
	
	if (IsValid(player.cwGearTab[class])) then
		player.cwGearTab[class]:Remove();
	end;
	
	if (itemTable) then
		if (itemTable("isAttachment")) then
			local position = player:GetPos();
			local angles = player:GetAngles();
			local model = itemTable("attachmentModel", itemTable("model"));
			
			player.cwGearTab[class] = ents.Create("cw_gear");
			player.cwGearTab[class]:SetParent(player);
			player.cwGearTab[class]:SetAngles(angles);
			player.cwGearTab[class]:SetModel(model);
			player.cwGearTab[class]:SetPos(position);
			player.cwGearTab[class]:Spawn();
			
			if (itemTable("attachmentMaterial")) then
				player.cwGearTab[class]:SetMaterial(itemTable("attachmentMaterial"));
			end;
			
			if (itemTable("attachmentColor")) then
				player.cwGearTab[class]:SetColor(
					Clockwork:UnpackColor(itemTable("attachmentColor"))
				);
			else
				player.cwGearTab[class]:SetColor(255, 255, 255, 255);
			end;
			
			if (IsValid(player.cwGearTab[class])) then
				player.cwGearTab[class]:SetOwner(player);
				player.cwGearTab[class]:SetItemTable(itemTable);
			end;
		end;
	end;
end;

-- A function to get whether a player is noclipping.
function Clockwork.player:IsNoClipping(player)
	if (player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle()) then
		return true;
	end;
end;

-- A function to get whether a player is an admin.
function Clockwork.player:IsAdmin(player)
	if (self:HasFlags(player, "o")) then
		return true;
	end;
end;

-- A function to get whether a player can hear another player.
function Clockwork.player:CanHearPlayer(player, target, allowance)
	if (Clockwork.config:Get("messages_must_see_player"):Get()) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;

-- A functon to get all property.
function Clockwork.player:GetAllProperty()
	for k, v in pairs(self.property) do
		if (!IsValid(v)) then
			self.property[k] = nil;
		end;
	end;
	
	return self.property;
end;

-- A function to set a player's action.
function Clockwork.player:SetAction(player, action, duration, priority, Callback)
	local currentAction = self:GetAction(player);
	
	if (type(action) != "string" or action == "") then
		Clockwork:DestroyTimer("Action"..player:UniqueID());
		
		player:SetSharedVar("StartActTime", 0);
		player:SetSharedVar("ActDuration", 0);
		player:SetSharedVar("ActName", "");
		
		return;
	elseif (duration == false or duration == 0) then
		if (currentAction == action) then
			return self:SetAction(player, false);
		else
			return false;
		end;
	end;
	
	if (player.cwAction) then
		if ((priority and priority > player.cwAction[2])
		or currentAction == "" or action == player.cwAction[1]) then
			player.cwAction = nil;
		end;
	end;

	if (!player.cwAction) then
		local curTime = CurTime();
		
		player:SetSharedVar("StartActTime", curTime);
		player:SetSharedVar("ActDuration", duration);
		player:SetSharedVar("ActName", action);
		
		if (priority) then
			player.cwAction = {action, priority};
		else
			player.cwAction = nil;
		end;
		
		Clockwork:CreateTimer("Action"..player:UniqueID(), duration, 1, function()
			if (Callback) then
				Callback();
			end;
		end);
	end;
end;

-- A function to set the player's character menu state.
function Clockwork.player:SetCharacterMenuState(player, state)
	Clockwork:StartDataStream(player, "CharacterMenu", state);
end;

-- A function to get a player's action.
function Clockwork.player:GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("StartActTime");
	local actionDuration = player:GetSharedVar("ActDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("ActName");
	
	if (CurTime() < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ((startActionTime + actionDuration) - curTime));
		else
			return action, actionDuration, startActionTime;
		end;
	else
		return "", 0, 0;
	end;
end;

-- A function to run a Clockwork command on a player.
function Clockwork.player:RunClockworkCommand(player, command, ...)
	return Clockwork.command:ConsoleCommand(player, "cwCmd", {command, ...});
end;

-- A function to get a player's wages name.
function Clockwork.player:GetWagesName(player)
	return Clockwork.class:Query(player:Team(), "wagesName", Clockwork.config:Get("wages_name"):Get());
end;

-- A function to get whether a player can see an NPC.
function Clockwork.player:CanSeeNPC(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add(trace.filter, ents.GetAll());
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if (trace.Fraction >= (allowance or 0.75)) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a player.
function Clockwork.player:CanSeePlayer(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	elseif (target:GetEyeTraceNoCursor().Entity == player) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:GetShootPos();
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add(trace.filter, ents.GetAll());
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if (trace.Fraction >= (allowance or 0.75)) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see an entity.
function Clockwork.player:CanSeeEntity(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:LocalToWorld(target:OBBCenter());
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add(trace.filter, ents.GetAll());
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if (trace.Fraction >= (allowance or 0.75)) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a position.
function Clockwork.player:CanSeePosition(player, position, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	trace.filter = {player};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add(trace.filter, ents.GetAll());
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if (trace.Fraction >= (allowance or 0.75)) then
		return true;
	end;
end;

-- A function to update whether a player's weapon is raised.
function Clockwork.player:UpdateWeaponRaised(player)
	local bIsRaised = self:GetWeaponRaised(player);
	local weapon = player:GetActiveWeapon();
	
	player:SetSharedVar("IsWepRaised", bIsRaised);
	
	if (IsValid(weapon)) then
		Clockwork:HandleWeaponFireDelay(player, bIsRaised, weapon, CurTime());
	end;
end;

-- A function to get whether a player's weapon is raised.
function Clockwork.player:GetWeaponRaised(player, bIsCached)
	if (bIsCached) then
		return player:GetSharedVar("IsWepRaised");
	end;
	
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon) and !weapon.NeverRaised) then
		if (weapon.GetRaised) then
			local bIsRaised = weapon:GetRaised();
			
			if (bIsRaised != nil) then
				return bIsRaised;
			end;
		end;
		
		return Clockwork.plugin:Call("GetPlayerWeaponRaised", player, weapon:GetClass(), weapon);
	end;
	
	return false;
end;

-- A function to toggle whether a player's weapon is raised.
function Clockwork.player:ToggleWeaponRaised(player)
	self:SetWeaponRaised(player, !player.cwWeaponRaiseClass);
end;

-- A function to set whether a player's weapon is raised.
function Clockwork.player:SetWeaponRaised(player, bIsRaised)
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon)) then
		if (type(bIsRaised) == "number") then
			player.cwAutoWepRaised = weapon:GetClass();
			player:UpdateWeaponRaised();
			
			Clockwork:CreateTimer("WeaponRaised"..player:UniqueID(), bIsRaised, 1, function()
				if (IsValid(player)) then
					player.cwAutoWepRaised = nil;
					player:UpdateWeaponRaised();
				end;
			end);
		elseif (bIsRaised) then
			if (!player.cwWeaponRaiseClass) then
				if (weapon.OnRaised) then
					weapon:OnRaised();
				end;
			end;
			
			player.cwWeaponRaiseClass = weapon:GetClass();
			player.cwAutoWepRaised = nil;
			player:UpdateWeaponRaised();
		else
			if (player.cwWeaponRaiseClass) then
				if (weapon.OnLowered) then
					weapon:OnLowered();
				end;
			end;
			
			player.cwWeaponRaiseClass = nil;
			player.cwAutoWepRaised = nil;
			player:UpdateWeaponRaised();
		end;
	end;
end;

-- A function to setup a player's remove property delays.
function Clockwork.player:SetupRemovePropertyDelays(player, bAllCharacters)
	local uniqueID = player:UniqueID();
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		local removeDelay = Clockwork.entity:QueryProperty(v, "removeDelay");
		
		if (IsValid(v) and removeDelay) then
			if (uniqueID == Clockwork.entity:QueryProperty(v, "uniqueID")
			and (bAllCharacters or key == Clockwork.entity:QueryProperty(v, "key"))) then
				Clockwork:CreateTimer("RemoveDelay"..v:EntIndex(), removeDelay, 1, function(entity)
					if (IsValid(entity)) then
						entity:Remove();
					end;
				end, v);
			end;
		end;
	end;
end;

-- A function to disable a player's property.
function Clockwork.player:DisableProperty(player, bCharacterOnly)
	local uniqueID = player:UniqueID();
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (IsValid(v) and uniqueID == Clockwork.entity:QueryProperty(v, "uniqueID")
		and (!bCharacterOnly or key == Clockwork.entity:QueryProperty(v, "key"))) then
			Clockwork.entity:SetPropertyVar(v, "owner", NULL);
			
			if (Clockwork.entity:QueryProperty(v, "networked")) then
				v:SetNetworkedEntity("Owner", NULL);
			end;
			
			v:SetOwnerKey(nil);
			v:SetNetworkedBool("Owned", false);
			v:SetNetworkedInt("Key", 0);
			
			if (v.SetPlayer) then
				v:SetVar("Founder", NULL);
				v:SetVar("FounderIndex", 0);
				v:SetNetworkedString("FounderName", "");
			end;
		end;
	end;
end;

-- A function to give property to a player.
function Clockwork.player:GiveProperty(player, entity, networked, removeDelay)
	Clockwork:DestroyTimer("RemoveDelay"..entity:EntIndex());
	Clockwork.entity:ClearProperty(entity);
	
	entity.cwPropertyTab = {
		key = player:GetCharacterKey(),
		owner = player,
		owned = true,
		uniqueID = player:UniqueID(),
		networked = networked,
		removeDelay = removeDelay
	};
	
	if (entity.SetPlayer) then
		entity:SetPlayer(player);
	end;
	
	if (networked) then
		entity:SetNetworkedEntity("Owner", player);
	end;
	
	entity:SetOwnerKey(player:GetCharacterKey());
	entity:SetNetworkedBool("Owned", true);
	entity:SetNetworkedInt("Key", entity.cwPropertyTab.key);
	
	self.property[entity:EntIndex()] = entity;
	Clockwork.plugin:Call("PlayerPropertyGiven", player, entity, networked, removeDelay);
end;

-- A function to give property to an offline player.
function Clockwork.player:GivePropertyOffline(key, uniqueID, entity, networked, removeDelay)
	Clockwork.entity:ClearProperty(entity);
	
	if (key and uniqueID) then
		local propertyUniqueID = Clockwork.entity:QueryProperty(entity, "uniqueID");
		local owner = player.GetByUniqueID(uniqueID);
		
		if (IsValid(owner) and owner:GetCharacterKey() == key) then
			self:GiveProperty(owner, entity, networked, removeDelay);
			return;
		else
			owner = nil;
		end;
		
		if (propertyUniqueID) then
			Clockwork:DestroyTimer("RemoveDelay"..entity:EntIndex().." "..cwPropertyTabUniqueID);
		end;
		
		entity.cwPropertyTab = {
			key = key,
			owner = owner,
			owned = true,
			uniqueID = uniqueID,
			networked = networked,
			removeDelay = removeDelay
		};
		
		if (IsValid(entity.cwPropertyTab.owner)) then
			if (entity.SetPlayer) then
				entity:SetPlayer(entity.cwPropertyTab.owner);
			end;
			
			if (networked) then
				entity:SetNetworkedEntity("Owner", entity.cwPropertyTab.owner);
			end;
		end;
		
		entity:SetNetworkedBool("Owned", true);
		entity:SetNetworkedInt("Key", key);
		entity:SetOwnerKey(key);
		
		self.property[entity:EntIndex()] = entity;
		Clockwork.plugin:Call("PlayerPropertyGivenOffline", key, uniqueID, entity, networked, removeDelay);
	end;
end;

-- A function to take property from an offline player.
function Clockwork.player:TakePropertyOffline(key, uniqueID, entity, bAnyCharacter)
	if (key and uniqueID) then
		local owner = player.GetByUniqueID(uniqueID);
		
		if (IsValid(owner) and owner:GetCharacterKey() == key) then
			self:TakeProperty(owner, entity);
			return;
		end;
		
		if (Clockwork.entity:QueryProperty(entity, "uniqueID") == uniqueID
		and Clockwork.entity:QueryProperty(entity, "key") == key) then
			entity.cwPropertyTab = nil;
			entity:SetNetworkedEntity("Owner", NULL);
			entity:SetNetworkedBool("Owned", false);
			entity:SetNetworkedInt("Key", 0);
			entity:SetOwnerKey(nil);
			
			if (entity.SetPlayer) then
				entity:SetVar("Founder", nil);
				entity:SetVar("FounderIndex", nil);
				entity:SetNetworkedString("FounderName", "");
			end;
			
			self.property[entity:EntIndex()] = nil;
			Clockwork.plugin:Call("PlayerPropertyTakenOffline", key, uniqueID, entity);
		end;
	end;
end;

-- A function to take property from a player.
function Clockwork.player:TakeProperty(player, entity)
	if (Clockwork.entity:GetOwner(entity) == player) then
		entity.cwPropertyTab = nil;
		
		entity:SetNetworkedEntity("Owner", NULL);
		entity:SetNetworkedBool("Owned", false);
		entity:SetNetworkedInt("Key", 0);
		entity:SetOwnerKey(nil);
		
		if (entity.SetPlayer) then
			entity:SetVar("Founder", nil);
			entity:SetVar("FounderIndex", nil);
			entity:SetNetworkedString("FounderName", "");
		end;
		
		self.property[entity:EntIndex()] = nil;
		Clockwork.plugin:Call("PlayerPropertyTaken", player, entity);
	end;
end;

-- A function to set a player to their default skin.
function Clockwork.player:SetDefaultSkin(player)
	player:SetSkin(self:GetDefaultSkin(player));
end;

-- A function to get a player's default skin.
function Clockwork.player:GetDefaultSkin(player)
	return Clockwork.plugin:Call("GetPlayerDefaultSkin", player);
end;

-- A function to set a player to their default model.
function Clockwork.player:SetDefaultModel(player)
	player:SetModel(self:GetDefaultModel(player));
end;

-- A function to get a player's default model.
function Clockwork.player:GetDefaultModel(player)
	return Clockwork.plugin:Call("GetPlayerDefaultModel", player);
end;

-- A function to get whether a player is drunk.
function Clockwork.player:GetDrunk(player)
	if (player.cwDrunkTab) then return #player.cwDrunkTab; end;
end;

-- A function to set whether a player is drunk.
function Clockwork.player:SetDrunk(player, expire)
	local curTime = CurTime();
	
	if (expire == false) then
		player.cwDrunkTab = nil;
	elseif (!player.cwDrunkTab) then
		player.cwDrunkTab = {curTime + expire};
	else
		player.cwDrunkTab[#player.cwDrunkTab + 1] = curTime + expire;
	end;
	
	player:SetSharedVar("IsDrunk", self:GetDrunk(player) or 0);
end;

-- A function to strip a player's default ammo.
function Clockwork.player:StripDefaultAmmo(player, weapon, itemTable)
	if (!itemTable) then
		itemTable = Clockwork.item:GetByWeapon(weapon);
	end;
	
	if (itemTable) then
		local secondaryDefaultAmmo = itemTable("secondaryDefaultAmmo");
		local primaryDefaultAmmo = itemTable("primaryDefaultAmmo");
		
		if (primaryDefaultAmmo) then
			local ammoClass = weapon:GetPrimaryAmmoType();
			
			if (weapon:Clip1() != -1) then
				weapon:SetClip1(0);
			end;
			
			if (type(primaryDefaultAmmo) == "number") then
				player:SetAmmo(
					math.max(player:GetAmmoCount(ammoClass) - primaryDefaultAmmo, 0), ammoClass
				);
			end;
		end;
		
		if (secondaryDefaultAmmo) then
			local ammoClass = weapon:GetSecondaryAmmoType();
			
			if (weapon:Clip2() != -1) then
				weapon:SetClip2(0);
			end;
			
			if (type(secondaryDefaultAmmo) == "number") then
				player:SetAmmo(
					math.max(player:GetAmmoCount(ammoClass) - secondaryDefaultAmmo, 0), ammoClass
				);
			end;
		end;
	end;
end;

-- A function to check if a player is whitelisted for a faction.
function Clockwork.player:IsWhitelisted(player, faction)
	return table.HasValue(player:GetData("Whitelisted"), faction);
end;

-- A function to set whether a player is whitelisted for a faction.
function Clockwork.player:SetWhitelisted(player, faction, isWhitelisted)
	local whitelisted = player:GetData("Whitelisted");
	
	if (isWhitelisted) then
		if (!self:IsWhitelisted(player, faction)) then
			whitelisted[#whitelisted + 1] = faction;
		end;
	else
		for k, v in pairs(whitelisted) do
			if (v == faction) then
				whitelisted[k] = nil;
			end;
		end;
	end;
	
	Clockwork:StartDataStream(player, "SetWhitelisted", {faction, isWhitelisted});
end;

-- A function to create a Condition timer.
function Clockwork.player:ConditionTimer(player, delay, Condition, Callback)
	delay = CurTime() + delay; local uniqueID = player:UniqueID();
	
	if (player.cwConditionTimer) then
		player.cwConditionTimer.Callback(false);
		player.cwConditionTimer = nil;
	end;
	
	player.cwConditionTimer = {
		delay = delay,
		Callback = Callback,
		Condition = Condition
	};
	
	Clockwork:CreateTimer("CondTimer"..uniqueID, 0, 0, function()
		if (IsValid(player)) then
			if (Condition()) then
				if (CurTime() >= delay) then
					Callback(true); player.cwConditionTimer = nil;
					Clockwork:DestroyTimer("CondTimer"..uniqueID);
				end;
			else
				Callback(false); player.cwConditionTimer = nil;
				Clockwork:DestroyTimer("CondTimer"..uniqueID);
			end;
		else
			Clockwork:DestroyTimer("CondTimer"..uniqueID);
		end;
	end);
end;

-- A function to create an entity Condition timer.
function Clockwork.player:EntityConditionTimer(player, target, entity, delay, distance, Condition, Callback)
	delay = CurTime() + delay; entity = entity or target;
	
	local uniqueID = player:UniqueID();
	
	if (player.cwConditionEntTimer) then
		player.cwConditionEntTimer.Callback(false);
		player.cwConditionEntTimer = nil;
	end;
	
	player.cwConditionEntTimer = {
		delay = delay,
		target = target,
		entity = entity,
		distance = distance,
		Callback = Callback,
		Condition = Condition
	};
	
	Clockwork:CreateTimer("EntityCondTimer"..uniqueID, 0, 0, function()
		if (IsValid(player)) then
			local trace = player:GetEyeTraceNoCursor();
			
			if (IsValid(target) and IsValid(entity) and trace.Entity == entity
			and trace.Entity:GetPos():Distance(player:GetShootPos()) <= distance and Condition()) then
				if (CurTime() >= delay) then
					Callback(true); player.cwConditionEntTimer = nil;
					
					Clockwork:DestroyTimer("EntityCondTimer"..uniqueID);
				end;
			else
				Callback(false); player.cwConditionEntTimer = nil;
				
				Clockwork:DestroyTimer("EntityCondTimer"..uniqueID);
			end;
		else
			Clockwork:DestroyTimer("EntityCondTimer"..uniqueID);
		end;
	end);
end;

-- A function to get a player's spawn ammo.
function Clockwork.player:GetSpawnAmmo(player, ammo)
	if (ammo) then
		return player.cwSpawnAmmo[ammo];
	else
		return player.cwSpawnAmmo;
	end;
end;

-- A function to get a player's spawn weapon.
function Clockwork.player:GetSpawnWeapon(player, weapon)
	if (weapon) then
		return player.cwSpawnWeps[weapon];
	else
		return player.cwSpawnWeps;
	end;
end;

-- A function to take spawn ammo from a player.
function Clockwork.player:TakeSpawnAmmo(player, ammo, amount)
	if (player.cwSpawnAmmo[ammo]) then
		if (player.cwSpawnAmmo[ammo] < amount) then
			amount = player.cwSpawnAmmo[ammo];
			
			player.cwSpawnAmmo[ammo] = nil;
		else
			player.cwSpawnAmmo[ammo] = player.cwSpawnAmmo[ammo] - amount;
		end;
		
		player:RemoveAmmo(amount, ammo);
	end;
end;

-- A function to give the player spawn ammo.
function Clockwork.player:GiveSpawnAmmo(player, ammo, amount)
	if (player.cwSpawnAmmo[ammo]) then
		player.cwSpawnAmmo[ammo] = player.cwSpawnAmmo[ammo] + amount;
	else
		player.cwSpawnAmmo[ammo] = amount;
	end;
	
	player:GiveAmmo(amount, ammo);
end;

-- A function to take a player's spawn weapon.
function Clockwork.player:TakeSpawnWeapon(player, class)
	player.cwSpawnWeps[class] = nil;
	player:StripWeapon(class);
end;

-- A function to give a player a spawn weapon.
function Clockwork.player:GiveSpawnWeapon(player, class)
	player.cwSpawnWeps[class] = true;
	player:Give(class);
end;

-- A function to give a player an item weapon.
function Clockwork.player:GiveItemWeapon(player, itemTable)
	if (Clockwork.item:IsWeapon(itemTable)) then
		player:Give(itemTable("weaponClass"), itemTable);
		return true;
	end;
end;

-- A function to give a player a spawn item weapon.
function Clockwork.player:GiveSpawnItemWeapon(player, itemTable)
	if (Clockwork.item:IsWeapon(itemTable)) then
		player.cwSpawnWeps[itemTable("weaponClass")] = true;
		player:Give(itemTable("weaponClass"), itemTable);
		
		return true;
	end;
end;

-- A function to give flags to a player.
function Clockwork.player:GiveFlags(player, flags)
	for i = 1, string.len(flags) do
		local flag = string.sub(flags, i, i);
		
		if (!string.find(player:GetFlags(), flag)) then
			player:SetCharacterData("Flags", player:GetFlags()..flag, true);
			
			Clockwork.plugin:Call("PlayerFlagsGiven", player, flag);
		end;
	end;
end;

-- A function to play a sound to a player.
function Clockwork.player:PlaySound(player, sound)
	umsg.Start("cwPlaySound", player);
		umsg.String(sound);
	umsg.End();
end;

-- A function to get a player's maximum characters.
function Clockwork.player:GetMaximumCharacters(player)
	local maximum = Clockwork.config:Get("additional_characters"):Get();
	
	for k, v in pairs(Clockwork.faction.stored) do
		if (!v.whitelist or self:IsWhitelisted(player, v.name)) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

-- A function to query a player's character.
function Clockwork.player:Query(player, key, default)
	local character = player:GetCharacter();
	
	if (character) then
		key = Clockwork:SetCamelCase(key, true);
		
		if (character[key] != nil) then
			return character[key];
		end;
	end;
	
	return default;
end;

-- A function to set a player to a safe position.
function Clockwork.player:SetSafePosition(player, position, filter)
	position = self:GetSafePosition(player, position, filter);
	
	if (position) then
		player:SetMoveType(MOVETYPE_NOCLIP);
		player:SetPos(position);
		
		if (player:IsInWorld()) then
			player:SetMoveType(MOVETYPE_WALK);
		else
			player:Spawn();
		end;
	end;
end;

-- A function to get the safest position near a position.
function Clockwork.player:GetSafePosition(player, position, filter)
	local closestPosition = nil;
	local distanceAmount = 8;
	local directions = {};
	local yawForward = player:EyeAngles().yaw;
	local angles = {
		math.NormalizeAngle(yawForward - 180),
		math.NormalizeAngle(yawForward - 135),
		math.NormalizeAngle(yawForward + 135),
		math.NormalizeAngle(yawForward + 45),
		math.NormalizeAngle(yawForward + 90),
		math.NormalizeAngle(yawForward - 45),
		math.NormalizeAngle(yawForward - 90),
		math.NormalizeAngle(yawForward)
	};
	
	position = position + Vector(0, 0, 32);
	
	if (!filter) then
		filter = {player};
	elseif (type(filter) != "table") then
		filter = {filter};
	end;
	
	if (!table.HasValue(filter, player)) then
		filter[#filter + 1] = player;
	end;
	
	for i = 1, 8 do
		for k, v in ipairs(angles) do
			directions[#directions + 1] = {v, distanceAmount};
		end;
		
		distanceAmount = distanceAmount * 2;
	end;
	
	-- A function to get a lower position.
	local function GetLowerPosition(testPosition, ignoreHeight)
		local trace = {
			filter = filter,
			endpos = testPosition - Vector(0, 0, 256),
			start = testPosition
		};
		
		return util.TraceLine(trace).HitPos + Vector(0, 0, 32);
	end;
	
	local trace = {
		filter = filter,
		endpos = position + Vector(0, 0, 256),
		start = position
	};
	
	local safePosition = GetLowerPosition(util.TraceLine(trace).HitPos);
	
	if (safePosition) then
		position = safePosition;
	end;
	
    for k, v in ipairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + (angleVector * v[2]);
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (traceLine.Hit) then
			trace = {
				filter = filter,
				endpos = traceLine.HitPos - (angleVector * v[2]),
				start = traceLine.HitPos
			};
			
			traceLine = util.TraceEntity(trace, player);
			
			if (!traceLine.Hit) then
				position = traceLine.HitPos;
			end;
		end;
		
		if (!traceLine.Hit) then
			break;
		end;
    end;
	
    for k, v in ipairs(directions) do
		local angleVector = Angle(0, v[1], 0):Forward();
		local testPosition = position + (angleVector * v[2]);
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (!traceLine.Hit) then
			return traceLine.HitPos;
		end;
    end;
	
	return position;
end;

-- Called to convert a player's data to a string.
function Clockwork.player:ConvertDataString(player, data)
	local success, value = pcall(Json.Decode, data);
	
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to return a player's property.
function Clockwork.player:ReturnProperty(player)
	local uniqueID = player:UniqueID();
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (IsValid(v)) then
			if (uniqueID == Clockwork.entity:QueryProperty(v, "uniqueID")) then
				if (key == Clockwork.entity:QueryProperty(v, "key")) then
					self:GiveProperty(player, v, Clockwork.entity:QueryProperty(v, "networked"));
				end;
			end;
		end;
	end;
	
	Clockwork.plugin:Call("PlayerReturnProperty", player);
end;

-- A function to take flags from a player.
function Clockwork.player:TakeFlags(player, flags)
	for i = 1, string.len(flags) do
		local flag = string.sub(flags, i, i);
		
		if (string.find(player:GetFlags(), flag)) then
			player:SetCharacterData("Flags", string.gsub(player:GetFlags(), flag, ""), true);
			
			Clockwork.plugin:Call("PlayerFlagsTaken", player, flag);
		end;
	end;
end;

-- A function to set whether a player's menu is open.
function Clockwork.player:SetMenuOpen(player, isOpen)
	umsg.Start("cwMenuOpen", player);
		umsg.Bool(isOpen);
	umsg.End();
end;

-- A function to set whether a player has intialized.
function Clockwork.player:SetInitialized(player, initialized)
	player:SetSharedVar("Initialized", initialized);
end;

-- A function to check if a player has any flags.
function Clockwork.player:HasAnyFlags(player, flags, default)
	if (player:GetCharacter()) then
		local playerFlags = player:GetFlags();
		
		if (Clockwork.class:HasAnyFlags(player:Team(), flags) and !default) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success = true;
				
				if (!default) then
					local hasFlag = Clockwork.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
					if (hasFlag != false) then
						if (hasFlag) then
							return true;
						end;
					else
						success = nil;
					end;
				end;
				
				if (success) then
					if (flag == "s") then
						if (player:IsSuperAdmin()) then
							return true;
						end;
					elseif (flag == "a") then
						if (player:IsAdmin()) then
							return true;
						end;
					elseif (flag == "o") then
						if (player:IsSuperAdmin() or player:IsAdmin()) then
							return true;
						elseif (player:IsUserGroup("operator")) then
							return true;
						end;
					elseif (string.find(playerFlags, flag)) then
						return true;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to check if a player has flags.
function Clockwork.player:HasFlags(player, flags, default)
	if (player:GetCharacter()) then
		local playerFlags = player:GetFlags();
		
		if (Clockwork.class:HasFlags(player:Team(), flags) and !default) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success;
				
				if (!default) then
					local hasFlag = Clockwork.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
					if (hasFlag != false) then
						if (hasFlag) then
							success = true;
						end;
					else
						return;
					end;
				end;
				
				if (!success) then
					if (flag == "s") then
						if (!player:IsSuperAdmin()) then
							return;
						end;
					elseif (flag == "a") then
						if (!player:IsAdmin()) then
							return;
						end;
					elseif (flag == "o") then
						if (!player:IsSuperAdmin() and !player:IsAdmin()) then
							if (!player:IsUserGroup("operator")) then
								return;
							end;
						end;
					elseif (!string.find(playerFlags, flag)) then
						return;
					end;
				end;
			end;
		end;
		
		return true;
	end;
end;

-- A function to use a player's death code.
function Clockwork.player:UseDeathCode(player, commandTable, arguments)
	Clockwork.plugin:Call("PlayerDeathCodeUsed", player, commandTable, arguments);
	
	self:TakeDeathCode(player);
end;

-- A function to get whether a player has a death code.
function Clockwork.player:GetDeathCode(player, authenticated)
	if (player.cwDeathCodeIdx and (!authenticated or player.cwDeathCodeAuth)) then
		return player.cwDeathCodeIdx;
	end;
end;

-- A function to take a player's death code.
function Clockwork.player:TakeDeathCode(player)
	player.cwDeathCodeAuth = nil;
	player.cwDeathCodeIdx = nil;
end;

-- A function to give a player their death code.
function Clockwork.player:GiveDeathCode(player)
	player.cwDeathCodeIdx = math.random(0, 99999);
	player.cwDeathCodeAuth = nil;
	
	umsg.Start("cwChatBoxDeathCode", player);
		umsg.Long(player.cwDeathCodeIdx);
	umsg.End();
end;

-- A function to take a door from a player.
function Clockwork.player:TakeDoor(player, door, bForce, bThisDoorOnly, bChildrenOnly)
	local doorCost = Clockwork.config:Get("door_cost"):Get();
	
	if (!bThisDoorOnly) then
		local doorParent = Clockwork.entity:GetDoorParent(door);
		
		if (!doorParent or bChildrenOnly) then
			for k, v in pairs(Clockwork.entity:GetDoorChildren(door)) do
				if (IsValid(v)) then
					self:TakeDoor(player, v, true, true);
				end;
			end;
		else
			return self:TakeDoor(player, doorParent, bForce);
		end;
	end;
	
	if (Clockwork.plugin:Call("PlayerCanUnlockEntity", player, door)) then
		door:Fire("Unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
	
	Clockwork.entity:SetDoorText(door, false);
	self:TakeProperty(player, door)
	
	if (door:GetClass() == "prop_dynamic") then
		if (!door:IsMapEntity()) then
			door:Remove();
		end;
	end;
	
	if (!force and doorCost > 0) then
		self:GiveCash(player, doorCost / 2, "selling a door");
	end;
end;

-- A function to make a player say text as a radio broadcast.
function Clockwork.player:SayRadio(player, text, check, noEavesdrop)
	local eavesdroppers = {};
	local listeners = {};
	local canRadio = true;
	local info = {listeners = {}, noEavesdrop = noEavesdrop, text = text};
	
	Clockwork.plugin:Call("PlayerAdjustRadioInfo", player, info);
	
	for k, v in pairs(info.listeners) do
		if (type(k) == "Player") then
			listeners[k] = k;
		elseif (type(v) == "Player") then
			listeners[v] = v;
		end;
	end;
	
	if (!info.noEavesdrop) then
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized() and !listeners[v]) then
				if (v:GetShootPos():Distance(player:GetShootPos()) <= Clockwork.config:Get("talk_radius"):Get()) then
					eavesdroppers[v] = v;
				end;
			end;
		end;
	end;
	
	if (check) then
		canRadio = Clockwork.plugin:Call("PlayerCanRadio", player, info.text, listeners, eavesdroppers);
	end;
	
	if (canRadio) then
		info = Clockwork.chatBox:Add(listeners, player, "radio", info.text);
		
		if (info and IsValid(info.speaker)) then
			Clockwork.chatBox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			
			Clockwork.plugin:Call("PlayerRadioUsed", player, info.text, listeners, eavesdroppers);
		end;
	end;
end;

-- A function to get a player's faction table.
function Clockwork.player:GetFactionTable(player)
	return Clockwork.faction.stored[player:GetFaction()];
end;

-- A function to give a door to a player.
function Clockwork.player:GiveDoor(player, door, name, unsellable, override)
	if (Clockwork.entity:IsDoor(door)) then
		local doorParent = Clockwork.entity:GetDoorParent(door);
		
		if (doorParent and !override) then
			self:GiveDoor(player, doorParent, name, unsellable);
		else
			for k, v in pairs(Clockwork.entity:GetDoorChildren(door)) do
				if (IsValid(v)) then
					self:GiveDoor(player, v, name, unsellable, true);
				end;
			end;
			
			door.unsellable = unsellable;
			door.accessList = {};
			
			Clockwork.entity:SetDoorText(door, name or "A purchased door.");
			self:GiveProperty(player, door, true);
			
			if (Clockwork.plugin:Call("PlayerCanUnlockEntity", player, door)) then
				door:EmitSound("doors/door_latch3.wav");
				door:Fire("Unlock", "", 0);
			end;
		end;
	end;
end;

-- A function to get a player's real trace.
function Clockwork.player:GetRealTrace(player, useFilterTrace)
	local eyePos = player:EyePos();
	local trace = player:GetEyeTraceNoCursor();
	
	local newTrace = util.TraceLine({
		endpos = eyePos + (player:GetAimVector() * 4096),
		filter = player,
		start = eyePos,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	});
	
	if ((IsValid(newTrace.Entity) and (!IsValid(trace.Entity)
	or trace.Entity:IsVehicle()) and !newTrace.HitWorld) or useFilterTrace) then
		trace = newTrace;
	end;
	
	return trace;
end;

-- A function to check if a player recognises another player.
function Clockwork.player:DoesRecognise(player, target, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, target, RECOGNISE_PARTIAL);
	elseif (Clockwork.config:Get("recognise_system"):Get()) then
		local recognisedNames = player:GetRecognisedNames();
		local realValue = false;
		local key = target:GetCharacterKey();
		
		if (recognisedNames[key]) then
			if (isAccurate) then
				realValue = (recognisedNames[key] == status);
			else
				realValue = (recognisedNames[key] >= status);
			end;
		end;
		
		return Clockwork.plugin:Call("PlayerDoesRecognisePlayer", player, target, status, isAccurate, realValue);
	else
		return true;
	end;
end;

-- A function to send a player a creation fault.
function Clockwork.player:SetCreateFault(player, fault)
	if (!fault) then
		fault = "There has been an unknown error, please contact the administrator!";
	end;
	
	umsg.Start("cwCharacterFinish", player)
		umsg.Bool(false);
		umsg.String(fault);
	umsg.End();
end;

-- A function to force a player to delete a character.
function Clockwork.player:ForceDeleteCharacter(player, characterID)
	local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
	local schemaFolder = Clockwork:GetSchemaFolder();
	local character = player.cwCharacterList[characterID];
	
	if (character) then
		tmysql.query("DELETE FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..player:SteamID().."\" AND _CharacterID = "..characterID);
		
		if (!Clockwork.plugin:Call("PlayerDeleteCharacter", player, character)) then
			Clockwork:PrintLog(LOGTYPE_GENERIC, player:SteamName().." has deleted the character '"..character.name.."'.");
		end;
		
		player.cwCharacterList[characterID] = nil;
		
		umsg.Start("cwCharacterRemove", player)
			umsg.Short(characterID);
		umsg.End();
	end;
end;

-- A function to delete a player's character.
function Clockwork.player:DeleteCharacter(player, characterID)
	local character = player.cwCharacterList[characterID];
	
	if (character) then
		if (player:GetCharacter() != character) then
			local fault = Clockwork.plugin:Call("PlayerCanDeleteCharacter", player, character);
			
			if (fault == nil or fault == true) then
				self:ForceDeleteCharacter(player, characterID);
				
				return true;
			elseif (type(fault) != "string") then
				return false, "You cannot delete this character!";
			else
				return false, fault;
			end;
		else
			return false, "You cannot delete the character you are using!";
		end;
	else
		return false, "This character does not exist!";
	end;
end;

-- A function to use a player's character.
function Clockwork.player:UseCharacter(player, characterID)
	local isCharacterMenuReset = player:IsCharacterMenuReset();
	local currentCharacter = player:GetCharacter();
	local character = player.cwCharacterList[characterID];
	
	if (!character) then
		return false, "This character does not exist!";
	end;
	
	if (currentCharacter != character or isCharacterMenuReset) then
		local factionTable = Clockwork.faction:Get(character.faction);
		local fault = Clockwork.plugin:Call("PlayerCanUseCharacter", player, character);
		
		if (fault == nil or fault == true) then
			local players = #Clockwork.faction:GetPlayers(character.faction);
			local limit = Clockwork.faction:GetLimit(factionTable.name);
			
			if (isCharacterMenuReset and character.faction == currentCharacter.faction) then
				players = players - 1;
			end;
				
			if (Clockwork.plugin:Call("PlayerCanBypassFactionLimit", player, character)) then
				limit = nil;
			end;
			
			if (limit and players == limit) then
				return false, "The "..character.faction.." faction is full ("..limit.."/"..limit..")!";
			else
				if (currentCharacter) then
					local fault = Clockwork.plugin:Call("PlayerCanSwitchCharacter", player, character);
					
					if (fault != nil and fault != true) then
						return false, fault or "You cannot switch to this character!";
					end;
				end;
				
				Clockwork:PrintLog(LOGTYPE_GENERIC, player:SteamName().." has loaded the character '"..character.name.."'.");
				
				if (isCharacterMenuReset) then
					player.cwCharMenuReset = false;
					player:Spawn();
				else
					self:LoadCharacter(player, characterID);
				end;
				
				return true;
			end;
		else
			return false, fault or "You cannot use this character!";
		end;
	else
		return false, "You are already using this character!";
	end;
end;

-- A function to get a player's character.
function Clockwork.player:GetCharacter(player)
	return player.cwCharacter;
end;

-- A function to get a player's unrecognised name.
function Clockwork.player:GetUnrecognisedName(player)
	local unrecognisedPhysDesc = self:GetPhysDesc(player);
	local unrecognisedName = Clockwork.config:Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc != "") then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

-- A function to format text based on a relationship.
function Clockwork.player:FormatRecognisedText(player, text, ...)
	for i = 1, #arg do
		if (string.find(text, "%%s") and IsValid(arg[i])) then
			local unrecognisedName = "["..self:GetUnrecognisedName(arg[i]).."]";
			
			if (self:DoesRecognise(player, arg[i])) then
				unrecognisedName = arg[i]:Name();
			end;
			
			text = string.gsub(text, "%%s", unrecognisedName, 1);
		end;
	end;
	
	return text;
end;

-- A function to restore a recognised name.
function Clockwork.player:RestoreRecognisedName(player, target)
	local recognisedNames = player:GetRecognisedNames();
	local key = target:GetCharacterKey();
	
	if (recognisedNames[key]) then
		if (Clockwork.plugin:Call("PlayerCanRestoreRecognisedName", player, target)) then
			self:SetRecognises(player, target, recognisedNames[key], true);
		else
			recognisedNames[key] = nil;
		end;
	end;
end;

-- A function to restore a player's recognised names.
function Clockwork.player:RestoreRecognisedNames(player)
	umsg.Start("cwClearRecognisedNames", player);
	umsg.End();
	
	if (Clockwork.config:Get("save_recognised_names"):Get()) then
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				self:RestoreRecognisedName(player, v);
				self:RestoreRecognisedName(v, player);
			end;
		end;
	end;
end;

-- A function to set whether a player recognises a player.
function Clockwork.player:SetRecognises(player, target, status, bForce)
	local recognisedNames = player:GetRecognisedNames();
	local name = target:Name();
	local key = target:GetCharacterKey();
	
	if (status == RECOGNISE_SAVE) then
		if (Clockwork.config:Get("save_recognised_names"):Get()) then
			if (!Clockwork.plugin:Call("PlayerCanSaveRecognisedName", player, target)) then
				status = RECOGNISE_TOTAL;
			end;
		else
			status = RECOGNISE_TOTAL;
		end;
	end;
	
	if (!status or bForce or !self:DoesRecognise(player, target, status)) then
		recognisedNames[key] = status or nil;
		
		umsg.Start("cwRecognisedName", player);
			umsg.Long(key);
			umsg.Short(status or 0);
		umsg.End();
	end;
end;

-- A function to get a player's physical description.
function Clockwork.player:GetPhysDesc(player)
	local physDesc = player:GetSharedVar("PhysDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = Clockwork.class:Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = Clockwork.config:Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = Clockwork:ModifyPhysDesc(physDesc);
	end;
	
	local override = Clockwork.plugin:Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

-- A function to clear a player's recognised names list.
function Clockwork.player:ClearRecognisedNames(player, status, isAccurate)
	if (!status) then
		local character = player:GetCharacter();
		
		if (character) then
			character.recognisedNames = {};
			
			umsg.Start("cwClearRecognisedNames", player);
			umsg.End();
		end;
	else
		for k, v in ipairs(_player.GetAll()) do
			if (v:HasInitialized()) then
				if (self:DoesRecognise(player, v, status, isAccurate)) then
					self:SetRecognises(player, v, false);
				end;
			end;
		end;
	end;
	
	Clockwork.plugin:Call("PlayerRecognisedNamesCleared", player, status, isAccurate);
end;

-- A function to clear a player's name from being recognised.
function Clockwork.player:ClearName(player, status, isAccurate)
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (!status or self:DoesRecognise(v, player, status, isAccurate)) then
				self:SetRecognises(v, player, false);
			end;
		end;
	end;
	
	Clockwork.plugin:Call("PlayerNameCleared", player, status, isAccurate);
end;

-- A function to holsters all of a player's weapons.
function Clockwork.player:HolsterAll(player)
	for k, v in pairs(player:GetWeapons()) do
		local class = v:GetClass();
		local itemTable = Clockwork.item:GetByWeapon(v);
		
		if (itemTable and Clockwork.plugin:Call("PlayerCanHolsterWeapon", player, itemTable, v, true, true)) then
			Clockwork.plugin:Call("PlayerHolsterWeapon", player, itemTable, v, true);
			player:StripWeapon(class);
			player:GiveItem(itemTable, true);
		end;
	end;
	
	player:SelectWeapon("cw_hands");
end;

-- A function to set a shared variable for a player.
function Clockwork.player:SetSharedVar(player, key, value)
	if (IsValid(player)) then
		local sharedVars = Clockwork:GetSharedVars():Player();
		
		if (!sharedVars or not sharedVars[key]) then
			player:SetNetworkedVar(key, value);
			return;
		end;
		
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData.bPlayerOnly) then
			local class = Clockwork:ConvertUserMessageClass(sharedVarData.class);
			local realValue = value;
			
			if (value == nil) then
				realValue = Clockwork:GetDefaultNetworkedValue(sharedVarData.class);
			end;
			
			if (player.cwSharedVars[key] != realValue) then
				player.cwSharedVars[key] = realValue;
				
				umsg.Start("cwSharedVar", player);
					umsg.String(key);
					umsg[class](realValue);
				umsg.End();
			end;
		else
			local class = Clockwork:ConvertNetworkedClass(sharedVarData.class);
			
			if (class) then
				if (value == nil) then
					value = Clockwork:GetDefaultClassValue(class);
				end;
				
				player["SetNetworked"..class](player, key, value);
			else
				player:SetNetworkedVar(key, value);
			end;
		end;
	end;
end;

-- A function to get a player's shared variable.
function Clockwork.player:GetSharedVar(player, key)
	if (IsValid(player)) then
		local sharedVars = Clockwork:GetSharedVars():Player();
		
		if (!sharedVars or not sharedVars[key]) then
			return player:GetNetworkedVar(key);
		end;
		
		local sharedVarData = sharedVars[key];
		
		if (sharedVarData.bPlayerOnly) then
			if (!player.cwSharedVars[key]) then
				return Clockwork:GetDefaultNetworkedValue(sharedVarData.class);
			else
				return player.cwSharedVars[key];
			end;
		else
			local class = Clockwork:ConvertNetworkedClass(
				sharedVarData.class
			);
			
			if (class) then
				return player["GetNetworked"..class](player, key);
			else
				return player:GetNetworkedVar(key);
			end;
		end;
	end;
end;

-- A function to set whether a player's character is banned.
function Clockwork.player:SetBanned(player, banned)
	player:SetCharacterData("CharBanned", banned);
	player:SaveCharacter();
	player:SetSharedVar("CharBanned", banned);
end;

-- A function to set a player's name.
function Clockwork.player:SetName(player, name, saveless)
	local previousName = player:Name();
	local newName = name;
	
	player:SetCharacterData("Name", newName, true);
	player:SetSharedVar("Name", newName);
	
	if (!player.cwFirstSpawn) then
		Clockwork.plugin:Call("PlayerNameChanged", player, previousName, newName);
	end;
	
	if (!saveless) then
		player:SaveCharacter();
	end;
end;

-- A function to get a player's generator count.
function Clockwork.player:GetGeneratorCount(player)
	local generators = Clockwork.generator:GetAll();
	local count = 0;
	
	for k, v in pairs(generators) do
		count = count + self:GetPropertyCount(player, k);
	end;
	
	return count;
end;

-- A function to get a player's property entities.
function Clockwork.player:GetPropertyEntities(player, class)
	local uniqueID = player:UniqueID();
	local entities = {};
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (uniqueID == Clockwork.entity:QueryProperty(v, "uniqueID")) then
			if (key == Clockwork.entity:QueryProperty(v, "key")) then
				if (!class or v:GetClass() == class) then
					entities[#entities + 1] = v;
				end;
			end;
		end;
	end;
	
	return entities;
end;

-- A function to get a player's property count.
function Clockwork.player:GetPropertyCount(player, class)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (uniqueID == Clockwork.entity:QueryProperty(v, "uniqueID")) then
			if (key == Clockwork.entity:QueryProperty(v, "key")) then
				if (!class or v:GetClass() == class) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

-- A function to get a player's door count.
function Clockwork.player:GetDoorCount(player)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:GetCharacterKey();
	
	for k, v in pairs(self:GetAllProperty()) do
		if (Clockwork.entity:IsDoor(v) and !Clockwork.entity:GetDoorParent(v)) then
			if (uniqueID == Clockwork.entity:QueryProperty(v, "uniqueID")) then
				if (player:GetCharacterKey() == Clockwork.entity:QueryProperty(v, "key")) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

-- A function to take a player's door access.
function Clockwork.player:TakeDoorAccess(player, door)
	if (door.accessList) then
		door.accessList[player:GetCharacterKey()] = false;
	end;
end;

-- A function to give a player door access.
function Clockwork.player:GiveDoorAccess(player, door, access)
	local key = player:GetCharacterKey();
	
	if (!door.accessList) then
		door.accessList = {
			[key] = access
		};
	else
		door.accessList[key] = access;
	end;
end;

-- A function to check if a player has door access.
function Clockwork.player:HasDoorAccess(player, door, access, isAccurate)
	if (!access) then
		return self:HasDoorAccess(player, door, DOOR_ACCESS_BASIC, isAccurate);
	else
		local doorParent = Clockwork.entity:GetDoorParent(door);
		local key = player:GetCharacterKey();
		
		if (doorParent and Clockwork.entity:DoorHasSharedAccess(doorParent)
		and (!door.accessList or door.accessList[key] == nil)) then
			return Clockwork.plugin:Call("PlayerDoesHaveDoorAccess", player, doorParent, access, isAccurate);
		else
			return Clockwork.plugin:Call("PlayerDoesHaveDoorAccess", player, door, access, isAccurate);
		end;
	end;
end;

-- A function to check if a player can afford an amount.
function Clockwork.player:CanAfford(player, amount)
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		return (player:GetCash() >= amount);
	else
		return true;
	end;
end;

-- A function to give a player an amount of cash.
function Clockwork.player:GiveCash(player, amount, reason, bNoMsg)
	if (Clockwork.config:Get("cash_enabled"):Get()) then
		local positiveHintColor = "positive_hint";
		local negativeHintColor = "negative_hint";
		local roundedAmount = math.Round(amount);
		local cash = math.Round(math.max(player:GetCash() + roundedAmount, 0));
		
		player:SetCharacterData("Cash", cash, true);
		player:SetSharedVar("Cash", cash);
		
		if (roundedAmount < 0) then
			roundedAmount = math.abs(roundedAmount);
			
			if (!bNoMsg) then
				if (reason) then
					Clockwork.player:Notify(player, "Your character has lost "..FORMAT_CASH(roundedAmount).." ("..reason..")!");
				else
					Clockwork.player:Notify(player, "Your character has lost "..FORMAT_CASH(roundedAmount).."!");
				end;
			end;
		elseif (roundedAmount > 0) then
			if (!bNoMsg) then
				if (reason) then
					Clockwork.player:Notify(player, "Your character has gained "..FORMAT_CASH(roundedAmount).." ("..reason..").");
				else
					Clockwork.player:Notify(player, "Your character has gained "..FORMAT_CASH(roundedAmount)..".");
				end;
			end;
		end;
		
		Clockwork.plugin:Call("PlayerCashUpdated", player, roundedAmount, reason, bNoMsg);
	end;
end;

-- A function to show cinematic text to a player.
function Clockwork.player:CinematicText(player, text, color, barLength, hangTime)
	Clockwork:StartDataStream(player, "CinematicText", {
		text = text,
		color = color,
		barLength = barLength,
		hangTime = hangTime
	});
end;

-- A function to show cinematic text to each player.
function Clockwork.player:CinematicTextAll(text, color, hangTime)
	
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			self:CinematicText(v, text, color, hangTime);
		end;
	end;
end;

-- A function to find a player by an ID.
function Clockwork.player:FindByID(name)
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (string.find(string.lower(v:Name()), string.lower(name), 1, true)) then
				return v;
			end;
		end;
	end;
	
	return false;
end;

-- A function to notify each player in a radius.
function Clockwork.player:NotifyInRadius(text, class, position, radius)
	local listeners = {};
	
	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (position:Distance(v:GetPos()) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;
	
	self:Notify(listeners, text, class);
end;

-- A function to notify each player.
function Clockwork.player:NotifyAll(text, class)
	self:Notify(nil, text, true);
end;

-- A function to notify a player.
function Clockwork.player:Notify(player, text, class)
	if (type(player) == "table") then
		for k, v in ipairs(player) do
			self:Notify(v, text, class);
		end;
	elseif (class == true) then
		Clockwork.chatBox:Add(player, nil, "notify_all", text);
	elseif (!class) then
		Clockwork.chatBox:Add(player, nil, "notify", text);
	else
		umsg.Start("cwNotification", player);
			umsg.String(text);
			umsg.Short(class);
		umsg.End();
	end;
end;

-- A function to set a player's weapons list from a table.
function Clockwork.player:SetWeapons(player, weapons, bForceReturn)
	for k, v in pairs(weapons) do
		if (!player:HasWeapon(v.weaponData["class"])) then
			if (!v.teamIndex or player:Team() == v.teamIndex) then
				player:Give(
					v.weaponData["class"], v.weaponData["itemTable"], bForceReturn
				);
			end;
		end;
	end;
end;

-- A function to give ammo to a player from a table.
function Clockwork.player:GiveAmmo(player, ammo)
	for k, v in pairs(ammo) do player:GiveAmmo(v, k); end;
end;

-- A function to set a player's ammo list from a table.
function Clockwork.player:SetAmmo(player, ammo)
	for k, v in pairs(ammo) do player:SetAmmo(v, k); end;
end;

-- A function to get a player's ammo list as a table.
function Clockwork.player:GetAmmo(player, bDoStrip)
	local spawnAmmo = self:GetSpawnAmmo(player);
	local ammo = {
		["sniperpenetratedround"] = player:GetAmmoCount("sniperpenetratedround"),
		["striderminigun"] = player:GetAmmoCount("striderminigun"),
		["helicoptergun"] = player:GetAmmoCount("helicoptergun"),
		["combinecannon"] = player:GetAmmoCount("combinecannon"),
		["smg1_grenade"] = player:GetAmmoCount("smg1_grenade"),
		["gaussenergy"] = player:GetAmmoCount("gaussenergy"),
		["sniperround"] = player:GetAmmoCount("sniperround"),
		["airboatgun"] = player:GetAmmoCount("airboatgun"),
		["ar2altfire"] = player:GetAmmoCount("ar2altfire"),
		["rpg_round"] = player:GetAmmoCount("rpg_round"),
		["xbowbolt"] = player:GetAmmoCount("xbowbolt"),
		["buckshot"] = player:GetAmmoCount("buckshot"),
		["alyxgun"] = player:GetAmmoCount("alyxgun"),
		["grenade"] = player:GetAmmoCount("grenade"),
		["thumper"] = player:GetAmmoCount("thumper"),
		["gravity"] = player:GetAmmoCount("gravity"),
		["battery"] = player:GetAmmoCount("battery"),
		["pistol"] = player:GetAmmoCount("pistol"),
		["slam"] = player:GetAmmoCount("slam"),
		["smg1"] = player:GetAmmoCount("smg1"),
		["357"] = player:GetAmmoCount("357"),
		["ar2"] = player:GetAmmoCount("ar2")
	};
	
	if (spawnAmmo) then
		for k, v in pairs(spawnAmmo) do
			if (ammo[k]) then
				ammo[k] = math.max(ammo[k] - v, 0);
			end;
		end;
	end;
	
	if (bDoStrip) then
		player:RemoveAllAmmo();
	end;
	
	return ammo;
end;

-- A function to get a player's weapons list as a table.
function Clockwork.player:GetWeapons(player, bDoKeep)
	local weapons = {};
	
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = Clockwork.item:GetByWeapon(v);
		local teamIndex = player:Team();
		local class = v:GetClass();
		
		if (!self:GetSpawnWeapon(player, class)) then
			teamIndex = nil;
		end;
		
		weapons[#weapons + 1] = {
			weaponData = {
				itemTable = itemTable,
				class = class
			},
			teamIndex = teamIndex
		};
		
		if (!bDoKeep) then
			player:StripWeapon(class);
		end;
	end;
	
	return weapons;
end;

-- A function to get the total weight of a player's equipped weapons.
function Clockwork.player:GetEquippedWeight(player)
	local weight = 0;
	
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = Clockwork.item:GetByWeapon(v);
		
		if (itemTable) then
			weight = weight + itemTable("weight");
		end;
	end;
	
	return weight;
end;

-- A function to get a player's holstered weapon.
function Clockwork.player:GetHolsteredWeapon(player)
	for k, v in pairs(player:GetWeapons()) do
		local itemTable = Clockwork.item:GetByWeapon(v);
		local class = v:GetClass();
		
		if (itemTable) then
			if (self:GetWeaponClass(player) != class) then
				return class;
			end;
		end;
	end;
end;

-- A function to check whether a player is ragdolled.
function Clockwork.player:IsRagdolled(player, exception, bNoEntity)
	if (player:GetRagdollEntity() or bNoEntity) then
		local ragdolled = player:GetSharedVar("IsRagdoll");
		
		if (ragdolled == exception) then
			return false;
		else
			return (ragdolled != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to set a player's unragdoll time.
function Clockwork.player:SetUnragdollTime(player, delay)
	player.cwRagdollPaused = nil;
	
	if (delay) then
		self:SetAction(player, "unragdoll", delay, 2, function()
			if (IsValid(player) and player:Alive()) then
				self:SetRagdollState(player, RAGDOLL_NONE);
			end;
		end);
	else
		self:SetAction(player, "unragdoll", false);
	end;
end;

-- A function to pause a player's unragdoll time.
function Clockwork.player:PauseUnragdollTime(player)
	if (!player.cwRagdollPaused) then
		local unragdollTime = self:GetUnragdollTime(player);
		local curTime = CurTime();
		
		if (player:IsRagdolled()) then
			if (unragdollTime > 0) then
				player.cwRagdollPaused = unragdollTime - curTime;
				self:SetAction(player, "unragdoll", false);
			end;
		end;
	end;
end;

-- A function to start a player's unragdoll time.
function Clockwork.player:StartUnragdollTime(player)
	if (player.cwRagdollPaused) then
		if (player:IsRagdolled()) then
			self:SetUnragdollTime(player, player.cwRagdollPaused);
			
			player.cwRagdollPaused = nil;
		end;
	end;
end;

-- A function to get a player's unragdoll time.
function Clockwork.player:GetUnragdollTime(player)
	local action, actionDuration, startActionTime = self:GetAction(player);
	
	if (action == "unragdoll") then
		return startActionTime + actionDuration;
	else
		return 0;
	end;
end;

-- A function to get a player's ragdoll state.
function Clockwork.player:GetRagdollState(player)
	return player:GetSharedVar("IsRagdoll");
end;

-- A function to get a player's ragdoll entity.
function Clockwork.player:GetRagdollEntity(player)
	if (player.cwRagdollTab) then
		if (IsValid(player.cwRagdollTab.entity)) then
			return player.cwRagdollTab.entity;
		end;
	end;
end;

-- A function to get a player's ragdoll table.
function Clockwork.player:GetRagdollTable(player)
	return player.cwRagdollTab;
end;

-- A function to do a player's ragdoll decay check.
function Clockwork.player:DoRagdollDecayCheck(player, ragdoll)
	local index = ragdoll:EntIndex();
	
	Clockwork:CreateTimer("DecayCheck"..index, 60, 0, function()
		local ragdollIsValid = IsValid(ragdoll);
		local playerIsValid = IsValid(player);
		
		if (!playerIsValid and ragdollIsValid) then
			if (!Clockwork.entity:IsDecaying(ragdoll)) then
				local decayTime = Clockwork.config:Get("body_decay_time"):Get();
				
				if (decayTime > 0 and Clockwork.plugin:Call("PlayerCanRagdollDecay", player, ragdoll, decayTime)) then
					Clockwork.entity:Decay(ragdoll, decayTime);
				end;
			else
				Clockwork:DestroyTimer("DecayCheck"..index);
			end;
		elseif (!ragdollIsValid) then
			Clockwork:DestroyTimer("DecayCheck"..index);
		end;
	end);
end;

-- A function to set a player's ragdoll immunity.
function Clockwork.player:SetRagdollImmunity(player, delay)
	if (delay) then
		player:GetRagdollTable().immunity = CurTime() + delay;
	else
		player:GetRagdollTable().immunity = 0;
	end;
end;

-- A function to set a player's ragdoll state.
function Clockwork.player:SetRagdollState(player, state, delay, decay, force, multiplier, velocityCallback)
	if (state == RAGDOLL_KNOCKEDOUT or state == RAGDOLL_FALLENOVER) then
		if (player:IsRagdolled()) then
			if (Clockwork.plugin:Call("PlayerCanRagdoll", player, state, delay, decay, player.cwRagdollTab)) then
				self:SetUnragdollTime(player, delay);
				
				player:SetSharedVar("IsRagdoll", state);
				player.cwRagdollTab.delay = delay;
				player.cwRagdollTab.decay = decay;
				
				Clockwork.plugin:Call("PlayerRagdolled", player, state, player.cwRagdollTab);
			end;
		elseif (Clockwork.plugin:Call("PlayerCanRagdoll", player, state, delay, decay)) then
			local velocity = player:GetVelocity() + (player:GetAimVector() * 128);
			local ragdoll = ents.Create("prop_ragdoll");
			
			ragdoll:SetMaterial(player:GetMaterial());
			ragdoll:SetAngles(player:GetAngles());
			ragdoll:SetColor(player:GetColor());
			ragdoll:SetModel(player:GetModel());
			ragdoll:SetSkin(player:GetSkin());
			ragdoll:SetPos(player:GetPos());
			ragdoll:Spawn();
			
			player.cwRagdollTab = {};
			player.cwRagdollTab.eyeAngles = player:EyeAngles();
			player.cwRagdollTab.immunity = CurTime() + Clockwork.config:Get("ragdoll_immunity_time"):Get();
			player.cwRagdollTab.moveType = MOVETYPE_WALK;
			player.cwRagdollTab.entity = ragdoll;
			player.cwRagdollTab.health = player:Health();
			player.cwRagdollTab.armor = player:Armor();
			player.cwRagdollTab.delay = delay;
			player.cwRagdollTab.decay = decay;
			
			if (!player:IsOnGround()) then
				player.cwRagdollTab.immunity = 0;
			end;
			
			if (IsValid(ragdoll)) then
				local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
				
				ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				for i = 1, ragdoll:GetPhysicsObjectCount() do
					local physicsObject = ragdoll:GetPhysicsObjectNum(i);
					local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
					local position, angle = player:GetBonePosition(boneIndex);
					
					if (IsValid(physicsObject)) then
						physicsObject:SetPos(position);
						physicsObject:SetAngle(angle);
						
						if (!velocityCallback) then
							if (boneIndex == headIndex) then
								physicsObject:SetVelocity(velocity * 1.5);
							else
								physicsObject:SetVelocity(velocity);
							end;
							
							if (force) then
								if (boneIndex == headIndex) then
									physicsObject:ApplyForceCenter(force * 1.5);
								else
									physicsObject:ApplyForceCenter(force);
								end;
							end;
						else
							velocityCallback(physicsObject, boneIndex, ragdoll, velocity, force);
						end;
					end;
				end;
			end;
			
			if (player:Alive()) then
				if (IsValid(player:GetActiveWeapon())) then
					player.cwRagdollTab.weapon = self:GetWeaponClass(player);
				end;
				
				player.cwRagdollTab.weapons = self:GetWeapons(player, true);
				
				if (delay) then
					self:SetUnragdollTime(player, delay);
				end;
			end;
			
			if (player:InVehicle()) then
				player:ExitVehicle();
				player.cwRagdollTab.eyeAngles = Angle(0, 0, 0);
			end;
			
			if (player:IsOnFire()) then
				ragdoll:Ignite(8, 0);
			end;
			
			player:Spectate(OBS_MODE_CHASE);
			player:RunCommand("-duck");
			player:RunCommand("-voicerecord");
			player:SetMoveType(MOVETYPE_OBSERVER);
			player:StripWeapons(true);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			if (player:FlashlightIsOn()) then
				player:Flashlight(false);
			end;
			
			player.cwRagdollPaused = nil;
			
			player:SetSharedVar("IsRagdoll", state);
			player:SetSharedVar("Ragdoll", ragdoll);
			
			if (state != RAGDOLL_FALLENOVER) then
				self:GiveDeathCode(player);
			end;
			
			Clockwork.entity:SetPlayer(ragdoll, player);
			self:DoRagdollDecayCheck(player, ragdoll);
			
			Clockwork.plugin:Call("PlayerRagdolled", player, state, player.cwRagdollTab);
		end;
	elseif (state == RAGDOLL_NONE or state == RAGDOLL_RESET) then
		if (player:IsRagdolled(nil, true)) then
			local ragdollTable = player:GetRagdollTable();
			
			if (Clockwork.plugin:Call("PlayerCanUnragdoll", player, state, ragdollTable)) then
				player:UnSpectate();
				player:CrosshairEnable();
				
				if (state != RAGDOLL_RESET) then
					self:LightSpawn(player, nil, nil, true);
				end;
				
				if (state != RAGDOLL_RESET) then
					if (IsValid(ragdollTable.entity)) then
						local position = Clockwork.entity:GetPelvisPosition(ragdollTable.entity);
						
						if (position) then
							self:SetSafePosition(player, position, ragdollTable.entity);
						end;
						
						player:SetSkin(ragdollTable.entity:GetSkin());
						player:SetColor(ragdollTable.entity:GetColor());
						player:SetModel(ragdollTable.entity:GetModel());
						player:SetMaterial(ragdollTable.entity:GetMaterial());
					end;
					
					player:SetArmor(ragdollTable.armor);
					player:SetHealth(ragdollTable.health);
					player:SetMoveType(ragdollTable.moveType);
					player:SetEyeAngles(ragdollTable.eyeAngles);
				end;
				
				if (IsValid(ragdollTable.entity)) then
					Clockwork:DestroyTimer("DecayCheck"..ragdollTable.entity:EntIndex());
					
					if (ragdollTable.decay) then
						if (Clockwork.plugin:Call("PlayerCanRagdollDecay", player, ragdollTable.entity, ragdollTable.decay)) then
							Clockwork.entity:Decay(ragdollTable.entity, ragdollTable.decay);
						end;
					else
						ragdollTable.entity:Remove();
					end;
				end;
				
				if (state != RAGDOLL_RESET) then
					self:SetWeapons(player, ragdollTable.weapons, true);
					
					if (ragdollTable.weapon) then
						player:SelectWeapon(ragdollTable.weapon);
					end;
				end;
				
				self:SetUnragdollTime(player, false);
				
				player:SetSharedVar("IsRagdoll", RAGDOLL_NONE);
				player:SetSharedVar("Ragdoll", NULL);
				
				Clockwork.plugin:Call("PlayerUnragdolled", player, state, ragdollTable);
				
				player.cwRagdollPaused = nil;
				player.cwRagdollTab = {};
			end;
		end;
	end;
end;

-- A function to make a player drop their weapons.
function Clockwork.player:DropWeapons(player)
	local ragdollEntity = player:GetRagdollEntity();
	
	if (player:IsRagdolled()) then
		local ragdollWeapons = player:GetRagdollWeapons();
		
		for k, v in pairs(ragdollWeapons) do
			local itemTable = v.weaponData["itemTable"];
			
			if (itemTable and Clockwork.plugin:Call("PlayerCanDropWeapon", player, itemTable, NULL, true)) then
				local info = {
					itemTable = itemTable,
					position = ragdollEntity:GetPos() + Vector(0, 0, math.random(1, 48)),
					angles = Angle(0, 0, 0)
				};
				
				player:TakeItem(info.itemTable, true);
				ragdollWeapons[k] = nil;
				
				if (Clockwork.plugin:Call("PlayerAdjustDropWeaponInfo", player, info)) then
					local entity = Clockwork.entity:CreateItem(player, info.itemTable, info.position, info.angles);
					
					if (IsValid(entity)) then
						Clockwork.plugin:Call("PlayerDropWeapon", player, info.itemTable, entity, NULL);
					end;
				end;
			end;
		end;
	else
		for k, v in pairs(player:GetWeapons()) do
			local itemTable = Clockwork.item:GetByWeapon(v);
			
			if (itemTable and Clockwork.plugin:Call("PlayerCanDropWeapon", player, itemTable, v, true)) then
				local info = {
					itemTable = itemTable,
					position = player:GetPos() + Vector(0, 0, math.random(1, 48)),
					angles = Angle(0, 0, 0)
				};
				
				if (Clockwork.plugin:Call("PlayerAdjustDropWeaponInfo", player, info)) then
					local entity = Clockwork.entity:CreateItem(
						player, info.itemTable, info.position, info.angles
					);
					
					if (IsValid(entity)) then
						Clockwork.plugin:Call("PlayerDropWeapon", player, info.itemTable, entity, v);
						player:StripWeapon(v:GetClass());
						player:TakeItem(info.itemTable, true);
					end;
				end;
			end;
		end;
	end;
end;

-- A function to lightly spawn a player.
function Clockwork.player:LightSpawn(player, weapons, ammo, bForceReturn)
	if (player:IsRagdolled() and !bForceReturn) then
		self:SetRagdollState(player, RAGDOLL_NONE);
	end;
	
	player.cwLightSpawn = true;
	
	local moveType = player:GetMoveType();
	local material = player:GetMaterial();
	local position = player:GetPos();
	local angles = player:EyeAngles();
	local weapon = player:GetActiveWeapon();
	local health = player:Health();
	local armor = player:Armor();
	local model = player:GetModel();
	local color = player:GetColor();
	local skin = player:GetSkin();
	
	if (ammo) then
		if (type(ammo) != "table") then
			ammo = self:GetAmmo(player, true);
		end;
	end;
	
	if (weapons) then
		if (type(weapons) != "table") then
			weapons = self:GetWeapons(player);
		end;
		
		if (IsValid(weapon)) then
			weapon = weapon:GetClass();
		end;
	end;
	
	player.cwSpawnCallback = function(player, gamemodeHook)
		if (weapons) then
			Clockwork:PlayerLoadout(player);
			
			self:SetWeapons(player, weapons, bForceReturn);
			
			if (type(weapon) == "string") then
				player:SelectWeapon(weapon);
			end;
		end;
		
		if (ammo) then
			self:GiveAmmo(player, ammo);
		end;
		
		player:SetPos(position);
		player:SetSkin(skin);
		player:SetModel(model);
		player:SetColor(color);
		player:SetArmor(armor);
		player:SetHealth(health);
		player:SetMaterial(material);
		player:SetMoveType(moveType);
		player:SetEyeAngles(angles);
		
		if (gamemodeHook) then
			special = special or false;
			
			Clockwork.plugin:Call("PostPlayerLightSpawn", player, weapons, ammo, special);
		end;
		
		player:ResetSequence(player:GetSequence());
	end;
	
	player:Spawn();
end;

-- A function to convert a table to camel case.
function Clockwork.player:ConvertToCamelCase(baseTable)
	local newTable = {};
	
	for k, v in pairs(baseTable) do
		local key = Clockwork:SetCamelCase(string.gsub(k, "_", ""), true);
		
		if (key and key != "") then
			newTable[key] = v;
		end;
	end;
	
	return newTable;
end;

-- A function to get a player's characters.
function Clockwork.player:GetCharacters(player, Callback)
	if (IsValid(player)) then
		local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
		local schemaFolder = Clockwork:GetSchemaFolder();
		
		tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..player:SteamID().."\"", function(result)
			if (IsValid(player)) then
				if (result and type(result) == "table" and #result > 0) then
					local characters = {};
					
					for k, v in pairs(result) do
						characters[k] = self:ConvertToCamelCase(v);
					end;
					
					Callback(characters);
				else
					Callback();
				end;
			end;
		end, 1);
	end
end;

-- A function to add a character to the character screen.
function Clockwork.player:CharacterScreenAdd(player, character)
	local info = {
		name = character.name,
		model = character.model,
		banned = character.data["CharBanned"],
		faction = character.faction,
		characterID = character.characterID
	};
	
	if (character.data["PhysDesc"]) then
		if (string.len(character.data["PhysDesc"]) > 64) then
			info.details = string.sub(character.data["PhysDesc"], 1, 64).."...";
		else
			info.details = character.data["PhysDesc"];
		end;
	end;
	
	if (character.data["CharBanned"]) then
		info.details = "This character is banned.";
	end;
	
	Clockwork.plugin:Call("PlayerAdjustCharacterScreenInfo", player, character, info);
	Clockwork:StartDataStream(player, "CharacterAdd", info);
end;

-- A function to convert a character's MySQL variables to Lua variables.
function Clockwork.player:ConvertCharacterMySQL(baseTable)
	baseTable.recognisedNames = self:ConvertCharacterRecognisedNamesString(baseTable.recognisedNames);
	baseTable.characterID = tonumber(baseTable.characterID);
	baseTable.attributes = self:ConvertCharacterDataString(baseTable.attributes);
	baseTable.inventory = Clockwork.inventory:ToLoadable(
		self:ConvertCharacterDataString(baseTable.inventory)
	);
	baseTable.cash = tonumber(baseTable.cash);
	baseTable.ammo = self:ConvertCharacterDataString(baseTable.ammo);
	baseTable.data = self:ConvertCharacterDataString(baseTable.data);
	baseTable.key = tonumber(baseTable.key);
end;

-- A function to get a player's character ID.
function Clockwork.player:GetCharacterID(player)
	local character = player:GetCharacter();
	
	if (character) then
		for k, v in pairs(player:GetCharacters()) do
			if (v == character) then
				return k;
			end;
		end;
	end;
end;

-- A function to load a player's character.
function Clockwork.player:LoadCharacter(player, characterID, mergeCreate, Callback, bForce)
	local character = {};
	local unixTime = os.time();
	
	if (mergeCreate) then
		character = {};
		character.name = name;
		character.data = {};
		character.ammo = {};
		character.cash = Clockwork.config:Get("default_cash"):Get();
		character.model = "models/police.mdl";
		character.flags = "b";
		character.schema = Clockwork:GetSchemaFolder();
		character.gender = GENDER_MALE;
		character.faction = FACTION_CITIZEN;
		character.steamID = player:SteamID();
		character.steamName = player:SteamName();
		character.inventory = {};
		character.attributes = {};
		character.onNextLoad = "";
		character.lastPlayed = unixTime;
		character.timeCreated = unixTime;
		character.characterID = characterID;
		character.recognisedNames = {};
		
		if (!player.cwCharacterList[characterID]) then
			table.Merge(character, mergeCreate);
			
			if (character and type(character) == "table") then
				character.inventory = {};
				Clockwork.plugin:Call(
					"GetPlayerDefaultInventory", player, character, character.inventory
				);
				
				if (!bForce) then
					local fault = Clockwork.plugin:Call("PlayerCanCreateCharacter", player, character, characterID);
					
					if (fault == false or type(fault) == "string") then
						return self:SetCreateFault(player, fault or "You cannot create this character!");
					end;
				end;
				
				self:SaveCharacter(player, true, character, function(key)
					player.cwCharacterList[characterID] = character;
					player.cwCharacterList[characterID].key = key;
					
					Clockwork.plugin:Call("PlayerCharacterCreated", player, character);
					
					self:CharacterScreenAdd(player, character);
					
					if (Callback) then
						Callback();
					end;
				end);
			end;
		end;
	else
		character = player.cwCharacterList[characterID];
		
		if (character) then
			if (player:GetCharacter()) then
				self:SaveCharacter(player);
				self:UpdateCharacter(player);
				
				Clockwork.plugin:Call("PlayerCharacterUnloaded", player);
			end;
			
			player.cwCharacter = character;
			
			if (player:Alive()) then
				player:KillSilent();
			end;
			
			if (self:SetBasicSharedVars(player)) then
				Clockwork.plugin:Call("PlayerCharacterLoaded", player);
				player:SaveCharacter();
			end;
		end;
	end;
end;

-- A function to set a player's basic shared variables.
function Clockwork.player:SetBasicSharedVars(player)
	local gender = player:GetGender();
	local faction = player:GetFaction();
	
	player:SetSharedVar("Flags", player:GetFlags());
	player:SetSharedVar("Model", self:GetDefaultModel(player));
	player:SetSharedVar("Name", player:Name());
	player:SetSharedVar("Key", player:GetCharacterKey());
	
	if (Clockwork.faction.stored[faction]) then
		player:SetSharedVar("Faction", Clockwork.faction.stored[faction].index);
	end;
	
	if (gender == GENDER_MALE) then
		player:SetSharedVar("Gender", 2);
	else
		player:SetSharedVar("Gender", 1);
	end;
	
	return true;
end;

-- A function to get the character's ammo as a string.
function Clockwork.player:GetCharacterAmmoString(player, character, bRawTable)
	local ammo = table.Copy(character.ammo);
	
	for k, v in pairs(self:GetAmmo(player)) do
		if (v > 0) then
			ammo[k] = v;
		end;
	end;
	
	if (!bRawTable) then
		return Json.Encode(ammo);
	else
		return ammo;
	end;
end;

-- A function to get the character's data as a string.
function Clockwork.player:GetCharacterDataString(player, character, bRawTable)
	local data = table.Copy(character.data);
	
	Clockwork.plugin:Call("PlayerSaveCharacterData", player, data);
	
	if (!bRawTable) then
		return Json.Encode(data);
	else
		return data;
	end;
end;

-- A function to get the character's recognised names as a string.
function Clockwork.player:GetCharacterRecognisedNamesString(player, character)
	local recognisedNames = {};
	
	for k, v in pairs(character.recognisedNames) do
		if (v == RECOGNISE_SAVE) then
			recognisedNames[#recognisedNames + 1] = k;
		end;
	end;
	
	return Json.Encode(recognisedNames);
end;

-- A function to get the character's inventory as a string.
function Clockwork.player:GetCharacterInventoryString(player, character, bRawTable)
	local inventory = Clockwork.inventory:CreateDuplicate(character.inventory);
		Clockwork.plugin:Call("PlayerAddToSavedInventory", player, character, function(itemTable)
			Clockwork.inventory:AddInstance(inventory, itemTable);
		end);
	inventory = Clockwork.inventory:ToSaveable(inventory);
	
	if (!bRawTable) then
		return Json.Encode(inventory);
	else
		return inventory;
	end;
end;

-- A function to convert a character's recognised names string to a table.
function Clockwork.player:ConvertCharacterRecognisedNamesString(data)
	local success, value = pcall(Json.Decode, data);
	
	if (success) then
		local recognisedNames = {};
		
		for k, v in pairs(value) do
			recognisedNames[v] = RECOGNISE_SAVE;
		end;
		
		return recognisedNames;
	else
		return {};
	end;
end;

-- A function to convert a character's data string to a table.
function Clockwork.player:ConvertCharacterDataString(data)
	local success, value = pcall(Json.Decode, data);
	
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to load a player's data.
function Clockwork.player:LoadData(player, Callback)
	if (!Clockwork.AddedDonationsRow) then
		tmysql.query("ALTER TABLE "..Clockwork.config:Get("mysql_players_table"):Get().." ADD _Donations TEXT AFTER _SteamID");
		Clockwork.AddedDonationsRow = true;
	end;
	
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
	local schemaFolder = Clockwork:GetSchemaFolder();
	local unixTime = os.time();
	local steamID = player:SteamID();
	
	tmysql.query("SELECT * FROM "..playersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"", function(result)
		if (IsValid(player) and !player.cwData) then
			local ownerSteamID = Clockwork.config:Get("owner_steamid"):Get();
			local onNextPlay = "";
			
			if (result and type(result) == "table" and #result > 0) then
				player.cwTimeJoined = tonumber(result[1]._TimeJoined);
				player.cwLastPlayed = tonumber(result[1]._LastPlayed);
				player.cwUserGroup = result[1]._UserGroup;
				player.cwData = self:ConvertDataString(player, result[1]._Data);
				
				local success, value = pcall(Json.Decode, result[1]._Donations);
				
				if (success) then
					player.cwDonations = value;
				else
					player.cwDonations = {};
				end;
				
				onNextPlay = result[1]._OnNextPlay;
			else
				player.cwTimeJoined = unixTime;
				player.cwLastPlayed = unixTime;
				player.cwDonations = {};
				player.cwUserGroup = "user";
				player.cwData = self:SaveData(player, true);
			end;
			
			if (string.lower(steamID) == string.lower(ownerSteamID)) then
				player.cwUserGroup = "superadmin";
			end;
			
			if (!player.cwUserGroup or player.cwUserGroup == "") then
				player.cwUserGroup = "user";
			end;
			
			if (!Clockwork.config:Get("use_own_group_system"):Get()
			and player.cwUserGroup != "user") then
				player:SetUserGroup(player.cwUserGroup);
			end;
			
			Clockwork.plugin:Call("PlayerRestoreData", player, player.cwData);
			
			if (Callback and IsValid(player)) then
				Callback(player);
			end;
			
			if (onNextPlay != "") then
				tmysql.query("UPDATE "..playersTable.." SET _OnNextPlay = \"\" WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"");
				
				PLAYER = player;
					RunString(onNextPlay);
				PLAYER = nil;
			end;
		end;
	end, 1);
	
	timer.Simple(2, function()
		if (IsValid(player) and !player.cwData) then
			self:LoadData(player, Callback);
		end;
	end);
end;

-- A function to save a players's data.
function Clockwork.player:SaveData(player, create, delay, bReturnQuery)
	if (create) then
		local query = self:GetDataCreateQuery(player);
		
		if (delay) then
			timer.Simple(delay, function()
				tmysql.query(query);
			end);
		elseif (bReturnQuery) then
			return query;
		else
			tmysql.query(query);
		end;
		
		return {};
	else
		local query = self:GetDataUpdateQuery(player);
		
		if (delay) then
			timer.Simple(delay, function()
				tmysql.query(query);
			end);
		elseif (!bReturnQuery) then
			tmysql.query(query);
		else
			return query;
		end;
	end;
end;

-- A function to get the create query of a player's data.
function Clockwork.player:GetDataCreateQuery(player)
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
	local schemaFolder = Clockwork:GetSchemaFolder();
	local steamName = tmysql.escape(player:SteamName());
	local ipAddress = player:IPAddress();
	local userGroup = "user";
	local unixTime = os.time();
	local steamID = player:SteamID();
	local query = "INSERT INTO "..playersTable.." (_Data, _Schema, _SteamID, _Donations, _UserGroup, _IPAddress, _SteamName, _OnNextPlay, _LastPlayed, _TimeJoined) ";
	
	query = query.."VALUES (\"\", \""..schemaFolder.."\", \""..steamID.."\", \"\", \""..userGroup.."\", \""..ipAddress.."\", \""..steamName.."\",";
	query = query.." \"\", \""..unixTime.."\", \""..unixTime.."\")";
	
	return query;
end;

-- A function to get the update query of player's data.
function Clockwork.player:GetDataUpdateQuery(player)
	local schemaFolder = Clockwork:GetSchemaFolder();
	local steamName = tmysql.escape(player:SteamName());
	local ipAddress = player:IPAddress();
	local userGroup = player:GetClockworkUserGroup();
	local steamID = player:SteamID();
	local data = table.Copy(player.cwData);
	
	Clockwork.plugin:Call("PlayerSaveData", player, data);
	
	local playersTable = Clockwork.config:Get("mysql_players_table"):Get();
	local unixTime = os.time();
	local query = "UPDATE "..playersTable.." SET _Data = \""..tmysql.escape(Json.Encode(data)).."\",";
	
	query = query.." _SteamName = \""..steamName.."\", _IPAddress = \""..ipAddress.."\", _LastPlayed = \""..unixTime.."\", _UserGroup = \""..userGroup.."\"";
	query = query.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"";
	
	return query;
end;

-- A function to get the create query of a character.
function Clockwork.player:GetCharacterCreateQuery(player, character)
	local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
	local values = "";
	local amount = 1;
	local keys = "";
	
	if (!character or type(character) != "table") then
		character = player:GetCharacter();
	end;
	
	local characterKeys = table.Count(character);
	
	for k, v in pairs(character) do
		if (characterKeys != amount) then
			keys = keys.."_"..Clockwork:SetCamelCase(k, false)..", ";
		else
			keys = keys.."_"..Clockwork:SetCamelCase(k, false);
		end;
		
		if (type(v) == "table") then
			if (k == "recognisedNames") then
				v = Json.Encode(character.recognisedNames);
			elseif (k == "attributes") then
				v = Json.Encode(character.attributes);
			elseif (k == "inventory") then
				v = Json.Encode(
					Clockwork.inventory:ToSaveable(character.inventory)
				);
			elseif (k == "ammo") then
				v = Json.Encode(character.ammo);
			elseif (k == "data") then
				v = Json.Encode(v);
			end;
		end;
		
		local value = tmysql.escape(tostring(v));
		
		if (characterKeys != amount) then
			values = values.."\""..value.."\", ";
		else
			values = values.."\""..value.."\"";
		end;
		
		amount = amount + 1;
	end;
	
	return "INSERT INTO "..charactersTable.." ("..keys..") VALUES ("..values..")";
end;

-- A function to get the update query of a character.
function Clockwork.player:GetCharacterUpdateQuery(player, character)
	local currentCharacter = player:GetCharacter();
	local charactersTable = Clockwork.config:Get("mysql_characters_table"):Get();
	local schemaFolder = Clockwork:GetSchemaFolder();
	local unixTime = os.time();
	local steamID = player:SteamID();
	local query = "";
	
	if (!character or type(character) != "table") then
		character = currentCharacter;
	end;
	
	for k, v in pairs(character) do
		if (k != "key" and k != "onNextLoad") then
			if (type(v) == "table") then
				if (k == "recognisedNames") then
					v = self:GetCharacterRecognisedNamesString(player, character);
				elseif (k == "attributes") then
					v = Json.Encode(character.attributes);
				elseif (k == "inventory") then
					if (currentCharacter == character) then
						v = self:GetCharacterInventoryString(player, character);
					else
						v = Json.Encode(
							Clockwork.inventory:ToSaveable(character.inventory)
						);
					end;
				elseif (k == "ammo") then
					if (currentCharacter == character) then
						v = self:GetCharacterAmmoString(player, character);
					else
						v = Json.Encode(character.ammo);
					end;
				elseif (k == "data") then
					if (currentCharacter == character) then
						v = self:GetCharacterDataString(player, character);
					else
						v = Json.Encode(character.data);
					end;
				end;
			elseif (k == "lastPlayed") then
				v = unixTime;
			elseif (k == "steamName") then
				v = player:SteamName();
			end;
			
			local value = tmysql.escape(tostring(v));
			
			if (query == "") then
				query = "UPDATE "..charactersTable.." SET _"..Clockwork:SetCamelCase(k, false).." = \""..value.."\"";
			else
				query = query..", _"..Clockwork:SetCamelCase(k, false).." = \""..value.."\"";
			end;
		end;
	end;
	
	return query.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\" AND _CharacterID = "..character.characterID;
end;

-- A function to update a player's character.
function Clockwork.player:UpdateCharacter(player)
	player.cwCharacter.inventory = self:GetCharacterInventoryString(player, player.cwCharacter, true);
	player.cwCharacter.ammo = self:GetCharacterAmmoString(player, player.cwCharacter, true);
	player.cwCharacter.data = self:GetCharacterDataString(player, player.cwCharacter, true);
end;

-- A function to save a player's character.
function Clockwork.player:SaveCharacter(player, create, character, Callback)
	if (create) then
		local query = self:GetCharacterCreateQuery(player, character);
		
		tmysql.query(query, function(result, status, lastID)
			if (Callback and tonumber(lastID)) then
				Callback(tonumber(lastID));
			end;
		end, 2);
	elseif (player:HasInitialized()) then
		local characterQuery = self:GetCharacterUpdateQuery(player, character);
		local dataQuery = self:SaveData(player, nil, nil, true);
		
		tmysql.query(characterQuery);
		tmysql.query(dataQuery);
	end;
end;

-- A function to get the class of a player's active weapon.
function Clockwork.player:GetWeaponClass(player, safe)
	if (IsValid(player:GetActiveWeapon())) then
		return player:GetActiveWeapon():GetClass();
	else
		return safe;
	end;
end;

-- A function to call a player's think hook.
function Clockwork.player:CallThinkHook(player, setSharedVars, infoTable, curTime)
	infoTable.inventoryWeight = Clockwork.config:Get("default_inv_weight"):Get();
	infoTable.crouchedSpeed = player.cwCrouchedSpeed;
	infoTable.jumpPower = player.cwJumpPower;
	infoTable.walkSpeed = player.cwWalkSpeed;
	infoTable.isRunning = player:IsRunning();
	infoTable.isJogging = player:IsJogging();
	infoTable.runSpeed = player.cwRunSpeed;
	infoTable.wages = Clockwork.class:Query(player:Team(), "wages", 0);
	
	if (!player:IsJogging(true)) then
		infoTable.isJogging = nil;
		player:SetSharedVar("IsJogMode", false);
	end;
	
	if (setSharedVars) then
		Clockwork.plugin:Call("PlayerSetSharedVars", player, curTime);
		player.cwNextSetSharedVars = nil;
	end;
	
	Clockwork.plugin:Call("PlayerThink", player, curTime, infoTable);
	player.cwNextThink = nil;

end;

-- A function to get a player's wages.
function Clockwork.player:GetWages(player)
	return player:GetSharedVar("Wages");
end;