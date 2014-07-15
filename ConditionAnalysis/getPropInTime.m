function [id,SourceDir,Time,Area,Centroid] = getPropInTime(SourceDirs )
% [id,SourceDir,Time,Area,CentralMass] = getPropInTime(SourceDirs)
    

    DATA_FILE_NAME='data.mat';

    id = [];
    SourceDir=cell(0);
    Time=[];
    Area=[];
    Centroid=[];
    
    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    
    for i=1:length(SourceDirs)
        % Load data file
        data=load(fullfile(SourceDirs{i},DATA_FILE_NAME));
        
        indexes = 1:length(data.IgnoredColonies);
        indexes = indexes(~data.IgnoredColonies);
        id = [id indexes];
        SourceDir={SourceDir ; repmat(SourceDirs(i),[1 length(indexes) ])};
        Time=[Time  repmat(data.FilesDateTime',[1 length(indexes) ])];
        Area=[Area  data.Area(:,indexes)];
        Centroid=[Centroid  data.Centroid(:,indexes,:)];
        
    end
    

end

