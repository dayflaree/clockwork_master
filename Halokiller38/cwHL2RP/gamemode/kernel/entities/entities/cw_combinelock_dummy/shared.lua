--[[
	Free Clockwork!
--]]

ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.Author = "kurozael";
ENT.PrintName = "Combine Lock";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.UsableInVehicle = true;
ENT.PhysgunDisabled = true;

-- Called when the datatables are setup.
function ENT:SetupDataTables()
	self:DTVar("Float", 0, "smokeCharge");
	self:DTVar("Float", 1, "flash");
	self:DTVar("Bool", 0, "locked");
end;

-- A function to get whether the entity is locked.
function ENT:IsLocked()
	return self:GetDTBool("locked");
end;