ITEM.Name = "Bucket Hat"
ITEM.Enabled = true
ITEM.Description = "Gives you a bucket hat."
ITEM.Cost = 100
ITEM.Model = "models/props_junk/MetalBucket01a.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item.ID)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item.ID)
	end,
	
	ModifyHat = function(ent, pos, ang)
		ent:SetModelScale(Vector(0.7, 0.7, 0.7))
		pos = pos + (ang:Forward() * -5) + (ang:Up() * 5)
		ang:RotateAroundAxis(ang:Right(), 200)
		return ent, pos, ang
	end
}