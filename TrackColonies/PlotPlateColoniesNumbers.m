function PlotPlateColoniesNumbers(TimeGap, DirName, ForMovie)
% PlotPlateColoniesNumbers(TimeGap, DirName, ForMovie)
% Plot numbers for each colony. Color of number is according
% to the colony status.
% arguments:
%   TimeGap - time we are handling
%   DirName - name of directory
%   ForMovie - boolean

    if nargin < 2
        DirName = uigetdir;
        if isequal(DirName,0)
            return;
        end
    end
    
    if nargin < 3
        ForMovie=0;
    end
    
    dataFileStr=GetDataName(DirName);
    data=load(dataFileStr);
    
    % Get File name by time
    times=data.FilesDateTime;
    
    PlotPlateColoniesNumbersByData(...
             TimeGap,data.Centroid,data.IgnoredColonies,times,ForMovie);    
end

