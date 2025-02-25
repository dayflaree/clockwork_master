local PANEL = {}

AccessorFunc(PANEL, "InfoHeight", "InfoHeight")

local icon = surface.GetTextureID("gui/silkicons/shield")

function PANEL:Init()
	self.AutoSize = false
	
	self.Info = ""
	self.InfoHeight = 14
end

function PANEL:SetData(data)
	self.Data = data
	self.Info = data.Name
	self:SetMaterial(data.Material)
	self:SetTooltip(data.Description)
	
	if LocalPlayer():PS_CanAfford(self.Data.Cost) then
		self.BarColor = Color(0, 50, 0, 125)
	else
		self.BarColor = Color(50, 0, 0, 125)
	end
end

function PANEL:PaintOver()
	if self.Data.AdminOnly then
		surface.SetTexture(icon)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(0, 0, 16, 16)
	end
	
	surface.SetDrawColor(self.BarColor.r, self.BarColor.g, self.BarColor.b, self.BarColor.a)
	surface.DrawRect(0, self:GetTall() - self.InfoHeight, self:GetWide(), self.InfoHeight)
	draw.SimpleText(self.Info, "DefaultSmall", self:GetWide() / 2, self:GetTall() - (self.InfoHeight / 2) - 1, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:OnCursorEntered()
	if self.Sell then
		self.Info = "Sell: " .. POINTSHOP.Config.SellCost(self.Data.Cost)
	else
		self.Info = "Buy: " .. self.Data.Cost
	end
end

function PANEL:OnCursorExited()
	self.Info = self.Data.Name
end

vgui.Register("DShopMaterial", PANEL, "Material")