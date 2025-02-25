--[[
	Name: sh_info.lua.
	Author: LauScript.
--]]

local PLUGIN = PLUGIN;

-- Called when OpenAura has loaded all of the entities.
function PLUGIN:OpenAuraInitPostEntity()
end;

PLUGIN.Sounds = {
	light = {
		"avoxgaming/gas_mask/gas_mask_light/gas_mask_light_breath1.wav",
		"avoxgaming/gas_mask/gas_mask_light/gas_mask_light_breath2.wav",
		"avoxgaming/gas_mask/gas_mask_light/gas_mask_light_breath3.wav",
		"avoxgaming/gas_mask/gas_mask_light/gas_mask_light_breath4.wav",
		"avoxgaming/gas_mask/gas_mask_light/gas_mask_light_breath5.wav"
	},
	medium ={
		"avoxgaming/gas_mask/gas_mask_middle/gas_mask_middle_breath1.wav",
		"avoxgaming/gas_mask/gas_mask_middle/gas_mask_middle_breath2.wav",
		"avoxgaming/gas_mask/gas_mask_middle/gas_mask_middle_breath3.wav",
		"avoxgaming/gas_mask/gas_mask_middle/gas_mask_middle_breath4.wav",
		"avoxgaming/gas_mask/gas_mask_middle/gas_mask_middle_breath5.wav"
	},
	heavy = {
		"avoxgaming/gas_mask/gas_mask_hard/gas_mask_hard_breath1.wav",
		"avoxgaming/gas_mask/gas_mask_hard/gas_mask_hard_breath2.wav",
		"avoxgaming/gas_mask/gas_mask_hard/gas_mask_hard_breath3.wav",
		"avoxgaming/gas_mask/gas_mask_hard/gas_mask_hard_breath4.wav",
		"avoxgaming/gas_mask/gas_mask_hard/gas_mask_hard_breath5.wav"
	}
};

-- Called each tick.
function PLUGIN:Tick()
	for _,p in pairs( player.GetAll() ) do
		if ( p:GetSharedVar("wearingRespirator") ) then
			if ( p:Alive() ) then
				if ( p.LastBreath ) then
					if ( CurTime() > p.LastBreath + 10 ) then
				
						local sound = "avoxgaming/gas_mask/gas_mask_light/gas_mask_light_breath1.wav"
						local quality = p:GetSharedVar("filterQuality");
				
						if ( quality >= 50) then
							sound = table.Random(self.Sounds.light);
						elseif( quality >= 30 ) then
							sound = table.Random(self.Sounds.medium);
						elseif( quality >= 1 ) then
							sound = table.Random(self.Sounds.heavy);
						end;
				
					p:EmitSound(sound,50,100);
					p.LastBreath = CurTime() + 10;
					end;
				else
					p.LastBreath = CurTime();
				end;
			end;
		end;
	end;
end;

-- Called when a player's character data should be saved.
function PLUGIN:PlayerSaveCharacterData(player, data)
	if ( data["filterQuality"] ) then
		data["filterQuality"] = math.Round( data["filterQuality"] );
	end;
end;

-- Called when a player's character data should be restored.
function PLUGIN:PlayerRestoreCharacterData(player, data)
	data["filterQuality"] = data["filterQuality"] or 0;
end;

-- Called just after a player spawns.
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!firstSpawn and !lightSpawn) then
		player:SetCharacterData("filterQuality", 0);
	end;
end;

-- Called when a player's shared variables should be set.
function PLUGIN:PlayerSetSharedVars(player, curTime)
	player:SetSharedVar( "filterQuality", math.Round( player:GetCharacterData("filterQuality") ) );
end;