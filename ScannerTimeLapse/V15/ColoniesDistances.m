function Dist = ColoniesDistances(DirName)
%% function ColoniesDistances(DirName)
% -------------------------------------------------------------------------
% Purpose: Marks the colonies numbers on the plate
%
% Arguments: DirName(optional) - Directory of the files.
% -------------------------------------------------------------------------
% Irit L. Reisman 01.09.2011
% -------------------------------------------------------------------------


%% File list
if nargin == 0
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
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


%% CM of the colonies
NColonies = size(VecCen,1);
FirstCM    = zeros(NColonies,2);
for k=1:NColonies
    FirstTime = find(VecCen(k,1,:), 1, 'first');
    FirstCM(k,:) = VecCen(k,:,FirstTime);
end
spots = find(VecCen(:,1,end)==0); % All colonies at end

%% Calculating distance from all colonies
gridX = repmat(FirstCM(:,1),1,NColonies);
gridY = repmat(FirstCM(:,2),1,NColonies);
DistX = gridX'-gridX;
DistY = gridY'-gridY;

DistX(ExcludedBacteria,:) = 0;
DistX(spots,:) = 0;
DistX(:,ExcludedBacteria) = 0;
DistX(:,spots) = 0;

DistY(ExcludedBacteria,:) = 0;
DistY(spots,:) = 0;
DistY(:,ExcludedBacteria) = 0;
DistY(:,spots) = 0;

Dist  = sqrt(DistX.^2+DistY.^2);


