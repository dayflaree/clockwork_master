--[[
	Free Clockwork!
--]]

Clockwork.attributes = Clockwork:NewLibrary("Attributes");

if (SERVER) then
	function Clockwork.attributes:Progress(player, attribute, amount, gradual)
		local attributeTable = Clockwork.attribute:Get(attribute);
		local attributes = player:GetAttributes();
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (gradual and attributes[attribute]) then
				if (amount > 0) then
					amount = math.max(amount - ((amount / attributeTable.maximum) * attributes[attribute].amount), amount / attributeTable.maximum);
				else
					amount = math.min((amount / attributeTable.maximum) * attributes[attribute].amount, amount / attributeTable.maximum);
				end;
			end;
			
			amount = amount * Clockwork.config:Get("scale_attribute_progress"):Get();
			
			if (attributes[attribute]) then
				if (attributes[attribute].amount == attributeTable.maximum) then
					if (amount > 0) then
						return false, "You have the maximum of this "..Clockwork.option:GetKey("name_attribute", true).."!";
					end;
				end;
			else
				attributes[attribute] = {amount = 0, progress = 0};
			end;
			
			local progress = attributes[attribute].progress + amount;
			local remaining = math.max(progress - 100, 0);
			
			if (progress >= 100) then
				attributes[attribute].progress = 0;
				
				player:UpdateAttribute(attribute, 1);
				
				if (remaining > 0) then
					return player:ProgressAttribute(attribute, remaining);
				end;
			elseif (progress < 0) then
				attributes[attribute].progress = 100;
				
				player:UpdateAttribute(attribute, -1);
				
				if (progress < 0) then
					return player:ProgressAttribute(attribute, progress);
				end;
			else
				attributes[attribute].progress = progress;
			end;
			
			if (attributes[attribute].amount == 0 and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			if (player:HasInitialized()) then
				if (attributes[attribute]) then
					player.cwAttrProgress[attribute] = math.floor(attributes[attribute].progress);
				else
					player.cwAttrProgress[attribute] = 0;
				end;
			end;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	-- A function to update a player's attribute.
	function Clockwork.attributes:Update(player, attribute, amount)
		local attributeTable = Clockwork.attribute:Get(attribute);
		local attributes = player:GetAttributes();
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (!attributes[attribute]) then
				attributes[attribute] = {amount = 0, progress = 0};
			elseif (attributes[attribute].amount == attributeTable.maximum) then
				if (amount and amount > 0) then
					return false, "You have reached the maximum of this "..Clockwork.option:GetKey("name_attribute", true).."!";
				end;
			end;
			
			attributes[attribute].amount = math.Clamp(attributes[attribute].amount + (amount or 0), 0, attributeTable.maximum);
			
			if (amount and amount > 0) then
				attributes[attribute].progress = 0;
				
				if (player:HasInitialized()) then
					player.cwAttrProgress[attribute] = 0;
					player.cwAttrProgressTime = 0;
				end;
			end;
			
			umsg.Start("cwAttrUpdate", player);
				umsg.Long(attributeTable.index);
				umsg.Long(attributes[attribute].amount);
			umsg.End();
			
			if (attributes[attribute].amount == 0
			and attributes[attribute].progress == 0) then
				attributes[attribute] = nil;
			end;
			
			Clockwork.plugin:Call("PlayerAttributeUpdated", player, attributeTable, amount);
			
			return true;
		else
			return false, "That is not a valid attribute!";
		end;
	end;
	
	-- A function to clear a player's attribute boosts.
	function Clockwork.attributes:ClearBoosts(player)
		umsg.Start("cwAttrBoostClear", player);
		umsg.End();
		
		player.cwAttrBoosts = {};
	end;
	
	--- A function to get whether a boost is active for a player.
	function Clockwork.attributes:IsBoostActive(player, identifier, attribute, amount, duration)
		if (player.cwAttrBoosts) then
			local attributeTable = Clockwork.attribute:Get(attribute);
			
			if (attributeTable) then
				attribute = attributeTable.uniqueID;
				
				if (player.cwAttrBoosts[attribute]) then
					local attributeBoost = player.cwAttrBoosts[attribute][identifier];
					
					if (attributeBoost) then
						if (amount and duration) then
							return attributeBoost.amount == amount and attributeBoost.duration == duration;
						elseif (amount) then
							return attributeBoost.amount == amount;
						elseif (duration) then
							return attributeBoost.duration == duration;
						else
							return true;
						end;
					end;
				end;
			end;
		end;
	end;
	
	-- A function to boost a player's attribute.
	function Clockwork.attributes:Boost(player, identifier, attribute, amount, duration)
		local attributeTable = Clockwork.attribute:Get(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (amount) then
				if (!identifier) then
					identifier = tostring({});
				end;
				
				if (!player.cwAttrBoosts[attribute]) then
					player.cwAttrBoosts[attribute] = {};
				end;
				
				if (duration) then
					player.cwAttrBoosts[attribute][identifier] = {
						duration = duration,
						endTime = CurTime() + duration,
						default = amount,
						amount = amount,
					};
				else
					player.cwAttrBoosts[attribute][identifier] = {
						amount = amount
					};
				end;
				
				umsg.Start("cwAttrBoost", player);
					umsg.Long(attributeTable.index);
					umsg.Long(player.cwAttrBoosts[attribute][identifier].amount);
					umsg.Long(player.cwAttrBoosts[attribute][identifier].duration);
					umsg.Long(player.cwAttrBoosts[attribute][identifier].endTime);
					umsg.String(identifier);
				umsg.End();
				
				return identifier;
			elseif (identifier) then
				if (self:IsBoostActive(player, identifier, attribute)) then
					if (player.cwAttrBoosts[attribute]) then
						player.cwAttrBoosts[attribute][identifier] = nil;
					end;
					
					umsg.Start("cwAttrBoostClear", player);
						umsg.Long(attributeTable.index);
						umsg.String(identifier);
					umsg.End();
				end;
				
				return true;
			elseif (player.cwAttrBoosts[attribute]) then
				umsg.Start("cwAttrBoostClear", player);
					umsg.Long(attributeTable.index);
				umsg.End();
				
				player.cwAttrBoosts[attribute] = {};
				
				return true;
			end;
		else
			self:ClearBoosts(player);
			
			return true;
		end;
	end;
	
	-- A function to get a player's attribute as a fraction.
	function Clockwork.attributes:Fraction(player, attribute, fraction, negative)
		local attributeTable = Clockwork.attribute:Get(attribute);
		
		if (attributeTable) then
			local maximum = attributeTable.maximum;
			local amount = self:Get(player, attribute, nil, negative) or 0;
			
			if (amount < 0 and type(negative) == "number") then
				fraction = negative;
			end;
			
			if (!attributeTable.cache[amount][fraction]) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount;
			end;
			
			return attributeTable.cache[amount][fraction];
		end;
	end;
	
	-- A function to get whether a player has an attribute.
	function Clockwork.attributes:Get(player, attribute, boostless, negative)
		local attributeTable = Clockwork.attribute:Get(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (Clockwork:HasObjectAccess(player, attributeTable)) then
				local maximum = attributeTable.maximum;
				local default = player:GetAttributes()[attribute];
				local boosts = player.cwAttrBoosts[attribute];
				
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum);
					else
						amount = math.Clamp(amount, 0, maximum);
					end;
					
					return math.ceil(amount), progress;
				end;
			end;
		end;
	end;
else
	Clockwork.attributes.stored = {};
	Clockwork.attributes.boosts = {};
	
	-- A function to get the attributes panel.
	function Clockwork.attributes:GetPanel()
		return self.panel;
	end;
	
	-- A function to get the local player's attribute as a fraction.
	function Clockwork.attributes:Fraction(attribute, fraction, negative)
		local attributeTable = Clockwork.attribute:Get(attribute);
		
		if (attributeTable) then
			local maximum = attributeTable.maximum;
			local amount = self:Get(attribute, nil, negative) or 0;
			
			if (amount < 0 and type(negative) == "number") then
				fraction = negative;
			end;
			
			if (!attributeTable.cache[amount][fraction]) then
				attributeTable.cache[amount][fraction] = (fraction / maximum) * amount;
			end;
			
			return attributeTable.cache[amount][fraction];
		end;
	end;
	
	-- A function to get whether the local player has an attribute.
	function Clockwork.attributes:Get(attribute, boostless, negative)
		local attributeTable = Clockwork.attribute:Get(attribute);
		
		if (attributeTable) then
			attribute = attributeTable.uniqueID;
			
			if (Clockwork:HasObjectAccess(Clockwork.Client, attributeTable)) then
				local maximum = attributeTable.maximum;
				local default = self.stored[attribute];
				local boosts = self.boosts[attribute];
				
				if (boostless) then
					if (default) then
						return default.amount, default.progress;
					end;
				else
					local progress = 0;
					local amount = 0;
					
					if (default) then
						amount = amount + default.amount;
						progress = progress + default.progress;
					end;
					
					if (boosts) then
						for k, v in pairs(boosts) do
							amount = amount + v.amount;
						end;
					end;
					
					if (negative) then
						amount = math.Clamp(amount, -maximum, maximum);
					else
						amount = math.Clamp(amount, 0, maximum);
					end;
					
					return math.ceil(amount), progress;
				end;
			end;
		end;
	end;
	
	usermessage.Hook("cwAttrBoostClear", function(msg)
		local index = msg:ReadLong();
		local identifier = msg:ReadString();
		local attributeTable = Clockwork.attribute:Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (identifier and identifier != "") then
				if (Clockwork.attributes.boosts[attribute]) then
					Clockwork.attributes.boosts[attribute][identifier] = nil;
				end;
			else
				Clockwork.attributes.boosts[attribute] = nil;
			end;
		else
			Clockwork.attributes.boosts = {};
		end;
		
		if (Clockwork.menu:GetOpen()) then
			local panel = Clockwork.attributes:GetPanel();
			
			if (panel and Clockwork.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
	
	usermessage.Hook("cwAttrBoost", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local duration = msg:ReadLong();
		local endTime = msg:ReadLong();
		local identifier = msg:ReadString();
		local attributeTable = Clockwork.attribute:Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (!Clockwork.attributes.boosts[attribute]) then
				Clockwork.attributes.boosts[attribute] = {};
			end;
			
			if (amount == 0) then
				Clockwork.attributes.boosts[attribute][identifier] = nil;
			elseif (duration > 0 and endTime > 0) then
				Clockwork.attributes.boosts[attribute][identifier] = {
					duration = duration,
					endTime = endTime,
					default = amount,
					amount = amount
				};
			else
				Clockwork.attributes.boosts[attribute][identifier] = {
					default = amount,
					amount = amount
				};
			end;
			
			if (Clockwork.menu:GetOpen()) then
				local panel = Clockwork.attributes:GetPanel();
				
				if (panel and Clockwork.menu:GetActivePanel() == panel) then
					panel:Rebuild();
				end;
			end;
		end;
	end);
	
	usermessage.Hook("cwAttributeProgress", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadShort();
		local attributeTable = Clockwork.attribute:Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (Clockwork.attributes.stored[attribute]) then
				Clockwork.attributes.stored[attribute].progress = amount;
			else
				Clockwork.attributes.stored[attribute] = {amount = 0, progress = amount};
			end;
		end;
	end);
	
	usermessage.Hook("cwAttrUpdate", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local attributeTable = Clockwork.attribute:Get(index);
		
		if (attributeTable) then
			local attribute = attributeTable.uniqueID;
			
			if (Clockwork.attributes.stored[attribute]) then
				Clockwork.attributes.stored[attribute].amount = amount;
			else
				Clockwork.attributes.stored[attribute] = {amount = amount, progress = 0};
			end;
		end;
	end);
	
	usermessage.Hook("cwAttrClear", function(msg)
		Clockwork.attributes.stored = {};
		Clockwork.attributes.boosts = {};
		
		if (Clockwork.menu:GetOpen()) then
			local panel = Clockwork.attributes:GetPanel();
			
			if (panel and Clockwork.menu:GetActivePanel() == panel) then
				panel:Rebuild();
			end;
		end;
	end);
end;