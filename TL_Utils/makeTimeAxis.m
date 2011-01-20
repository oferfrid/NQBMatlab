function TimeAxis = makeTimeAxis(FileDir)
% TimeAxis = makeTimeAxis(FileDir)
%--------------------------------------------------------------------------
% Purpose : creating the Time Axis from the original files
% Description : Reading the time of creation of all the files, and
%       subtracting the first date from the rest.
% Arguments : FileDir - the directory of the pictures
% Returns : TimeAxis - the time in minutes from the first picture
%--------------------------------------------------------------------------
% Irit Levin. 14.05.2007

%% Getting the file list and their dates
disp([datestr(now)   '   Time Axis']);
dirOutput = dir(fullfile(FileDir, '*.tif'));
FileVec   = {dirOutput.name}';
DateList  = {dirOutput.date}';
VecDate   = datenum(DateList);
FirstFile = VecDate(1);
TimeAxis  = round((VecDate-FirstFile)*24*60);
% save(fullfile(FileDir,'TimeAxis'),'TimeAxis');