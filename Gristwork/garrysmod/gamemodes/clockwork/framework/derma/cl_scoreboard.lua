--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local Clockwork = Clockwork;
local IsValid = IsValid;
local pairs = pairs;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(Clockwork.menu:GetWidth(), Clockwork.menu:GetHeight());
	
	self.panelList = vgui.Create("cwPanelList", self);
 	self.panelList:SetPadding(2);
 	self.panelList:SetSpacing(2);
 	self.panelList:SizeToContents();
	self.panelList:EnableVerticalScrollbar();
	
	Clockwork.scoreboard = self;
	Clockwork.scoreboard:Rebuild();
end;

-- A function to rebuild the panel.
function PANEL:Rebuild()
	self.panelList:Clear();
	
	local availableClasses = {};
	local classes = {};
	
	for k, v in pairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			local class = Clockwork.plugin:Call("GetPlayerScoreboardClass", v);
			
			if (class) then
				if (!availableClasses[class]) then
					availableClasses[class] = {};
				end;
				
				if (Clockwork.plugin:Call("PlayerShouldShowOnScoreboard", v)) then
					availableClasses[class][#availableClasses[class] + 1] = v;
				end;
			end;
		end;
	end;
	
	for k, v in pairs(availableClasses) do
		table.sort(v, function(a, b)
			return Clockwork.plugin:Call("ScoreboardSortClassPlayers", k, a, b);
		end);
		
		if (#v > 0) then
			classes[#classes + 1] = {name = k, players = v};
		end;
	end;
	
	table.sort(classes, function(a, b)
		return a.name < b.name;
	end);
	
	if (table.Count(classes) > 0) then
		local label = vgui.Create("cwInfoText", self);
			label:SetText("Clicking a player's model icon may bring up some options.");
			label:SetInfoColor("blue");
		self.panelList:AddItem(label);
		
		for k, v in pairs(classes) do
			local characterForm = vgui.Create("DForm", self);
			local panelList = vgui.Create("DPanelList", self);
			
			for k2, v2 in pairs(v.players) do
				self.playerData = {
					avatarImage = true,
					steamName = v2:SteamName(),
					faction = v2:GetFaction(),
					player = v2,
					class = _team.GetName(v2:Team()),
					model = v2:GetModel(),
					skin = v2:GetSkin(),
					name = v2:Name()
				};
				
				panelList:AddItem(vgui.Create("cwScoreboardItem", self)) ;
			end;
			
			self.panelList:AddItem(characterForm);
			
			panelList:SetAutoSize(true);
			panelList:SetPadding(4);
			panelList:SetSpacing(4);
			
			characterForm:SetName(v.name);
			characterForm:AddItem(panelList);
			characterForm:SetPadding(4); 
		end;
	else
		local label = vgui.Create("cwInfoText", self);
			label:SetText("There are no players to display.");
			label:SetInfoColor("orange");
		self.panelList:AddItem(label);
	end;
	
	self.panelList:InvalidateLayout(true);
end;

-- Called when the menu is opened.
function PANEL:OnMenuOpened()
	if (Clockwork.menu:IsPanelActive(self)) then
		self:Rebuild();
	end;
end;

-- Called when the panel is selected.
function PANEL:OnSelected() self:Rebuild(); end;

-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.panelList:StretchToParent(4, 28, 4, 4);
	self:SetSize(w, math.min(self.panelList.pnlCanvas:GetTall() + 32, ScrH() * 0.75));
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h);
	
	return true;
end;

-- Called each frame.
function PANEL:Think()
	self:InvalidateLayout(true);
end;

vgui.Register("cwScoreboard", PANEL, "EditablePanel");

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	SCOREBOARD_PANEL = true;
		self:SetSize(self:GetParent():GetWide(), 32);
		
		local playerData = self:GetParent().playerData;
		local info = {
			doesRecognise = Clockwork.player:DoesRecognise(playerData.player),
			avatarImage = playerData.avatarImage,
			steamName = playerData.steamName,
			faction = playerData.faction,
			player = playerData.player,
			class = playerData.class,
			model = playerData.model,
			skin = playerData.skin,
			name = playerData.name
		};
		
		info.text = Clockwork.plugin:Call("GetPlayerScoreboardText", info.player);
		
		Clockwork.plugin:Call("ScoreboardAdjustPlayerInfo", info);
		
		self.toolTip = info.toolTip;
		self.player = info.player;
		
		self.nameLabel = vgui.Create("DLabel", self);
		self.nameLabel:SetText(info.name);
		self.nameLabel:SetDark(true);
		self.nameLabel:SizeToContents();
		
		self.factionLabel = vgui.Create("DLabel", self); 
		self.factionLabel:SetText(info.faction);
		self.factionLabel:SizeToContents();
		self.factionLabel:SetDark(true);
		
		if (type(info.text) == "string") then
			self.factionLabel:SetText(info.text);
			self.factionLabel:SizeToContents();
		end;
		
		if (info.doesRecognise) then
			self.spawnIcon = vgui.Create("cwSpawnIcon", self);
			self.spawnIcon:SetModel(info.model, info.skin);
			self.spawnIcon:SetSize(30, 30);
		else
			self.spawnIcon = vgui.Create("DImageButton", self);
			self.spawnIcon:SetImage("clockwork/unknown.png");
			self.spawnIcon:SetSize(30, 30);
		end;
		
		-- Called when the spawn icon is clicked.
		function self.spawnIcon.DoClick(spawnIcon)
			local options = {};
				Clockwork.plugin:Call("GetPlayerScoreboardOptions", info.player, options);
			Clockwork.kernel:AddMenuFromData(nil, options);
		end;
		
		self.avatarImage = vgui.Create("AvatarImage", self);
		self.avatarImage:SetSize(30, 30);
		
		self.avatarButton = vgui.Create("DButton", self.avatarImage);
		self.avatarButton:Dock(FILL);
		self.avatarButton:SetText("");
		self.avatarButton:SetDrawBorder(false);
		self.avatarButton:SetDrawBackground(false);

		if (info.avatarImage) then
			self.avatarButton:SetToolTip("This player's name is "..info.steamName..".\nThis player's Steam ID is "..info.player:SteamID()..".");
			self.avatarButton.DoClick = function(button)
				if (IsValid(info.player)) then
					info.player:ShowProfile();
				end;
			end;

			self.avatarImage:SetPlayer(info.player);
		end;
	SCOREBOARD_PANEL = nil;
end;

-- Called each frame.
function PANEL:Think()
	if (IsValid(self.player)) then
		if (self.toolTip) then
			self.spawnIcon:SetToolTip(self.toolTip);
		else
			self.spawnIcon:SetToolTip("This player's ping is "..self.player:Ping()..".");
		end;
	end;
	
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(30, 30);
end;
-- Called when the layout should be performed.
function PANEL:PerformLayout(w, h)
	self.factionLabel:SizeToContents();
	
	self.spawnIcon:SetPos(1, 1);
	self.spawnIcon:SetSize(30, 30);
	self.avatarImage:SetPos(40, 1);
	self.avatarImage:SetSize(30, 30);
	
	self.nameLabel:SetPos(80, 2);
	self.factionLabel:SetPos(80, 30 - self.factionLabel:GetTall());
end;

vgui.Register("cwScoreboardItem", PANEL, "Panel");