ITEM.Name = "Melon Head"
ITEM.Enabled = true
ITEM.Description = "Gives you a melon head."
ITEM.Cost = 100
ITEM.Model = "models/props_junk/watermelon01.mdl"
ITEM.Attachment = "eyes"

ITEM.Functions = {
	OnGive = function(ply, item)
		ply:PS_AddHat(item.ID)
	end,
	
	OnTake = function(ply, item)
		ply:PS_RemoveHat(item)
	end,
	
	ModifyHat = function(ent, pos, ang)
		pos = pos + (ang:Forward() * -2)
		return ent, pos, ang
	end
}