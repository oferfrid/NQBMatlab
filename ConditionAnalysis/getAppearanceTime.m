function [id,AppearanceTime ] = getAppearanceTime( SourceDirs )
    
    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    numOfSources=length(SourceDirs);
    
    id=cell(numOfSources);
    AppearanceTime=cell(numOfSources);
    
    for i=1:numOfSources
        % Load data file
        data=load(fullfile(SourceDirs{i},GetDefaultDataName));
        
        indexes = 1:length(data.IgnoredColonies);
        indexes = indexes((~data.IgnoredColonies)&(data.Area(end,:)>0)');
        id{i}=indexes;
        
        [~,I]=max(data.Area(:,indexes)>0,[],1);
        PlateAppearanceTime = data.FilesDateTime(I);
        AppearanceTime{i}=PlateAppearanceTime;
    end
end

