--[[
	Free Clockwork!
--]]

Clockwork:IncludePrefixed("shared.lua")

local glowMaterial = Material("sprites/glow04_noz");

-- Called when the entity should draw.
function ENT:Draw()
	self:DrawModel();
	
	local smokeChargeTime = self:GetDTFloat("smokeCharge");
	local r, g, b, a = self:GetColor();
	local flashTime = self:GetDTFloat("flash");
	local position = self:GetPos();
	local forward = self:GetForward() * -4;
	local curTime = CurTime();
	local right = self:GetRight() * -6;
	local up = self:GetUp() * -8;
	
	if (self:GetDTBool("SetRed")) then
		cam.Start3D( EyePos(), EyeAngles() );
			render.SetMaterial(glowMaterial);
			render.DrawSprite(position + forward + right + up, 5, 5, Color(255, 0, 0, a));
		cam.End3D();
		
	elseif (self:IsLocked()) then
		cam.Start3D( EyePos(), EyeAngles() );
			render.SetMaterial(glowMaterial);
			render.DrawSprite(position + forward + right + up, 5, 5, Color(255, 150, 0, a));
		cam.End3D();
	
	elseif (smokeChargeTime > curTime) then
		local glowColor = Color(255, 0, 0, a);
		local timeLeft = smokeChargeTime - curTime;
		
		if ( !self.nextFlash or curTime >= self.nextFlash or (self.flashUntil and self.flashUntil > curTime) ) then
			cam.Start3D( EyePos(), EyeAngles() );
				render.SetMaterial(glowMaterial);
				render.DrawSprite(position + forward + right + up, 30, 30, glowColor);
				
			cam.End3D();
			
			if (!self.flashUntil or curTime >= self.flashUntil) then
				self.nextFlash = curTime + (timeLeft / 4);
				self.flashUntil = curTime + (FrameTime() * 4);
				
				self:EmitSound("hl1/fvox/beep.wav");
			end;
		end;
	end;
end;