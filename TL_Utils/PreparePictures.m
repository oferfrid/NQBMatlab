function  PreparePictures(DestDirName, board, plateVec,...
                                        SourceDirName,logFile,startTime)
% PreparePictures( DestDirName, board, plateVec, SourceDirName )
% -------------------------------------------------------------------------
% Purpose: makes all the necessary preparations for TimeLapse to work
% Description: Alignes the pictures, finds the plates and cuts the picture.
%              If no previous time axis exists the whole new time axis 
%              will be processed.
% Arguments: DestDirName - directory full name
%       plateVec - plates to cut
%       board - The board used for the scan
%       SourceDirName (optional) - source files dir
%       logFile - the directory and name of the log file. default - empty string
%       startTime - a lower bound for the time axis. default - empty string
% Output files: DestDirName/circlesVec.mat
%       DestDirName/motions.mat
%       DestDirName/TimeAxis.mat
%       DestDirName_# - a folder for each plate
% -------------------------------------------------------------------------
% Irit Levin 01.2008
% Update - Nir Dick, continueExp being added

%% getting the arguments not supplied
if nargin == 2
    plateVec = 1:6;
    SourceDirName = uigetdir;
    if isequal(DestDirName,0)
        return;
    end
end
if nargin == 3
    SourceDirName = uigetdir;
    if isequal(DestDirName,0)
        return;
    end
end

[successMK,mgsMK,msgidMK] = mkdir(DestDirName);
if ~successMK
    error(msgidMK, mgsMK);
end

if nargin <= 4
    startTime='';
    logFile='';
elseif (nargin==5)
    startTime='';
end

ConfigurationFile;

%% time axis
% Calculate the range of pictures process.
% If no previous expirement exists (i.e. no time axis), start the
% processing from the begining of the experiment.
% If previous time axis exists but its last time is later then current time
% axis late time, start processing from the begining of the experiment.
% If previous time axis exists and its last time is before current
% experiment last time, process images between previous last time to
% current last time.

prevTimeAxisExists = dir(fullfile(DestDirName,'TimeAxis.mat'));

if (~isempty(prevTimeAxisExists))
    prevTimeAxis=load(fullfile(DestDirName,'TimeAxis'),'TimeAxis');
    prevSize=size(prevTimeAxis.TimeAxis,2);
    
    TimeAxis = makeTimeAxis(SourceDirName,startTime,logFile);
    save(fullfile(DestDirName,'TimeAxis'),'TimeAxis');    
    currSize=size(TimeAxis,2);
    
    if (currSize-prevSize>=0)
        prevLastInd=prevSize;
        cutStartInd=prevLastInd+1;
    else
        prevLastInd=1;
        cutStartInd=1;
    end
else
    TimeAxis = makeTimeAxis(SourceDirName,startTime,logFile);
    save(fullfile(DestDirName,'TimeAxis'),'TimeAxis');
    prevLastInd=1;
    cutStartInd=1;
end


%% find plates
% disp([datestr(now), '   FIND PLATES'])
str=fullfile(SourceDirName, '*.tif');
dirOutput = dir(str);
FileVec   = {dirOutput.name}';
% checking if exist
circlesFile = fullfile(DestDirName, 'circlesVec.mat');
circlesExist = dir(circlesFile);
if isempty(circlesExist)
    I_4 =  imread( fullfile(SourceDirName,char(FileVec(1))) ) ;
    I = rgb2gray(im2double( I_4(:,:,1:3) ));
    [circlesVec]=findPlates(I, board)
    save(circlesFile,'circlesVec');
else
    circ = load(circlesFile);
    circlesVec = circ.circlesVec;
end

%% align pictures
motions = FindMotions(SourceDirName, DestDirName,prevLastInd);

%% cut picture
CutPicture(SourceDirName, DestDirName, plateVec , circlesVec,cutStartInd);
