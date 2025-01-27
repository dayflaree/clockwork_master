--[[
	This script has been purchased for "Blt950's HL2RP & Clockwork plugins" from CoderHire.com
	� 2014 Blt950 do not share, re-distribute or modify
	without permission.
--]]

local COMMAND = Clockwork.command:New("ConfiscationFieldAdd");
COMMAND.tip = "Add a combine confiscation field at your target position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local trace = player:GetEyeTraceNoCursor();
	local entity = ents.Create("cw_confield");
	
	entity:SetPos(trace.HitPos + Vector(0, 0, 48));
	entity:Spawn();
	
	if ( IsValid(entity) ) then
		entity:SetAngles(Angle(0, player:EyeAngles().yaw + 180, 0));
		
		Clockwork.player:Notify(player, "You have added a confiscation field.");
	end;
end;

COMMAND:Register();