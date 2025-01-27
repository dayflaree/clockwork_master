--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:IncludePrefixed("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local physDesc = self:GetDTString(1);
	local name = self:GetDTString(0);
	
	y = Clockwork.kernel:DrawInfo(name, x, y, colorTargetID, alpha);
	
	if (physDesc != "") then
		y = Clockwork.kernel:DrawInfo(physDesc, x, y, colorWhite, alpha);
	end;
end;

-- Called when the entity initializes.
function ENT:Initialize()
	self.AutomaticFrameAdvance = true;
end;

-- Called every frame.
function ENT:Think()
	self:FrameAdvance(FrameTime());
end;