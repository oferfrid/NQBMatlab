function [ColoniesGrowth, ColoniesIndices] = getColoniesGrowthRate(FileDir, lb, ub)
%% ColonisGrowth = getColoniesGrowthRate(FileDir)
% -------------------------------------------------------------------------
% Purpose: This function calculates the growth rate of each colony
% 
% Description: The function checkes which colonies have survived, and for
%   them, it checkes, when were they first detected
% 
% Arguments: FileDir - The directory of the data
%       lb - lower bound size in pixels
%       ub - upper bound size in pixels
%
% Returns: ColoniesGrowth - vector of the times it take for each colony to
%       reach from lb size to ub size.
%       ColoniesIndices - Colony's index respectivly
% -------------------------------------------------------------------------
% Irit Levin. 11.2009

%% Loading data and initializations
DirName = fullfile(FileDir, 'Results');
load(fullfile(DirName,'VecArea'));
load(fullfile(DirName,'TimeAxis'));
load(fullfile(DirName,'CircParams'));
load(fullfile(DirName,'VecCen'));
load(fullfile(DirName,'ExcludedBacteria.txt'));

%% excluding bacteria
VecArea(ExcludedBacteria,:)   = 0;

NotCloseToBorder = FindColoniesInWorkingArea(FileDir);
bigEnoughColony = find(VecArea(:,end)>=ub);
ColoniesIndices = intersect(NotCloseToBorder, bigEnoughColony);

%% Claculating the growth rate
ColoniesGrowth = zeros(length(ColoniesIndices),1);
for k=1:length(ColoniesIndices)
    lbIndex = find(VecArea(ColoniesIndices(k),:)>=lb,1,'first');
    ubIndex = find(VecArea(ColoniesIndices(k),:)>=ub,1,'first');
    ColoniesGrowth(k) = TimeAxis(ubIndex)-TimeAxis(lbIndex);
end
