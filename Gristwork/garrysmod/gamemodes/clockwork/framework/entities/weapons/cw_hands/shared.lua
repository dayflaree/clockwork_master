
if (SERVER) then
	AddCSLuaFile("shared.lua");
end;

if (CLIENT) then
	SWEP.Slot = 5;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Hands";
	SWEP.DrawCrosshair = true;
end;

SWEP.Author = "robotboy655 & MaxOfS2D";
SWEP.Purpose = "Punching characters and knocking on doors.";
SWEP.Instructions = "Primary Fire: Punch.\nSecondary Fire: Knock.";

SWEP.Spawnable = false;
SWEP.UseHands = true;

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl";
SWEP.WorldModel = "";

SWEP.ViewModelFOV = 52;

SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Damage = 6;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo = "none";

SWEP.Secondary.NeverRaised = true;
SWEP.Secondary.ClipSize	= -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	 = "none";

SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;

SWEP.Slot = 0;
SWEP.SlotPos = 5;
SWEP.DrawAmmo = false;
SWEP.DrawCrosshair = true;

SWEP.LoweredAngles = Angle(60, 60, 60);
SWEP.AttackAnims = {"fists_left", "fists_right", "fists_uppercut"};

-- Called when the weapon entity is created.
function SWEP:Initialize()
	self:SetWeaponHoldType("fist");
end;

-- Called after view model is drawn.
function SWEP:PreDrawViewModel(viewModel, weapon, player )
	viewModel:SetMaterial("engine/occlusionproxy");
end;

-- A function to punch an entity.
function SWEP:PunchEntity()
	local bounds = Vector(0, 0, 0);
	local startPosition = self.Owner:GetShootPos();
	local finishPosition = startPosition + (self.Owner:GetAimVector() * 64);
	local traceLineAttack = util.TraceLine({
		start = startPosition,
		endpos = finishPosition,
		filter = self.Owner
	});
	
	self.Weapon:EmitSound("weapons/crossbow/hitbod2.wav", 25);
	
	if (SERVER) then
		self.Weapon:CallOnClient("PunchEntity", "");
		
		if (IsValid(traceLineAttack.Entity)) then
			traceLineAttack.Entity:TakeDamageInfo(
				Clockwork.kernel:FakeDamageInfo(self.Primary.Damage, self, self.Owner, traceLineAttack.HitPos, DMG_CLUB, 1)
			);
		end;
	end;
end;

-- A function to play the knock sound.
function SWEP:PlayKnockSound()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayKnockSound", "");
	end;
	
	self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav");
end;

-- A function to play the punch animation.
function SWEP:PlayPunchAnimation()
	if (SERVER) then
		self.Weapon:CallOnClient("PlayPunchAnimation", "");
	end;
	
	self.Owner:EmitSound("npc/vort/claw_swing2.wav");
	self.Owner:SetAnimation(PLAYER_ATTACK1);
end;

-- Called when primary attack button is pressed.
function SWEP:PrimaryAttack()
	if (!SERVER) then
		return;
	end;

	local viewModel = self.Owner:GetViewModel();

	viewModel:ResetSequence(
		viewModel:LookupSequence("fists_idle_01")
	);

	if (Clockwork.plugin:Call("PlayerCanThrowPunch", self.Owner)) then
		self:PlayPunchAnimation();
			
		local trace = self.Owner:GetEyeTraceNoCursor();
			
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
			if (IsValid(trace.Entity)) then
				if (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") then
					if (trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 10
					and Clockwork.plugin:Call("PlayerCanPunchKnockout", self.Owner, trace.Entity)) then
						Clockwork.player:SetRagdollState(trace.Entity, RAGDOLL_KNOCKEDOUT, 15);
						Clockwork.plugin:Call("PlayerPunchKnockout", self.Owner, trace.Entity);
					elseif (Clockwork.plugin:Call("PlayerCanPunchEntity", self.Owner, trace.Entity)) then
						self:PunchEntity();
						Clockwork.plugin:Call("PlayerPunchEntity", self.Owner, trace.Entity);
					end;
						
					if (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
						local normal = trace.Entity:GetPos() - self.Owner:GetPos();
							normal:Normalize();
						local push = 128 * normal;
							
						trace.Entity:SetVelocity(push);
					end;
				elseif (IsValid(trace.Entity:GetPhysicsObject())) then
					if (Clockwork.plugin:Call("PlayerCanPunchEntity", self.Owner, trace.Entity)) then
						self:PunchEntity();
							
						Clockwork.plugin:Call("PlayerPunchEntity", self.Owner, trace.Entity);
					end;
				elseif (trace.Hit) then
					self:PunchEntity();
				end;
			elseif (trace.Hit) then
				self:PunchEntity();
			end;
		end;
			
		Clockwork.plugin:Call("PlayerPunchThrown", self.Owner);
			
		local info = {
			primaryFire = 0.9,
			secondaryFire = 0.5
		};
			
		Clockwork.plugin:Call("PlayerAdjustNextPunchInfo", self.Owner, info);

		local curTime = CurTime();
		local animationName = self.AttackAnims[math.random(1, #self.AttackAnims)];

		timer.Simple(0, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then 
				return;
			end;
		
			local viewModel = self.Owner:GetViewModel();

			viewModel:ResetSequence(
				viewModel:LookupSequence(animationName)
			);

			self:Idle();
		end);

		timer.Simple( 0.05, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then
				return;
			end;

			if (animationName == "fists_left") then
				self.Owner:ViewPunch(
					Angle( 0, 16, 0)
				);
			elseif (animationName == "fists_right") then
				self.Owner:ViewPunch(
					Angle( 0, -16, 0)
				);
			elseif (animationName == "fists_uppercut") then
				self.Owner:ViewPunch(
					Angle( 16, -8, 0)
				);
			end;
		end);

		timer.Simple(0.2, function()
			if (!IsValid(self) or !IsValid(self.Owner) or !self.Owner:GetActiveWeapon() or self.Owner:GetActiveWeapon() != self) then
				return;
			end;

			if (animationName == "fists_left") then
				self.Owner:ViewPunch(
					Angle(4, -16, 0) 
				);
			elseif (animationName == "fists_right") then
				self.Owner:ViewPunch(
					Angle(4, 16, 0)
				);
			elseif (animationName == "fists_uppercut") then
				self.Owner:ViewPunch(
					Angle(-32, 0, 0)
				);
			end;
		end);
			
		self.Weapon:SetNextPrimaryFire(curTime + info.primaryFire);
		self.Weapon:SetNextSecondaryFire(curTime + info.secondaryFire);
	end;
end;

-- Called when secondary attack button is pressed.
function SWEP:SecondaryAttack()
	if (!SERVER) then
		return;
	end;

	local trace = self.Owner:GetEyeTraceNoCursor();
		
	if (IsValid(trace.Entity) and Clockwork.entity:IsDoor(trace.Entity)) then
		if (self.Owner:GetShootPos():Distance(trace.HitPos) <= 64) then
			if (Clockwork.plugin:Call("PlayerCanKnockOnDoor", self.Owner, trace.Entity)) then
				local curTime = CurTime();

				self:PlayKnockSound();
					
				self.Weapon:SetNextPrimaryFire(curTime + 0.25);
				self.Weapon:SetNextSecondaryFire(curTime + 0.25);
					
				Clockwork.plugin:Call("PlayerKnockOnDoor", self.Owner, trace.Entity);
			end;
		end;
	end;
end;

-- A function to set the weapon as idle.
function SWEP:Idle()
	local viewModel = self.Owner:GetViewModel();

	timer.Create("fists_idle"..self:EntIndex(), viewModel:SequenceDuration(), 1, function()
		viewModel:ResetSequence(
			viewModel:LookupSequence("fists_idle_0"..math.random(1, 2))
		);
	end);
end;

-- Called when the swep is about to be removed.
function SWEP:OnRemove()
	if (IsValid(self.Owner)) then
		local viewModel = self.Owner:GetViewModel();

		if (IsValid(viewModel)) then
			viewModel:SetMaterial("");
		end;
	end;

	timer.Stop("fists_idle"..self:EntIndex());
end;

-- Called when weapon tries to holster.
function SWEP:Holster(weapon)
	self:OnRemove()

	return true;
end;

-- Called when player has just switched to this weapon.
function SWEP:Deploy()
	local viewModel = self.Owner:GetViewModel();

	viewModel:ResetSequence(
		viewModel:LookupSequence("fists_draw")
	);

	self:Idle();

	return true;
end;
