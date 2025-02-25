--[[
	Free Clockwork!
--]]

Clockwork.attribute = Clockwork:NewLibrary("Attribute");
Clockwork.attribute.stored = {};
Clockwork.attribute.buffer = {};

-- A function to get a new attribute.
function Clockwork.attribute:New()
	return {};
end;

-- A function to get the attribute buffer.
function Clockwork.attribute:GetBuffer()
	return self.buffer;
end;

-- A function to get all attributes.
function Clockwork.attribute:GetAll()
	return self.stored;
end;

-- A function to register a new attribute.
function Clockwork.attribute:Register(attribute)
	attribute.uniqueID = attribute.uniqueID or string.lower(string.gsub(attribute.name, "%s", "_"));
	attribute.index = Clockwork:GetShortCRC(attribute.name);
	attribute.cache = {};
	
	for i = -attribute.maximum, attribute.maximum do
		attribute.cache[i] = {};
	end;
	
	self.stored[attribute.uniqueID] = attribute;
	self.buffer[attribute.index] = attribute;
	
	if (SERVER and attribute.image) then
		resource.AddFile("materials/"..attribute.image..".vtf");
		resource.AddFile("materials/"..attribute.image..".vmt");
	end;
	
	return attribute.uniqueID;
end;

-- A function to get an attribute by its name.
function Clockwork.attribute:Get(name)
	if (name) then
		if (self.buffer[name]) then
			return self.buffer[name];
		elseif (self.stored[name]) then
			return self.stored[name];
		else
			local attribute;
			
			for k, v in pairs(self.stored) do
				if (string.find(string.lower(v.name), string.lower(name))) then
					if (attribute) then
						if (string.len(v.name) < string.len(attribute.name)) then
							attribute = v;
						end;
					else
						attribute = v;
					end;
				end;
			end;
			
			return attribute;
		end;
	end;
end;