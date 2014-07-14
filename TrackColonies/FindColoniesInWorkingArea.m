function relevantColonies = FindColoniesInWorkingArea(Mask,VecCen)
%% CID = FindColoniesInWorkingArea(FileDir)
% -------------------------------------------------------------------------
% Purpose: Returns the colony IDs in the working area.
% 
% Description: Checks the distance of the centre of the colonies from the 
%          borders 
% 
% Arguments: FileDir - The full path of the directory
%
% Returns: CID - An Array of colony IDs
% -------------------------------------------------------------------------
% Irit L. Reisman 08.2011

    %% Constants

    NearBorder = 15;        % proximity to the border


    %% Mask exists

    [localR,localC]=meshgrid(1:2*NearBorder+1,1:2*NearBorder+1);
    local=(localR-NearBorder-1).^2+(localC-NearBorder-1).^2<=...
                                                   (NearBorder*NearBorder);
    maxVal=sum(sum(local));
    
    conved=conv2(double(Mask),double(local),'same');
    NumColonies = length(VecCen);
    
    relevantColonies=zeros(NumColonies,1);
    
    for k=1:NumColonies
        % remove excluded
       
            if (conved(VecCen(k).X,VecCen(k).Y)==maxVal)
                relevantColonies(k)=1;
            end
        
    end
end
