--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local amount = self:GetAmount();
	
	y = Clockwork.kernel:DrawInfo(Clockwork.option:GetKey("name_cash"), x, y, colorTargetID, alpha);
	y = Clockwork.kernel:DrawInfo(Clockwork.kernel:FormatCash(amount), x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (Clockwork.plugin:Call("CashEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;