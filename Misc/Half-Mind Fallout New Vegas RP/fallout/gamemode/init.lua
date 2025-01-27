include( "sh_enum.lua" );
include( "shared.lua" );
include( "sh_util.lua" );
include( "sh_accessor.lua" );
include( "sh_admin.lua" );
include( "sh_animations.lua" );
include( "sh_chatcmd.lua" );
include( "sh_items.lua" );
include( "sh_models.lua" );
include( "sh_player.lua" );
include( "sh_playerclass.lua" );
include( "sh_sandbox.lua" );
include( "sh_soundscripts.lua" );
include( "sv_admin.lua" );
include( "sv_chat.lua" );
include( "sv_items.lua" );
include( "sv_logs.lua" );
include( "sv_map.lua" );
include( "sv_mysql.lua" );
include( "sv_net.lua" );
include( "sv_player.lua" );
include( "sv_resource.lua" );
include( "sv_security.lua" );
include( "sv_think.lua" );
include( "sv_vehicles.lua" );
include( "sv_weapons.lua" );

AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "sh_enum.lua" );
AddCSLuaFile( "shared.lua" );
AddCSLuaFile( "sh_util.lua" );
AddCSLuaFile( "sh_accessor.lua" );
AddCSLuaFile( "sh_admin.lua" );
AddCSLuaFile( "sh_animations.lua" );
AddCSLuaFile( "sh_chatcmd.lua" );
AddCSLuaFile( "sh_items.lua" );
AddCSLuaFile( "sh_models.lua" );
AddCSLuaFile( "sh_player.lua" );
AddCSLuaFile( "sh_playerclass.lua" );
AddCSLuaFile( "sh_sandbox.lua" );
AddCSLuaFile( "sh_soundscripts.lua" );
AddCSLuaFile( "gui/cl_inventory.lua" );
AddCSLuaFile( "gui/cl_gui.lua" );
AddCSLuaFile( "gui/cl_guiext.lua" );
AddCSLuaFile( "gui/cl_skin.lua" );
AddCSLuaFile( "cl_admin.lua" );
AddCSLuaFile( "cl_binds.lua" );
AddCSLuaFile( "cl_charcreate.lua" );
AddCSLuaFile( "cl_chat.lua" );
AddCSLuaFile( "cl_dev.lua" );
AddCSLuaFile( "cl_hud.lua" );
AddCSLuaFile( "cl_items.lua" );
AddCSLuaFile( "cl_map.lua" );
AddCSLuaFile( "cl_scoreboard.lua" );
AddCSLuaFile( "cl_sound.lua" );
AddCSLuaFile( "cl_think.lua" );
AddCSLuaFile( "cl_bonemerge.lua" );

function GM:Initialize()
	
	game.ConsoleCommand( "net_maxfilesize 64\n" );
	
	game.ConsoleCommand( "sbox_persist 1\n" );
	
	game.ConsoleCommand( "sv_allowupload 0\n" );
	game.ConsoleCommand( "sv_allowdownload 0\n" );
	game.ConsoleCommand( "sv_voiceenable 0\n" );
	
	if( game.IsDedicated() and !self.PrivateMode ) then
		
		game.ConsoleCommand( "sv_allowcslua 0\n" );
		
	else
		
		game.ConsoleCommand( "sv_allowcslua 1\n" );
		
	end
	
	self:SetupDataDirectories();
	
	self:ConnectToSQL();
	self:LoadBans();
	self:LoadFactionSpawns();
	
end

function GM:ShutDown()

	self:SaveFactionSpawns();

end

local files = file.Find( GM.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua", "LUA", "namedesc" );

if( #files > 0 ) then

	for _, v in pairs( files ) do
		
		include( "maps/" .. v );
		AddCSLuaFile( "maps/" .. v );
		
	end
	
	MsgC( Color( 128, 128, 128, 255 ), "Map lua file for " .. game.GetMap() .. " loaded serverside.\n" );
	
end