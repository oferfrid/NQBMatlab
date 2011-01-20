function PreparePictures(board, plateVec, DirName )
% PreparePictures(board, plateVec, DirName )
% -------------------------------------------------------------------------
% Purpose: makes all the necessary preparations for TimeLapse to work
% Description: Alignes the pictures, finds the plates and cuts the picture.
% Arguments: DirName(optional) - directory full name
%       plateVec - plates to cut
%       board - The board used for the scan
% Output files: under DirNameA all the aligned pictures. SHOULD BE DELETED
%       AFTER CUT PICTURE
%       DirName_# - a folder for each plate
% -------------------------------------------------------------------------
% Irit Levin 01.2008

%% getting the arguments not supplied
if nargin == 1
    plateVec = 1:6;
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
end
if nargin == 2
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
end

%% find plated
disp([datestr(now), '   FIND PLATES'])
dirOutput = dir(fullfile(DirName, '*.tif'));
FileVec   = {dirOutput.name}';
I_4 =  imread( fullfile(DirName,char(FileVec(1))) ) ;
I = rgb2gray(double( I_4(:,:,1:3) )/255);
[circlesVec]=findPlates(I, board)

%% align pictures
disp([datestr(now), '   ALIGN PICTURES'])
AlignAll(DirName,'*.tif');

%% time axis
disp([datestr(now), '   MAKE TIME AXIS'])
makeTimeAxis(DirName);
AlignedDir = [DirName 'A'];
[successMV,mgsMV,msgidMV] = movefile(fullfile(DirName,'TimeAxis.mat'),AlignedDir);
if ~successMV
    error(msgidMV, mgsMV);
end
%% cut picture
disp([datestr(now), '   CUT PICTURE'])
CutPicture(AlignedDir, DirName, plateVec , circlesVec);
disp('DON''T FORGET TO DELETE THE ALIGNED PICTURES !!!')