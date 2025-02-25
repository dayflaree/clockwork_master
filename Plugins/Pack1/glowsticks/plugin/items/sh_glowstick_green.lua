local ITEM = Clockwork.item:New();
ITEM.name = "Glowstick (Green)";
ITEM.cost = 50;
ITEM.model = "models/pg_props/pg_obj/pg_glow_stick.mdl";
ITEM.weight = 0.2;
ITEM.category = "Lights"
ITEM.useText = "Crack";
ITEM.business = false;
ITEM.description = "A Flood Light capable of illuminating large areas.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	local entity = ents.Create("ent_glowstick_fly");
	
	if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
		
		Clockwork.player:GiveProperty(player, entity);
		
		entity:SetModel(self.model);
		entity:SetPos(trace.HitPos);
		entity:Spawn();
		
		if ( IsValid(itemEntity) ) then
			local physicsObject = itemEntity:GetPhysicsObject();
			
			entity:SetPos( itemEntity:GetPos() );
			entity:SetAngles( itemEntity:GetAngles() );
			
			if ( IsValid(physicsObject) ) then
				if ( !physicsObject:IsMoveable() ) then
					physicsObject = entity:GetPhysicsObject();
					
					if ( IsValid(physicsObject) ) then
						physicsObject:EnableMotion(false);
					end;
				end;
			end;
		else
			Clockwork.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
		end;
	else
		Clockwork.player:Notify(player, "You cannot drop a light that far away!");
		
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();