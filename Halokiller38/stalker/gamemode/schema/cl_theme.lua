--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local THEME = openAura.theme:Begin();

-- Called when fonts should be created.
function THEME:CreateFonts()
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(2048), 500, true, false, "veg_Large3D2D");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(31), 500, true, false, "veg_IntroTextSmall");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(24), 500, true, false, "veg_IntroTextTiny");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(36), 500, true, false, "veg_CinematicText");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(78), 500, true, false, "veg_IntroTextBig");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(24), 500, true, false, "veg_TargetIDText");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(126), 500, true, false, "veg_MenuTextHuge");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(78), 500, true, false, "veg_MenuTextBig");
	surface.CreateFont("DOWNCOME", ScaleToWideScreen(20), 500, true, false, "veg_MainText");
	surface.CreateFont("Verdana", ScaleToWideScreen(17), 600, true, false, "veg_PlayerInfoText");
end;

-- Called when to initialize the theme.
function THEME:Initialize()
	openAura.option:SetColor( "information", Color(255, 255, 255, 255) );
	openAura.option:SetFont("bar_text", "veg_TargetIDText");
	openAura.option:SetFont("main_text", "veg_MainText");
	openAura.option:SetFont("hints_text", "veg_IntroTextTiny");
	openAura.option:SetFont("large_3d_2d", "veg_Large3D2D");
	openAura.option:SetFont("target_id_text", "veg_TargetIDText");
	openAura.option:SetFont("cinematic_text", "veg_CinematicText");
	openAura.option:SetFont("date_time_text", "veg_IntroTextSmall");
	openAura.option:SetFont("menu_text_big", "veg_MenuTextBig");
	openAura.option:SetFont("menu_text_huge", "veg_MenuTextHuge");
	openAura.option:SetFont("menu_text_tiny", "veg_IntroTextTiny");
	openAura.option:SetFont("intro_text_big", "veg_IntroTextBig");
	openAura.option:SetFont("menu_text_small", "veg_IntroTextSmall");
	openAura.option:SetFont("intro_text_tiny", "veg_IntroTextTiny");
	openAura.option:SetFont("intro_text_small", "veg_IntroTextSmall");
	openAura.option:SetFont("player_info_text", "veg_PlayerInfoText");
end;

local DIRTY_TEXTURE = surface.GetTextureID("stalker/dirty");
local SCRATCH_TEXTURE = surface.GetTextureID("stalker/scratch");

-- Called just before a bar is drawn.
function THEME.module:PreDrawBar(barInfo)
	surface.SetDrawColor(255, 255, 255, 150);
	surface.SetTexture(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.width, barInfo.height);
	
	barInfo.drawBackground = false;
	barInfo.drawProgress = false;
	
	if (barInfo.text) then
		barInfo.text = string.upper(barInfo.text);
	end;
end;

-- Called just after a bar is drawn.
function THEME.module:PostDrawBar(barInfo)
	surface.SetDrawColor(barInfo.color.r, barInfo.color.g, barInfo.color.b, barInfo.color.a);
	surface.SetTexture(SCRATCH_TEXTURE);
	surface.DrawTexturedRect(barInfo.x, barInfo.y, barInfo.progressWidth, barInfo.height);
end;

-- Called just before the weapon selection info is drawn.
function THEME.module:PreDrawWeaponSelectionInfo(info)
	surface.SetDrawColor( 255, 255, 255, math.min(200, info.alpha) );
	surface.SetTexture(DIRTY_TEXTURE);
	surface.DrawTexturedRect(info.x, info.y, info.width, info.height);
	
	info.drawBackground = false;
end;

-- Called just before the local player's information is drawn.
function THEME.module:PreDrawPlayerInfo(boxInfo, information, subInformation)
	surface.SetDrawColor(255, 255, 255, 100);
	surface.SetTexture(DIRTY_TEXTURE);
	surface.DrawTexturedRect(boxInfo.x, boxInfo.y, boxInfo.width, boxInfo.height);
	
	boxInfo.drawBackground = false;
end;

-- Called after the character menu has initialized.
function THEME.hooks:PostCharacterMenuInit(panel) end;

-- Called every frame that the character menu is open.
function THEME.hooks:PostCharacterMenuThink(panel) end;

-- Called after the character menu is painted.
function THEME.hooks:PostCharacterMenuPaint(panel) end;

-- Called after a character menu panel is opened.
function THEME.hooks:PostCharacterMenuOpenPanel(panel) end;

-- Called after the main menu has initialized.
function THEME.hooks:PostMainMenuInit(panel) end;

-- Called after the main menu is rebuilt.
function THEME.hooks:PostMainMenuRebuild(panel) end;

-- Called after a main menu panel is opened.
function THEME.hooks:PostMainMenuOpenPanel(panel, panelToOpen) end;

-- Called after the main menu is painted.
function THEME.hooks:PostMainMenuPaint(panel) end;

-- Called every frame that the main menu is open.
function THEME.hooks:PostMainMenuThink(panel) end;

openAura.theme:Finish(THEME);