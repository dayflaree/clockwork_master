ITEM.Name = "Paper Ball";
ITEM.NicePhrase = "Crumpled up paper";
ITEM.Description = "Lots of creases"; 
ITEM.Model = "models/props/cs_office/trash_can_p5.mdl"
ITEM.CamPos = Vector( 50, 78, 90 );
ITEM.LookAt = Vector( 0, 0, 0 ); 
ITEM.FOV = 5;
ITEM.Width = 1;
ITEM.Height = 1;
ITEM.Flags = "x";

ITEM.AddsOn = false;
ITEM.AddOnMax = 3;

ITEM.Tier = 1;

function ITEM:Examine()

local n = math.random( 1, 3 );
if( n == 1 ) then

self.Owner:NoticePlainWhite( "Quite useless.");

elseif( n == 2 ) then

self.Owner:NoticePlainWhite( "Very crumpled up..." );

else

self.Owner:NoticePlainWhite( "Some scribbling inside." );

end

end