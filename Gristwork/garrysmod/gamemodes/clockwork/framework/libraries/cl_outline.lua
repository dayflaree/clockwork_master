--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local Color = Color;
local render = render;
local math = math;

--[[ We need the plugin library to add this as a module! --]]
if (!Clockwork.plugin) then include("sh_plugin.lua"); end;

Clockwork.outline = Clockwork.kernel:NewLibrary("Outline");
Clockwork.outline.stored = Clockwork.outline.stored or {};

-- A function to add an entity outline.
function Clockwork.outline:Add(entity, glowColor, glowSize, bIgnoreZ)
	local index = entity:EntIndex();

	if (!glowSize) then
		glowSize = 2;
	end;
	
	self.stored[index] = {
		entity = {entity},
		glowColor = glowColor,
		glowSize = glowSize,
		bIgnoreZ = bIgnoreZ
	};
end;

-- A function to remove an entity outline.
function Clockwork.outline:Remove(entity)
	local index = entity:EntIndex();

	if (self.stored[index]) then
		self.stored[index] = nil;
	end;
end;

-- A function to add a fading entity outline.
function Clockwork.outline:Fader(entity, glowColor, iDrawDist, bShowAnyway, tIgnoreEnts, glowSize, bIgnoreZ)
	local fOutlineAlpha = glowColor.a;
	
	if (iDrawDist) then
		local distance = Clockwork.Client:GetPos():Distance(entity:GetPos());
		fOutlineAlpha = fOutlineAlpha - ((fOutlineAlpha / iDrawDist) * math.min(distance, iDrawDist));
	end;
	
	if (!Clockwork.player:CanSeeEntity(Clockwork.Client, entity, 0.9, tIgnoreEnts)
	and !bShowAnyway) then
		fOutlineAlpha = 0;
	end;
	
	if (!entity.cwLastOutlineAlpha) then
		entity.cwLastOutlineAlpha = 0;
	end;
	
	entity.cwLastOutlineAlpha = math.Approach(
		entity.cwLastOutlineAlpha, fOutlineAlpha, FrameTime() * 64
	);
	
	if (entity.cwLastOutlineAlpha > 0) then	
		self:Add(
			entity, Color(glowColor.r, glowColor.g, glowColor.b, entity.cwLastOutlineAlpha),
			glowSize, bIgnoreZ
		);
	end
end;

-- Called when GMod halos should be added.
function Clockwork.outline:PreDrawHalos()
	Clockwork.plugin:Call("AddEntityOutlines", self);
	
	for k, v in pairs(self.stored) do
		if (v.glowColor.a == 0) then continue; end;

		effects.halo.Add(
			v.entity, v.glowColor, v.glowSize, v.glowSize, 1, true, v.bIgnoreZ
		);
	end;
end;

--[[
	Register the library as a module. We're doing this because
	we want the PreDrawHalos function to be called
	before anything else.
--]]

Clockwork.plugin:Add("Outline", Clockwork.outline);