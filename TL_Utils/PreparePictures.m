function PreparePictures( DestDirName, board, plateVec, SourceDirName )
% PreparePictures( DestDirName, board, plateVec, SourceDirName )
% -------------------------------------------------------------------------
% Purpose: makes all the necessary preparations for TimeLapse to work
% Description: Alignes the pictures, finds the plates and cuts the picture.
% Arguments: DestDirName - directory full name
%       plateVec - plates to cut
%       board - The board used for the scan
%       SourceDirName (optional) - source files dir
% Output files: DestDirName/circlesVec.mat
%       DestDirName/motions.mat
%       DestDirName/TimeAxis.mat
%       DestDirName_# - a folder for each plate
% -------------------------------------------------------------------------
% Irit Levin 01.2008

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

ConfigurationFile;

%% find plates
% disp([datestr(now), '   FIND PLATES'])
dirOutput = dir(fullfile(SourceDirName, '*.tif'));
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
motions = FindMotions(SourceDirName, DestDirName);

%% time axis
TimeAxis = makeTimeAxis(SourceDirName);
save(fullfile(DestDirName,'TimeAxis'),'TimeAxis');

%% cut picture
fprintf(['Starting cut: ' DestDirName]);
CutPicture(SourceDirName, DestDirName, plateVec , circlesVec);
