function [id,SourceDir,Time,Area,CentralMass] = getPropInTime(SourceDirs )
% [id,SourceDir,Time,Area,CentralMass] = getPropInTime(SourceDirs)
    

    DATA_FILE_NAME='data.mat';

    id = [];
    SourceDir=[];
    Time=[];
    Area=[];
    CentralMass=[];
    
    for i=1:length(SourceDirs)
        % Load data file
        data=load(fullfile(SourceDirs(i),DATA_FILE_NAME));
        
        indexes = 1:length(ColoniesStatus);
        indexes = indexes(~ColoniesStatus);
        id = [id ; indexes];
        SourceDir=[SourceDir ; repmat(SourceDirs(i),[1, length(indexes)])];
        Time=[Time ; data.FilesDateTime];
        Area=[Area ; data.Area];
        CentralMass=[CentralMass ; data.CentralMass];
    end
    

end

