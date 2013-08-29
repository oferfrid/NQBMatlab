function F = ShowPlate(TimeGap, DirName, forMovie)
%% function F = ShowPlate(TimeGap, DirName, forMovie)
% -------------------------------------------------------------------------
% Purpose: showing the result file of the plate with the marked colonies
%
% Arguments: TimeGap - Time since first picture.
%           FileDir(optional) - Directory of the files.
%           forMovie(optional) - true if this is for movie making purposes
%
% Returns: F - frame for movie
% -------------------------------------------------------------------------
% Irit Levin. 20.10.2006.
% updates
% Irit Levin. 13.01.2008
% -------------------------------------------------------------------------

%% constants
r = 440;
x = 526; y=526;

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
%[pathstr, FileDir, ext, versn] = fileparts(DirName);
[pathstr, name, ext]= fileparts(DirName);

dirOutput = dir(fullfile(DirName, 'Pictures', '*.tif'));
FileVec = {dirOutput.name}';

%% Loading the timeAxis file
TimeAxis = 0;
load(fullfile(DirName, 'Results', 'TimeAxis'));
FileNum  = find(round(TimeAxis) == TimeGap);

%% Reading the picture, and the data files
PName    = char(FileVec(FileNum));
LName    = char(FileVec(end));     % loading last frame's L for the colours
LName    = LName(1:8);
LName(1) = 'L';

% if the cleaned image is still saved, reads it from the file instead of
% cleaning it (which takes a lot of time
dirRes = dir(fullfile(DirName, 'tmpCleanImg'));
tmpClnImgExist = size(dirRes,1);
if tmpClnImgExist
    FullPName = fullfile(DirName, 'tmpCleanImg', ['cln' PName]);
    FullPName(end-2:end) = 'jpg'; 
    clnImg = double(imread(FullPName))/255;
else
    FullPName = fullfile(DirName,'Pictures',PName);
    I = rgb2gray(double(imread(FullPName))/(255));
    clnImg = cleanImg(I);
end
    
FullLName = fullfile(DirName, 'LRGB', LName);
load(FullLName);
load(fullfile(DirName, 'Results', 'CircParams'));
CenFile = fullfile(DirName, 'Results', 'VecCen');
load(CenFile);

%% clouring the colonies
Lrgb = label2rgb(L, 'jet', 'k', 'shuffle');
LName = PName(1:8);  % loading this frame's L - for the size of each colony
LName(1) = 'L';
FullLName = fullfile(DirName,'LRGB',LName);
load(FullLName);
ColonyLoc = uint8(L~=0);
for k=1:3
    LrgbSized(:,:,k) = ColonyLoc.*Lrgb(:,:,k);
end

%% showing the plate

% resize for movie
if forMovie
    clnImg = imresize(clnImg, 0.5);
    LrgbSized= imresize(LrgbSized, 0.5);
    VecCen = round(VecCen/2);
    X      = round(x(1)/2);
    Y      = round(y(1)/2);
    r      = r/2;
else
    X      = x(1);
    Y      = y(1);
    %figure;
end

ColoniesCM = find(VecCen(:,1,FileNum));
ColoniesNum = size(ColoniesCM,1);
h = LrgbShow(LrgbSized, clnImg, X, Y, r, ColoniesNum);

%% excluding bacteria
load(fullfile(DirName,'Results', 'ExcludedBacteria.txt'));

%% numbering the colonies
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
        
        text (VecCen(ColoniesCM(k),1,FirstTime), VecCen(ColoniesCM(k),2,FirstTime),...
              num2str(ColoniesCM(k)),'color',colourText ,'BackgroundColor','none',...
              'FontSize',8, 'FontWeight', WeightText);
    end
end

NumOfColonies = length(setdiff(ColoniesCM, ExcludedBacteria)); % num of colonies without excluded bacteria
description = getDescription(DirName);
FigTitle = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   description, TimeGap, NumOfColonies);
title(FigTitle);
drawnow;

F = getframe(h);
% impixelinfo