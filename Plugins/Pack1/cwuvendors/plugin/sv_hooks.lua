local PLUGIN = PLUGIN;

-- Called when Clockwork has loaded all of the entities.
function PLUGIN:ClockworkInitPostEntity()
	self:LoadCwuVendingMachines();
end;

-- Called when data should be saved.
function PLUGIN:SaveData() 
	self:SaveCwuVendingMachines();
end;