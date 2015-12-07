function [id,Time,Area,Centroid] = getPropInTime(SourceDirs)
    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    numOfDirs=length(SourceDirs);
    
    id = cell(1,numOfDirs);
    Time=cell(1,numOfDirs);
    Area=cell(1,numOfDirs);
    Centroid=cell(1,numOfDirs);
    
   for i=1:numOfDirs
        % Load data file
        data=load(GetDataName(SourceDirs{i}));
        
        % Build the id vecs - colonie's id and source dir
        indexes = 1:length(data.IgnoredColonies);
        indexes = indexes(~data.IgnoredColonies);
        id{i}=indexes;
        
        % Load add the times arrea
        Time{i}=data.FilesDateTime;
        Area{i}=data.Area(:,indexes);
        Centroid{i}=data.Centroid(:,indexes,:);
   end
end

