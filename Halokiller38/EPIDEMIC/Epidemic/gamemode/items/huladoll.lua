ITEM.Name = "Hula Doll";
ITEM.NicePhrase = "A Hula Doll";
ITEM.Description = "Looks fun"; 
ITEM.Model = "models/props_lab/huladoll.mdl"
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

self.Owner:NoticePlainWhite( "Looks like it is shakeable.");

elseif( n == 2 ) then

self.Owner:NoticePlainWhite( "A always need for a vacation." );

else

self.Owner:NoticePlainWhite( "Brings up spirits." );

end

end