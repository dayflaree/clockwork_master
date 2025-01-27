--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local AddCSLuaFile = AddCSLuaFile;
local ErrorNoHalt = ErrorNoHalt;
local pairs = pairs;
local pcall = pcall;
local scripted_ents = scripted_ents;
local effects = effects;
local weapons = weapons;
local string = string;
local table = table;
local file = file;
local util = util;

Clockwork.plugin = Clockwork.kernel:NewLibrary("Plugin");
Clockwork.plugin.stored = Clockwork.plugin.stored or {};
Clockwork.plugin.buffer = Clockwork.plugin.buffer or {};
Clockwork.plugin.modules = Clockwork.plugin.modules or {};
Clockwork.plugin.unloaded = Clockwork.plugin.unloaded or {};
Clockwork.plugin.hookTable = Clockwork.plugin.hookTable or {};

if (SERVER) then
	function Clockwork.plugin:SetUnloaded(name, bIsUnloaded)
		local plugin = self:FindByID(name);
		
		if (plugin and plugin != Schema) then
			if (bIsUnloaded) then
				self.unloaded[plugin.folderName] = true;
			else
				self.unloaded[plugin.folderName] = nil;
			end;
			
			Clockwork.datastream:Start(nil, "PluginSetUnloaded", {name, bIsUnloaded});
			
			Clockwork.kernel:SaveSchemaData("plugins", self.unloaded);
			
			return true;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is disabled.
	function Clockwork.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:FindByID(k);
					
					if (unloaded and unloaded != Schema
					and plugin.folderName != unloaded.folderName) then
						if (table.HasValue(unloaded.plugins, plugin.folderName)) then
							return true;
						end;
					end;
				end;
			end;
		else
			for k, v in pairs(self.unloaded) do
				local unloaded = self:FindByID(k);
				
				if (unloaded and unloaded != Schema and name != unloaded.folderName) then
					if (table.HasValue(unloaded.plugins, name)) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function Clockwork.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				return (self.unloaded[plugin.folderName] == true);
			end;
		else
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
else
	Clockwork.plugin.override = Clockwork.plugin.override or {};
	
	-- A function to set whether a plugin is unloaded.
	function Clockwork.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:FindByID(name);
		
		if (plugin) then
			self.override[plugin.folderName] = isUnloaded;
		end;
	end;
	
	-- A function to get whether a plugin is disabled.
	function Clockwork.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:FindByID(k);
					
					if (unloaded and unloaded != Schema
					and plugin.folderName != unloaded.folderName) then
						if (table.HasValue(unloaded.plugins, plugin.folderName)) then
							return true;
						end;
					end;
				end;
			end;
		else
			for k, v in pairs(self.unloaded) do
				local unloaded = self:FindByID(k);
				
				if (unloaded and unloaded != Schema
				and name != unloaded.folderName) then
					if (table.HasValue(unloaded.plugins, name)) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function Clockwork.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				if (self.override[plugin.folderName] != nil) then
					return self.override[plugin.folderName];
				end;
				
				return (self.unloaded[plugin.folderName] == true);
			end;
		else
			if (self.override[name] != nil) then
				return self.override[name];
			end;
			
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
	
	Clockwork.datastream:Hook("PluginGetUnloaded", function(data)	
		for k, v in pairs(Clockwork.plugin.stored) do
			if (data[v.folderName]) then
				Clockwork.plugin:SetUnloaded(v.name, true);
			else
				Clockwork.plugin:SetUnloaded(v.name, false);
			end;
		end;
	end);
	
	Clockwork.datastream:Hook("PluginSetUnloaded", function(data)
		local plugin = Clockwork.plugin:FindByID(data[1]);
		
		if (plugin) then
			Clockwork.plugin:SetUnloaded(plugin.name, (data[2] == true));
		end;
	end);
end;

-- A function to set if the plugin system is initialized.
function Clockwork.plugin:SetInitialized(bInitialized)
	self.cwInitialized = bInitialized;
end;

-- A function to get whether the config has initialized.
function Clockwork.plugin:HasInitialized()
	return self.cwInitialized;
end;

-- A function to initialize the plugin system.
function Clockwork.plugin:Initialize()
	if (self:HasInitialized()) then
		return;
	end;

	if (SERVER) then
		self.unloaded = Clockwork.kernel:RestoreSchemaData("plugins");
	end;
	
	self:SetInitialized(true);
end;

-- A function to check Schema function mismatches.
function Clockwork.plugin:CheckMismatches()
	if (Schema) then
		local funcIdxMismatches = {};
		
		for k, v in pairs(Schema) do
			if (type(v) == "function" and Schema.__funcIdx[k]
			and tostring(v) ~= Schema.__funcIdx[k]) then
				table.insert(funcIdxMismatches, k);
			end;
		end;
		
		for k, v in ipairs(funcIdxMismatches) do
			ErrorNoHalt("[Clockwork] The Schema hook '"..v.."' was overriden by a plugin, this is not good!\n");
		end;
	end;
end;

-- A function to register a new plugin.
function Clockwork.plugin:Register(pluginTable)
	local newBaseDir = Clockwork.kernel:RemoveTextFromEnd(pluginTable.baseDir, "/schema");
	local files, pluginFolders = _file.Find(newBaseDir.."/plugins/*", "LUA", "namedesc");

	--[[ Todo: Prevent PLUGIN meta functions from being indexed. --]]
	if (Schema != pluginTable) then
		for k, v in pairs(pluginTable) do
			if (type(v) == "function") then
				self.hookTable[k] = self.hookTable[k] or {};
				self.hookTable[k][pluginTable.name] = v;
			end;
		end;
	end;

	self.buffer[pluginTable.folderName] = pluginTable;
	self.stored[pluginTable.name] = pluginTable;
	self.stored[pluginTable.name].plugins = {};
	
	for k, v in pairs(pluginFolders) do
		if (v != ".." and v != ".") then
			table.insert(self.stored[pluginTable.name].plugins, v);
		end;
	end;
	
	if (!self:IsUnloaded(pluginTable)) then
		self:IncludeExtras(pluginTable:GetBaseDir());
	
		if (CLIENT and Schema != pluginTable) then
			pluginTable.helpID = Clockwork.directory:AddCode("Plugins", [[
				<div class="cwTitleSeperator">
					]]..string.upper(pluginTable:GetName())..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						developed by ]]..pluginTable:GetAuthor()..[[
					</div>
					]]..pluginTable:GetDescription()..[[
				</div>
			]], true, pluginTable:GetAuthor());
		end;
	end;
	
	--[[
		Schema functions shouldn't be overriden. There's always a way to do it
		with plugins, so this will be warned against!
	--]]
	if (Schema == pluginTable) then
		Schema.__funcIdx = {};
		
		for k, v in pairs(Schema) do
			if (type(v) == "function") then
				Schema.__funcIdx[k] = tostring(v);
			end;
		end;
	end;

	self:IncludePlugins(newBaseDir);
end;

-- A function to find a plugin by an ID.
function Clockwork.plugin:FindByID(identifier)
	return self.stored[identifier] or self.buffer[identifier];
end;

-- A function to include a plugin.
function Clockwork.plugin:Include(directory, bIsSchema)
	local schemaFolder = string.lower(Clockwork.kernel:GetSchemaFolder());
	local explodeDir = string.Explode("/", directory);
	local folderName = string.lower(explodeDir[#explodeDir - 1]);
	local pathCRC = util.CRC(string.lower(directory));
	
	if (!self:HasInitialized()) then
		self:Initialize();
	end;
	
	PLUGIN_BASE_DIR = directory;
	PLUGIN_FOLDERNAME = folderName;
	
	if (bIsSchema) then
		Schema = Schema or self:New();
		
		if (SERVER) then
			local schemaInfo = Clockwork.kernel:GetSchemaGamemodeInfo();
				table.Merge(Schema, schemaInfo);
			CW_SCRIPT_SHARED.schemaData = schemaInfo;
		elseif (CW_SCRIPT_SHARED.schemaData) then
			table.Merge(Schema, CW_SCRIPT_SHARED.schemaData);
		else
			ErrorNoHalt("[Clockwork] The schema has no "..schemaFolder..".ini!\n");
		end;
		
		if (_file.Exists(directory.."/sh_schema.lua", "LUA")) then
			AddCSLuaFile(directory.."/sh_schema.lua");
			include(directory.."/sh_schema.lua");
		else
			ErrorNoHalt("[Clockwork] The schema has no sh_schema.lua.\n");
		end;

		Schema:Register();
	else
		PLUGIN = self:FindByID(PLUGIN_FOLDERNAME) or self:New();
		
		if (SERVER) then
			local iniTable = Clockwork.config:LoadINI(
				"gamemodes/"..Clockwork.kernel:RemoveTextFromEnd(directory, "/plugin").."/plugin.ini", true, true
			);
			
			if (iniTable and iniTable["Plugin"]) then
				table.Merge(PLUGIN, iniTable["Plugin"]);
				CW_SCRIPT_SHARED.plugins[pathCRC] = iniTable["Plugin"];
			elseif (_file.Exists(directory.."/sh_plugin.lua", "LUA")) then
				ErrorNoHalt("[Clockwork] The "..PLUGIN_FOLDERNAME.." plugin has no plugin.ini!\n");
			end;
		else
			if (CW_SCRIPT_SHARED.plugins[pathCRC]) then
				table.Merge(PLUGIN, CW_SCRIPT_SHARED.plugins[pathCRC]);
			else
				ErrorNoHalt("[Clockwork] The "..PLUGIN_FOLDERNAME.." plugin has no plugin.ini!\n");
			end;
		end;
		
		if (_file.Exists(directory.."/sh_plugin.lua", "LUA")) then
			Clockwork.kernel:IncludePrefixed(directory.."/sh_plugin.lua");
		end;
		
		PLUGIN:Register();
		PLUGIN = nil;
	end;
end;

-- A function to create a new plugin.
function Clockwork.plugin:New()
	local pluginTable = {
		description = "An undescribed plugin or schema.",
		folderName = PLUGIN_FOLDERNAME,
		baseDir = PLUGIN_BASE_DIR,
		version = 1.0,
		author = "Unknown",
		name = "Unknown"
	};
	
	pluginTable.SetGlobalAlias = function(pluginTable, aliasName)
		_G[aliasName] = pluginTable;
	end;
	
	pluginTable.GetDescription = function(pluginTable)
		return pluginTable.description;
	end;
	
	pluginTable.GetBaseDir = function(pluginTable)
		return pluginTable.baseDir;
	end;
	
	pluginTable.GetVersion = function(pluginTable)
		return pluginTable.version;
	end;
	
	pluginTable.GetAuthor = function(pluginTable)
		return pluginTable.author;
	end;
	
	pluginTable.GetName = function(pluginTable)
		return pluginTable.name;
	end;
	
	pluginTable.Register = function(pluginTable)
		self:Register(pluginTable);
	end;
	
	return pluginTable;
end;

-- A function to run the plugin hooks.
function Clockwork.plugin:RunHooks(name, bGamemode, ...)
	for k, v in pairs(self.modules) do
		if (v[name]) then
			if (Profiler) then
				Profiler.Push(name, tostring(k));
			end;

			local bSuccess, value = pcall(v[name], v, ...);

			if (Profiler) then
				Profiler.Pop();
			end;
			
			if (!bSuccess) then
				ErrorNoHalt("[Clockwork] The "..(v.name and "'"..v.name.."'" or "").." '"..name.."' plugin hook has failed to run.\n"..value.."\n");
			elseif (value != nil) then
				return value;
			end;
		end;
	end;
	
	if (self.hookTable and self.hookTable[name]) then
		for k, v in pairs(self.hookTable[name]) do
			if (self:IsUnloaded(self.stored[k].folderName, true)) then 
				continue; 
			end;

			if (Profiler) then
				Profiler.Push(name, tostring(k));
			end;

			local bSuccess, value = pcall(v, self.stored[k], ...);

			if (Profiler) then
				Profiler.Pop();
			end;

			if (!bSuccess) then
				ErrorNoHalt("[Clockwork] The "..(k and "'"..k.."'" or "").." '"..name.."' plugin hook has failed to run.\n"..value.."\n");
			elseif (value != nil) then
				return value;
			end;
		end;
	end;
	
	if (Schema and Schema[name]) then
		if (Profiler) then
			Profiler.Push(name, "Schema");
		end;

		local bSuccess, value = pcall(Schema[name], Schema, ...);

		if (Profiler) then
			Profiler.Pop();
		end;
		
		if (!bSuccess) then
			ErrorNoHalt("[Clockwork] The '"..name.."' schema hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;
	
	if (bGamemode and Clockwork[name]) then
		if (Profiler) then
			Profiler.Push(name, "Clockwork");
		end;

		local bSuccess, value = pcall(Clockwork[name], Clockwork, ...);

		if (Profiler) then
			Profiler.Pop();
		end;
		
		if (!bSuccess) then
			ErrorNoHalt("[Clockwork] The '"..name.."' clockwork hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;
end;

-- A function to call a function for all plugins.
function Clockwork.plugin:Call(name, ...)
	return self:RunHooks(name, true, ...);
end;

-- A function to remove a module by name.
function Clockwork.plugin:Remove(name)
	self.modules[name] = nil;
end;

-- A function to add a table as a module.
function Clockwork.plugin:Add(name, moduleTable)
	self.modules[name] = moduleTable;
end;

-- A function to include a plugin's entities.
function Clockwork.plugin:IncludeEntities(directory)
	local files, entityFolders = _file.Find(directory.."/entities/entities/*", "LUA", "namedesc");

	for k, v in pairs(entityFolders) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim", Folder = directory.."/entities/entities/"..v};
			
			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/shared.lua");
				end;
				
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/entities/"..v.."/cl_init.lua");
				end;
			elseif (_file.Exists(directory.."/entities/entities/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/cl_init.lua");
			elseif (_file.Exists(directory.."/entities/entities/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/shared.lua");
			end;
			
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

-- A function to include a plugin's effects.
function Clockwork.plugin:IncludeEffects(directory)
	local files, effectFolders = _file.Find(directory.."/entities/effects/*", "LUA", "namedesc");
	
	for k, v in pairs(effectFolders) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if (_file.Exists("gamemodes/"..directory.."/entities/effects/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/cl_init.lua");
				elseif (_file.Exists("gamemodes/"..directory.."/entities/effects/"..v.."/init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/init.lua");
				end;
			elseif (_file.Exists(directory.."/entities/effects/"..v.."/cl_init.lua", "LUA")) then
				EFFECT = {Folder = directory.."/entities/effects/"..v};
					include(directory.."/entities/effects/"..v.."/cl_init.lua");
				effects.Register(EFFECT, v); EFFECT = nil;
			elseif (_file.Exists(directory.."/entities/effects/"..v.."/init.lua", "LUA")) then
				EFFECT = {Folder = directory.."/entities/effects/"..v};
					include(directory.."/entities/effects/"..v.."/init.lua");
				effects.Register(EFFECT, v); EFFECT = nil;
			end;
		end;
	end;
end;

-- A function to include a plugin's weapons.
function Clockwork.plugin:IncludeWeapons(directory)
	local files, weaponFolders = _file.Find(directory.."/entities/weapons/*", "LUA");

	for k, v in pairs(weaponFolders) do
		if (v != ".." and v != ".") then
			SWEP = { Folder = directory.."/entities/weapons/"..v, Base = "weapon_base", Primary = {}, Secondary = {} };
			
			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/weapons/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/weapons/"..v.."/shared.lua");
				end;
				
				if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/weapons/"..v.."/cl_init.lua");
				end;
			elseif (_file.Exists(directory.."/entities/weapons/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/weapons/"..v.."/cl_init.lua");
			elseif (_file.Exists(directory.."/entities/weapons/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/weapons/"..v.."/shared.lua");
			end;
			
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

-- A function to include a plugin's plugins.
function Clockwork.plugin:IncludePlugins(directory)
	local files, pluginFolders = _file.Find(directory.."/plugins/*", "LUA", "namedesc");
	
	for k, v in pairs(pluginFolders) do
		self:Include(directory.."/plugins/"..string.lower(v).."/plugin");
	end;
end;

-- A function to include a plugin's extras.
function Clockwork.plugin:IncludeExtras(directory)
	self:IncludeEffects(directory);
	self:IncludeWeapons(directory);
	self:IncludeEntities(directory);
	
	for k, v in pairs(_file.Find(directory.."/libraries/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/libraries/"..v);
	end;

	for k, v in pairs(_file.Find(directory.."/directory/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/directory/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/system/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/system/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/factions/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/factions/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/classes/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/classes/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/attributes/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/attributes/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/items/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/items/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/derma/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/derma/"..v);
	end;
	
	for k, v in pairs(_file.Find(directory.."/commands/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/commands/"..v);
	end;
end;

--[[ This table will hold the plugin info, if it doesn't already exist. --]]
if (!CW_SCRIPT_SHARED.plugins) then
	CW_SCRIPT_SHARED.plugins = {};
end;