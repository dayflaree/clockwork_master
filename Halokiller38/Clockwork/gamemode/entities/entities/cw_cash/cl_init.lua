--[[
	Free Clockwork!
--]]

include("shared.lua")

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local amount = self:GetDTInt("Amount");
	
	y = Clockwork:DrawInfo(Clockwork.option:GetKey("name_cash"), x, y, colorTargetID, alpha);
	y = Clockwork:DrawInfo(FORMAT_CASH(amount), x, y, colorWhite, alpha);
end;

-- Called when the entity should draw.
function ENT:Draw()
	if (Clockwork.plugin:Call("CashEntityDraw", self) != false) then
		self:DrawModel();
	end;
end;