function [TimeAxis,AppearenceMinute] = AppearenceDistribution(FileDir)
%% [TimeAxis,AppearenceMinute] = AppearenceDistribution(FileDir)
% -------------------------------------------------------------------------
% Purpose: This function calculates when each colony started apearing
% 
% Description: The function checkes which colonies have survived, and for
%   them, it checkes, when were they first detected
% 
% Arguments: FileDir - The directory of the data
%
% Returns: TimeAxis - times of frames
%   AppearenceMinute - a vector of the appearence minute of each colony
% -------------------------------------------------------------------------
% Irit Levin. 12.2006
% Update: 03.08
% returns a vector of the appearence minute instead of How many colonies
% showed up in each frame

%% Loading data and initializations
DirName = fullfile(FileDir, 'Results');
load(fullfile(DirName,'VecArea'));
load(fullfile(DirName,'TimeAxis'));
load(fullfile(DirName,'CircParams'));
load(fullfile(DirName,'ExcludedBacteria.txt'));


%% excluding bacteria
NotCloseToBorder = FindColoniesInWorkingArea(FileDir);
RelevantColonies = setdiff(NotCloseToBorder, ExcludedBacteria);

%% Claculating the distribution
NColonies = length(RelevantColonies);
AppearenceMinute = zeros(NColonies,1);
for k=1:NColonies
    AppearenceIndex = find(VecArea(RelevantColonies(k),:),1);
    AppearenceMinute(k) = TimeAxis(AppearenceIndex);
end