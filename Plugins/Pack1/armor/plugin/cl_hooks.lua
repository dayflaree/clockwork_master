
local Clockwork = Clockwork;
local PLUGIN = PLUGIN;

-- Called when the filter bar is needed
function PLUGIN:GetBars(bars)
	local filterQuality = Clockwork.Client:GetSharedVar("filterQuality");
	local maxFilterQuality = Clockwork.Client:GetSharedVar("maxFilterQuality") or 1800;
	
	if (Clockwork.Client:GetSharedVar("hasGasmask") and filterQuality > 0) then
		if (!filterQuality) then
			filterQuality = 0;
		end;

		if (!self.filterQuality) then
			self.filterQuality = filterQuality;
		else
			self.filterQuality = math.Approach(self.filterQuality, filterQuality, maxFilterQuality / 100);
		end;
		
		bars:Add("FILTER", Color(0, 0, 255, 255), "", self.filterQuality, maxFilterQuality, (self.filterQuality < (maxFilterQuality / 10)));
	end;
end;

-- Called when gasmask screen space effects should be rendered.
function PLUGIN:RenderScreenspaceEffects()
	local hasGasmask = Clockwork.Client:GetSharedVar("hasGasmask");
	if (hasGasmask and Clockwork.Client:GetFaction() != FACTION_MPF) then
		local health = LocalPlayer():Health();
		
		if (health <= 20) then
			DrawMaterialOverlay("effects/gasmask_screen_4.vmt", 0.1);
		elseif(health <= 30) then
			DrawMaterialOverlay("effects/gasmask_screen_3.vmt", 0.1);
		elseif(health <= 60) then
			DrawMaterialOverlay("effects/gasmask_screen_2.vmt", 0.1);
		elseif(health <= 90) then
			DrawMaterialOverlay("effects/gasmask_screen_1.vmt", 0.1);
		else
			DrawMaterialOverlay("effects/gasmask_screen.vmt", 0.1);
		end;
	end;
end;

function PLUGIN:GetTargetPlayerText(player, targetPlayerText)
	local bConcealed = player:GetSharedVar("isConcealed");

	if (bConcealed and !Clockwork.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		targetPlayerText:Add("CONCEALED", "This person's identity is concealed.");
	end;
end;

function PLUGIN:DestroyTargetPlayerText(player, targetPlayerText)
	local bConcealed = player:GetSharedVar("isConcealed");

	if (bConcealed and !Clockwork.player:DoesRecognise(player, RECOGNISE_PARTIAL)) then
		targetPlayerText:Destroy("PHYSDESC");
	end;
end;

--[[
function PLUGIN:GetTargetPlayerName(player)
	local bConcealed = player:GetSharedVar("isConcealed");

	if (bConcealed) then
		return "This person's identity is concealed.";
	end;
end;
]]--