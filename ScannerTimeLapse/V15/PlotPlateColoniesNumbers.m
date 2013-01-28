function PlotPlateColoniesNumbers(TimeGap, DirName, forMovie)
%% function PlotPlateColoniesNumbers(TimeGap, DirName, forMovie)
% -------------------------------------------------------------------------
% Purpose: Marks the colonies numbers on the plate
%
% Arguments: TimeGap - Time since first picture.
%           FileDir(optional) - Directory of the files.
%           forMovie(optional) - true if this is for movie making purposes
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

%% loading the list of files
LRGBDir = fullfile(DirName, 'LRGB');
dirOutput = dir(fullfile(LRGBDir, '*.mat'));
FileVec = {dirOutput.name}';

%% Loading the timeAxis, Centres, plate parameters, excluded bact
ResultsDir= fullfile(DirName, 'Results'); 
load(fullfile(ResultsDir, 'TimeAxis'));
load(fullfile(ResultsDir, 'VecCen'));
ExcludeFile= fullfile(ResultsDir, 'ExcludedBacteria.txt');
ExcludedBacteria = load(ExcludeFile);

%% Reading the picture, and the data files
FileNum  = find(TimeAxis <= TimeGap, 1, 'last');
currLName    = fullfile(LRGBDir,char(FileVec(FileNum)));
load(currLName);      % loading this current frame's L - for the size of each colony

%% resize for movie
if forMovie
    VecCen = round(VecCen/2);
end


%% numbering the colonies
ColoniesCM = find(VecCen(:,1,FileNum)); % All colonies at time TimeGap (includes noise and colonies close to border)
ColoniesNum = size(ColoniesCM,1);
CID = FindColoniesInWorkingArea(DirName); % All colonies in th Working area at the end
CloseToBorder = setdiff(ColoniesCM,CID);

h = gcf;
hold on;

if ColoniesNum
    for k=1:ColoniesNum
        FirstTime = find(VecCen(ColoniesCM(k),1,:), 1, 'first');
        colourText = 'w';
        WeightText = 'normal';
        % marking in red the new colonies
        if FirstTime == FileNum
            colourText = 'r';
            WeightText = 'demi';
        end
        % marking in blue the colonies that are going to disapear
        if FileNum<length(TimeAxis)
            if ~VecCen(ColoniesCM(k),1,FileNum+1)
                colourText = 'b';
                WeightText = 'demi';
            end
        end
        % marking the excluded bacteris in yellow
        if size(find(ExcludedBacteria==ColoniesCM(k)),1 )
            colourText = 'y';
        end
        % marking the colonies close to the border magenta
        if any(ColoniesCM(k)==CloseToBorder)
            colourText = 'm';
        end
        
        text (VecCen(ColoniesCM(k),1,FirstTime), VecCen(ColoniesCM(k),2,FirstTime),...
              num2str(ColoniesCM(k)),'color',colourText ,'BackgroundColor','none',...
              'FontSize',8, 'FontWeight', WeightText,...
              'HorizontalAlignment','center');
    end
end

NColonies = NumberOfColonies(DirName);
description = getDescription(DirName);
FigTitle = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   description, TimeGap, NColonies);
title(FigTitle);
drawnow;

% F = getframe(h);
% impixelinfo