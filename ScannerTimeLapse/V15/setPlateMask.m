function setPlateMask(DirName)
% setPlateMask(DirName)
% -------------------------------------------------------------------------
% Purpose: sets the PlateMask fast.
% Arguments:DirName - Name of directory.
% -------------------------------------------------------------------------

Files = dir(fullfile(DirName,'Pictures','*.tif'));
%% getting the relevant area in the picture, unless a file already exists
% with the circle parameters
[successMK,mgsMK,msgidMK] = mkdir(DirName,'Results');
if ~successMK
    error(msgidMK, mgsMK);
end
CircFile  = dir(fullfile(DirName,'Results','CircParams.mat'));
CircExist = size(CircFile,1);
if CircExist
    load(fullfile(DirName,'Results','CircParams'));
else
%% constatnts
r = 436;    % the relevant radius in the plate in pixels
x = 526; y=526;
end
CImage = imread(fullfile(DirName,'Pictures',Files(end,1).name));
Image =  rgb2gray(CImage(:, :, 1:3));
CBGImage = imread(fullfile(DirName,'Pictures',Files(1,1).name));
BGImage =  rgb2gray(CBGImage(:, :, 1:3));
ClearImage  = imsubtract(Image ,BGImage);
h=figure;
imshow(ClearImage,[]);
circ = imellipse(gca, [x-r y-r 2*r 2*r]);
setFixedAspectRatioMode(circ, 1)
position = wait(circ);
minmax = [min(position); max(position)];
r=mean(diff(minmax)/2);
xy = mean(minmax);
x=xy(1);
y=xy(2);
save(fullfile(DirName,'Results','CircParams'),'x','y','r');
close(h);
