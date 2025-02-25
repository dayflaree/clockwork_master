AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "CWU Vending Machine"
ENT.Author = "Fruitman"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.PhysgunAllowAdmin = true

function ENT:SpawnFunction(client, trace)
	local entity = ents.Create("cwu_vend")
	entity:SetPos(trace.HitPos + Vector(0, 0, 48))

	local angles = (entity:GetPos() - client:GetPos()):Angle()
	angles.p = 0
	angles.y = math.Round(angles.y / 45) * 45 + 180
	angles.r = 0

	entity:SetAngles(angles)
	entity:Spawn()
	entity:Activate()

	for k, v in pairs(ents.FindInBox(entity:LocalToWorld(entity:OBBMins()), entity:LocalToWorld(entity:OBBMaxs()))) do
		if (string.find(v:GetClass(), "prop") and v:GetModel() == "models/fruit_cwuvendor/vendingmachinesoda01a.mdl") then
			entity:SetPos(v:GetPos())
			entity:SetAngles(v:GetAngles())
			SafeRemoveEntity(v)

			break
		end
	end

	return entity
end

function ENT:GetNearestButton(client)
	client = client or (CLIENT and LocalPlayer())

	if (self.buttons) then
		if (SERVER) then
			local position = self:GetPos()
			local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

			self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
			self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
			self.buttons[3] = position + f*18 + r*-24.4 + u*1.35
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)
		local hitPos = trace.HitPos

		if (hitPos) then
			for k, v in pairs(self.buttons) do
				if (v:Distance(hitPos) <= 2) then
					return k
				end
			end
		end
	end
end

if (SERVER) then
	function ENT:Initialize()
		self.buttons = {}

		local position = self:GetPos()
		local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

		self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
		self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
		self.buttons[3] = position + f*18 + r*-24.4 + u*1.35

		self:SetModel("models/fruit_cwuvendor/vendingmachinesoda01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		--self:SetSharedVar("stocks", {10, 5, 5})
		self:SetDTFloat(1, 10);
		self:SetDTFloat(2, 5);
		self:SetDTFloat(3, 5);
		--self:SetSharedVar("active", true)
		self:SetDTBool(0, true);
		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		for k, v in pairs(ents.FindInBox(self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()))) do
			if (string.find(v:GetClass(), "prop") and v:GetModel() == "models/fruit_cwuvendor/vendingmachinesoda01a.mdl") then
				self:SetPos(v:GetPos())
				self:SetAngles(v:GetAngles())
				SafeRemoveEntity(v)

				return
			end
		end
	end

	function ENT:Use(activator)
		activator:EmitSound("buttons/lightswitch2.wav", 55, 125)

		if ((self.nextUse or 0) < CurTime()) then
			self.nextUse = CurTime() + 2
		else
			return
		end

		local button = self:GetNearestButton(activator)
		--local stocks = self:GetSharedVar("stocks")

		if (Schema:PlayerIsCombine(activator) or activator:GetFaction() == FACTION_CWU) then
			if (activator:KeyDown(IN_SPEED) and button and self:GetDTFloat(button)) then
				if (self:GetDTFloat(button) > 0) then
					--return activator:SendOverlayText("NO REFILL IS REQUIRED FOR THIS MACHINE.")
					Clockwork.player:Notify(activator, "No refill is required for this machine.")
				end

				self:EmitSound("buttons/button5.wav")

				if (!Clockwork.player:CanAfford(activator, 25)) then
					--return activator:SendOverlayText("INSUFFICIENT FUNDS (25 TOKENS) TO REFILL MACHINE.")
					return Clockwork.player:Notify(activator, "You need 25 Tokens to restock this machine.")
				else
					--activator:SendOverlayText("25 TOKENS HAVE BEEN TAKEN TO REFILL MACHINE.")
					Clockwork.player:GiveCash(activator, -25, "restocking vending machine");
				end

				timer.Simple(1, function()
					if (!IsValid(self)) then return end

					self:SetDTFloat(button, (button == 1 and 10 or 5));
					--self:SetSharedVar("stocks", stocks)
				end)

				return
			else
				--self:SetSharedVar("active", !self:GetSharedVar("active"))
				self:SetDTBool(0, !self:GetDTBool(0))
				self:EmitSound("buttons/combine_button1.wav" or "buttons/combine_button2.wav")

				return
			end
		end

		if (self:GetDTBool(0) == false) then
			return
		end

		if (button and self:GetDTFloat(button) and self:GetDTFloat(button) > 0) then
			local item = "uu_bandage"
			local price = 30

			if (button == 2) then
				item = "paracetamol"
				price = price + 20
			elseif (button == 3) then
				item = "cough_syrup"
				price = price + 20 
			end

			if (!Clockwork.player:CanAfford(activator, price)) then
				self:EmitSound("buttons/button2.wav")
				return Clockwork.player:Notify(activator, "You need "..tostring(price).." Tokens to purchase this selection.")
			end

			local position = self:GetPos()
			local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()
			local itemPosition = position + f*19 + r*4 + u*-26
			--local entity = cwu.item.Spawn(itemPosition, nil, item)
			local entity = Clockwork.entity:CreateItem(activator, Clockwork.item:CreateInstance(item), itemPosition, self:GetAngles());

			if (IsValid(entity)) then
				self:SetDTFloat(button, self:GetDTFloat(button) - 1);

				if (self:GetDTFloat(button) < 1) then
					self:EmitSound("buttons/button6.wav")
				end

				self:EmitSound("buttons/button4.wav", Angle(0, 0, 90))

				Clockwork.player:GiveCash(activator, -price, "vending machine");
			end
		end
	end
else
	local draw_SimpleText = draw.SimpleText
	local glowMaterial = Material("sprites/glow04_noz")

	local color_green = Color(0, 255, 0, 255)
	local color_red = Color(255, 0, 0, 255)
	local color_orange = Color(255, 125, 0, 255)

	function ENT:Initialize()
		self.buttons = {}

		local position = self:GetPos()
		local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

		self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
		self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
		self.buttons[3] = position + f*18 + r*-24.4 + u*1.35
	end

	function ENT:Draw()
		self:DrawModel()

		local position = self:GetPos()
		local angles = self:GetAngles()
		angles:RotateAroundAxis(angles:Up(), 90)
		angles:RotateAroundAxis(angles:Forward(), 90)

		local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

		cam.Start3D2D(position + f*17.80 + r*-19.5 + u*5.75, angles, 0.06)
			draw_SimpleText("BAND", "hl2_MainText", 0, 0, Color(240, 240, 240, alpha))
			draw_SimpleText("PCM", "hl2_MainText", 0, 30, Color(240, 240, 240, alpha))
			draw_SimpleText("SYRUP", "hl2_MainText", 0, 63, Color(240, 240, 240, alpha))
		cam.End3D2D()
	

		render.SetMaterial(glowMaterial)

		if (self.buttons) then
			local position = self:GetPos()
			local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

			self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
			self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
			self.buttons[3] = position + f*18 + r*-24.4 + u*1.35

			local closest = self:GetNearestButton()
			--local stocks = self:GetSharedVar("stocks")

			for k, v in pairs(self.buttons) do
				local color = color_green

				if (self:GetDTBool(0) != false) then
					if (self:GetDTFloat(k) and self:GetDTFloat(k) < 1) then
						color = color_red
						color.a = 200
					end

					if (closest != k) then
						color.a = color == color_red and 100 or 75
					else
						color.a = 230 + (math.sin(RealTime() * 7.5) * 25)
					end

					if (LocalPlayer():KeyDown(IN_USE) and closest == k) then
						color = table.Copy(color)
						color.r = math.min(color.r + 100, 255)
						color.g = math.min(color.g + 100, 255)
						color.b = math.min(color.b + 100, 255)
					end
				else
					color = color_orange
				end

				render.DrawSprite(v, 4, 4, color)
			end
		end
	end
end
