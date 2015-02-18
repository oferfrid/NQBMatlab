function [ output_args ] = SetStartingTime(SourceDir,StartingTime,LogFile)
    if nargin>2
        fid = fopen(LogFile);
        firstLine=fgets(fid);
        fclose(fid);

        % get the time from the first line
        [startIndex,endIndex] = regexpi(firstLine,...
                                        '\d\d\d\d/\d\d/\d\d \d\d:\d\d:\d\d');
        StartTime=firstLine(startIndex:endIndex);
        StartingTime=datenum(StartTime,'yyyy/mm/dd HH:MM:SS');
    end
    save(GetDataName(SourceDir),'StartingTime','-append');
end

