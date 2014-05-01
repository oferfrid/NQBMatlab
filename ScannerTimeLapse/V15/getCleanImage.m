%% function getCleanImage(DirName,BW,TimeGap)
% -------------------------------------------------------------------------
% Purpose: Return a clean image (i.e. substruction of the background from
% the image.
%
% Arguments: DirName - The base directory
%            BW - 1 if image is grayscale and 0 if not
%            TimeGap - the time to take the image of
% Return: The image.
% -------------------------------------------------------------------------
% Nir Dick 4.2014
% -------------------------------------------------------------------------
function [ clnImg ] = getCleanImage(DirName,BW,TimeGap)
    dirOutput = dir(fullfile(DirName, 'Pictures', '*.tif'));
    FileVec = {dirOutput.name}';

    %% Loading the timeAxis file
    TimeAxis = 0;
    load(fullfile(DirName, 'Results', 'TimeAxis'));
    FileNum  = find(TimeAxis <= TimeGap, 1, 'last');

    %% Reading the picture, and the data files
    PName    = char(FileVec(FileNum));

    if BW
        % if the cleaned image is still saved, reads it from the file instead of
        % cleaning it (which takes a lot of time
        dirRes = dir(fullfile(DirName, 'tmpCleanImg'));
        tmpClnImgExist = size(dirRes,1);
        if tmpClnImgExist
            FullPName = fullfile(DirName, 'tmpCleanImg', ['cln' PName]);
            FullPName(end-2:end) = 'jpg';
            clnImg = im2double(imread(FullPName));
        else
            FullPName = fullfile(DirName,'Pictures',PName);
            I = rgb2gray(im2double(imread(FullPName)));
            clnImg = cleanImg(I);
        end
    else
        FullPName = fullfile(DirName,'Pictures',PName);
        clnImg = im2double(imread(FullPName));
end

