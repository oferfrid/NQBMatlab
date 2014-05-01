function TimeAxis = makeTimeAxis(FileDir,startTime,logFile)
% TimeAxis = makeTimeAxis(FileDir)
%--------------------------------------------------------------------------
% Purpose : creating the Time Axis from the original files
% Description : Reading the time of creation of all the files, and
%       subtracting the first date from the rest.
% Arguments : FileDir - the directory of the pictures
%             startTime - a string that represent a lower bound for the
%                         time axis. deafult - empty string.
%                         Please keep the 'YYYY/mm/dd HH:MM:SS' format
%             logFile - directory and name for the log file of the experimant,
%                       default - FileDir/LogFile.txt
% Returns : TimeAxis - the time in minutes from the first picture
%--------------------------------------------------------------------------
% Irit Levin. 14.05.2007
% -------------------------------------------------------------------------
% Updates: 
% Ofer Fridman 11.09 - VecDate = [dirOutput.datenum]
% Nir Dick 9.9.2013 - adding startTime, logDir
% Nir Dick 1.4.2014 - repalcing logDir in logFile

if (nargin==1)
    startTime='';
end

if ((nargin<=2)||strcmp(logFile,''))
    logFile=fullfile(FileDir,'LogFile.txt');
end
    
if strcmp(startTime,'')
    fid = fopen(logFile);
    firstLine=fgets(fid);
    fclose(fid);
        
    % get the time from the first line
    [startIndex,endIndex] = regexpi(firstLine,...
                                    '\d\d\d\d/\d\d/\d\d \d\d:\d\d:\d\d');
    startTime=firstLine(startIndex:endIndex);
end

startTime=datenum(startTime,'YYYY/mm/dd HH:MM:SS');

%% Getting the file list and their dates
disp([datestr(now)   '   Time Axis']);
dirOutput = dir(fullfile(FileDir, '*.tif'));

VecDate   = [dirOutput.datenum];
FirstFile = VecDate(1);
TimeAxis  = round((VecDate-startTime)*24*60);
