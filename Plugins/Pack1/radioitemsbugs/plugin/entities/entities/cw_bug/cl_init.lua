include("shared.lua");

local glowMaterial = Material("sprites/glow04_noz");

-- Called when the target ID HUD should be painted.
function ENT:HUDPaintTargetID(x, y, alpha)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	local frequency = self:GetFrequency();
	local channelTable = Clockwork.radio:FindByID(frequency);
	
	y = Clockwork.kernel:DrawInfo("Civil Protection Audio Monitor", x, y, colorTargetID, alpha);
	
	--[[if (!channelTable and Schema:PlayerIsCombine(LocalPlayer())) then
		y = Clockwork.kernel:DrawInfo("This bug has been disabled.", x, y, colorWhite, alpha);
	else
		y = Clockwork.kernel:DrawInfo("Listening.");
	end;]]
end;

--[[
function ENT:Draw()
	self:DrawModel();
	
	local r, g, b, a = self:GetColor();
	local glowColor = Color(0, 255, 0, a);
	local position = self:GetPos();
	local forward = self:GetForward() * 9;
	local right = self:GetRight() * 5;
	local up = self:GetUp() * 8;
	
	if (self:IsOff()) then
		glowColor = Color(255, 0, 0, a);
	end;
	
	cam.Start3D( EyePos(), EyeAngles() );
		render.SetMaterial(glowMaterial);
		render.DrawSprite(position + forward + right + up, 16, 16, glowColor);
	cam.End3D();
end;]]