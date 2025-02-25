ITEM.Name = "Cone Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a cone head."
ITEM.Cost = 100
ITEM.Model = "models/props_junk/TrafficCone001a.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item.ID)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item.ID)
	end,
	
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.8, 0.8, 0.8))
		pos = pos + (ang:Forward() * -7) + (ang:Up() * 12)
		ang:RotateAroundAxis(ang:Right(), 20)
		return ent, pos, ang
	end
}