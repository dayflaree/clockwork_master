--[[
	Free Clockwork!
--]]

if (CLIENT) then
	SYSTEM = Clockwork.system:New();
	SYSTEM.name = "Manage Plugins";
	SYSTEM.toolTip = "You can load and unload plugins from here.";
	SYSTEM.doesCreateForm = false;
	
	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local unloadTable = Clockwork.command:Get("PluginUnload");
		local loadTable = Clockwork.command:Get("PluginLoad");
		
		if (loadTable and unloadTable) then
			if (Clockwork.player:HasFlags(Clockwork.Client, loadTable.access)
			or Clockwork.player:HasFlags(Clockwork.Client, unloadTable.access)) then
				return true;
			end;
		end;
		
		return false;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		self.pluginButtons = {};
		
		local donePlugins = {};
		local categories = {};
		local mainPlugins = {};
		
		for k, v in pairs(Clockwork.plugin.stored) do
			if (v != Clockwork.schema) then
				categories[v.author] = categories[v.author] or {};
				categories[v.author][#categories[v.author] + 1] = v;
			end;
		end;
		
		for k, v in pairs(categories) do
			table.sort(v, function(a, b)
				return a.name < b.name;
			end);
			
			mainPlugins[#mainPlugins + 1] = {
				category = k,
				plugins = v
			};
		end;
		
		table.sort(mainPlugins, function(a, b)
			return a.category < b.category;
		end);
		
		Clockwork:StartDataStream("SystemPluginGet", true);
		
		if (#mainPlugins > 0) then
			local label = vgui.Create("cwInfoText", systemPanel);
				label:SetText("Plugins colored red are unloaded.");
				label:SetInfoColor("red");
			systemPanel.panelList:AddItem(label);
			
			local label = vgui.Create("cwInfoText", systemPanel);
				label:SetText("Plugins colored green are loaded.");
				label:SetInfoColor("green");
			systemPanel.panelList:AddItem(label);
			
			local label = vgui.Create("cwInfoText", systemPanel);
				label:SetText("Plugins colored orange are disabled.");
				label:SetInfoColor("orange");
			systemPanel.panelList:AddItem(label);
			
			for k, v in ipairs(mainPlugins) do
				local pluginForm = vgui.Create("DForm", systemPanel);
				local panelList = vgui.Create("DPanelList", systemPanel);
				
				for k2, v2 in pairs(v.plugins) do
					self.pluginButtons[v2.name] = vgui.Create("cwInfoText", systemPanel);
						self.pluginButtons[v2.name]:SetText(v2.name);
						self.pluginButtons[v2.name]:SetButton(true);
						self.pluginButtons[v2.name]:SetToolTip(v2.description);
					panelList:AddItem(self.pluginButtons[v2.name]);
					
					if (Clockwork.plugin:IsDisabled(v2.name)) then
						self.pluginButtons[v2.name]:SetInfoColor("orange");
						self.pluginButtons[v2.name]:SetButton(false);
					elseif (Clockwork.plugin:IsUnloaded(v2.name)) then
						self.pluginButtons[v2.name]:SetInfoColor("red");
					else
						self.pluginButtons[v2.name]:SetInfoColor("green");
					end;
					
					-- Called when the button is clicked.
					self.pluginButtons[v2.name].DoClick = function(button)
						if (!Clockwork.plugin:IsDisabled(v2.name)) then
							if (Clockwork.plugin:IsUnloaded(v2.name)) then
								Clockwork:StartDataStream("SystemPluginSet", {v2.name, false});
							else
								Clockwork:StartDataStream("SystemPluginSet", {v2.name, true});
							end;
						end;
					end;
				end;
				
				systemPanel.panelList:AddItem(pluginForm);
				
				panelList:SetAutoSize(true);
				panelList:SetPadding(4);
				panelList:SetSpacing(4);
				
				pluginForm:SetName(v.category);
				pluginForm:AddItem(panelList);
				pluginForm:SetPadding(4);
			end;
		else
			local label = vgui.Create("cwInfoText", systemPanel);
				label:SetText("There are no plugins installed on the server.");
				label:SetInfoColor("red");
			systemPanel.panelList:AddItem(label);
		end;
	end;
	
	-- A function to update the plugin buttons.
	function SYSTEM:UpdatePluginButtons()
		for k, v in pairs(self.pluginButtons) do
			if (Clockwork.plugin:IsDisabled(k)) then
				v:SetInfoColor("orange");
				v:SetButton(false);
			elseif (Clockwork.plugin:IsUnloaded(k)) then
				v:SetInfoColor("red");
				v:SetButton(true);
			else
				v:SetInfoColor("green");
				v:SetButton(true);
			end;
		end;
	end;

	Clockwork.system:Register(SYSTEM);
	
	Clockwork:HookDataStream("SystemPluginGet", function(data)
		local systemTable = Clockwork.system:Get("Manage Plugins");
		local unloaded = data;
		
		for k, v in pairs(Clockwork.plugin.stored) do
			if (unloaded[v.folderName]) then
				Clockwork.plugin:SetUnloaded(v.name, true);
			else
				Clockwork.plugin:SetUnloaded(v.name, false);
			end;
		end;
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:UpdatePluginButtons();
		end;
	end);
	
	Clockwork:HookDataStream("SystemPluginSet", function(data)
		local systemTable = Clockwork.system:Get("Manage Plugins");
		local plugin = Clockwork.plugin:FindByID(data[1]);
		
		if (plugin) then
			Clockwork.plugin:SetUnloaded(plugin.name, (data[2] == true));
		end;
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:UpdatePluginButtons();
		end;
	end);
else
	Clockwork:HookDataStream("SystemPluginGet", function(player, data)
		Clockwork:StartDataStream(player, "SystemPluginGet", Clockwork.plugin.unloaded);
	end);
	
	Clockwork:HookDataStream("SystemPluginSet", function(player, data)
		local unloadTable = Clockwork.command:Get("PluginLoad");
		local loadTable = Clockwork.command:Get("PluginLoad");
		
		if (data[2] == true and (!loadTable or !Clockwork.player:HasFlags(player, loadTable.access))) then
			return;
		elseif (data[2] == false and (!unloadTable or !Clockwork.player:HasFlags(player, unloadTable.access))) then
			return;
		elseif (type(data[2]) != "boolean") then
			return;
		end;
		
		local plugin = Clockwork.plugin:FindByID(data[1]);
		
		if (plugin) then
			if (!Clockwork.plugin:IsDisabled(plugin.name)) then
				local success = Clockwork.plugin:SetUnloaded(plugin.name, data[2]);
				local recipients = {};
				
				if (success) then
					if (data[2]) then
						Clockwork.player:NotifyAll(player:Name().." has unloaded the "..plugin.name.." plugin for the next restart.");
					else
						Clockwork.player:NotifyAll(player:Name().." has loaded the "..plugin.name.." plugin for the next restart.");
					end;
					
					for k, v in ipairs(_player.GetAll()) do
						if (v:HasInitialized()) then
							if (Clockwork.player:HasFlags(v, loadTable.access)
							or Clockwork.player:HasFlags(v, unloadTable.access)) then
								recipients[#recipients + 1] = v;
							end;
						end;
					end;
					
					if (#recipients > 0) then
						Clockwork:StartDataStream(recipients, "SystemPluginSet", { plugin.name, data[2] });
					end;
				elseif (data[2]) then
					Clockwork.player:Notify(player, "This plugin could not be unloaded!");
				else
					Clockwork.player:Notify(player, "This plugin could not be loaded!");
				end;
			else
				Clockwork.player:Notify(player, "This plugin depends on another plugin!");
			end;
		else
			Clockwork.player:Notify(player, "This plugin is not valid!");
		end;
	end);
end;