function [IsColony] = IsColony( L,Stat )
    Min_Area       = 10;        % minimal area for thr colony to be added
    
    IsColony = Stat>=Min_Area;


end