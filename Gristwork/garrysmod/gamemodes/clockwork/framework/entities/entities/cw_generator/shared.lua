--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

DEFINE_BASECLASS("base_gmodentity");

ENT.Type = "anim";
ENT.Model = "models/props_combine/combine_mine01.mdl";
ENT.Author = "kurozael";
ENT.PrintName = "Generator";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;

-- Called when the data tables are setup.
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Power");
end;

-- A function to get the entity's item table.
function ENT:GetItemTable()
	return Clockwork.entity:FetchItemTable(self);
end;