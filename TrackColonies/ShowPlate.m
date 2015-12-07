function ShowPlate(TimeGap, DirName, ForMovie,Handles,Lrgb)
% ShowPlate(TimeGap, DirName, ForMovie,Handles,Lrgb)
% Plot all plate data: Picture, analysis, numbers
% arguments:
%   TimeGap - the time we are handling
%   DirName - source directory
%   ForMovie - 0/1
%   Handles - graphic handle
%   Lrgb - L colors data
    
    if nargin < 2
        DirName = uigetdir;
        if isequal(DirName,0)
            return;
        end
    end

    if nargin < 3
        ForMovie=false;
    end
    
    if nargin < 4
        f=figure;
        Handles=gca;
    end
    
    if nargin < 5
        Lrgb=[];
    end
    
    PlotPlate(TimeGap, DirName, 1, ForMovie,Handles,[0 1]);
    PlotPlateAnalysis(TimeGap, DirName, ForMovie,Handles,Lrgb);
    PlotPlateColoniesNumbers(TimeGap, DirName, ForMovie);
end

