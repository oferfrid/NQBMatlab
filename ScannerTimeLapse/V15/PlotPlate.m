function PlotPlate(TimeGap, DirName, BW, forMovie,handle,limits)
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

if nargin <6
    limits='';
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
    
clnImg=getCleanImage(DirName,BW,TimeGap);

% clean the unrelevant area of the image
clnImgRelevant=getImageRelevantArea(DirName,clnImg,BW);

%% showing the plate

% resize for movie
if forMovie
    clnImg = imresize(clnImg, 0.5);
end

if isempty(limits)
    limits = stretchlim(clnImgRelevant);
end

clnImg = imadjust(clnImg, limits,[]);
% Nir - handle added and Tag and axis image
himage=imshow(clnImg,[],'Parent',handle);
set(himage,'Tag','ImageColony');
set(himage, 'AlphaData', 0.5);


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
