--[[
Name: "sh_auto.lua".
Product: "Nexus".
--]]

local MOUNT = MOUNT;

nexus.player.RegisterSharedVar("sh_BeingDragged", NWTYPE_BOOL, true);

NEXUS:IncludePrefixed("sv_hooks.lua");
NEXUS:IncludePrefixed("cl_hooks.lua");