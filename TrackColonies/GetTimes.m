function [times] = GetTimes(datain)
    % datain - if string, this is the data location
    %          if struct this is the data itself
    data=[];
    if isstruct(datain)
        data = datain;
    else
        dataFileStr=GetDataName(datain);
        data=load(dataFileStr);
    end
    
    StartTime=0;
    if isfield(data,'StartingTime')
        StartTime=data.StartingTime;
    end

    times=data.FilesDateTime;
    if StartTime
        times=round((times-StartTime)*24*60);
    end
end

