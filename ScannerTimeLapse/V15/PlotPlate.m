function PlotPlate(TimeGap, DirName, BW, forMovie,handle)
%% function PlotPlate(TimeGap, DirName, forMovie)
% -------------------------------------------------------------------------
% Purpose: showing the result file of the plate with the marked colonies
%
% Arguments: TimeGap - Time since first picture.
%           FileDir(optional) - Directory of the files.
%           BW (optional)     - image in {BW}/RGB
%           forMovie(optional) - true if this is for movie making purposes
% -------------------------------------------------------------------------
% Irit L. Reisman 01.09.2011 
% -------------------------------------------------------------------------

s = warning('query', 'all');
warning('off','Images:initSize:adjustingMag');
 
%% File list
if nargin == 1
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
    BW = true;
    forMovie = false;
elseif nargin == 2
    BW = true;
    forMovie = false;
elseif nargin == 3
    forMovie = false;
end

if nargin<5
    handle=gca;
end

%prevh=gca;
%axes(handle);

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


%% showing the plate

% resize for movie
if forMovie
    clnImg = imresize(clnImg, 0.5);
end

% Nir - handle added and Tag and axis image
himage=imshow(clnImg,[],'Parent',handle);
set(himage,'Tag','ImageColony');

%% Title
NColonies = NumberOfColonies(DirName);
description = getDescription(DirName);
FigTitle = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   description, TimeGap, NColonies);
title(handle,FigTitle);


% Nir remove draw now
%drawnow;

warning(s)
% h = gcf;
%axes(prevh);
% F = getframe(h);
