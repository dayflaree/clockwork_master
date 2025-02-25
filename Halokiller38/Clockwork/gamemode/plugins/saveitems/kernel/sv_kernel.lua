--[[
	Free Clockwork!
--]]

-- A function to load the shipments.
function PLUGIN:LoadShipments()
	local shipments = Clockwork:RestoreSchemaData("plugins/shipments/"..game.GetMap());
	
	for k, v in pairs(shipments) do
		if (Clockwork.item.stored[v.item]) then
			local entity = Clockwork.entity:CreateShipment(
				{key = v.key, uniqueID = v.uniqueID}, v.item, v.amount, v.position, v.angles
			);
			
			if (IsValid(entity) and !v.isMoveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				if (IsValid(physicsObject)) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the shipments.
function PLUGIN:SaveShipments()
	local shipments = {};
	
	for k, v in pairs(ents.FindByClass("cw_shipment")) do
		local physicsObject = v:GetPhysicsObject();
		local itemTable = v:GetItemTable();
		local bMoveable = nil;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		shipments[#shipments + 1] = {
			key = Clockwork.entity:QueryProperty(v, "key"),
			item = itemTable("uniqueID"),
			angles = v:GetAngles(),
			amount = table.Count(v.cwInventory[itemTable("uniqueID")]),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/shipments/"..game.GetMap(), shipments);
end;

-- A function to load the items.
function PLUGIN:LoadItems()
	local items = Clockwork:RestoreSchemaData("plugins/items/"..game.GetMap());
	
	for k, v in pairs(items) do
		local itemTable = Clockwork.item:CreateInstance(v.item, v.itemID, v.data);
		
		if (itemTable) then
			local entity = Clockwork.entity:CreateItem(
				{key = v.key, uniqueID = v.uniqueID}, itemTable, v.position, v.angles
			);
			
			if (IsValid(entity) and !v.isMoveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				if (IsValid(physicsObject)) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the items.
function PLUGIN:SaveItems()
	local items = {};
	
	for k, v in pairs(ents.FindByClass("cw_item")) do
		local physicsObject = v:GetPhysicsObject();
		local itemTable = v:GetItemTable();
		local bMoveable = false;
		
		if (IsValid(physicsObject)) then
			bMoveable = physicsObject:IsMoveable();
		end;
		
		items[#items + 1] = {
			key = Clockwork.entity:QueryProperty(v, "key"),
			item = itemTable("uniqueID"),
			data = itemTable("data"),
			itemID = itemTable("itemID"),
			angles = v:GetAngles(),
			uniqueID = Clockwork.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			isMoveable = bMoveable
		};
	end;
	
	Clockwork:SaveSchemaData("plugins/items/"..game.GetMap(), items);
end;