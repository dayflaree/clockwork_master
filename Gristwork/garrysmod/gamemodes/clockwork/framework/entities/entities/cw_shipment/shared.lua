--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

DEFINE_BASECLASS("base_gmodentity");

ENT.Type = "anim";
ENT.Author = "kurozael";
ENT.PrintName = "Shipment";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the data tables are setup.
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Index");
end;

-- A function to get the entity's item table.
function ENT:GetItemTable()
	if (CLIENT) then
		local index = self:GetIndex();
		
		if (index != 0) then
			return Clockwork.item:FindByID(index);
		end;
	end;
	
	return self.cwItemTable;
end;