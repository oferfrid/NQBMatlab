function relevantColonies = FindColoniesInWorkingArea(Mask,VecCen)
%% relevantColonies = FindColoniesInWorkingArea(Mask,VecCen)
% -------------------------------------------------------------------------
% Purpose: Returns a logical array specifying for each colony if its in 
%          working area (1) or not (0). Being in working area means that
%          the colony's sent center is with NearBorder pixels inside the
%          mask.
% 
% Arguments: Mask - The plate's mask
%            VecCen - centers array 
%
% Returns: a logical array specifying for each colony if its in 
%          working area
% -------------------------------------------------------------------------
% Nir Dick 2015

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
       
            if (conved(VecCen(k).Y,VecCen(k).X)==maxVal)
                relevantColonies(k)=1;
            end
        
    end
end
