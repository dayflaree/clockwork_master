--[[
	Free Clockwork!
--]]

local PLUGIN = PLUGIN;

-- Called when the top text is needed.
function PLUGIN:GetTopText(topText)
	local beingDragged = Clockwork.Client:GetSharedVar("IsDragged");
	
	if (Clockwork.Client:IsRagdolled() and beingDragged) then
		topText:Add("BEING_DRAGGED", "You are being dragged");
	end;
end;

-- Called when the local player attempts to get up.
function PLUGIN:PlayerCanGetUp()
	local beingDragged = Clockwork.Client:GetSharedVar("IsDragged");
	
	if (beingDragged) then
		return false;
	end;
end;

timer.Simple(1, function()
	local SWEP = weapons.GetStored("cw_hands");

	if (SWEP) then
		SWEP.Instructions = "Reload: Drop\n"..SWEP.Instructions;
		
		SWEP.Instructions = Clockwork:Replace(SWEP.Instructions, "Knock.", "Knock/Pickup.");
		SWEP.Instructions = Clockwork:Replace(SWEP.Instructions, "Punch.", "Punch/Throw.");
	end;
end);