function [ApperanceTime] = getAppearanceTime(SourceDirs,DataTimeFlag,BeginTimes)

    substract=0;
    sentTimeFlag=0;
    if nargin < 2
        DataTimeFlag=false;
    else
        substract=1;
        
        if nargin > 2
            sentTimeFlag=1;
            if(~iscell(BeginTimes))
                BeginTimes = {BeginTimes};
            end
        end
    end

    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    numOfSources=length(SourceDirs);
    
    ApperanceTime.plate=[];
    ApperanceTime.id=[];
    ApperanceTime.time=[];
    
    for i=1:numOfSources
        % Load data file
        data=load(fullfile(SourceDirs{i},GetDefaultDataName));
        
        if isfield(data,'StartingTime') && DataTimeFlag
            currBeginTime=data.StartingTime;
        elseif sentTimeFlag
            currBeginTime=BeginTimes{i};
        else
            substract=0;
        end
        
        indexes = 1:length(data.IgnoredColonies);
        indexes = indexes((~data.IgnoredColonies)&(data.Area(end,:)>0)');
        
        [~,I]=max(data.Area(:,indexes)>0,[],1);
        PlateAppearanceTime = data.FilesDateTime(I);
        
        if substract
            PlateAppearanceTime=round((PlateAppearanceTime-currBeginTime)*24*60);
        end
               
        ApperanceTime.plate=[ApperanceTime.plate,i*ones(size(indexes))];
        ApperanceTime.id=[ApperanceTime.id,indexes];
        ApperanceTime.time=[ApperanceTime.time,PlateAppearanceTime];
    end
end

