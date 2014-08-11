function ShowPlate(TimeGap, DirName, ForMovie,Handles)
    
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
    
    PlotPlate(TimeGap, DirName, 1, ForMovie,Handles,[0 1]);
    PlotPlateAnalysis(TimeGap, DirName, ForMovie,Handles);
    PlotPlateColoniesNumbers(TimeGap, DirName, ForMovie);
end

