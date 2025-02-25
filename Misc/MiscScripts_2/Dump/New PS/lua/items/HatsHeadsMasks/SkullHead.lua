ITEM.Name = "Skull Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a skull head."
ITEM.Cost = 150
ITEM.Model = "models/Gibs/HGIBS.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item.ID)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
	
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(1.6, 1.6, 1.6))
		pos = pos + (ang:Forward() * -2.5)
		ang:RotateAroundAxis(ang:Right(), -15)
		return ent, pos, ang
	end
}