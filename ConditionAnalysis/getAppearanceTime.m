function [ApperanceTime] = getAppearanceTime(SourceDirs,BeginTimes)
    dataFlag=0;
    if nargin<2
        dataFlag=1;
        BeginTimes=zeros(size(SourceDirs));
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
        data=load(GetDataName(SourceDirs{i}));
        
        if dataFlag&&isfield(data,'StartingTime')
            currBeginTime=data.StartingTime;
        else
            currBeginTime=BeginTimes(i);
        end
        
        indexes = 1:length(data.IgnoredColonies);
        indexes = indexes(~data.IgnoredColonies);
        
        [~,I]=max(data.Area(:,indexes)>0,[],1);
        PlateAppearanceTime = data.FilesDateTime(I);
        
        PlateAppearanceTime=PlateAppearanceTime-currBeginTime;
        
        if currBeginTime
            PlateAppearanceTime=round(PlateAppearanceTime*24*60);
        end
               
        ApperanceTime.plate=[ApperanceTime.plate,i*ones(size(indexes))];
        ApperanceTime.id=[ApperanceTime.id,indexes];
        ApperanceTime.time=[ApperanceTime.time,PlateAppearanceTime];
    end
end
