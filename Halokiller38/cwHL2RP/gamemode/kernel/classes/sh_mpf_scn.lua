--[[
	Free Clockwork!
--]]

local CLASS = {};

CLASS.color = Color(50, 100, 150, 255);
CLASS.factions = {FACTION_MPF};
CLASS.description = "A metropolice scanner, it utilises Combine technology.";
CLASS.defaultPhysDesc = "Making beeping sounds";

CLASS_SCN = Clockwork.class:Register(CLASS, "Metropolice Scanner");