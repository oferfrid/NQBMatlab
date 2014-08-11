function PlotPlateColoniesNumbers(TimeGap, DirName, ForMovie)
    if nargin < 2
        DirName = uigetdir;
        if isequal(DirName,0)
            return;
        end
    end
    
    if nargin < 3
        ForMovie=0;
    end
    
    dataFileStr=fullfile(DirName,GetDefaultDataName);
    data=load(dataFileStr);
    
    % Get File name by time
    times=data.FilesDateTime;
    
    PlotPlateColoniesNumbersByData(...
             TimeGap,data.Centroid,data.IgnoredColonies,times,ForMovie);    
end

