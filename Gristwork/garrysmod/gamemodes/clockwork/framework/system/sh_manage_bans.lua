--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;

if (CLIENT) then
	local SYSTEM = Clockwork.system:New();
	SYSTEM.name = "Manage Bans";
	SYSTEM.toolTip = "A method to unban players graphically.";
	SYSTEM.bannedPage = 1;
	SYSTEM.bannedPlayers = nil;
	SYSTEM.doesCreateForm = false;

	-- Called to get whether the local player has access to the system.
	function SYSTEM:HasAccess()
		local unbanTable = Clockwork.command:FindByID("PlyUnban");
		if (unbanTable and Clockwork.player:HasFlags(Clockwork.Client, unbanTable.access)) then
			return true;
		end;
	end;

	-- Called when the system should be displayed.
	function SYSTEM:OnDisplay(systemPanel, systemForm)
		if (!self.noRefresh) then
			Clockwork.datastream:Start("SystemUnbanGet", self.bannedPage);
		else
			self.noRefresh = nil;
		end;
		
		if (self.bannedPlayers) then
			if (#self.bannedPlayers > 0) then
				for k, v in pairs(self.bannedPlayers) do
					local timeLeftMessage = "This player is banned permanently.";
					local infoColor = "red";
					
					if (v.timeLeft > 0) then
						local hoursLeft = math.Round(math.max(v.timeLeft / 3600, 0));
						local minutesLeft = math.Round(math.max(v.timeLeft / 60, 0));
						
						if (hoursLeft >= 1) then
							timeLeftMessage = "Unbanned in "..hoursLeft.." hour(s).";
						elseif (minutesLeft >= 1) then
							timeLeftMessage = "Unbanned in "..hoursLeft.." minute(s).";
						else
							timeLeftMessage = "Unbanned in "..v.timeLeft.." second(s).";
						end;
						
						infoColor = "orange";
					end;
					
					local label = vgui.Create("cwInfoText", systemPanel);
						label:SetText(v.steamName);
						label:SetButton(true);
						label:SetToolTip(v.identifier.."\n"..timeLeftMessage.."\nBanned for '"..v.reason.."'.");
						label:SetInfoColor(infoColor);
					systemPanel.panelList:AddItem(label);
					
					-- Called when the button is clicked.
					function label.DoClick(button)
						Derma_Query("Are you sure that you want to unban "..v.steamName.."?", "Unban "..v.steamName..".", "Yes", function()
							Clockwork.datastream:Start("SystemUnbanDo", v.identifier);
						end, "No", function() end);
					end;
				end;
				
				if (self.pageCount > 1) then
					local pageForm = vgui.Create("DForm", systemPanel);
						pageForm:SetName("Page "..self.bannedPage.."/"..self.pageCount);
						pageForm:SetPadding(4);
					systemPanel.panelList:AddItem(pageForm);
					
					if (self.isNext) then
						local nextButton = pageForm:Button("Next");
						
						-- Called when the button is clicked.
						function nextButton.DoClick(button)
							Clockwork.datastream:Start("SystemUnbanGet", self.bannedPage + 1);
						end;
					end;
					
					if (self.isBack) then
						local backButton = pageForm:Button("Back");
						
						-- Called when the button is clicked.
						function backButton.DoClick(button)
							Clockwork.datastream:Start("SystemUnbanGet", self.bannedPage - 1);
						end;
					end;
				end;
			else
				local label = vgui.Create("cwInfoText", systemPanel);
					label:SetText("There are no banned players to display.");
					label:SetInfoColor("orange");
				systemPanel.panelList:AddItem(label);
			end;
		else
			local label = vgui.Create("cwInfoText", systemPanel);
				label:SetText("Hold on while the banned player list is retrieved...");
				label:SetInfoColor("blue");
			systemPanel.panelList:AddItem(label);
		end;
	end;

	SYSTEM:Register();
	
	Clockwork.datastream:Hook("SystemUnbanRebuild", function(data)
		local systemTable = Clockwork.system:FindByID("Manage Bans");
		
		if (systemTable and systemTable:IsActive()) then
			systemTable:Rebuild();
		end;
	end);
	
	Clockwork.datastream:Hook("SystemUnbanGet", function(data)
		if (type(data) == "table") then
			local systemTable = Clockwork.system:FindByID("Manage Bans");
			
			if (systemTable) then
				systemTable.bannedPlayers = data.players;
				systemTable.bannedPage = data.page;
				systemTable.pageCount = data.pageCount;
				systemTable.noRefresh = true;
				systemTable.isBack = data.isBack;
				systemTable.isNext = data.isNext;
				systemTable:Rebuild();
			end;
		else
			local systemTable = Clockwork.system:FindByID("Manage Bans");
			
			if (systemTable) then
				systemTable.bannedPlayers = {};
				systemTable.bannedPage = 1;
				systemTable.noRefresh = true;
					
				if (systemTable:IsActive()) then
					systemTable:Rebuild();
				end;
			end;
		end;
	end);
else
	Clockwork.datastream:Hook("SystemUnbanDo", function(player, data)
		if (type(data) == "string") then
			Clockwork.player:RunClockworkCommand(player, "PlyUnban", data);
			
			Clockwork.datastream:Start(player, "SystemUnbanRebuild", true);
		end;
	end);
	
	Clockwork.datastream:Hook("SystemUnbanGet", function(player, data)
		local page = tonumber(data);
		
		if (page) then
			local bannedPlayers = {};
			local sendPlayers = {};
			local finishIndex = page * 8;
			local startIndex = finishIndex - 7;
			local pageCount = 0;
			local unixTime = os.time();
			
			for k, v in pairs(Clockwork.bans.stored) do
				local unbanTime = tonumber(v.unbanTime);
			
				if (unbanTime == 0 or unbanTime > unixTime) then
					local timeLeft = unbanTime - unixTime;
					
					if (unbanTime == 0) then
						timeLeft = 0;
					end;
					
					bannedPlayers[#bannedPlayers + 1] = {
						identifier = k,
						steamName = v.steamName,
						timeLeft = timeLeft,
						reason = v.reason
					};
				end;
			end;
			
			table.sort(bannedPlayers, function(a, b)
				if (a.steamName and b.steamName) then
					return a.steamName < b.steamName;
				end;
			end);
			
			pageCount = math.ceil(#bannedPlayers / 8);
			
			for k, v in pairs(bannedPlayers) do
				if (k >= startIndex and k <= finishIndex) then
					sendPlayers[#sendPlayers + 1] = v;
				end;
			end;
			
			if (#sendPlayers > 0) then
				Clockwork.datastream:Start(player, "SystemUnbanGet", {
					pageCount = pageCount,
					players = sendPlayers,
					isNext = (bannedPlayers[finishIndex + 1] != nil),
					isBack = (bannedPlayers[startIndex - 1] != nil),
					page = page
				});
			else
				Clockwork.datastream:Start(player, "SystemUnbanGet", false);
			end;
		end;
	end);
end;