--[[
Name: "sh_auto.lua".
Product: "eXperim3nt".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_coms.lua");
NEXUS:IncludePrefixed("sv_hooks.lua");
NEXUS:IncludePrefixed("cl_hooks.lua");

ThirdPerson = {}

if CLIENT then

	CreateClientConVar("~wstp_bob", 1, true, false)
	CreateClientConVar("~wstp_bobscale", 0.5, true, false)
	CreateClientConVar("~wstp_back", 20, true, false)
	CreateClientConVar("~wstp_right", 25, true, false)
	CreateClientConVar("~wstp_up", 0, true, false)
	CreateClientConVar("~wstp_smooth", 1, true, false)
	CreateClientConVar("~wstp_smoothscale", 0.2, true, false)

	function ThirdPerson.CalcView(player, pos, angles, fov)
		local smooth = GetConVarNumber("~wstp_smooth")
		local smoothscale = GetConVarNumber("~wstp_smoothscale")
		if player:GetNetworkedInt("thirdperson") == 1 then
			angles = player:GetAimVector():Angle()

			local targetpos = Vector(0, 0, 60)
			if player:KeyDown(IN_DUCK) then
				if player:GetVelocity():Length() > 0 then
					targetpos.z = 50
				else
					targetpos.z = 40
				end
			end

			player:SetAngles(angles)
			local targetfov = fov
			if player:GetVelocity():DotProduct(player:GetForward()) > 10 then
				if player:KeyDown(IN_SPEED) then
					targetpos = targetpos + player:GetForward() * -10
					if GetConVarNumber("~wstp_bob") != 0 and player:OnGround() then
						angles.pitch = angles.pitch + GetConVarNumber("~wstp_bobscale") * math.sin(CurTime() * 10)
						angles.roll = angles.roll + GetConVarNumber("~wstp_bobscale") * math.cos(CurTime() * 10)
						targetfov = targetfov + 3
					end
				else
					targetpos = targetpos + player:GetForward() * -5
				end
			end 
			// tween to the target position
			pos = player:GetVar("thirdperson_pos") or targetpos
			if smooth != 0 then
				pos.x = math.Approach(pos.x, targetpos.x, math.abs(targetpos.x - pos.x) * smoothscale)
				pos.y = math.Approach(pos.y, targetpos.y, math.abs(targetpos.y - pos.y) * smoothscale)
				pos.z = math.Approach(pos.z, targetpos.z, math.abs(targetpos.z - pos.z) * smoothscale)
			else
				pos = targetpos
			end
			player:SetVar("thirdperson_pos", pos)

			// offset it by the stored amounts, but trace so it stays outside walls
			// we don't tween this so the camera feels like its tightly following the mouse
			local offset = Vector(5, 5, 5)
			if player:GetVar("thirdperson_zoom") != 1 then
				offset.x = GetConVarNumber("~wstp_back")
				offset.y = GetConVarNumber("~wstp_right")
				offset.z = GetConVarNumber("~wstp_up")
			end
			local t = {}
			t.start = player:GetPos() + pos
			t.endpos = t.start + angles:Forward() * -offset.x
			t.endpos = t.endpos + angles:Right() * offset.y
			t.endpos = t.endpos + angles:Up() * offset.z
			t.filter = player
			if player:GetScriptedVehicle():IsValid() then
				pos = t.endpos
			else
				local tr = util.TraceLine(t)
				pos = tr.HitPos
				if tr.Fraction < 1.0 then
					pos = pos + tr.HitNormal * 5
				end
			end
			player:SetVar("thirdperson_viewpos", pos)

			// tween the fov
			fov = player:GetVar("thirdperson_fov") or targetfov
			if smooth != 0 then
				fov = math.Approach(fov, targetfov, math.abs(targetfov - fov) * smoothscale)
			else
				fov = targetfov
			end
			player:SetVar("thirdperson_fov", fov)

			return GAMEMODE:CalcView(player, pos, angles, fov)
		end
	end
	hook.Add("CalcView", "ThirdPerson.CalcView", ThirdPerson.CalcView)

	// thanks to termy58's crosshair example
	// ... and thanks to termy58 for finding my stupid bug :P
	function ThirdPerson.HUDPaint()
		local player = LocalPlayer()
		if player:GetNetworkedInt("thirdperson") == 0 then
			return
		end
		
		if (NEXUS.config:Get("thirdperson_crosshair"):Get() ) then
		// trace from muzzle to hit pos
		local t = {}
		t.start = player:GetShootPos()
		t.endpos = t.start + player:GetAimVector() * 9000
		t.filter = player
		local tr = util.TraceLine(t)
		local pos = tr.HitPos:ToScreen()
		local fraction = math.min((tr.HitPos - t.start):Length(), 1024) / 1024
		local size = 10 + 20 * (1.0 - fraction)
		local offset = size * 0.5
		local offset2 = offset - (size * 0.1)

		// trace from camera to hit pos, if blocked, red cursor
		t = {}
		t.start = player:GetVar("thirdperson_viewpos") or player:GetPos()
		t.endpos = tr.HitPos + tr.HitNormal * 5
		t.filter = player
		local tr = util.TraceLine(t)
		if tr.Fraction != 1.0 then
			surface.SetDrawColor(255, 48, 0, 255)
		else
			surface.SetDrawColor(255, 208, 64, 255)
		end
		surface.DrawLine(pos.x - offset, pos.y, pos.x - offset2, pos.y)
		surface.DrawLine(pos.x + offset, pos.y, pos.x + offset2, pos.y)
		surface.DrawLine(pos.x, pos.y - offset, pos.x, pos.y - offset2)
		surface.DrawLine(pos.x, pos.y + offset, pos.x, pos.y + offset2)
		surface.DrawLine(pos.x - 1, pos.y, pos.x + 1, pos.y)
		surface.DrawLine(pos.x, pos.y - 1, pos.x, pos.y + 1)
		end
	end
	hook.Add("HUDPaint", "ThirdPerson.HUDPaint", ThirdPerson.HUDPaint)

	function ThirdPerson.HUDShouldDraw(name)
		if name == "CHudCrosshair" and LocalPlayer():GetNetworkedInt("thirdperson") == 1 then
			return false
		end
	end
	hook.Add("HUDShouldDraw", "ThirdPerson.HUDShouldDraw", ThirdPerson.HUDShouldDraw)

	function ThirdPerson.Zoom(player, command, arguments)
		if player:GetVar("thirdperson_zoom") == 1 then
			player:SetVar("thirdperson_zoom", 0)
		else
			player:SetVar("thirdperson_zoom", 1)
		end
	end
	concommand.Add("~wstp_zoom", ThirdPerson.Zoom)

else 

	function ThirdPerson.Command(player, command, arguments)
		if not arguments[1] then
			if player:GetNetworkedInt("thirdperson") == 1 then
			ThirdPerson.Disable(player)
			else
				ThirdPerson.Enable(player)
			end
		elseif arguments[1] == "1" then
			ThirdPerson.Enable(player)
			self:TakeAnimatedLegs(player);
		elseif arguments[1] == "0" then
			ThirdPerson.Disable(player)
		end
	end
	concommand.Add("ws_thirdperson", ThirdPerson.Command)

	function ThirdPerson.Disable(player)
		if player:GetNetworkedInt("thirdperson") == 0 then
			return
		end
		local entity = player:GetViewEntity()
		player:SetNetworkedInt("thirdperson", 0)
		player:SetViewEntity(player)
		entity:Remove()
	end

	function ThirdPerson.Enable(player)
		if player:GetNetworkedInt("thirdperson") == 1 then
			return
		end
		local entity = ents.Create("prop_dynamic")
		entity:SetModel("models/error.mdl")
		entity:Spawn()
		entity:SetAngles(player:GetAngles())
		entity:SetMoveType(MOVETYPE_NONE)
		entity:SetParent(player)
		entity:SetPos(player:GetPos() + Vector(0, 0, 60))
		entity:SetRenderMode(RENDERMODE_NONE)
		entity:SetSolid(SOLID_NONE)
		entity:DrawShadow( false )
		entity:SetColor( 0, 0, 0, 0 )
		player:SetViewEntity(entity)
		player:SetNetworkedInt("thirdperson", 1)
	end

end

function ThirdPerson.UpdateAnimation(player)
	if player:KeyDown(IN_SPEED) then
		player:SetPlaybackRate(1.5)
	end
end
hook.Add("UpdateAnimation", "ThirdPerson.UpdateAnimation", ThirdPerson.UpdateAnimation)
