ITEM.Name = ".45 ACP Rounds";
ITEM.Desc = "Ammunition for firearms chambered in .45 ACP.";
ITEM.Model = "models/maxibammo/357.mdl";

ITEM.W = 1;
ITEM.H = 1;
ITEM.Stackable = true;
ITEM.StackLimit = 200;
ITEM.Category = CATEGORY_AMMO;
ITEM.BasePrice = 999;
ITEM.Vars.Ammo = 30;

function ITEM:GetDesc( item )
	
	local str = "Ammunition for firearms chambered in .45 ACP.\n\n";
	str = str .. "There are " .. item.Vars.Ammo .. " rounds left.";
	
	return str;
	
end