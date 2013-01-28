function [r,p] = plotDistanceVsGrowth(DirName, L)
%% function plotDistanceVsGrowth(DirName)
% -------------------------------------------------------------------------
% Purpose: Plots The Growth against the weighted distance
%
% Arguments: DirName(optional) - Directory of the files.
% -------------------------------------------------------------------------
% Irit L. Reisman 14.11.2011
% -------------------------------------------------------------------------

%% Constants
% L = 60;    % Typical Effecting Length
lb = 20;
ub = 80;

%% File list
if nargin == 0
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
end


%% Loading the timeAxis, Centres, plate parameters, excluded bact
ResultsDir= fullfile(DirName, 'Results'); 
load(fullfile(ResultsDir, 'TimeAxis'));
load(fullfile(ResultsDir, 'VecArea'));
ExcludeFile= fullfile(ResultsDir, 'ExcludedBacteria.txt');
ExcludedBacteria = load(ExcludeFile);

%% Calculating Time Diffrences
NColonies = size(VecArea,1);
AppearenceMinute = zeros(NColonies,1);
for k=1:NColonies
    AppearenceIndex = find(VecArea(k,:),1);
    AppearenceMinute(k) = TimeAxis(AppearenceIndex);
end
spots = find(VecArea(:,end)==0); % All colonies at end
AppearenceMinute(ExcludedBacteria) = 0;
AppearenceMinute(spots) = 0;


AppearanceMat = repmat(AppearenceMinute, 1, NColonies);
TimeDiff      = AppearanceMat' - AppearanceMat - 2*60;
TimeDiff(ExcludedBacteria,:) = 0;
TimeDiff(:,ExcludedBacteria) = 0;
TimeDiff(spots,:) = 0;
TimeDiff(:,spots) = 0;

%% adding weight only of colonies that grew before
GrewAfter = zeros(size(TimeDiff));
GrewAfter(TimeDiff>0) = 1;

%% Distance Weights 
Dist = ColoniesDistances(DirName);
Weights = exp(-Dist./L);
WeightsTime = Weights.*GrewAfter;

WeightedDist = sum(WeightsTime);

%% get Growth rate
[ColoniesGrowth, CID] = getColoniesGrowthRate(DirName, lb, ub);
% CID = FindColoniesInWorkingArea(DirName);

%% correlation calculation
[r,p] = corr(WeightedDist(CID)',ColoniesGrowth);

%% plot
figure;
plot(ColoniesGrowth, WeightedDist(CID),'o');
title(['L = ' num2str(L)])
xlabel('Growth (pixels)')
ylabel('Weighted distance')
% figure;
% plot(VecArea(CID,end),WeightedDist(CID),'o');
% xlabel('Final Area (pixels)')
% ylabel('Weighted distance')