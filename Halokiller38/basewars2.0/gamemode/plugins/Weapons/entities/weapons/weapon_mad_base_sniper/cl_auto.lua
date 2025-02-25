

SWEP.PrintName			= "Mad Cows Weapon Sniper Base"		// 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 3							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot

/*---------------------------------------------------------
   Name: SWEP:DrawHUD()
---------------------------------------------------------*/
local iScreenWidth 	= surface.ScreenWidth()
local iScreenHeight 	= surface.ScreenHeight()

local SCOPEFADE_TIME = 0.4

SWEP.crosshairAngle = 120; -- Degrees
SWEP.crosshairMul = 0;
function SWEP:DrawHUD()

	self:SecondDrawHUD()
	self:DrawFuelHUD()

	if (self.Sniper) then

		local bScope = self.Weapon:GetDTBool(2)

		if bScope ~= self.bLastScope then // Are we turning the scope off/on?
			self.bLastScope = bScope
			self.fScopeTime = CurTime()
		elseif bScope then
			local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")

			if fScopeZoom ~= self.fLastScopeZoom then // Are we changing the scope zoom level?
		
				self.fLastScopeZoom = fScopeZoom
				self.fScopeTime = CurTime()
			end
		end
			
		local fScopeTime = self.fScopeTime or 0

		if fScopeTime > CurTime() - SCOPEFADE_TIME then
		
			local Mul = 1.0 -- This scales the alpha
			Mul = 1 - math.Clamp((CurTime() - fScopeTime) / SCOPEFADE_TIME, 0, 1)
		
			surface.SetDrawColor(0, 0, 0, 255 * Mul) // Draw a black rect over everything and scale the alpha for a neat fadein effect
			surface.DrawRect(0, 0, iScreenWidth,iScreenHeight)
		end

		if (bScope) then 
	
			// Draw the crosshair
			if not (self.RedDot) then
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawLine(self.CrossHairTable.x11, self.CrossHairTable.y11, self.CrossHairTable.x12, self.CrossHairTable.y12)
				surface.DrawLine(self.CrossHairTable.x21, self.CrossHairTable.y21, self.CrossHairTable.x22, self.CrossHairTable.y22)
			end

			// Put the texture
			surface.SetDrawColor(0, 0, 0, 255)

			if (self.RedDot) then
				surface.SetTexture(surface.GetTextureID("scope/scope_reddot"))
			else
				surface.SetTexture(surface.GetTextureID("scope/scope_normal"))
			end

			surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)

			// Fill in everything else
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(self.QuadTable.x1 - 2.5, self.QuadTable.y1 - 2.5, self.QuadTable.w1 + 5, self.QuadTable.h1 + 5)
			surface.DrawRect(self.QuadTable.x2 - 2.5, self.QuadTable.y2 - 2.5, self.QuadTable.w2 + 5, self.QuadTable.h2 + 5)
			surface.DrawRect(self.QuadTable.x3 - 2.5, self.QuadTable.y3 - 2.5, self.QuadTable.w3 + 5, self.QuadTable.h3 + 5)
			surface.DrawRect(self.QuadTable.x4 - 2.5, self.QuadTable.y4 - 2.5, self.QuadTable.w4 + 5, self.QuadTable.h4 + 5)
		end
	end

	if (self.Weapon:GetDTBool(1) and not self.Weapon:GetNetworkedBool("Suppressor")) or (cl_crosshair_t:GetBool() == false) or (LocalPlayer():InVehicle()) then return end
	
	if self.Primary.Cone < 0.005 then
		self.Primary.Cone = 0.005
	end
	
	local origin = LocalPlayer():GetEyeTraceNoCursor().HitPos:ToScreen();
	local distance = ((self.Primary.Cone * 275) + (((self.Primary.Cone * 275) * (ScrH() / 720))) * (1 / self:CrosshairAccuracy())) * 1.5;
	distance = math.Clamp(distance, 0, (ScrH() / 2) - 100);
	
	if (self.reloadUntil and CurTime() <= self.reloadUntil) then
		if (self.crosshairMul >= 120) then
			self.crosshairMul = 0;
		end;
		self.crosshairMul = self.crosshairMul + FrameTime() * 150;
	else
		self.crosshairMul = math.Approach(self.crosshairMul, 120, FrameTime() * 150);
	end;
	
	for i = self.crosshairAngle / 2, 360 - self.crosshairAngle / 2, self.crosshairAngle do
		local addX = math.sin(math.rad(i + self.crosshairMul)) * distance;
		local addY = math.cos(math.rad(i + self.crosshairMul)) * distance;
		
		surface.SetDrawColor(0, 0, 0, 255);
		surface.DrawRect(origin.x + addX - 3, origin.y + addY - 3, 6, 6);
		surface.SetDrawColor(255, 255, 255, 255);
		surface.DrawRect(origin.x + addX - 2, origin.y + addY - 2, 4, 4);
	end;
end

/*---------------------------------------------------------
   Name: SWEP:TranslateFOV()
---------------------------------------------------------*/
local IRONSIGHT_TIME = 0.2

function SWEP:TranslateFOV(current_fov)

	local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")

	if self.Weapon:GetDTBool(2) then return current_fov / fScopeZoom end
	
	local bIron = self.Weapon:GetDTBool(1)

	if bIron ~= self.bLastIron then // Do the same thing as in CalcViewModel. I don't know why this works, but it does.
		self.bLastIron = bIron 
		self.fIronTime = CurTime()
	end
	
	local fIronTime = self.fIronTime or 0

	if not bIron and (fIronTime < CurTime() - IRONSIGHT_TIME) then 
		return current_fov
	end
	
	local Mul = 1.0 // More interpolating shit
	
	if fIronTime > CurTime() - IRONSIGHT_TIME then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
		if not bIron then Mul = 1 - Mul end
	end

	current_fov = current_fov*(1 + Mul/self.IronSightZoom - Mul)

	return current_fov
end

/*---------------------------------------------------------
   Name: SWEP:GetTracerOrigin()
   Desc: Allows you to override where the tracer comes from (in first person view)
	   returning anything but a vector indicates that you want the default action.
---------------------------------------------------------*/
function SWEP:GetTracerOrigin()

	if (self.Weapon:GetDTBool(1)) then
		local pos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Up() * -5
		return pos
	end
end

/*---------------------------------------------------------
   Name: SniperCreateMove()
---------------------------------------------------------*/
local staggerdir = VectorRand():Normalize()

local function SniperCreateMove(cmd)

	if (LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetDTBool(2)) then
		local ang = cmd:GetViewAngles()

		local ft = FrameTime()

		ang.pitch = math.NormalizeAngle(ang.pitch + staggerdir.z * ft * 1)
		ang.yaw = math.NormalizeAngle(ang.yaw + staggerdir.x * ft * 1)

		staggerdir = (staggerdir + ft * 10 * VectorRand()):Normalize()

		cmd:SetViewAngles(ang)	
	end
end
hook.Add ("CreateMove", "SniperCreateMove", SniperCreateMove)