function [ output_args ] = SetStartingTime(SourceDir,StartingTime,LogFile)
% output_args = SetStartingTime(SourceDir,StartingTime,LogFile)
% -------------------------------------------------------------------------
% Purpose: checking statistical parmeters for a histogram
% Arguments: 
%       SourceDir - The directory in its data file we want to save the time
%       StartingTime - The starting time in 'yyyy/mm/dd HH:MM:SS' format
%       LogFile - the log file from it to take the starting time
% Returns: 
% -------------------------------------------------------------------------
% Irit Levin Reisman. 2015
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
