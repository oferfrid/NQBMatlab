function ProcessPictures(DirName)
%%
% ProcessPictures(DirName)
%--------------------------------------------------------------------------
% Purpose: prearing the pictures for matching colonies
%
% Description: going over all the *.tif files in the directory, cleaning
%       the images and saving it in a temporary dir, and saving a L file
%       which is the result of 'connected components' algorithm
%
% Arguments: DirName - a full directory name
%
% Output: L%_00000.mat - connected components files under the directory
%       DirName\LRGB
%       clnP%_00000.jpg - the clean image in a jpg format, saved temporarly
%       for the movie under DirName\tmpCleanImg
%--------------------------------------------------------------------------
% Irit Levin, 01.2008

%% constatnts
r = 440;    % the relevant radius in the plate in pixels
x = 526; y=526;
Min_Thresh = 0.15;       % minimal threshold for bw picture
TH = 8/255;

%% getting the list of the files
picDir    = fullfile(DirName, 'Pictures');
dirOutput = dir(fullfile(picDir,'*.tif'));
FileVec   = {dirOutput.name}';

%% making a directory for the output files
[successMK,mgsMK,msgidMK] = mkdir(DirName,'LRGB');
if ~successMK
    error(msgidMK, mgsMK);
end
[successMK,mgsMK,msgidMK] = mkdir(DirName,'tmpCleanImg');
if ~successMK
    error(msgidMK, mgsMK);
end
LRGB_Dir = fullfile(DirName,'LRGB');
clnImg_Dir = fullfile(DirName,'tmpCleanImg');

% %% getting the Time axis from the names of the files
% % file name is 'P#_00000.tif' where 000000 is the number of seconds from
% % the first picture
% MinFromFirst = char(FileVec);
% MinFromFirst = MinFromFirst(:,4:8);   
% TimeAxis     = str2double(MinFromFirst);

%% looking at the relevant area in the plate
% creating an indices matrix, and a distance from the centre matrix
FullFileName = fullfile(picDir, char(FileVec(1)));
I = rgb2gray(double(imread(FullFileName))/255);
load(fullfile(DirName,'Results', 'CircParams'));
[rows, cols]  = size(I);
indMat(:,:,1) = repmat([1:rows]', 1, cols);
indMat(:,:,2) = repmat([1:cols] , rows ,1);
dist = sqrt((indMat(:,:,2)-x(1)).^2+(indMat(:,:,1)-y(1)).^2);
relevantArea = dist<=r;

%% initialize a progress bar
progress_bar = waitbar(0);

%% cleaning all frames
NumOfFiles = size(FileVec,1);
bg = imread(FullFileName); %%% 19.1.09

for k=1:NumOfFiles
    %% reading the next file in the list
    msg = sprintf('Processing picture %d/%d', k,NumOfFiles);
    waitbar(k/NumOfFiles, progress_bar, msg);
    
    FullFileName = fullfile(picDir, char(FileVec(k)));
    I = imread(FullFileName);

    %% cleaning the noises
    clnImg = cleanImgNew(I,bg);
    
    %% cleaning the noises fast method
%     clnImg = imsubtract(I, bg*0.5); 

    Mask = im2bw( clnImg,TH);
    relevantImage =  medfilt2(Mask);
    BW = relevantArea.*im2double(relevantImage);
    
    %% getting rid of small noises
    %SE = strel('disk',2);
    %relevantImage = imopen(relevantImage1,SE);
    
    %% labeling the different colonies with 'connencted components' algorithm
     %level(k) = max(graythresh(relevantImage),Min_Thresh);
    level(k) = TH;
%     BW   = relevantImage1;
    L = bwlabel(BW);
    
    %% saving the picture
    % connected components
    LrgbName = char(FileVec(k));
    LrgbName = LrgbName(1:end-4);
    LrgbName(1) = 'L';
    FullName = fullfile(LRGB_Dir, LrgbName);
    save(FullName,'L');
    % clean image
    TmpClnImg = ['cln' char(FileVec(k))];
    TmpClnImg(end-2:end) = 'jpg';
    FullName = fullfile(clnImg_Dir, TmpClnImg);
    imwrite(clnImg ,FullName ,'jpg');
    % Threshold vector
    FullName = fullfile(DirName,'Results', 'ThresholdVec');
    save(FullName,'level');
end
close(progress_bar);

