function motions = FindMotions(SourceDirName, DestDirName)
% motions = FindMotions(SourceDirName, DestDirName)
% -------------------------------------------------------------------------
% Purpose: Align pictures.
% Description: using GM's fullPyrMotion_trans
% Arguments: SourceDirName - The dirctory of the tif files
%       DestDirName - The dirctory of the result files
%       GenFileName - general file name (e.g. 'img*')
% Returns: motions - an array of the movement relative to the first picture
% Output: DirName\Results\motions.mat
% -------------------------------------------------------------------------
% Irit Levin Reisman. 10.2008

%% initialization
% addpath 'C:\Documents and Settings\Irit\My Documents\MATLAB\DEVELOP\GeneralUtilities\MGBacteriaTracker\motion'

disp([datestr(now)   '   Calculating Motion']);
[successMK,mgsMK,msgidMK] = mkdir(DestDirName);
if ~successMK
    error(msgidMK, mgsMK);
end
motions = [0 0];
% CropRect = [20 800 1800 700];
% rect: [xmin ymin width height]
CropRect = [870 800 900 800];


%% aligning pictures
% calculation motion if the file doesn't aleady exist
motionsFile = fullfile(DestDirName, 'motions.mat');
motionExist = dir(motionsFile);
if isempty(motionExist)
    %initialize a progress bar
    progress_bar = waitbar(0);
    progress = 0;
    
    % going over all the files
    FullFileName = fullfile(SourceDirName, '*.tif');
    dirOutput  = dir(FullFileName);
    FileVec    = {dirOutput.name}';
    NumOfFiles = size(FileVec,1);
    
    % calculate motion in multi-resolution using the selected motion
    % calculation method.
    % the pictures are very big so they are converted to grayscale and
    % cropped
    Img_4 = im2double(imread( fullfile( SourceDirName,char(FileVec(1)) ) ));
    Img = rgb2gray(Img_4(:,:,1:3));
    BaseCropped = imcrop(Img, CropRect);
%     figure; imshow(BaseCropped);
    clear Img_4 Img
    for k=2:NumOfFiles
%        progress = progress + 1;
        waitbar(k/NumOfFiles, progress_bar, ...
                sprintf('Calculating Motion: image %d/%d', k,NumOfFiles));
    
        Img_4 = im2double(imread( fullfile( SourceDirName,char(FileVec(k)) ) ));
        Img = rgb2gray(Img_4(:,:,1:3));
        CurrCropped = imcrop(Img, CropRect);
        clear Img_4 Img
        [u v] = fullPyrMotion_trans(BaseCropped, CurrCropped);
        % add the translation valuses into the result vector
        motions = [motions; u v];
        BaseCropped = CurrCropped;
%         figure; imshow(BaseCropped);
    end
    
    save(motionsFile,'motions');
    %close(progress_bar);
else
    mot=load(motionsFile);
    motions = mot.motions;
end