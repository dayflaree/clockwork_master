-------------------------------
-- LemonadeScript
-- Author: LuaBanana and Looter
-- Project Start: 5/24/2008
--
-- teams.lua
-- Holds the team functions.
-------------------------------

LEMON.Teams = {  };

function LEMON.AddTeam( team )

	local n = #LEMON.Teams + 1;
	
	LEMON.CallHook("AddTeam", team);
	
	LEMON.Teams[ n ] = team;
	
	--LEMON.DayLog( "script.txt", "Added team " .. team.name );
	
end

function LEMON.InitTeams( )

	for k, v in pairs( LEMON.Teams ) do
	
		team.SetUp( k, v[ "name" ], v[ "color" ] );
		
		-- Send the team to client
		for k2, ply in pairs(player.GetAll()) do
			umsg.Start( "setupteam", ply );
			
				umsg.Long( k );
				umsg.String( v[ "name" ] );
				umsg.Long( v[ "color" ].r );
				umsg.Long( v[ "color" ].g );
				umsg.Long( v[ "color" ].b );
				umsg.Long( v[ "color" ].a );
				umsg.Bool( v[ "public" ] );
				umsg.Long( v[ "salary" ] );
				umsg.String( v[ "flag_key" ] );
				umsg.Bool( v[ "business" ] );
				
				LEMON.CallHook("SendTeamData", ply, v);
				
			umsg.End( );
			
		end
			
	end
	
end

function LEMON.TeamObject( )

	local team = {  };
	
	-- Basic team configuration
	team.name = "";
	team.armor = 0;
	team.color = Color( 0, 0, 0, 255 );
	
	-- Model configuration
	team.model_path = "";
	team.default_model = false; -- Does the team have a model to use
	team.partial_model = false; -- Is the regular citizen model's suffix added onto the end of our modelpath ( Ex. male_07.mdl )
	
	-- Weapons Configuration
	team.weapons = {  };
	
	-- Flag Configuration
	team.flag_key = ""; -- What is used with rp_flag
	team.door_groups = {  }; -- What groups of doors can the team open
	team.radio_groups = {  }; -- What radios can the team talk on
	team.sound_groups = {  }; -- What voices can the team use
	team.item_groups = {  }; -- What items can the team purchase
	
	-- Salaries
	team.salary = 0; -- How many credits does this flag earn every paycheck?

	team.public = true;
	team.business = false;
	team.broadcast = false;
	
	LEMON.CallHook("CreateTeamObject", team); -- Hooray, plugins get to throw in their own variables! :3
	
	return team;
	
end
