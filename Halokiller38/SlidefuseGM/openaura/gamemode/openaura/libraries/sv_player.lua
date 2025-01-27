--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.player = {};
openAura.player.property = {};
openAura.player.sharedVars = {};

-- A function to get a player's gear.
function openAura.player:GetGear(player, class)
	if ( player.gearTable and IsValid( player.gearTable[class] ) ) then
		return player.gearTable[class];
	end;
end;

-- A function to open the character menu.
function openAura.player:SetCharacterMenuOpen(player, bReset)
	if ( player:HasInitialized() ) then
		umsg.Start("aura_CharacterOpen", player);
			umsg.Bool(bReset == true);
		umsg.End();
		
		if (bReset) then
			player.characterMenuReset = true;
			player:KillSilent();
		end;
	end;
end;

-- A function to start a sound for a player.
function openAura.player:StartSound(player, uniqueID, sound)
	if (!player.playingSounds) then
		player.playingSounds = {};
	end;
	
	if (!player.playingSounds[uniqueID] or player.playingSounds[uniqueID] != sound) then
		player.playingSounds[uniqueID] = sound;
		
		umsg.Start("aura_StartSound", player);
			umsg.String(uniqueID);
			umsg.String(sound);
		umsg.End();
	end;
end;

-- A function to stop a sound for a player.
function openAura.player:StopSound(player, uniqueID, iFadeOut)
	if (!player.playingSounds) then
		player.playingSounds = {};
	end;
	
	if ( player.playingSounds[uniqueID] ) then
		player.playingSounds[uniqueID] = nil;
		
		umsg.Start("aura_StopSound", player);
			umsg.String(uniqueID);
			umsg.Float(iFadeOut or 0);
		umsg.End();
	end;
end;

-- A function to create a player's gear.
function openAura.player:CreateGear(player, class, itemTable)
	if (!player.gearTable) then
		player.gearTable = {};
	end;
	
	if ( IsValid( player.gearTable[class] ) ) then
		player.gearTable[class]:Remove();
	end;
	
	if (itemTable.isAttachment) then
		local position = player:GetPos();
		local angles = player:GetAngles();
		local model = itemTable.model;
		
		if (itemTable.attachmentModel) then
			model = itemTable.attachmentModel;
		end;
		
		player.gearTable[class] = ents.Create("aura_gear");
		player.gearTable[class]:SetParent(player);
		player.gearTable[class]:SetAngles(angles);
		player.gearTable[class]:SetColor(255, 255, 255, 0);
		player.gearTable[class]:SetModel(model);
		player.gearTable[class]:SetPos(position);
		player.gearTable[class]:Spawn();
		
		if (itemTable.attachmentColor) then
			player.gearTable[class]:SetColor( openAura:UnpackColor(itemTable.attachmentColor) );
		end;
		
		if (itemTable.attachmentMaterial) then
			player.gearTable[class]:SetMaterial(itemTable.attachmentMaterial);
		end;
		
		if ( IsValid( player.gearTable[class] ) ) then
			player.gearTable[class]:SetOwner(player);
			player.gearTable[class]:SetItem(itemTable);
		end;
	end;
end;

-- A function to get whether a player is noclipping.
function openAura.player:IsNoClipping(player)
	if ( player:GetMoveType() == MOVETYPE_NOCLIP
	and !player:InVehicle() ) then
		return true;
	end;
end;

-- A function to get whether a player is an admin.
function openAura.player:IsAdmin(player)
	if ( self:HasFlags(player, "o") ) then
		return true;
	end;
end;

-- A function to get whether a player can hear another player.
function openAura.player:CanHearPlayer(player, target, allowance)
	if ( openAura.config:Get("messages_must_see_player"):Get() ) then
		return self:CanSeePlayer(player, target, (allowance or 0.5), true);
	else
		return true;
	end;
end;

-- A functon to get all property.
function openAura.player:GetAllProperty()
	for k, v in pairs(self.property) do
		if ( !IsValid(v) ) then
			self.property[k] = nil;
		end;
	end;
	
	return self.property;
end;

-- A function to register a player's shared variable.
function openAura.player:RegisterSharedVar(name, class, playerOnly)
	self.sharedVars[name] = {
		playerOnly = playerOnly,
		class = class,
		name = name
	};
end;

-- A function to set a player's action.
function openAura.player:SetAction(player, action, duration, priority, Callback)
	local currentAction = self:GetAction(player);
	
	if (type(action) != "string" or action == "") then
		openAura:DestroyTimer( "action_"..player:UniqueID() );
		
		player:SetSharedVar("startActionTime", 0);
		player:SetSharedVar("actionDuration", 0);
		player:SetSharedVar("action", "");
		
		return;
	elseif (duration == false or duration == 0) then
		if (currentAction == action) then
			return self:SetAction(player, false);
		else
			return false;
		end;
	end;
	
	if (player.action) then
		if ( ( priority and priority > player.action[2] ) or currentAction == ""
		or action == player.action[1] ) then
			player.action = nil;
		end;
	end;

	if (!player.action) then
		local curTime = CurTime();
		
		player:SetSharedVar("startActionTime", curTime);
		player:SetSharedVar("actionDuration", duration);
		player:SetSharedVar("action", action);
		
		if (priority) then
			player.action = {action, priority};
		else
			player.action = nil;
		end;
		
		openAura:CreateTimer("action_"..player:UniqueID(), duration, 1, function()
			if (Callback) then
				Callback();
			end;
		end);
	end;
end;

-- A function to set the player's character menu state.
function openAura.player:SetCharacterMenuState(player, state)
	openAura:StartDataStream(player, "CharacterMenu", state);
end;

-- A function to get a player's action.
function openAura.player:GetAction(player, percentage)
	local startActionTime = player:GetSharedVar("startActionTime");
	local actionDuration = player:GetSharedVar("actionDuration");
	local curTime = CurTime();
	local action = player:GetSharedVar("action");
	
	if (CurTime() < startActionTime + actionDuration) then
		if (percentage) then
			return action, (100 / actionDuration) * (actionDuration - ( (startActionTime + actionDuration) - curTime) );
		else
			return action, actionDuration, startActionTime;
		end;
	else
		return "", 0, 0;
	end;
end;

-- A function to run a OpenAura command on a player.
function openAura.player:RunOpenAuraCommand(player, command, ...)
	return openAura.command:ConsoleCommand( player, "aura", {command, ...} );
end;

-- A function to get a player's wages name.
function openAura.player:GetWagesName(player)
	return openAura.class:Query( player:Team(), "wagesName", openAura.config:Get("wages_name"):Get() );
end;

-- A function to get whether a player can see an NPC.
function openAura.player:CanSeeNPC(player, target, allowance, ignoreEnts)
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
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a player.
function openAura.player:CanSeePlayer(player, target, allowance, ignoreEnts)
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
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see an entity.
function openAura.player:CanSeeEntity(player, target, allowance, ignoreEnts)
	if (player:GetEyeTraceNoCursor().Entity == target) then
		return true;
	else
		local trace = {};
		
		trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
		trace.start = player:GetShootPos();
		trace.endpos = target:LocalToWorld( target:OBBCenter() );
		trace.filter = {player, target};
		
		if (ignoreEnts) then
			if (type(ignoreEnts) == "table") then
				table.Add(trace.filter, ignoreEnts);
			else
				table.Add( trace.filter, ents.GetAll() );
			end;
		end;
		
		trace = util.TraceLine(trace);
		
		if ( trace.Fraction >= (allowance or 0.75) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can see a position.
function openAura.player:CanSeePosition(player, position, allowance, ignoreEnts)
	local trace = {};
	
	trace.mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER;
	trace.start = player:GetShootPos();
	trace.endpos = position;
	trace.filter = {player};
	
	if (ignoreEnts) then
		if (type(ignoreEnts) == "table") then
			table.Add(trace.filter, ignoreEnts);
		else
			table.Add( trace.filter, ents.GetAll() );
		end;
	end;
	
	trace = util.TraceLine(trace);
	
	if ( trace.Fraction >= (allowance or 0.75) ) then
		return true;
	end;
end;

-- A function to update whether a player's weapon is raised.
function openAura.player:UpdateWeaponRaised(player)
	local raised = self:GetWeaponRaised(player);
	local weapon = player:GetActiveWeapon();
	
	player:SetSharedVar("weaponRaised", raised);
	
	if ( IsValid(weapon) ) then
		openAura:HandleWeaponFireDelay( player, raised, weapon, CurTime() );
	end;
end;

-- A function to get whether a player's weapon is raised.
function openAura.player:GetWeaponRaised(player, getCached)
	if (getCached) then
		return player:GetSharedVar("weaponRaised");
	end;
	
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon) and !weapon.NeverRaised) then
		if (weapon.GetRaised) then
			local raised = weapon:GetRaised();
			
			if (raised != nil) then
				return raised;
			end;
		end;
		
		return openAura.plugin:Call("GetPlayerWeaponRaised", player, weapon:GetClass(), weapon);
	end;
	
	return false;
end;

-- A function to toggle whether a player's weapon is raised.
function openAura.player:ToggleWeaponRaised(player)
	self:SetWeaponRaised(player, !player.toggleWeaponRaised);
end;

-- A function to set whether a player's weapon is raised.
function openAura.player:SetWeaponRaised(player, raised)
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		if (type(raised) == "number") then
			player.autoWeaponRaised = weapon:GetClass();
			player:UpdateWeaponRaised();
			
			openAura:CreateTimer("auto_reapon_raised_"..player:UniqueID(), raised, 1, function()
				if ( IsValid(player) ) then
					player.autoWeaponRaised = nil;
					player:UpdateWeaponRaised();
				end;
			end);
		elseif (raised) then
			if (!player.toggleWeaponRaised) then
				if (weapon.OnRaised) then
					weapon:OnRaised();
				end;
			end;
			
			player.toggleWeaponRaised = weapon:GetClass();
			player.autoWeaponRaised = nil;
			player:UpdateWeaponRaised();
		else
			if (player.toggleWeaponRaised) then
				if (weapon.OnLowered) then
					weapon:OnLowered();
				end;
			end;
			
			player.toggleWeaponRaised = nil;
			player.autoWeaponRaised = nil;
			player:UpdateWeaponRaised();
		end;
	end;
end;

-- A function to setup a player's remove property delays.
function openAura.player:SetupRemovePropertyDelays(player)
	local uniqueID = player:UniqueID();
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( self:GetAllProperty() ) do
		local removeDelay = openAura.entity:QueryProperty(v, "removeDelay");
		
		if (IsValid(v) and removeDelay) then
			if ( uniqueID == openAura.entity:QueryProperty(v, "uniqueID") ) then
				if ( key == openAura.entity:QueryProperty(v, "key") ) then
					openAura:CreateTimer("remove_delay_"..v:EntIndex(), removeDelay, 1, function(entity)
						if ( IsValid(entity) ) then
							entity:Remove();
						end;
					end, v);
				end;
			end;
		end;
	end;
end;

-- A function to disable a player's property.
function openAura.player:DisableProperty(player)
	local uniqueID = player:UniqueID();
	
	for k, v in pairs( self:GetAllProperty() ) do
		if ( IsValid(v) and uniqueID == openAura.entity:QueryProperty(v, "uniqueID") ) then
			openAura.entity:SetPropertyVar(v, "owner", NULL);
			
			if ( openAura.entity:QueryProperty(v, "networked") ) then
				v:SetNetworkedEntity("owner", NULL);
			end;
			
			v:SetOwnerKey(nil);
			v:SetNetworkedBool("owned", false);
			
			if (v.SetPlayer) then
				v:SetVar("Founder", NULL);
				v:SetVar("FounderIndex", 0);
				v:SetNetworkedString("FounderName", "");
			end;
		end;
	end;
end;

-- A function to give property to a player.
function openAura.player:GiveProperty(player, entity, networked, removeDelay)
	openAura:DestroyTimer( "remove_delay_"..entity:EntIndex() );
	
	openAura.entity:ClearProperty(entity);
	
	entity.property = {
		key = player:QueryCharacter("key"),
		owner = player,
		owned = true,
		uniqueID = player:UniqueID(),
		networked = networked,
		removeDelay = removeDelay
	};
	
	if ( IsValid(player) ) then
		if (entity.SetPlayer) then
			entity:SetPlayer(player);
		end;
		
		if (networked) then
			entity:SetNetworkedEntity("owner", player);
		end;
	end;
	
	entity:SetOwnerKey( player:QueryCharacter("key") );
	entity:SetNetworkedBool("owned", true);
	
	self.property[ entity:EntIndex() ] = entity;
	
	openAura.plugin:Call("PlayerPropertyGiven", player, entity, networked, removeDelay);
end;

-- A function to give property to an offline player.
function openAura.player:GivePropertyOffline(key, uniqueID, entity, networked, removeDelay)
	openAura.entity:ClearProperty(entity);
	
	if (key and uniqueID) then
		local propertyUniqueID = openAura.entity:QueryProperty(entity, "uniqueID");
		local owner = player.GetByUniqueID(uniqueID);
		
		if (owner) then
			if (owner:QueryCharacter("key") != key) then
				owner = nil;
			else
				self:GiveProperty(owner, entity, networked, removeDelay);
				
				return;
			end;
		end;
		
		if (propertyUniqueID) then
			openAura:DestroyTimer("remove_delay_"..entity:EntIndex().." "..propertyUniqueID);
		end;
		
		entity.property = {
			key = key,
			owner = owner,
			owned = true,
			uniqueID = uniqueID,
			networked = networked,
			removeDelay = removeDelay
		};
		
		if ( IsValid(entity.property.owner) ) then
			if (entity.SetPlayer) then
				entity:SetPlayer(entity.property.owner);
			end;
			
			if (networked) then
				entity:SetNetworkedEntity("owner", entity.property.owner);
			end;
		end;
		
		entity:SetNetworkedBool("owned", true);
		entity:SetOwnerKey(key);
		
		self.property[ entity:EntIndex() ] = entity;
		
		openAura.plugin:Call("PlayerPropertyGivenOffline", key, uniqueID, entity, networked, removeDelay);
	end;
end;

-- A function to take property from an offline player.
function openAura.player:TakePropertyOffline(key, uniqueID, entity)
	if (key and uniqueID) then
		local owner = player.GetByUniqueID(uniqueID);
		
		if (owner and owner:QueryCharacter("key") == key) then
			self:TakeProperty(owner, entity);
			
			return;
		end;
		
		if (openAura.entity:QueryProperty(entity, "uniqueID") == uniqueID) then
			if (openAura.entity:QueryProperty(entity, "key") == key) then
				entity.property = nil;
				
				entity:SetNetworkedEntity("owner", NULL);
				entity:SetNetworkedBool("owned", false);
				entity:SetOwnerKey(nil);
				
				if (entity.SetPlayer) then
					entity:SetVar("Founder", nil);
					entity:SetVar("FounderIndex", nil);
					entity:SetNetworkedString("FounderName", "");
				end;
				
				self.property[ entity:EntIndex() ] = nil;
				
				openAura.plugin:Call("PlayerPropertyTakenOffline", key, uniqueID, entity);
			end;
		end;
	end;
end;

-- A function to take property from a player.
function openAura.player:TakeProperty(player, entity)
	if (openAura.entity:GetOwner(entity) == player) then
		entity.property = nil;
		
		entity:SetNetworkedEntity("owner", NULL);
		entity:SetNetworkedBool("owned", false);
		entity:SetOwnerKey(nil);
		
		if (entity.SetPlayer) then
			entity:SetVar("Founder", nil);
			entity:SetVar("FounderIndex", nil);
			entity:SetNetworkedString("FounderName", "");
		end;
		
		self.property[ entity:EntIndex() ] = nil;
		
		openAura.plugin:Call("PlayerPropertyTaken", player, entity);
	end;
end;

-- A function to set a player to their default skin.
function openAura.player:SetDefaultSkin(player)
	player:SetSkin( self:GetDefaultSkin(player) );
end;

-- A function to get a player's default skin.
function openAura.player:GetDefaultSkin(player)
	return openAura.plugin:Call("GetPlayerDefaultSkin", player);
end;

-- A function to set a player to their default model.
function openAura.player:SetDefaultModel(player)
	player:SetModel( self:GetDefaultModel(player) );
end;

-- A function to get a player's default model.
function openAura.player:GetDefaultModel(player)
	return openAura.plugin:Call("GetPlayerDefaultModel", player);
end;

-- A function to get whether a player is drunk.
function openAura.player:GetDrunk(player)
	if (player.drunk) then return #player.drunk; end;
end;

-- A function to set whether a player is drunk.
function openAura.player:SetDrunk(player, expire)
	local curTime = CurTime();
	
	if (expire == false) then
		player.drunk = nil;
	elseif (!player.drunk) then
		player.drunk = {curTime + expire};
	else
		player.drunk[#player.drunk + 1] = curTime + expire;
	end;
	
	player:SetSharedVar("drunk", self:GetDrunk(player) or 0);
end;

-- A function to strip a player's default ammo.
function openAura.player:StripDefaultAmmo(player, weapon, itemTable)
	if (!itemTable) then
		itemTable = openAura.item:GetWeapon(weapon);
	end;
	
	if (itemTable) then
		if (itemTable.primaryDefaultAmmo) then
			local ammoClass = weapon:GetPrimaryAmmoType();
			
			if (weapon:Clip1() != -1) then
				weapon:SetClip1(0);
			end;
			
			if (type(itemTable.primaryDefaultAmmo) == "number") then
				player:SetAmmo(math.max(player:GetAmmoCount(ammoClass) - itemTable.primaryDefaultAmmo, 0), ammoClass);
			end;
		end;
		
		if (itemTable.secondaryDefaultAmmo) then
			local ammoClass = weapon:GetSecondaryAmmoType();
			
			if (weapon:Clip2() != -1) then
				weapon:SetClip2(0);
			end;
			
			if (type(itemTable.secondaryDefaultAmmo) == "number") then
				player:SetAmmo(math.max(player:GetAmmoCount(ammoClass) - itemTable.secondaryDefaultAmmo, 0), ammoClass);
			end;
		end;
	end;
end;

-- A function to restore a player's secondary ammo.
function openAura.player:RestoreSecondaryAmmo(player)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if ( IsValid(weapon) ) then
		local spawnAmmo = self:GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if (weapon:Clip2() != -1) then
			if ( ammo["s_"..class] ) then
				weapon:SetClip2( ammo["s_"..class] );
			elseif ( self:GetSpawnWeapon(player, class) ) then
				if ( spawnAmmo["s_"..class] ) then
					weapon:SetClip2( spawnAmmo["s_"..class] );
				end;
			end;
		end;
	end;
end;

-- A function to restore a player's primary ammo.
function openAura.player:RestorePrimaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if ( IsValid(weapon) ) then
		local spawnAmmo = self:GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if (weapon:Clip1() != -1) then
			if ( ammo["p_"..class] ) then
				weapon:SetClip1( ammo["p_"..class] );
			elseif ( self:GetSpawnWeapon(player, class) ) then
				if ( spawnAmmo["p_"..class] ) then
					weapon:SetClip1( spawnAmmo["p_"..class] );
				end;
			end;
		end;
	end;
end;

-- A function to save a player's secondary ammo.
function openAura.player:SaveSecondaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if (IsValid(weapon) and weapon:Clip2() >= 0) then
		local spawnAmmo = self:GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if ( self:GetSpawnWeapon(player, class) ) then
			spawnAmmo["s_"..class] = weapon:Clip2();
			
			if (spawnAmmo["s_"..class] == 0) then
				spawnAmmo["s_"..class] = nil;
			end;
		else
			ammo["s_"..class] = weapon:Clip2();
			
			if (ammo["s_"..class] == 0) then
				ammo["s_"..class] = nil;
			end;
		end;
	end;
end;

-- A function to save a player's primary ammo.
function openAura.player:SavePrimaryAmmo(player, weapon)
	if (!weapon) then
		weapon = player:GetActiveWeapon();
	end;
	
	if (IsValid(weapon) and weapon:Clip1() >= 0) then
		local spawnAmmo = self:GetSpawnAmmo(player);
		local class = weapon:GetClass();
		local ammo = player:QueryCharacter("ammo");
		
		if ( self:GetSpawnWeapon(player, class) ) then
			spawnAmmo["p_"..class] = weapon:Clip1();
			
			if (spawnAmmo["p_"..class] == 0) then
				spawnAmmo["p_"..class] = nil;
			end;
		else
			ammo["p_"..class] = weapon:Clip1();
			
			if (ammo["p_"..class] == 0) then
				ammo["p_"..class] = nil;
			end;
		end;
	end;
end;

-- A function to get a player's secondary ammo.
function openAura.player:GetSecondaryAmmo(player, class, bNotSpawn)
	local spawnAmmo = self:GetSpawnAmmo(player);
	local ammo = player:QueryCharacter("ammo");
	
	if (spawnAmmo["s_"..class] and spawnAmmo["s_"..class] > 0 and !bNotSpawn) then
		return spawnAmmo["s_"..class];
	elseif (ammo["s_"..class] and ammo["s_"..class] > 0) then
		return ammo["s_"..class];
	else
		return 0;
	end;
end;

-- A function to get a player's primary ammo.
function openAura.player:GetPrimaryAmmo(player, class, bNotSpawn)
	local spawnAmmo = self:GetSpawnAmmo(player);
	local ammo = player:QueryCharacter("ammo");
	
	if (spawnAmmo["p_"..class] and spawnAmmo["p_"..class] > 0 and !bNotSpawn) then
		return spawnAmmo["p_"..class];
	elseif (ammo["p_"..class] and ammo["p_"..class] > 0) then
		return ammo["p_"..class];
	else
		return 0;
	end;
end;

-- A function to set a player's secondary ammo.
function openAura.player:SetSecondaryAmmo(player, class, amount)
	player:QueryCharacter("ammo")["s_"..class] = amount;
	
	if ( player:HasWeapon(class) ) then
		player:GetWeapon(class):SetClip2(amount);
	end;
end;

-- A function to set a player's primary ammo.
function openAura.player:SetPrimaryAmmo(player, class, amount)
	player:QueryCharacter("ammo")["p_"..class] = amount;
	
	if ( player:HasWeapon(class) ) then
		player:GetWeapon(class):SetClip1(amount);
	end;
end;

-- A function to take a player's secondary ammo.
function openAura.player:TakeSecondaryAmmo(player, class)
	local ammo = player:QueryCharacter("ammo");
	
	if (ammo["s_"..class] and ammo["s_"..class] > 0) then
		local amount = ammo["s_"..class];
			ammo["s_"..class] = nil;
			
		if ( player:HasWeapon(class) ) then
			player:GetWeapon(class):SetClip2(0);
		end;
		
		return amount;
	else
		return 0;
	end;
end;

-- A function to take a player's primary ammo.
function openAura.player:TakePrimaryAmmo(player, class)
	local ammo = player:QueryCharacter("ammo");
	
	if (ammo["p_"..class] and ammo["p_"..class] > 0) then
		local amount = ammo["p_"..class];
			ammo["p_"..class] = nil;
			
		if ( player:HasWeapon(class) ) then
			player:GetWeapon(class):SetClip1(0);
		end;
		
		return amount;
	else
		return 0;
	end;
end;

-- A function to check if a player is whitelisted for a faction.
function openAura.player:IsWhitelisted(player, faction)
	return table.HasValue(player:GetData("whitelisted"), faction);
end;

-- A function to set whether a player is whitelisted for a faction.
function openAura.player:SetWhitelisted(player, faction, isWhitelisted)
	local whitelisted = player:GetData("whitelisted");
	
	if (isWhitelisted) then
		if ( !self:IsWhitelisted(player, faction) ) then
			whitelisted[#whitelisted + 1] = faction;
		end;
	else
		for k, v in pairs(whitelisted) do
			if (v == faction) then
				whitelisted[k] = nil;
			end;
		end;
	end;
	
	openAura:StartDataStream( player, "SetWhitelisted", {faction, isWhitelisted} );
end;

-- A function to create a Condition timer.
function openAura.player:ConditionTimer(player, delay, Condition, Callback)
	delay = CurTime() + delay; local uniqueID = player:UniqueID();
	
	if (player.conditionTimer) then
		player.conditionTimer.Callback(false);
		player.conditionTimer = nil;
	end;
	
	player.conditionTimer = {
		delay = delay,
		Callback = Callback,
		Condition = Condition
	};
	
	openAura:CreateTimer("condition_timer_"..uniqueID, 0, 0, function()
		if ( IsValid(player) ) then
			if ( Condition() ) then
				if (CurTime() >= delay) then
					Callback(true); player.conditionTimer = nil;
					
					openAura:DestroyTimer("condition_timer_"..uniqueID);
				end;
			else
				Callback(false); player.conditionTimer = nil;
				
				openAura:DestroyTimer("condition_timer_"..uniqueID);
			end;
		else
			openAura:DestroyTimer("condition_timer_"..uniqueID);
		end;
	end);
end;

-- A function to create an entity Condition timer.
function openAura.player:EntityConditionTimer(player, target, entity, delay, distance, Condition, Callback)
	delay = CurTime() + delay; entity = entity or target;
	
	local uniqueID = player:UniqueID();
	
	if (player.entityConditionTimer) then
		player.entityConditionTimer.Callback(false);
		player.entityConditionTimer = nil;
	end;
	
	player.entityConditionTimer = {
		delay = delay,
		target = target,
		entity = entity,
		distance = distance,
		Callback = Callback,
		Condition = Condition
	};
	
	openAura:CreateTimer("Entity condition_timer_"..uniqueID, 0, 0, function()
		if ( IsValid(player) ) then
			local trace = player:GetEyeTraceNoCursor();
			
			if ( IsValid(target) and IsValid(entity) and trace.Entity == entity
			and trace.Entity:GetPos():Distance( player:GetShootPos() ) <= distance and Condition() ) then
				if (CurTime() >= delay) then
					Callback(true); player.entityConditionTimer = nil;
					
					openAura:DestroyTimer("Entity condition_timer_"..uniqueID);
				end;
			else
				Callback(false); player.entityConditionTimer = nil;
				
				openAura:DestroyTimer("Entity condition_timer_"..uniqueID);
			end;
		else
			openAura:DestroyTimer("Entity condition_timer_"..uniqueID);
		end;
	end);
end;

-- A function to get a player's spawn ammo.
function openAura.player:GetSpawnAmmo(player, ammo)
	if (ammo) then
		return player.spawnAmmo[ammo];
	else
		return player.spawnAmmo;
	end;
end;

-- A function to get a player's spawn weapon.
function openAura.player:GetSpawnWeapon(player, weapon)
	if (weapon) then
		return player.spawnWeapons[weapon];
	else
		return player.spawnWeapons;
	end;
end;

-- A function to take spawn ammo from a player.
function openAura.player:TakeSpawnAmmo(player, ammo, amount)
	if ( player.spawnAmmo[ammo] ) then
		if (player.spawnAmmo[ammo] < amount) then
			amount = player.spawnAmmo[ammo];
			
			player.spawnAmmo[ammo] = nil;
		else
			player.spawnAmmo[ammo] = player.spawnAmmo[ammo] - amount;
		end;
		
		player:RemoveAmmo(amount, ammo);
	end;
end;

-- A function to give the player spawn ammo.
function openAura.player:GiveSpawnAmmo(player, ammo, amount)
	if ( player.spawnAmmo[ammo] ) then
		player.spawnAmmo[ammo] = player.spawnAmmo[ammo] + amount;
	else
		player.spawnAmmo[ammo] = amount;
	end;
	
	player:GiveAmmo(amount, ammo);
end;

-- A function to take a player's spawn weapon.
function openAura.player:TakeSpawnWeapon(player, class)
	player.spawnWeapons[class] = nil;
	
	player:StripWeapon(class);
end;

-- A function to give a player a spawn weapon.
function openAura.player:GiveSpawnWeapon(player, class, uniqueID)
	player.spawnWeapons[class] = true;
	
	player:Give(class, uniqueID);
end;

-- A function to give a player an item weapon.
function openAura.player:GiveItemWeapon(player, item)
	local itemTable = openAura.item:Get(item);
	
	if ( openAura.item:IsWeapon(itemTable) ) then
		player:Give(itemTable.weaponClass, itemTable.uniqueID);
		
		return true;
	end;
end;

-- A function to give a player a spawn item weapon.
function openAura.player:GiveSpawnItemWeapon(player, item)
	local itemTable = openAura.item:Get(item);
	
	if ( openAura.item:IsWeapon(itemTable) ) then
		player.spawnWeapons[itemTable.weaponClass] = true;
		
		player:Give(itemTable.weaponClass, itemTable.uniqueID);
		
		return true;
	end;
end;

-- A function to give flags to a player.
function openAura.player:GiveFlags(player, flags)
	for i = 1, string.len(flags) do
		local flag = string.sub(flags, i, i);
		
		if ( !string.find(player:QueryCharacter("flags"), flag) ) then
			player:SetCharacterData("flags", player:QueryCharacter("flags")..flag, true);
			
			openAura.plugin:Call("PlayerFlagsGiven", player, flag);
		end;
	end;
end;

-- A function to play a sound to a player.
function openAura.player:PlaySound(player, sound)
	umsg.Start("aura_PlaySound", player);
		umsg.String(sound);
	umsg.End();
end;

-- A function to get a player's maximum characters.
function openAura.player:GetMaximumCharacters(player)
	local maximum = openAura.config:Get("additional_characters"):Get();
	
	for k, v in pairs(openAura.faction.stored) do
		if ( !v.whitelist or self:IsWhitelisted(player, v.name) ) then
			maximum = maximum + 1;
		end;
	end;
	
	return maximum;
end;

-- A function to query a player's character.
function openAura.player:Query(player, key, default)
	local character = player:GetCharacter();
	
	if (character) then
		return character[key] or default;
	else
		return default;
	end;
end;

-- A function to set a player to a safe position.
function openAura.player:SetSafePosition(player, position, filter)
	position = self:GetSafePosition(player, position, filter);
	
	if (position) then
		player:SetMoveType(MOVETYPE_NOCLIP);
		player:SetPos(position);
		
		if ( player:IsInWorld() ) then
			player:SetMoveType(MOVETYPE_WALK);
		else
			player:Spawn();
		end;
	end;
end;

-- A function to get the safest position near a position.
function openAura.player:GetSafePosition(player, position, filter)
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
	
	if ( !table.HasValue(filter, player) ) then
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
		local testPosition = position + ( angleVector * v[2] );
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		};
		
		local traceLine = util.TraceEntity(trace, player);
		
		if (traceLine.Hit) then
			trace = {
				filter = filter,
				endpos = traceLine.HitPos - ( angleVector * v[2] ),
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
		local testPosition = position + ( angleVector * v[2] );
		
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

-- A function to return a player's property.
function openAura.player:ReturnProperty(player)
	local uniqueID = player:UniqueID();
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( self:GetAllProperty() ) do
		if ( IsValid(v) ) then
			if ( uniqueID == openAura.entity:QueryProperty(v, "uniqueID") ) then
				if ( key == openAura.entity:QueryProperty(v, "key") ) then
					self:GiveProperty( player, v, openAura.entity:QueryProperty(v, "networked") );
				end;
			end;
		end;
	end;
	
	openAura.plugin:Call("PlayerReturnProperty", player);
end;

-- A function to take flags from a player.
function openAura.player:TakeFlags(player, flags)
	for i = 1, string.len(flags) do
		local flag = string.sub(flags, i, i);
		
		if ( string.find(player:QueryCharacter("flags"), flag) ) then
			player:SetCharacterData("flags", string.gsub(player:QueryCharacter("flags"), flag, ""), true);
			
			openAura.plugin:Call("PlayerFlagsTaken", player, flag);
		end;
	end;
end;

-- A function to set whether a player's menu is open.
function openAura.player:SetMenuOpen(player, isOpen)
	umsg.Start("aura_MenuOpen", player);
		umsg.Bool(isOpen);
	umsg.End();
end;

-- A function to set whether a player has intialized.
function openAura.player:SetInitialized(player, initialized)
	player:SetSharedVar("initialized", initialized);
end;

-- A function to check if a player has any flags.
function openAura.player:HasAnyFlags(player, flags, default)
	if ( player:GetCharacter() ) then
		local playerFlags = player:QueryCharacter("flags");
		
		if ( openAura.class:HasAnyFlags(player:Team(), flags) and !default ) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success = true;
				
				if (!default) then
					local hasFlag = openAura.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
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
						if ( player:IsSuperAdmin() ) then
							return true;
						end;
					elseif (flag == "a") then
						if ( player:IsAdmin() ) then
							return true;
						end;
					elseif (flag == "o") then
						if ( player:IsSuperAdmin() or player:IsAdmin() ) then
							return true;
						elseif ( player:IsUserGroup("operator") ) then
							return true;
						end;
					elseif ( string.find(playerFlags, flag) ) then
						return true;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to check if a player has flags.
function openAura.player:HasFlags(player, flags, default)
	if ( player:GetCharacter() ) then
		local playerFlags = player:QueryCharacter("flags");
		
		if ( openAura.class:HasFlags(player:Team(), flags) and !default ) then
			return true;
		else
			for i = 1, string.len(flags) do
				local flag = string.sub(flags, i, i);
				local success;
				
				if (!default) then
					local hasFlag = openAura.plugin:Call("PlayerDoesHaveFlag", player, flag);
					
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
						if ( !player:IsSuperAdmin() ) then
							return;
						end;
					elseif (flag == "a") then
						if ( !player:IsAdmin() ) then
							return;
						end;
					elseif (flag == "o") then
						if ( !player:IsSuperAdmin() and !player:IsAdmin() ) then
							if ( !player:IsUserGroup("operator") ) then
								return;
							end;
						end;
					elseif ( !string.find(playerFlags, flag) ) then
						return;
					end;
				end;
			end;
		end;
		
		return true;
	end;
end;

-- A function to use a player's death code.
function openAura.player:UseDeathCode(player, commandTable, arguments)
	openAura.plugin:Call("PlayerDeathCodeUsed", player, commandTable, arguments);
	
	self:TakeDeathCode(player);
end;

-- A function to get whether a player has a death code.
function openAura.player:GetDeathCode(player, authenticated)
	if ( player.deathCode and (!authenticated or player.deathCodeAuthenticated) ) then
		return player.deathCode;
	end;
end;

-- A function to take a player's death code.
function openAura.player:TakeDeathCode(player)
	player.deathCodeAuthenticated = nil;
	player.deathCode = nil;
end;

-- A function to give a player their death code.
function openAura.player:GiveDeathCode(player)
	player.deathCode = math.random(0, 99999);
	player.deathCodeAuthenticated = nil;
	
	umsg.Start("aura_ChatBoxDeathCode", player);
		umsg.Long(player.deathCode);
	umsg.End();
end;

-- A function to take a door from a player.
function openAura.player:TakeDoor(player, door, force, thisDoorOnly, childrenOnly)
	local doorCost = openAura.config:Get("door_cost"):Get();
	
	if (!thisDoorOnly) then
		local doorParent = openAura.entity:GetDoorParent(door);
		
		if (doorParent and !childrenOnly) then
			return self:TakeDoor(player, doorParent, force);
		else
			for k, v in pairs( openAura.entity:GetDoorChildren(door) ) do
				if ( IsValid(v) ) then
					self:TakeDoor(player, v, true, true);
				end;
			end;
		end;
	end;
	
	if ( openAura.plugin:Call("PlayerCanUnlockEntity", player, door) ) then
		door:Fire("Unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
	
	openAura.entity:SetDoorText(door, false);
	self:TakeProperty(player, door)
	
	if (door:GetClass() == "prop_dynamic") then
		if ( !door:IsMapEntity() ) then
			door:Remove();
		end;
	end;
	
	if (!force and doorCost > 0) then
		self:GiveCash(player, doorCost / 2, "selling a door");
	end;
end;

-- A function to make a player say text as a radio broadcast.
function openAura.player:SayRadio(player, text, check, noEavesdrop)
	local eavesdroppers = {};
	local listeners = {};
	local canRadio = true;
	local info = {listeners = {}, noEavesdrop = noEavesdrop, text = text};
	
	openAura.plugin:Call("PlayerAdjustRadioInfo", player, info);
	
	for k, v in pairs(info.listeners) do
		if (type(k) == "Player") then
			listeners[k] = k;
		elseif (type(v) == "Player") then
			listeners[v] = v;
		end;
	end;
	
	if (!info.noEavesdrop) then
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() and !listeners[v] ) then
				if ( v:GetShootPos():Distance( player:GetShootPos() ) <= openAura.config:Get("talk_radius"):Get() ) then
					eavesdroppers[v] = v;
				end;
			end;
		end;
	end;
	
	if (check) then
		canRadio = openAura.plugin:Call("PlayerCanRadio", player, info.text, listeners, eavesdroppers);
	end;
	
	if (canRadio) then
		info = openAura.chatBox:Add(listeners, player, "radio", info.text);
		
		if ( info and IsValid(info.speaker) ) then
			openAura.chatBox:Add(eavesdroppers, info.speaker, "radio_eavesdrop", info.text);
			
			openAura.plugin:Call("PlayerRadioUsed", player, info.text, listeners, eavesdroppers);
		end;
	end;
end;

-- A function to get a player's faction table.
function openAura.player:GetFactionTable(player)
	return openAura.faction.stored[ player:QueryCharacter("faction") ];
end;

-- A function to get a player's faction.
function openAura.player:GetFaction(player)
	return player:QueryCharacter("faction");
end;

-- A function to give a door to a player.
function openAura.player:GiveDoor(player, door, name, unsellable, override)
	if ( openAura.entity:IsDoor(door) ) then
		local doorParent = openAura.entity:GetDoorParent(door);
		
		if (doorParent and !override) then
			self:GiveDoor(player, doorParent, name, unsellable);
		else
			for k, v in pairs( openAura.entity:GetDoorChildren(door) ) do
				if ( IsValid(v) ) then
					self:GiveDoor(player, v, name, unsellable, true);
				end;
			end;
			
			door.unsellable = unsellable;
			door.accessList = {};
			
			openAura.entity:SetDoorText(door, name or "A purchased door.");
			self:GiveProperty(player, door, true);
			
			if ( openAura.plugin:Call("PlayerCanUnlockEntity", player, door) ) then
				door:EmitSound("doors/door_latch3.wav");
				door:Fire("Unlock", "", 0);
			end;
		end;
	end;
end;

-- A function to get a player's real trace.
function openAura.player:GetRealTrace(player, useFilterTrace)
	local eyePos = player:EyePos();
	local trace = player:GetEyeTraceNoCursor();
	
	local newTrace = util.TraceLine( {
		endpos = eyePos + (player:GetAimVector() * 4096),
		filter = player,
		start = eyePos,
		mask = CONTENTS_SOLID + CONTENTS_MOVEABLE + CONTENTS_OPAQUE + CONTENTS_DEBRIS + CONTENTS_HITBOX + CONTENTS_MONSTER
	} );
	
	if ( (IsValid(newTrace.Entity) and ( !IsValid(trace.Entity)
	or trace.Entity:IsVehicle() ) and !newTrace.HitWorld) or useFilterTrace ) then
		trace = newTrace;
	end;
	
	return trace;
end;

-- A function to check if a player recognises another player.
function openAura.player:DoesRecognise(player, target, status, isAccurate)
	if (!status) then
		return self:DoesRecognise(player, target, RECOGNISE_PARTIAL);
	elseif ( openAura.config:Get("recognise_system"):Get() ) then
		local recognisedNames = player:QueryCharacter("recognisedNames");
		local realValue = false;
		local key = target:QueryCharacter("key");
		
		if ( recognisedNames[key] ) then
			if (isAccurate) then
				realValue = (recognisedNames[key] == status);
			else
				realValue = (recognisedNames[key] >= status);
			end;
		end;
		
		return openAura.plugin:Call("PlayerDoesRecognisePlayer", player, target, status, isAccurate, realValue);
	else
		return true;
	end;
end;

-- A function to send a player a creation fault.
function openAura.player:CreationError(player, fault)
	if (!fault) then
		fault = "There has been an unknown error, please contact the administrator!";
	end;
	
	umsg.Start("aura_CharacterFinish", player)
		umsg.Bool(false);
		umsg.String(fault);
	umsg.End();
end;

-- A function to force a player to delete a character.
function openAura.player:ForceDeleteCharacter(player, characterID)
	local charactersTable = openAura.config:Get("mysql_characters_table"):Get();
	local schemaFolder = openAura:GetSchemaFolder();
	local character = player.characters[characterID];
	
	if (character) then
		tmysql.query("DELETE FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..player:SteamID().."\" AND _CharacterID = "..characterID);
		
		if ( !openAura.plugin:Call("PlayerDeleteCharacter", player, character) ) then
			openAura:PrintLog(5, player:SteamName().." has deleted the character '"..character.name.."'.");
		end;
		
		player.characters[characterID] = nil;
		
		umsg.Start("aura_CharacterRemove", player)
			umsg.Short(characterID);
		umsg.End();
	end;
end;

-- A function to delete a player's character.
function openAura.player:DeleteCharacter(player, characterID)
	local character = player.characters[characterID];
	
	if (character) then
		if (player:GetCharacter() != character) then
			local fault = openAura.plugin:Call("PlayerCanDeleteCharacter", player, character);
			
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
function openAura.player:UseCharacter(player, characterID)
	local isCharacterMenuReset = player:IsCharacterMenuReset();
	local currentCharacter = player:GetCharacter();
	local character = player.characters[characterID];
	
	if (!character) then
		return false, "This character does not exist!";
	end;
	
	if (currentCharacter != character or isCharacterMenuReset) then
		local factionTable = openAura.faction:Get(character.faction);
		local fault = openAura.plugin:Call("PlayerCanUseCharacter", player, character);
		
		if (fault == nil or fault == true) then
			local players = #openAura.faction:GetPlayers(character.faction);
			local limit = openAura.faction:GetLimit(factionTable.name);
			
			if (isCharacterMenuReset and character.faction == currentCharacter.faction) then
				players = players - 1;
			end;
				
			if ( openAura.plugin:Call("PlayerCanBypassFactionLimit", player, character) ) then
				limit = nil;
			end;
			
			if (limit and players == limit) then
				return false, "The "..character.faction.." faction is full ("..limit.."/"..limit..")!";
			else
				if (currentCharacter) then
					local fault = openAura.plugin:Call("PlayerCanSwitchCharacter", player, character);
					
					if (fault != nil and fault != true) then
						return false, fault or "You cannot switch to this character!";
					end;
				end;
				
				openAura:PrintLog(5, player:SteamName().." has loaded the character '"..character.name.."'.");
				
				if (isCharacterMenuReset) then
					player.isCharacterMenuReset = false;
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
function openAura.player:GetCharacter(player)
	return player.character;
end;

-- A function to get a player's storage entity.
function openAura.player:GetStorageEntity(player)
	if ( player:GetStorageTable() ) then
		local entity = self:QueryStorage(player, "entity");
		
		if ( IsValid(entity) ) then return entity; end;
	end;
end;

-- A function to get a player's storage table.
function openAura.player:GetStorageTable(player)
	return player.storage;
end;

-- A function to query a player's storage.
function openAura.player:QueryStorage(player, key, default)
	local storage = player:GetStorageTable();
	
	if (storage) then
		return storage[key] or default;
	else
		return default;
	end;
end;

-- A function to close storage for a player.
function openAura.player:CloseStorage(player, server)
	local storage = player:GetStorageTable();
	local OnClose = self:QueryStorage(player, "OnClose");
	local entity = self:QueryStorage(player, "entity");
	
	if (storage and OnClose) then
		OnClose(player, storage, entity);
	end;
	
	if (!server) then
		umsg.Start("aura_StorageClose", player);
		umsg.End();
	end;
	
	player.storage = nil;
end;

-- A function to get the weight of a player's storage.
function openAura.player:GetStorageWeight(player)
	if ( player:GetStorageTable() ) then
		local inventory = self:QueryStorage(player, "inventory");
		local cash = self:QueryStorage(player, "cash");
		local weight = ( cash * openAura.config:Get("cash_weight"):Get() );
		
		if ( self:QueryStorage(player, "noCashWeight") ) then
			weight = 0;
		end;
		
		for k, v in pairs(inventory) do
			local itemTable = openAura.item:Get(k);
			
			if (itemTable) then
				weight = weight + (math.max(itemTable.storageWeight or itemTable.weight, 0) * v );
			end;
		end;
		
		return weight;
	else
		return 0;
	end;
end;

-- A function to open storage for a player.
function openAura.player:OpenStorage(player, data)
	local storage = player:GetStorageTable();
	local OnClose = self:QueryStorage(player, "OnClose");
	
	if (storage and OnClose) then
		OnClose(player, storage, storage.entity);
	end;
	
	if ( !openAura.config:Get("cash_enabled"):Get() ) then
		data.cash = nil;
	end;
	
	if (data.noCashWeight == nil) then
		data.noCashWeight = false;
	end;
	
	data.inventory = data.inventory or {};
	data.entity = data.entity or player;
	data.weight = data.weight or openAura.config:Get("default_inv_weight"):Get();
	data.cash = data.cash or 0;
	data.name = data.name or "Storage";
	
	player.storage = data;
	
	umsg.Start("aura_StorageStart", player);
		umsg.Bool(data.noCashWeight);
		umsg.Entity(data.entity);
		umsg.String(data.name);
	umsg.End();
	
	self:UpdateStorageCash(player, data.cash);
	self:UpdateStorageWeight(player, data.weight);
	
	for k, v in pairs(data.inventory) do
		self:UpdateStorageItem(player, k);
	end;
end;

-- A function to update a player's storage cash.
function openAura.player:UpdateStorageCash(player, cash)
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		local storageTable = player:GetStorageTable();
		
		if (storageTable) then
			local inventory = self:QueryStorage(player, "inventory");
			
			for k, v in ipairs( _player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (self:QueryStorage(v, "inventory") == inventory) then
							v.storage.cash = cash;
							
							umsg.Start("aura_StorageCash", v);
								umsg.Long(cash);
							umsg.End();
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to update a player's storage weight.
function openAura.player:UpdateStorageWeight(player, weight)
	
	if ( player:GetStorageTable() ) then
		local inventory = self:QueryStorage(player, "inventory");
		
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (self:QueryStorage(v, "inventory") == inventory) then
						v.storage.weight = weight;
						
						umsg.Start("aura_StorageWeight", v);
							umsg.Float(weight);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get whether a player can give to storage.
function openAura.player:CanGiveToStorage(player, item)
	local itemTable = openAura.item:Get(item);
	local entity = self:QueryStorage(player, "entity");
	
	if (itemTable) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerGive = (!entity:IsPlayer() or itemTable.allowPlayerGive != false);
		local allowEntityGive = (entity:IsPlayer() or itemTable.allowEntityGive != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowGive = (itemTable.allowGive != false);
		local shipment = (entity and entity:GetClass() == "aura_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerGive and allowStorage and allowGive) ) then
			return true;
		end;
	end;
end;

-- A function to get whether a player can take from storage.
function openAura.player:CanTakeFromStorage(player, item)
	local itemTable = openAura.item:Get(item);
	local entity = self:QueryStorage(player, "entity");
	
	if (itemTable) then
		local allowPlayerStorage = (!entity:IsPlayer() or itemTable.allowPlayerStorage != false);
		local allowEntityStorage = (entity:IsPlayer() or itemTable.allowEntityStorage != false);
		local allowPlayerTake = (!entity:IsPlayer() or itemTable.allowPlayerTake != false);
		local allowEntityTake = (entity:IsPlayer() or itemTable.allowEntityTake != false);
		local allowStorage = (itemTable.allowStorage != false);
		local allowTake = (itemTable.allowTake != false);
		local shipment = (entity and entity:GetClass() == "aura_shipment");
		
		if ( shipment or (allowPlayerStorage and allowPlayerTake and allowStorage and allowTake) ) then
			return true;
		end;
	end;
end;

-- A function to update each player's storage for a player.
function openAura.player:UpdateStorageForPlayer(player, item)
	local inventory = self:GetInventory(player);
	local cash = self:GetCash(player);
	
	if (item) then
		local itemTable = openAura.item:Get(item);
		
		if (itemTable) then
			for k, v in ipairs( _player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (self:QueryStorage(v, "inventory") == inventory) then
							umsg.Start("aura_StorageItem", v);
								umsg.Long(itemTable.index);
								umsg.Long(inventory[itemTable.uniqueID] or 0);
							umsg.End();
						end;
					end;
				end;
			end;
		end;
	elseif ( openAura.config:Get("cash_enabled"):Get() ) then
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( v:GetStorageTable() ) then
					if (self:QueryStorage(v, "inventory") == inventory) then
						v.storage.cash = cash;
						
						umsg.Start("aura_StorageCash", v);
							umsg.Long(cash);
						umsg.End();
					end;
				end;
			end;
		end;
	end;
end;

-- A function to update a storage item for a player.
function openAura.player:UpdateStorageItem(player, item, amount)
	
	if ( player:GetStorageTable() ) then
		local inventory = self:QueryStorage(player, "inventory");
		local itemTable = openAura.item:Get(item);
		
		if (itemTable) then
			item = itemTable.uniqueID;
			
			if (amount) then
				if ( amount < 0 and !self:CanTakeFromStorage(player, item) ) then
					return;
				elseif ( amount > 0 and !self:CanGiveToStorage(player, item) ) then
					return;
				end;
			end;
			
			if (amount) then
				inventory[item] = inventory[item] or 0;
				inventory[item] = inventory[item] + amount;
			end;
			
			if (inventory[item] and inventory[item] <= 0) then
				inventory[item] = nil;
			end;
			
			for k, v in ipairs( _player.GetAll() ) do
				if ( v:HasInitialized() ) then
					if ( v:GetStorageTable() ) then
						if (self:QueryStorage(v, "inventory") == inventory) then
							if (amount or player == v) then
								umsg.Start("aura_StorageItem", v);
									umsg.Long(itemTable.index);
									umsg.Long(inventory[item] or 0);
								umsg.End();
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- A function to get a player's gender.
function openAura.player:GetGender(player)
	return player:QueryCharacter("gender");
end;

-- A function to get a player's unrecognised name.
function openAura.player:GetUnrecognisedName(player)
	local unrecognisedPhysDesc = self:GetPhysDesc(player);
	local unrecognisedName = openAura.config:Get("unrecognised_name"):Get();
	local usedPhysDesc;
	
	if (unrecognisedPhysDesc != "") then
		unrecognisedName = unrecognisedPhysDesc;
		usedPhysDesc = true;
	end;
	
	return unrecognisedName, usedPhysDesc;
end;

-- A function to format text based on a relationship.
function openAura.player:FormatRecognisedText(player, text, ...)
	for i = 1, #arg do
		if ( string.find(text, "%%s") and IsValid( arg[i] ) ) then
			local unrecognisedName = "["..self:GetUnrecognisedName( arg[i] ).."]";
			
			if ( self:DoesRecognise( player, arg[i] ) ) then
				unrecognisedName = arg[i]:Name();
			end;
			
			text = string.gsub(text, "%%s", unrecognisedName, 1);
		end;
	end;
	
	return text;
end;

-- A function to restore a recognised name.
function openAura.player:RestoreRecognisedName(player, target)
	local recognisedNames = player:QueryCharacter("recognisedNames");
	local key = target:QueryCharacter("key");
	
	if ( recognisedNames[key] ) then
		if ( openAura.plugin:Call("PlayerCanRestoreRecognisedName", player, target) ) then
			self:SetRecognises(player, target, recognisedNames[key], true);
		else
			recognisedNames[key] = nil;
		end;
	end;
end;

-- A function to restore a player's recognised names.
function openAura.player:RestoreRecognisedNames(player)
	umsg.Start("aura_ClearRecognisedNames", player);
	umsg.End();
	
	if ( openAura.config:Get("save_recognised_names"):Get() ) then
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				self:RestoreRecognisedName(player, v);
				self:RestoreRecognisedName(v, player);
			end;
		end;
	end;
end;

-- A function to set whether a player recognises a player.
function openAura.player:SetRecognises(player, target, status, force)
	local recognisedNames = player:QueryCharacter("recognisedNames");
	local name = target:Name();
	local key = target:QueryCharacter("key");
	
	if (status == RECOGNISE_SAVE) then
		if ( openAura.config:Get("save_recognised_names"):Get() ) then
			if ( !openAura.plugin:Call("PlayerCanSaveRecognisedName", player, target) ) then
				status = RECOGNISE_TOTAL;
			end;
		else
			status = RECOGNISE_TOTAL;
		end;
	end;
	
	if ( !status or force or !self:DoesRecognise(player, target, status) ) then
		recognisedNames[key] = status or nil;
		
		status = status or 0;
		
		umsg.Start("aura_RecognisedName", player);
			umsg.Long(key);
			umsg.Short(status);
		umsg.End();
	end;
end;

-- A function to get a player's physical description.
function openAura.player:GetPhysDesc(player)
	local physDesc = player:GetSharedVar("physDesc");
	local team = player:Team();
	
	if (physDesc == "") then
		physDesc = openAura.class:Query(team, "defaultPhysDesc", "");
	end;
	
	if (physDesc == "") then
		physDesc = openAura.config:Get("default_physdesc"):Get();
	end;
	
	if (!physDesc or physDesc == "") then
		physDesc = "This character has no physical description set.";
	else
		physDesc = openAura:ModifyPhysDesc(physDesc);
	end;
	
	local override = openAura.plugin:Call("GetPlayerPhysDescOverride", player, physDesc);
	
	if (override) then
		physDesc = override;
	end;
	
	return physDesc;
end;

-- A function to clear a player's recognised names list.
function openAura.player:ClearRecognisedNames(player, status, isAccurate)
	if (!status) then
		local character = player:GetCharacter();
		
		if (character) then
			character.recognisedNames = {};
			
			umsg.Start("aura_ClearRecognisedNames", player);
			umsg.End();
		end;
	else
		for k, v in ipairs( _player.GetAll() ) do
			if ( v:HasInitialized() ) then
				if ( self:DoesRecognise(player, v, status, isAccurate) ) then
					self:SetRecognises(player, v, false);
				end;
			end;
		end;
	end;
	
	openAura.plugin:Call("PlayerRecognisedNamesCleared", player, status, isAccurate);
end;

-- A function to clear a player's name from being recognised.
function openAura.player:ClearName(player, status, isAccurate)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( !status or self:DoesRecognise(v, player, status, isAccurate) ) then
				self:SetRecognises(v, player, false);
			end;
		end;
	end;
	
	openAura.plugin:Call("PlayerNameCleared", player, status, isAccurate);
end;

-- A function to holsters all of a player's weapons.
function openAura.player:HolsterAll(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = openAura.item:GetWeapon(v);
		
		if (itemTable) then
			if ( openAura.plugin:Call("PlayerCanHolsterWeapon", player, itemTable, true, true) ) then
				player:StripWeapon(class);
				
				player:UpdateInventory(itemTable.uniqueID, 1, true);
				
				openAura.plugin:Call("PlayerHolsterWeapon", player, itemTable, true);
			end;
		end;
	end;
	
	player:SelectWeapon("aura_hands");
end;

-- A function to set a shared variable for a player.
function openAura.player:SetSharedVar(player, key, value)
	if ( IsValid(player) ) then
		local sharedVarData = self.sharedVars[key];
		local playerData = player.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				local class = openAura:ConvertUserMessageClass(sharedVarData.class);
				local realValue = value;
				
				if (value == nil) then
					realValue = openAura:GetDefaultNetworkedValue(sharedVarData.class);
				end;
				
				if (playerData != realValue) then
					player.sharedVars[key] = realValue;
					
					umsg.Start("aura_SharedVar", player);
						umsg.String(key);
						umsg[class](realValue);
					umsg.End();
				end;
			else
				local class = openAura:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
					if (value == nil) then
						value = openAura:GetDefaultClassValue(class);
					end;
					
					player["SetNetworked"..class](player, key, value);
				else
					player:SetNetworkedVar(key, value);
				end;
			end;
		else
			player:SetNetworkedVar(key, value);
		end;
	end;
end;

-- A function to get a player's shared variable.
function openAura.player:GetSharedVar(player, key)
	if ( IsValid(player) ) then
		local sharedVarData = self.sharedVars[key];
		local playerData = player.sharedVars[key];
		
		if (sharedVarData) then
			if (sharedVarData.playerOnly) then
				if (!playerData) then
					return openAura:GetDefaultNetworkedValue(sharedVarData.class);
				else
					return playerData;
				end;
			else
				local class = openAura:ConvertNetworkedClass(sharedVarData.class);
				
				if (class) then
					return player["GetNetworked"..class](player, key);
				else
					return player:GetNetworkedVar(key);
				end;
			end;
		else
			return player:GetNetworkedVar(key);
		end;
	end;
end;

-- A function to set whether a player's character is banned.
function openAura.player:SetBanned(player, banned)
	player:SetCharacterData("banned", banned);
	player:SaveCharacter();
	player:SetSharedVar("banned", banned);
end;

-- A function to set a player's name.
function openAura.player:SetName(player, name, saveless)
	local previousName = player:QueryCharacter("name");
	local newName = name;
	
	player:SetCharacterData("name", newName, true);
	player:SetSharedVar("name", newName);
	
	if (!player.firstSpawn) then
		openAura.plugin:Call("PlayerNameChanged", player, previousName, newName);
	end;
	
	if (!saveless) then
		player:SaveCharacter();
	end;
end;

-- A function to get a player's generator count.
function openAura.player:GetGeneratorCount(player)
	local generators = openAura.generator:GetAll();
	local count = 0;
	
	for k, v in pairs(generators) do
		count = count + self:GetPropertyCount(player, k);
	end;
	
	return count;
end;

-- A function to get a player's property entities.
function openAura.player:GetPropertyEntities(player, class)
	local uniqueID = player:UniqueID();
	local entities = {};
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( self:GetAllProperty() ) do
		if ( uniqueID == openAura.entity:QueryProperty(v, "uniqueID") ) then
			if ( key == openAura.entity:QueryProperty(v, "key") ) then
				if (!class or v:GetClass() == class) then
					entities[#entities + 1] = v;
				end;
			end;
		end;
	end;
	
	return entities;
end;

-- A function to get a player's property count.
function openAura.player:GetPropertyCount(player, class)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( self:GetAllProperty() ) do
		if ( uniqueID == openAura.entity:QueryProperty(v, "uniqueID") ) then
			if ( key == openAura.entity:QueryProperty(v, "key") ) then
				if (!class or v:GetClass() == class) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

-- A function to get a player's door count.
function openAura.player:GetDoorCount(player)
	local uniqueID = player:UniqueID();
	local count = 0;
	local key = player:QueryCharacter("key");
	
	for k, v in pairs( self:GetAllProperty() ) do
		if ( openAura.entity:IsDoor(v) and !openAura.entity:GetDoorParent(v) ) then
			if ( uniqueID == openAura.entity:QueryProperty(v, "uniqueID") ) then
				if ( player:QueryCharacter("key") == openAura.entity:QueryProperty(v, "key") ) then
					count = count + 1;
				end;
			end;
		end;
	end;
	
	return count;
end;

-- A function to take a player's door access.
function openAura.player:TakeDoorAccess(player, door)
	if (door.accessList) then
		door.accessList[ player:QueryCharacter("key") ] = false;
	end;
end;

-- A function to give a player door access.
function openAura.player:GiveDoorAccess(player, door, access)
	local key = player:QueryCharacter("key");
	
	if (!door.accessList) then
		door.accessList = {
			[key] = access
		};
	else
		door.accessList[key] = access;
	end;
end;

-- A function to check if a player has door access.
function openAura.player:HasDoorAccess(player, door, access, isAccurate)
	if (!access) then
		return self:HasDoorAccess(player, door, DOOR_ACCESS_BASIC, isAccurate);
	else
		local doorParent = openAura.entity:GetDoorParent(door);
		local key = player:QueryCharacter("key");
		
		if ( doorParent and openAura.entity:DoorHasSharedAccess(doorParent)
		and (!door.accessList or door.accessList[key] == nil) ) then
			return openAura.plugin:Call("PlayerDoesHaveDoorAccess", player, doorParent, access, isAccurate);
		else
			return openAura.plugin:Call("PlayerDoesHaveDoorAccess", player, door, access, isAccurate);
		end;
	end;
end;

-- A function to get a player's inventory.
function openAura.player:GetInventory(player)
	return player:QueryCharacter("inventory");
end;

-- A function to get a player's cash.
function openAura.player:GetCash(player)
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		return player:QueryCharacter("cash");
	else
		return 0;
	end;
end;

-- A function to check if a player can afford an amount.
function openAura.player:CanAfford(player, amount)
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		return self:GetCash(player) >= amount;
	else
		return true;
	end;
end;

-- A function to give a player an amount of cash.
function openAura.player:GiveCash(player, amount, reason, noMessage)
	if ( openAura.config:Get("cash_enabled"):Get() ) then
		local positiveHintColor = "positive_hint";
		local negativeHintColor = "negative_hint";
		local roundedAmount = math.Round(amount);
		local cash = math.Round( math.max(self:GetCash(player) + roundedAmount, 0) );
		
		player:SetCharacterData("cash", cash, true);
		player:SetSharedVar("cash", cash);
		
		if (roundedAmount < 0) then
			roundedAmount = math.abs(roundedAmount);
			
			if (!noMessage) then
				if (reason) then
					openAura.hint:Send(player, "Your character has lost "..FORMAT_CASH(roundedAmount).." ("..reason..").", 4, negativeHintColor);
				else
					openAura.hint:Send(player, "Your character has lost "..FORMAT_CASH(roundedAmount)..".", 4, negativeHintColor);
				end;
			end;
		elseif (roundedAmount > 0) then
			if (!noMessage) then
				if (reason) then
					openAura.hint:Send(player, "Your character has gained "..FORMAT_CASH(roundedAmount).." ("..reason..").", 4, positiveHintColor);
				else
					openAura.hint:Send(player, "Your character has gained "..FORMAT_CASH(roundedAmount)..".", 4, positiveHintColor);
				end;
			end;
		end;
		
		openAura.plugin:Call("PlayerCashUpdated", player, roundedAmount, reason, noMessage);
	end;
end;

-- A function to show cinematic text to a player.
function openAura.player:CinematicText(player, text, color, barLength, hangTime)
	openAura:StartDataStream( player, "CinematicText", {
		text = text,
		color = color,
		barLength = barLength,
		hangTime = hangTime
	} );
end;

-- A function to show cinematic text to each player.
function openAura.player:CinematicTextAll(text, color, hangTime)
	
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			self:CinematicText(v, text, color, hangTime);
		end;
	end;
end;

-- A function to get a player by a part of their name.
function openAura.player:Get(name)
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if ( string.find(string.lower( v:Name() ), string.lower(name), 1, true) ) then
				return v;
			end;
		end;
	end;
	
	return false;
end;

-- A function to notify each player in a radius.
function openAura.player:NotifyInRadius(text, class, position, radius)
	local listeners = {};
	
	for k, v in ipairs( _player.GetAll() ) do
		if ( v:HasInitialized() ) then
			if (position:Distance( v:GetPos() ) <= radius) then
				listeners[#listeners + 1] = v;
			end;
		end;
	end;
	
	self:Notify(listeners, text, class);
end;

-- A function to notify each player.
function openAura.player:NotifyAll(text, class)
	self:Notify(nil, text, true);
end;

-- A function to notify a player.
function openAura.player:Notify(player, text, class)
	if (type(player) == "table") then
		
		for k, v in ipairs(player) do
			self:Notify(v, text, class);
		end;
	elseif (class == true) then
		openAura.chatBox:Add(player, nil, "notify_all", text);
	elseif (!class) then
		openAura.chatBox:Add(player, nil, "notify", text);
	else
		umsg.Start("aura_Notification", player);
			umsg.String(text);
			umsg.Short(class);
		umsg.End();
	end;
end;

-- A function to set a player's weapons list from a table.
function openAura.player:SetWeapons(player, weapons, forceReturn)
	for k, v in pairs(weapons) do
		if ( player:HasWeapon( v.weaponData["class"] ) ) then
			if (v.canHolster) then
				local itemTable = openAura.item:GetWeapon( v.weaponData["class"], v.weaponData["uniqueID"] );
				
				if (itemTable) then
					player:UpdateInventory(itemTable.uniqueID, 1, true);
					
					openAura.plugin:Call("PlayerHolsterWeapon", player, itemTable, true);
				end;
			end;
		elseif (!v.teamIndex or player:Team() == v.teamIndex) then
			player:Give(v.weaponData["class"], v.weaponData["uniqueID"] , forceReturn);
			
			if ( !player:HasWeapon( v.weaponData["class"] ) ) then
				if (v.canHolster) then
					local itemTable = openAura.item:GetWeapon( v.weaponData["class"], v.weaponData["uniqueID"] );
					
					if (itemTable) then
						player:UpdateInventory(itemTable.uniqueID, 1, true);
						
						openAura.plugin:Call("PlayerHolsterWeapon", player, itemTable, true);
					end;
				end;
			end;
		end;
	end;
end;

-- A function to give ammo to a player from a table.
function openAura.player:GiveAmmo(player, ammo)
	for k, v in pairs(ammo) do player:GiveAmmo(v, k); end;
end;

-- A function to set a player's ammo list from a table.
function openAura.player:SetAmmo(player, ammo)
	for k, v in pairs(ammo) do player:SetAmmo(v, k); end;
end;

-- A function to get a player's ammo list as a table.
function openAura.player:GetAmmo(player, strip)
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
			if ( ammo[k] ) then
				ammo[k] = math.max(ammo[k] - v, 0);
			end;
		end;
	end;
	
	if (strip) then
		player:RemoveAllAmmo();
	end;
	
	return ammo;
end;

-- A function to get a player's weapons list as a table.
function openAura.player:GetWeapons(player, keep)
	local weapons = {};
	
	for k, v in pairs( player:GetWeapons() ) do
		local team = player:Team();
		local class = v:GetClass();
		local uniqueID = v:GetNetworkedString("uniqueID");
		local itemTable = openAura.item:GetWeapon(v);
		
		if ( !self:GetSpawnWeapon(player, class) ) then
			team = nil;
		end;
		
		if ( itemTable and openAura.plugin:Call("PlayerCanHolsterWeapon", player, itemTable, true, true) ) then
			weapons[#weapons + 1] = {
				weaponData = {class = class, uniqueID = uniqueID},
				canHolster = true,
				teamIndex = team
			};
		else
			weapons[#weapons + 1] = {
				weaponData = {class = class, uniqueID = uniqueID},
				canHolster = false,
				teamIndex = team
			};
		end;
		
		if (!keep) then
			player:StripWeapon(class);
		end;
	end;
	
	return weapons;
end;

-- A function to get the total weight of a player's equipped weapons.
function openAura.player:GetEquippedWeight(player)
	local weight = 0;
	
	for k, v in pairs( player:GetWeapons() ) do
		local itemTable = openAura.item:GetWeapon(v);
		
		if (itemTable) then
			weight = weight + itemTable.weight;
		end;
	end;
	
	return weight;
end;

-- A function to get a player's holstered weapon.
function openAura.player:GetHolsteredWeapon(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		local itemTable = openAura.item:GetWeapon(v);
		
		if (itemTable) then
			if (self:GetWeaponClass(player) != class) then
				return class;
			end;
		end;
	end;
end;

-- A function to check whether a player is ragdolled.
function openAura.player:IsRagdolled(player, exception, entityless)
	if (player:GetRagdollEntity() or entityless) then
		local ragdolled = player:GetSharedVar("ragdolled");
		
		if (ragdolled == exception) then
			return false;
		else
			return (ragdolled != RAGDOLL_NONE);
		end;
	end;
end;

-- A function to set a player's unragdoll time.
function openAura.player:SetUnragdollTime(player, delay)
	player.unragdollPaused = nil;
	
	if (delay) then
		self:SetAction(player, "unragdoll", delay, 2, function()
			if ( IsValid(player) and player:Alive() ) then
				self:SetRagdollState(player, RAGDOLL_NONE);
			end;
		end);
	else
		self:SetAction(player, "unragdoll", false);
	end;
end;

-- A function to pause a player's unragdoll time.
function openAura.player:PauseUnragdollTime(player)
	if (!player.unragdollPaused) then
		local unragdollTime = self:GetUnragdollTime(player);
		local curTime = CurTime();
		
		if ( player:IsRagdolled() ) then
			if (unragdollTime > 0) then
				player.unragdollPaused = unragdollTime - curTime;
				
				self:SetAction(player, "unragdoll", false);
			end;
		end;
	end;
end;

-- A function to start a player's unragdoll time.
function openAura.player:StartUnragdollTime(player)
	if (player.unragdollPaused) then
		if ( player:IsRagdolled() ) then
			self:SetUnragdollTime(player, player.unragdollPaused);
			
			player.unragdollPaused = nil;
		end;
	end;
end;

-- A function to get a player's unragdoll time.
function openAura.player:GetUnragdollTime(player)
	local action, actionDuration, startActionTime = self:GetAction(player);
	
	if (action == "unragdoll") then
		return startActionTime + actionDuration;
	else
		return 0;
	end;
end;

-- A function to get a player's ragdoll state.
function openAura.player:GetRagdollState(player)
	return player:GetSharedVar("ragdolled");
end;

-- A function to get a player's ragdoll entity.
function openAura.player:GetRagdollEntity(player)
	if (player.ragdollTable) then
		if ( IsValid(player.ragdollTable.entity) ) then
			return player.ragdollTable.entity;
		end;
	end;
end;

-- A function to get a player's ragdoll table.
function openAura.player:GetRagdollTable(player)
	return player.ragdollTable;
end;

-- A function to do a player's ragdoll decay check.
function openAura.player:DoRagdollDecayCheck(player, ragdoll)
	local index = ragdoll:EntIndex();
	
	openAura:CreateTimer("decay_check_"..index, 60, 0, function()
		local ragdollIsValid = IsValid(ragdoll);
		local playerIsValid = IsValid(player);
		
		if (!playerIsValid and ragdollIsValid) then
			if ( !openAura.entity:IsDecaying(ragdoll) ) then
				local decayTime = openAura.config:Get("body_decay_time"):Get();
				
				if ( decayTime > 0 and openAura.plugin:Call("PlayerCanRagdollDecay", player, ragdoll, decayTime) ) then
					openAura.entity:Decay(ragdoll, decayTime);
				end;
			else
				openAura:DestroyTimer("decay_check_"..index);
			end;
		elseif (!ragdollIsValid) then
			openAura:DestroyTimer("decay_check_"..index);
		end;
	end);
end;

-- A function to set a player's ragdoll immunity.
function openAura.player:SetRagdollImmunity(player, delay)
	if (delay) then
		player:GetRagdollTable().immunity = CurTime() + delay;
	else
		player:GetRagdollTable().immunity = 0;
	end;
end;

-- A function to set a player's ragdoll state.
function openAura.player:SetRagdollState(player, state, delay, decay, force, multiplier, velocityCallback)
	if (state == RAGDOLL_KNOCKEDOUT or state == RAGDOLL_FALLENOVER) then
		if ( player:IsRagdolled() ) then
			if ( openAura.plugin:Call("PlayerCanRagdoll", player, state, delay, decay, player.ragdollTable) ) then
				self:SetUnragdollTime(player, delay);
				
				player:SetSharedVar("ragdolled", state);

				player.ragdollTable.delay = delay;
				player.ragdollTable.decay = decay;
				
				openAura.plugin:Call("PlayerRagdolled", player, state, player.ragdollTable);
			end;
		elseif ( openAura.plugin:Call("PlayerCanRagdoll", player, state, delay, decay) ) then
			local velocity = player:GetVelocity() + (player:GetAimVector() * 128);
			local ragdoll = ents.Create("prop_ragdoll");
			
			ragdoll:SetMaterial( player:GetMaterial() );
			ragdoll:SetAngles( player:GetAngles() );
			ragdoll:SetColor( player:GetColor() );
			ragdoll:SetModel( player:GetModel() );
			ragdoll:SetSkin( player:GetSkin() );
			ragdoll:SetPos( player:GetPos() );
			ragdoll:Spawn();
			
			player.ragdollTable = {};
			player.ragdollTable.eyeAngles = player:EyeAngles();
			player.ragdollTable.immunity = CurTime() + openAura.config:Get("ragdoll_immunity_time"):Get();
			player.ragdollTable.moveType = MOVETYPE_WALK;
			player.ragdollTable.entity = ragdoll;
			player.ragdollTable.health = player:Health();
			player.ragdollTable.armor = player:Armor();
			player.ragdollTable.delay = delay;
			player.ragdollTable.decay = decay;
			
			if ( !player:IsOnGround() ) then
				player.ragdollTable.immunity = 0;
			end;
			
			if ( IsValid(ragdoll) ) then
				local headIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1");
				
				ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON);
				
				for i = 1, ragdoll:GetPhysicsObjectCount() do
					local physicsObject = ragdoll:GetPhysicsObjectNum(i);
					local boneIndex = ragdoll:TranslatePhysBoneToBone(i);
					local position, angle = player:GetBonePosition(boneIndex);
					
					if ( IsValid(physicsObject) ) then
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
			
			if ( player:Alive() ) then
				if ( IsValid( player:GetActiveWeapon() ) ) then
					player.ragdollTable.weapon = self:GetWeaponClass(player);
				end;
				
				player.ragdollTable.weapons = self:GetWeapons(player, true);
				
				if (delay) then
					self:SetUnragdollTime(player, delay);
				end;
			end;
			
			if ( player:InVehicle() ) then
				player:ExitVehicle();
				
				player.ragdollTable.eyeAngles = Angle(0, 0, 0);
			end;
			
			if ( player:IsOnFire() ) then
				ragdoll:Ignite(8, 0);
			end;
			
			player:Spectate(OBS_MODE_CHASE);
			player:RunCommand("-duck");
			player:RunCommand("-voicerecord");
			player:SetMoveType(MOVETYPE_OBSERVER);
			player:StripWeapons(true);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			if ( player:FlashlightIsOn() ) then
				player:Flashlight(false);
			end;
			
			player.unragdollPaused = nil;
			
			player:SetSharedVar("ragdolled", state);
			player:SetSharedVar("ragdoll", ragdoll);
			
			if (state != RAGDOLL_FALLENOVER) then
				self:GiveDeathCode(player);
			end;
			
			openAura.entity:SetPlayer(ragdoll, player);
			self:DoRagdollDecayCheck(player, ragdoll);
			
			openAura.plugin:Call("PlayerRagdolled", player, state, player.ragdollTable);
		end;
	elseif (state == RAGDOLL_NONE or state == RAGDOLL_RESET) then
		if ( player:IsRagdolled(nil, true) ) then
			local ragdollTable = player:GetRagdollTable();
			
			if ( openAura.plugin:Call("PlayerCanUnragdoll", player, state, ragdollTable) ) then
				player:UnSpectate();
				player:CrosshairEnable();
				
				if (state != RAGDOLL_RESET) then
					self:LightSpawn(player, nil, nil, true);
				end;
				
				if (state != RAGDOLL_RESET) then
					if ( IsValid(ragdollTable.entity) ) then
						local position = openAura.entity:GetPelvisPosition(ragdollTable.entity);
						
						if (position) then
							self:SetSafePosition(player, position, ragdollTable.entity);
						end;
						
						player:SetSkin( ragdollTable.entity:GetSkin() );
						player:SetColor( ragdollTable.entity:GetColor() );
						player:SetModel( ragdollTable.entity:GetModel() );
						player:SetMaterial( ragdollTable.entity:GetMaterial() );
					end;
					
					player:SetArmor(ragdollTable.armor);
					player:SetHealth(ragdollTable.health);
					player:SetMoveType(ragdollTable.moveType);
					player:SetEyeAngles(ragdollTable.eyeAngles);
				end;
				
				if ( IsValid(ragdollTable.entity) ) then
					openAura:DestroyTimer( "decay_check_"..ragdollTable.entity:EntIndex() );
					
					if (ragdollTable.decay) then
						if ( openAura.plugin:Call("PlayerCanRagdollDecay", player, ragdollTable.entity, ragdollTable.decay) ) then
							openAura.entity:Decay(ragdollTable.entity, ragdollTable.decay);
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
				
				player:SetSharedVar("ragdolled", RAGDOLL_NONE);
				player:SetSharedVar("ragdoll", NULL);
				
				openAura.plugin:Call("PlayerUnragdolled", player, state, ragdollTable);
				
				player.unragdollPaused = nil;
				player.ragdollTable = {};
			end;
		end;
	end;
end;

-- A function to make a player drop their weapons.
function openAura.player:DropWeapons(player)
	local ragdollEntity = player:GetRagdollEntity();
	
	if ( player:IsRagdolled() ) then
		local ragdollWeapons = player:GetRagdollWeapons();
		
		for k, v in pairs(ragdollWeapons) do
			if (v.canHolster) then
				local itemTable = openAura.item:GetWeapon( v.weaponData["class"], v.weaponData["uniqueID"] );
				
				if (itemTable) then
					if ( openAura.plugin:Call("PlayerCanDropWeapon", player, itemTable, true) ) then
						local info = {
							itemTable = itemTable,
							position = ragdollEntity:GetPos() + Vector( 0, 0, math.random(1, 48) ),
							angles = Angle(0, 0, 0)
						};
						
						if ( openAura.plugin:Call("PlayerAdjustDropWeaponInfo", player, info) ) then
							local entity = openAura.entity:CreateItem(player, info.itemTable.uniqueID, info.position, info.angles);
							
							if ( IsValid(entity) ) then
								openAura.plugin:Call("PlayerDropWeapon", player, itemTable, entity);
							end;
						end;
						
						ragdollWeapons[k] = nil;
					end;
				end;
			end;
		end;
	else
		for k, v in pairs( player:GetWeapons() ) do
			local itemTable = openAura.item:GetWeapon(v);
			local class = v:GetClass();
			
			if (itemTable) then
				if ( openAura.plugin:Call("PlayerCanDropWeapon", player, itemTable, true) ) then
					local info = {
						itemTable = itemTable,
						position = player:GetPos() + Vector( 0, 0, math.random(1, 48) ),
						angles = Angle(0, 0, 0)
					};
					
					if ( openAura.plugin:Call("PlayerAdjustDropWeaponInfo", player, info) ) then
						local entity = openAura.entity:CreateItem(player, info.itemTable.uniqueID, info.position, info.angles);
						
						if ( IsValid(entity) ) then
							openAura.plugin:Call("PlayerDropWeapon", player, itemTable, entity);
						end;
					end;
					
					player:StripWeapon( v:GetClass() );
				end;
			end;
		end;
	end;
end;

-- A function to lightly spawn a player.
function openAura.player:LightSpawn(player, weapons, ammo, forceReturn)
	if (player:IsRagdolled() and !forceReturn) then
		self:SetRagdollState(player, RAGDOLL_NONE);
	end;
	
	player.lightSpawn = true;
	
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
		
		if ( IsValid(weapon) ) then
			weapon = weapon:GetClass();
		end;
	end;
	
	player.lightSpawnCallback = function(player, gamemodeHook)
		if (weapons) then
			openAura:PlayerLoadout(player);
			
			self:SetWeapons(player, weapons, forceReturn);
			
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
			
			openAura.plugin:Call("PostPlayerLightSpawn", player, weapons, ammo, special);
		end;
		
		player:ResetSequence( player:GetSequence() );
	end;
	
	player:Spawn();
end;

-- A function to convert a table to camel case.
function openAura.player:ConvertToCamelCase(base)
	local newTable = {};
	
	for k, v in pairs(base) do
		local key = openAura:SetCamelCase(string.gsub(k, "_", ""), true);
		
		if (key and key != "") then
			newTable[key] = v;
		end;
	end;
	
	return newTable;
end;

-- A function to get a player's characters.
function openAura.player:GetCharacters(player, Callback)
	if ( IsValid(player) ) then
		local charactersTable = openAura.config:Get("mysql_characters_table"):Get();
		local schemaFolder = openAura:GetSchemaFolder();
		local characters = {};
		
		tmysql.query("SELECT * FROM "..charactersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..player:SteamID().."\"", function(result)
			if ( IsValid(player) ) then
				if (result and type(result) == "table" and #result > 0) then
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
function openAura.player:CharacterScreenAdd(player, character)
	local info = {
		name = character.name,
		model = character.model,
		banned = character.data["banned"],
		faction = character.faction,
		characterID = character.characterID
	};
	
	if ( character.data["physdesc"] ) then
		if (string.len( character.data["physdesc"] ) > 64) then
			info.details = string.sub(character.data["physdesc"], 1, 64).."...";
		else
			info.details = character.data["physdesc"];
		end;
	end;
	
	if ( character.data["banned"] ) then
		info.details = "This character is banned.";
	end;
	
	openAura.plugin:Call("PlayerAdjustCharacterScreenInfo", player, character, info);
	
	openAura:StartDataStream(player, "CharacterAdd", info);
end;

-- A function to convert a character's MySQL variables to Lua variables.
function openAura.player:ConvertCharacterMySQL(base)
	base.recognisedNames = self:ConvertCharacterRecognisedNamesString(base.recognisedNames);
	base.characterID = tonumber(base.characterID);
	base.attributes = self:ConvertCharacterDataString(base.attributes);
	base.inventory = self:ConvertCharacterDataString(base.inventory);
	base.cash = tonumber(base.cash);
	base.ammo = self:ConvertCharacterDataString(base.ammo);
	base.data = self:ConvertCharacterDataString(base.data);
	base.key = tonumber(base.key);
end;

-- A function to get a player's character ID.
function openAura.player:GetCharacterID(player)
	local character = player:GetCharacter();
	
	if (character) then
		for k, v in pairs( player:GetCharacters() ) do
			if (v == character) then
				return k;
			end;
		end;
	end;
end;

-- A function to load a player's character.
function openAura.player:LoadCharacter(player, characterID, mergeCreate, Callback, force)
	local character = {};
	local unixTime = os.time();
	
	if (mergeCreate) then
		character = {};
		character.name = name;
		character.data = {};
		character.ammo = {};
		character.cash = openAura.config:Get("default_cash"):Get();
		character.model = "models/police.mdl";
		character.flags = "b";
		character.schema = openAura:GetSchemaFolder();
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
		
		if ( !player.characters[characterID] ) then
			table.Merge(character, mergeCreate);
			
			if (character and type(character) == "table") then
				character.inventory = openAura.inventory:GetDefault(player, character);
				
				if (!force) then
					local fault = openAura.plugin:Call("PlayerCanCreateCharacter", player, character, characterID);
					
					if (fault == false or type(fault) == "string") then
						return self:CreationError(player, fault or "You cannot create this character!");
					end;
				end;
				
				self:SaveCharacter(player, true, character, function(key)
					player.characters[characterID] = character;
					player.characters[characterID].key = key;
					
					openAura.plugin:Call("PlayerCharacterCreated", player, character);
					
					self:CharacterScreenAdd(player, character);
					
					if (Callback) then
						Callback();
					end;
				end);
			end;
		end;
	else
		character = player.characters[characterID];
		
		if (character) then
			if ( player:GetCharacter() ) then
				self:SaveCharacter(player);
				self:UpdateCharacter(player);
				
				openAura.plugin:Call("PlayerCharacterUnloaded", player);
			end;
			
			player.character = character;
			
			if ( player:Alive() ) then
				player:KillSilent();
			end;
			
			if ( self:SetBasicSharedVars(player) ) then
				openAura.plugin:Call("PlayerCharacterLoaded", player);
				
				player:SaveCharacter();
			end;
		end;
	end;
end;

-- A function to set a player's basic shared variables.
function openAura.player:SetBasicSharedVars(player)
	local gender = self:GetGender(player);
	local faction = player:QueryCharacter("faction");
	
	player:SetSharedVar( "flags", player:QueryCharacter("flags") );
	player:SetSharedVar( "model", self:GetDefaultModel(player) );
	player:SetSharedVar( "name", player:QueryCharacter("name") );
	player:SetSharedVar( "key", player:QueryCharacter("key") );
	
	if ( openAura.faction.stored[faction] ) then
		player:SetSharedVar("faction", openAura.faction.stored[faction].index);
	end;
	
	if (gender == GENDER_MALE) then
		player:SetSharedVar("gender", 2);
	else
		player:SetSharedVar("gender", 1);
	end;
	
	return true;
end;

-- A function to unescape a string.
function openAura.player:Unescape(text)
	return openAura:Replace(openAura:Replace(openAura:Replace(text, "\\\\", "\\"), '\\"', '"'), "\\'", "'");
end;

-- A function to get the character's ammo as a string.
function openAura.player:GetCharacterAmmoString(player, character, rawTable)
	local ammo = table.Copy(character.ammo);
	
	for k, v in pairs( self:GetAmmo(player) ) do
		if (v > 0) then
			ammo[k] = v;
		end;
	end;
	
	if (!rawTable) then
		return Json.Encode(ammo);
	else
		return ammo;
	end;
end;

-- A function to get the character's data as a string.
function openAura.player:GetCharacterDataString(player, character, rawTable)
	local data = table.Copy(character.data);
	
	openAura.plugin:Call("PlayerSaveCharacterData", player, data);
	
	if (!rawTable) then
		return Json.Encode(data);
	else
		return data;
	end;
end;

-- A function to get the character's recognised names as a string.
function openAura.player:GetCharacterRecognisedNamesString(player, character)
	local recognisedNames = {};
	
	for k, v in pairs(character.recognisedNames) do
		if (v == RECOGNISE_SAVE) then
			recognisedNames[#recognisedNames + 1] = k;
		end;
	end;
	
	return Json.Encode(recognisedNames);
end;

-- A function to get the character's inventory as a string.
function openAura.player:GetCharacterInventoryString(player, character, rawTable)
	local inventory = table.Copy(character.inventory);
	
	openAura.plugin:Call("PlayerGetInventoryString", player, character, inventory);
	
	for k, v in pairs(inventory) do
		local itemTable = openAura.item:Get(k);
		
		if (itemTable) then
			local amount = v;
			
			if (itemTable.GetInventoryStringAmount) then
				amount = itemTable:GetInventoryStringAmount(player);
			end;
			
			if (amount > 0) then
				inventory[k] = amount;
			else
				inventory[k] = nil;
			end;
		end;
	end;
	
	if (!rawTable) then
		return Json.Encode(inventory);
	else
		return inventory;
	end;
end;

-- A function to convert a character's recognised names string to a table.
function openAura.player:ConvertCharacterRecognisedNamesString(data)
	local success, value = pcall( Json.Decode, self:Unescape(data) );
	
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
function openAura.player:ConvertCharacterDataString(data)
	local success, value = pcall( Json.Decode, self:Unescape(data) );
	
	if (success) then
		return value;
	else
		return {};
	end;
end;

-- A function to load a player's data.
function openAura.player:LoadData(player, Callback)
	if (!openAura.AddedDonationsRow) then
		tmysql.query("ALTER TABLE "..openAura.config:Get("mysql_players_table"):Get().." ADD _Donations TEXT AFTER _SteamID");
		openAura.AddedDonationsRow = true;
	end;
	
	local playersTable = openAura.config:Get("mysql_players_table"):Get();
	local schemaFolder = openAura:GetSchemaFolder();
	local unixTime = os.time();
	local steamID = player:SteamID();
	
	tmysql.query("SELECT * FROM "..playersTable.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"", function(result)
		if (IsValid(player) and !player.data) then
			local ownerSteamID = openAura.config:Get("owner_steamid"):Get();
			local onNextPlay = "";
			
			if (result and type(result) == "table" and #result > 0) then
				player.timeJoined = tonumber(result[1]._TimeJoined);
				player.lastPlayed = tonumber(result[1]._LastPlayed);
				player.userGroup = result[1]._UserGroup;
				player.data = self:ConvertDataString(player, result[1]._Data);
				
				local success, value = pcall( Json.Decode, self:Unescape(result[1]._Donations) );
				
				if (success) then
					player.donations = value;
				else
					player.donations = {};
				end;
				
				onNextPlay = result[1]._OnNextPlay;
			else
				player.timeJoined = unixTime;
				player.lastPlayed = unixTime;
				player.donations = {};
				player.userGroup = "user";
				player.data = self:SaveData(player, true);
			end;
			
			if ( string.lower(steamID) == string.lower(ownerSteamID) ) then
				player.userGroup = "superadmin";
			end;
			
			if (!player.userGroup or player.userGroup == "") then
				player.userGroup = "user";
			end;
			
			if (player.userGroup != "user") then
				if ( !openAura.config:Get("use_own_group_system"):Get() ) then
					player:SetUserGroup(player.userGroup);
				end;
			end;
			
			openAura.plugin:Call("PlayerRestoreData", player, player.data);
			
			if ( Callback and IsValid(player) ) then
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
		if (IsValid(player) and !player.data) then
			self:LoadData(player, Callback);
		end;
	end);
end;

-- A function to save a players's data.
function openAura.player:SaveData(player, create, delay, bReturnQuery)
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
function openAura.player:GetDataCreateQuery(player)
	local playersTable = openAura.config:Get("mysql_players_table"):Get();
	local schemaFolder = openAura:GetSchemaFolder();
	local steamName = tmysql.escape( player:SteamName() );
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
function openAura.player:GetDataUpdateQuery(player)
	local schemaFolder = openAura:GetSchemaFolder();
	local steamName = tmysql.escape( player:SteamName() );
	local ipAddress = player:IPAddress();
	local userGroup = player:GetOpenAuraUserGroup();
	local steamID = player:SteamID();
	local data = table.Copy(player.data);
	
	openAura.plugin:Call("PlayerSaveData", player, data);
	
	local playersTable = openAura.config:Get("mysql_players_table"):Get();
	local unixTime = os.time();
	local query = "UPDATE "..playersTable.." SET _Data = \""..tmysql.escape( Json.Encode(data) ).."\",";
	
	query = query.." _SteamName = \""..steamName.."\", _IPAddress = \""..ipAddress.."\", _LastPlayed = \""..unixTime.."\", _UserGroup = \""..userGroup.."\"";
	query = query.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\"";
	
	return query;
end;

-- A function to get the create query of a character.
function openAura.player:GetCharacterCreateQuery(player, character)
	local charactersTable = openAura.config:Get("mysql_characters_table"):Get();
	local values = "";
	local amount = 1;
	local keys = "";
	
	if (!character or type(character) != "table") then
		character = player:GetCharacter();
	end;
	
	local characterKeys = table.Count(character);
	
	for k, v in pairs(character) do
		if (characterKeys != amount) then
			keys = keys.."_"..openAura:SetCamelCase(k, false)..", ";
		else
			keys = keys.."_"..openAura:SetCamelCase(k, false);
		end;
		
		if (type(v) == "table") then
			if (k == "recognisedNames") then
				v = Json.Encode(character.recognisedNames);
			elseif (k == "attributes") then
				v = Json.Encode(character.attributes);
			elseif (k == "inventory") then
				v = Json.Encode(character.inventory);
			elseif (k == "ammo") then
				v = Json.Encode(character.ammo);
			elseif (k == "data") then
				v = Json.Encode(v);
			end;
		end;
		
		local value = tmysql.escape( tostring(v) );
		
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
function openAura.player:GetCharacterUpdateQuery(player, character)
	local currentCharacter = player:GetCharacter();
	local charactersTable = openAura.config:Get("mysql_characters_table"):Get();
	local schemaFolder = openAura:GetSchemaFolder();
	local unixTime = os.time();
	local steamID = player:SteamID();
	local query = "";
	
	if (!character or type(character) != "table") then
		character = currentCharacter;
	end;
	
	if (character == currentCharacter) then
		if ( player:HasInitialized() ) then
			self:PreserveAmmo(player);
		end;
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
						v = Json.Encode(character.inventory);
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
			
			local value = tmysql.escape( tostring(v) );
			
			if (query == "") then
				query = "UPDATE "..charactersTable.." SET _"..openAura:SetCamelCase(k, false).." = \""..value.."\"";
			else
				query = query..", _"..openAura:SetCamelCase(k, false).." = \""..value.."\"";
			end;
		end;
	end;
	
	return query.." WHERE _Schema = \""..schemaFolder.."\" AND _SteamID = \""..steamID.."\" AND _CharacterID = "..character.characterID;
end;

-- A function to update a player's character.
function openAura.player:UpdateCharacter(player)
	player.character.inventory = self:GetCharacterInventoryString(player, player.character, true);
	player.character.ammo = self:GetCharacterAmmoString(player, player.character, true);
	player.character.data = self:GetCharacterDataString(player, player.character, true);
end;

-- A function to save a player's character.
function openAura.player:SaveCharacter(player, create, character, Callback)
	if (create) then
		local query = self:GetCharacterCreateQuery(player, character);
		
		tmysql.query(query, function(result, status, lastID)
			if ( Callback and tonumber(lastID) ) then
				Callback( tonumber(lastID) );
			end;
		end, 2);
	elseif ( player:HasInitialized() ) then
		local characterQuery = self:GetCharacterUpdateQuery(player, character);
		local dataQuery = self:SaveData(player, nil, nil, true);
		
		tmysql.query(characterQuery);
		tmysql.query(dataQuery);
	end;
end;

-- A function to get the class of a player's active weapon.
function openAura.player:GetWeaponClass(player, safe)
	if ( IsValid( player:GetActiveWeapon() ) ) then
		return player:GetActiveWeapon():GetClass();
	else
		return safe;
	end;
end;

-- A function to call a player's think hook.
function openAura.player:CallThinkHook(player, setSharedVars, infoTable, curTime)
	infoTable.inventoryWeight = openAura.config:Get("default_inv_weight"):Get();
	infoTable.crouchedSpeed = player.crouchedSpeed;
	infoTable.jumpPower = player.jumpPower;
	infoTable.walkSpeed = player.walkSpeed;
	infoTable.runSpeed = player.runSpeed;
	infoTable.running = player:IsRunning();
	infoTable.jogging = player:IsJogging();
	infoTable.wages = openAura.class:Query(player:Team(), "wages", 0);
	
	if ( !player:IsJogging(true) ) then
		infoTable.jogging = nil;
		player:SetSharedVar("jogging", false);
	end;
	
	if (setSharedVars) then
		openAura.plugin:Call("PlayerSetSharedVars", player, curTime);
		player.nextSetSharedVars = nil;
	end;
	
	openAura.plugin:Call("PlayerThink", player, curTime, infoTable);
	
	player.nextThink = nil;
end;

-- A function to preserve a player's ammo.
function openAura.player:PreserveAmmo(player)
	local weapon = player:GetActiveWeapon();
	
	for k, v in ipairs( player:GetWeapons() ) do
		local itemTable = openAura.item:GetWeapon(v);
		
		if (itemTable) then
			self:SavePrimaryAmmo(player, v);
			self:SaveSecondaryAmmo(player, v);
		end;
	end;
end;

-- A function to get a player's wages.
function openAura.player:GetWages(player)
	return player:GetSharedVar("wages");
end;