function [TimeAxis,TotalAppearanceTime]=GetAppearanceTimes(DirVec)
% [TimeAxis,TotalAppearanceTime]=GetAppearanceTimes(DirVec)
% -------------------------------------------------------------------------
% Purpose: This function calculates the common distribution of severeal
%   plates from the same experiment.
% 
% Description: calls AppearanceDistribution for each plate and adds
% 
% Arguments: DirVec - A cell array of the names of the directories
%
% Returns: TotalAppearanceTime - time of appearance for all plates
%          TimeAxis
% -------------------------------------------------------------------------
% Irit Levin. 01.2007
% update: 03.08
% using hist so that the pictures from both scanners, which have a different 
% time axis, would be calculated into the same histogram

DirNum = size(DirVec,1);

% Calculating the distribution for all the directories
TotalAppearanceTime = [];
for k=1:DirNum
    FileDir = char(DirVec(k));
    [TimeAxis,AppearanceTime] = AppearanceDistribution(FileDir);
    TotalAppearanceTime = [TotalAppearanceTime; AppearanceTime];
end