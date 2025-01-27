ITEM.Name = "Monitor Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a monitor head."
ITEM.Cost = 100
ITEM.Model = "models/props_lab/monitor02.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item.ID)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
	
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.6, 0.6, 0.6))
		pos = pos + (ang:Forward() * -5) + (ang:Up() * -5)
		return ent, pos, ang
	end
}