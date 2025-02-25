--[[
Name: "shared.lua".
Product: "Nexus".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
	SWEP.ActivityTranslate = {
		[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST,
		[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_FIST,
		[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_FIST,
		[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_FIST,
		[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK1,
		[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_FIST,
		[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_FIST,
		[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_FIST,
		[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_FIST
	};
end;

if (CLIENT) then
	SWEP.Slot = 5;
	SWEP.SlotPos = 2;
	SWEP.DrawAmmo = false;
	SWEP.PrintName = "Keys";
	SWEP.DrawCrosshair = true;
end

SWEP.Instructions = "Primary Fire: Lock.\nSecondary Fire: Unlock.";
SWEP.Contact = "";
SWEP.Purpose = "Locking and unlocking entities that you have access to.";
SWEP.Author	= "kuropixel";

SWEP.WorldModel = "models/weapons/w_fists_t.mdl";
SWEP.ViewModel = "models/weapons/v_punch.mdl";
SWEP.HoldType = "fist";

SWEP.AdminSpawnable = false;
SWEP.Spawnable = false;
  
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = true;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.Damage = 1;
SWEP.Primary.Ammo = "";

SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.Ammo	= "";

SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;
SWEP.LoweredAngles = Angle(60, 60, 60);
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NeverRaised = true;

-- Called when the SWEP is deployed.
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW);
end;

-- Called when the SWEP is holstered.
function SWEP:Holster(switchingTo)
	self:SendWeaponAnim(ACT_VM_HOLSTER);
	
	return true;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1);
	
	if (SERVER) then
		local action = nexus.player.GetAction(self.Owner);
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetPos():Distance(trace.HitPos) <= 192) then
			if ( IsValid(trace.Entity) ) then
				local info = nexus.mount.Call("PlayerGetLockInfo", self.Owner, trace.Entity);
				
				if ( info and nexus.mount.Call("PlayerCanLockEntity", self.Owner, trace.Entity) ) then
					local isNotUnlocking = (action != "unlock");
					local isNotLocking = (action != "lock");
					
					if (isNotLocking or isNotUnlocking) then
						local target = trace.Entity;
						local player = self.Owner;
						
						nexus.player.SetAction(player, "lock", info.duration);
						
						nexus.player.EntityConditionTimer(player, target, nil, info.duration, 192, function()
							if ( !nexus.mount.Call("PlayerCanLockEntity", player, target) ) then
								return false;
							else
								return player:Alive() and !player:IsRagdolled() and player:IsUsingKeys();
							end;
						end, function(success)
							if (success) then
								info.Callback(player, target);
								
								if (!info.noSound) then
									self.Owner:EmitSound("doors/door_latch3.wav");
								end;
							else
								nexus.player.SetAction(player, "lock", false);
							end;
						end);
					end;
				end;
			end;
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 1);
	
	if (SERVER) then
		local action = nexus.player.GetAction(self.Owner);
		local trace = self.Owner:GetEyeTraceNoCursor();
		
		if (self.Owner:GetPos():Distance(trace.HitPos) <= 192) then
			if ( IsValid(trace.Entity) ) then
				local info = nexus.mount.Call("PlayerGetUnlockInfo", self.Owner, trace.Entity);
				
				if ( info and nexus.mount.Call("PlayerCanUnlockEntity", self.Owner, trace.Entity) ) then
					local isNotUnlocking = (action != "unlock");
					local isNotLocking = (action != "lock");
					
					if (isNotLocking or isNotUnlocking) then
						local target = trace.Entity;
						local player = self.Owner;
						
						nexus.player.SetAction(player, "unlock", info.duration);
						
						nexus.player.EntityConditionTimer(player, target, nil, info.duration, 192, function()
							if ( !nexus.mount.Call("PlayerCanUnlockEntity", player, target) ) then
								return false;
							else
								return player:Alive() and !player:IsRagdolled() and player:IsUsingKeys();
							end;
						end, function(success)
							if (success) then
								info.Callback(player, target);
								
								if (!info.noSound) then
									self.Owner:EmitSound("doors/door_latch3.wav");
								end;
							else
								nexus.player.SetAction(player, "unlock", false);
							end;
						end);
					end;
				end;
			end;
		end;
	end;
end;