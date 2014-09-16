function [id,Time,Area,Centroid] = getPropInTime(SourceDirs)
    DATA_FILE_NAME='data.mat';
    
    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    numOfDirs=length(SourceDirs);
    
    id = cell(numOfDirs);
    Time=cell(numOfDirs);
    Area=cell(numOfDirs);
    Centroid=cell(numOfDirs);
    
   for i=1:numOfDirs
        % Load data file
        data=load(fullfile(SourceDirs{i},DATA_FILE_NAME));
        
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

