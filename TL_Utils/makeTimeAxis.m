function TimeAxis = makeTimeAxis(FileDir,startTime,logDir)
% TimeAxis = makeTimeAxis(FileDir)
%--------------------------------------------------------------------------
% Purpose : creating the Time Axis from the original files
% Description : Reading the time of creation of all the files, and
%       subtracting the first date from the rest.
% Arguments : FileDir - the directory of the pictures
%             startTime - a string that represent a lower bound for the
%                         time axis. deafult - empty string.
%             logDir - a directory for the log file of the experimant, in
%                      case we want to take the starting time from it.
%                      default - FileDir
% Returns : TimeAxis - the time in minutes from the first picture
%--------------------------------------------------------------------------
% Irit Levin. 14.05.2007
% -------------------------------------------------------------------------
% Updates: 
% Ofer Fridman 11.09 - VecDate = [dirOutput.datenum]
% Nir Dick 9.9.2013 - adding startTime, logDir

if (nargin==1)
    startTime='';
    logDir=FileDir;
elseif ((nargin==2)||strcmp(logDir,''))
    logDir=FileDir;
end
    
if strcmp(startTime,'')
    fid = fopen(fullfile(logDir, 'LogFile.txt'));
    firstLine=fgets(fid);
    fclose(fid);
        
    % get the time from the first line
    [startIndex,endIndex] = regexpi(firstLine,...
                                    '\d\d\d\d/\d\d/\d\d \d\d:\d\d:\d\d');
    startTime=firstLine(startIndex:endIndex);
end

startTime=datenum(startTime);

%% Getting the file list and their dates
disp([datestr(now)   '   Time Axis']);
dirOutput = dir(fullfile(FileDir, '*.tif'));

VecDate   = [dirOutput.datenum];
FirstFile = VecDate(1)
TimeAxis  = round((VecDate-startTime)*24*60);
