--[[
Name: "sv_auto.lua".
Product: "Half-Life 2".
--]]

RESISTANCE:IncludePrefixed("sh_auto.lua");

AddCSLuaFile("cl_auto.lua");
AddCSLuaFile("sh_auto.lua");

-- Called when the entity initializes.
function ENT:Initialize()
	self:SharedInitialize();
	
	self:SetModel("models/props_junk/watermelon01.mdl");
	
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	
	self.dispenser = ents.Create("prop_dynamic");
	self.dispenser:DrawShadow(false);
	self.dispenser:SetAngles( self:GetAngles() );
	self.dispenser:SetParent(self);
	self.dispenser:SetModel("models/props_combine/combine_dispenser.mdl");
	self.dispenser:SetPos( self:GetPos() );
	self.dispenser:Spawn();
	
	self:DeleteOnRemove(self.dispenser);
	
	local minimum = Vector(-8, -8, -8);
	local maximum = Vector(8, 8, 64);
	
	self:SetCollisionBounds(minimum, maximum);
	self:SetCollisionGroup(COLLISION_GROUP_WORLD);
	self:PhysicsInitBox(minimum, maximum);
	self:DrawShadow(false);
end;

-- Called when the entity's transmit state should be updated.
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS;
end;

-- A function to get whether the entity is locked.
function ENT:IsLocked()
	return self:GetSharedVar("sh_Locked");
end;

-- A function to toggle whether the entity is locked.
function ENT:Toggle()
	if ( self:IsLocked() ) then
		self:Unlock();
	else
		self:Lock();
	end;
end;

-- A function to lock the entity.
function ENT:Lock()
	self:SetSharedVar("sh_Locked", true);
	
	self:EmitRandomSound();
end;

-- A function to unlock the entity.
function ENT:Unlock()
	self:SetSharedVar("sh_Locked", false);
	
	self:EmitRandomSound();
end;

-- A function to set the entity's flash duration.
function ENT:SetFlashDuration(duration)
	self:EmitSound("buttons/combine_button_locked.wav");
	self:SetSharedVar("sh_Flash", CurTime() + duration);
end;

-- A function to create a dummy ration.
function ENT:CreateDummyRation()
	local forward = self:GetForward() * 15;
	local right = self:GetRight() * 0;
	local up = self:GetUp() * -8;
	
	local entity = ents.Create("prop_physics");
	
	entity:SetAngles( self:GetAngles() );
	entity:SetModel("models/weapons/w_package.mdl");
	entity:SetPos(self:GetPos() + forward + right + up);
	entity:Spawn();
	
	return entity;
end;

-- A function to activate the entity's ration.
function ENT:ActivateRation(activator, duration, force)
	local curTime = CurTime();
	
	if (!duration) then duration = 24; end;
	
	if (force or !self.nextActivateRation or curTime >= self.nextActivateRation) then
		self.nextActivateRation = curTime + duration + 2;
		
		self:SetSharedVar("sh_Ration", curTime + duration);
		
		RESISTANCE:CreateTimer("Ration: "..self:EntIndex(), duration, 1, function()
			if ( IsValid(self) ) then
				if ( !IsValid(activator) ) then
					activator = nil;
				end;
				
				local frameTime = FrameTime() * 0.5;
				local dispenser = self.dispenser;
				local entity = self:CreateDummyRation();
				
				if ( IsValid(entity) ) then
					dispenser:EmitSound("ambient/machines/combine_terminal_idle4.wav");
					
					entity:SetNotSolid(true);
					entity:SetParent(dispenser);
					
					timer.Simple(frameTime, function()
						if ( IsValid(self) and IsValid(entity) ) then
							entity:Fire("SetParentAttachment", "package_attachment", 0);
							
							timer.Simple(frameTime, function()
								if ( IsValid(self) and IsValid(entity) ) then
									dispenser:Fire("SetAnimation", "dispense_package", 0);
									
									timer.Simple(1.75, function()
										if ( IsValid(self) and IsValid(entity) ) then
											entity:CallOnRemove("CreateRation", function()
												if ( IsValid(entity) ) then
													resistance.entity.CreateItem( activator, "ration", entity:GetPos(), entity:GetAngles() );
												end;
											end);
											
											if (IsValid(activator) and !force) then
												if (activator:GetCharacterData("customclass") == "Civil Worker's Union") then
													self:ActivateRation(activator, 8, true);
												end;
											end;
											
											entity:SetNoDraw(true);
											entity:Remove();
										end;
									end);
								end;
							end);
						end;
					end);
				end;
			end;
		end);
	end;
end;

-- A function to emit a random sound from the entity.
function ENT:EmitRandomSound()
	local randomSounds = {
		"buttons/combine_button1.wav",
		"buttons/combine_button2.wav",
		"buttons/combine_button3.wav",
		"buttons/combine_button5.wav",
		"buttons/combine_button7.wav"
	};
	
	self:EmitSound( randomSounds[ math.random(1, #randomSounds) ] );
end;

-- Called when the entity's physics should be updated.
function ENT:PhysicsUpdate(physicsObject)
	if ( !self:IsPlayerHolding() and !self:IsConstrained() ) then
		physicsObject:SetVelocity( Vector(0, 0, 0) );
		physicsObject:Sleep();
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if (activator:IsPlayer() and activator:GetEyeTraceNoCursor().Entity == self) then
		local curTime = CurTime();
		local unixTime = os.time();
		
		if (!self.nextUse or curTime >= self.nextUse) then
			if (activator:QueryCharacter("faction") == FACTION_CITIZEN) then
				if ( !self:IsLocked() and unixTime >= activator:GetCharacterData("nextration", 0) ) then
					if (!self.nextActivateRation or curTime >= self.nextActivateRation) then
						self:ActivateRation(activator);
						
						activator:SetCharacterData("nextration", unixTime + resistance.config.Get("wages_interval"):Get() * 10);
					end;
				else
					self:SetFlashDuration(3);
				end;
			elseif (!self.nextActivateRation or curTime >= self.nextActivateRation) then
				self:Toggle();
			end;
			
			self.nextUse = curTime + 3;
		end;
	end;
end;

-- Called when a player attempts to use a tool.
function ENT:CanTool(player, trace, tool)
	return false;
end;