%Nir - add handles
function himage = PlotPlateAnalysis(TimeGap, DirName, forMovie,handles)
%% function PlotPlateAnalysis(TimeGap, DirName, forMovie)
% -------------------------------------------------------------------------
% Purpose: showing the result file of the plate 
%
% Arguments: TimeGap - Time since first picture.
%           FileDir(optional) - Directory of the files.
%           forMovie(optional) - true if this is for movie making purposes
%
% Returns: himage - The handle to the LRGB layer
% -------------------------------------------------------------------------
% Irit L. Reisman 01.09.2011
% -------------------------------------------------------------------------


%% File list
if nargin == 1
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
    forMovie = false;
elseif nargin == 2
    forMovie = false;
end

if nargin<4
    handle=gca;
end

prevh=gca;
axes(handles);

%% loading the list of files
LRGBDir = fullfile(DirName, 'LRGB');
dirOutput = dir(fullfile(LRGBDir, '*.mat'));
FileVec = {dirOutput.name}';

%% Loading the timeAxis, Centres, plate parameters, excluded bact
ResultsDir= fullfile(DirName, 'Results'); 
load(fullfile(ResultsDir, 'TimeAxis'));
load(fullfile(ResultsDir, 'CircParams'));

%% Reading the picture, and the data files
FileNum  = find(TimeAxis <= TimeGap, 1, 'last');
currLName    = fullfile(LRGBDir,char(FileVec(FileNum)));
LastLName    = fullfile(LRGBDir,char(FileVec(end)));  % loading last frame's L for the colours
load(LastLName);

%% clouring the colonies
Lrgb = label2rgb(L, 'jet', 'k', 'shuffle');
load(currLName);      % loading this current frame's L - for the size of each colony
ColonyLoc = uint8(L~=0);

for k=1:3
    LrgbSized(:,:,k) = ColonyLoc.*Lrgb(:,:,k);
end



%% resize for movie
if forMovie
    LrgbSized= imresize(LrgbSized, 0.5);
    x      = round(x/2);
    y      = round(y/2);
    r      = r/2;
end

%% showing the LRGB
% h = gcf;
hold on;
himage = imshow(LrgbSized,'InitialMagnification','fit','Parent',handles);

% Nir - add Tag ImageColony
set(himage,'Tag','ImageColony');
set(himage, 'AlphaData', 0.5);
circle([x,y],r ,500,'r-',handles);

%% Title
NColonies = NumberOfColonies(DirName);
description = getDescription(DirName);
FigTitle = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   description, TimeGap, NColonies);
title(handles,FigTitle);

%Nir - remove draw now 
%drawnow;

axes(prevh);
% F = getframe(h);
% impixelinfo
end