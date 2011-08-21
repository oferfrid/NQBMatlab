function [TimeAxis,TotalAppearenceTime]=GetAppearanceTimes(DirVec)
% [TimeAxis,TotalAppearenceTime]=GetAppearanceTimes(DirVec)
% -------------------------------------------------------------------------
% Purpose: This function calculates the common distribution of severeal
%   plates from the same experiment.
% 
% Description: calls AppearenceDistribution for each plate and adds
% 
% Arguments: DirVec - A cell array of the names of the directories
%
% Returns: TotalAppearenceTime - time of appearance for all plates
%          TimeAxis
% -------------------------------------------------------------------------
% Irit Levin. 01.2007
% update: 03.08
% using hist so that the pictures from both scanners, which have a different 
% time axis, would be calculated into the same histogram

DirNum = size(DirVec,1);

% Calculating the distribution for all the directories
TotalAppearenceTime = [];
for k=1:DirNum
    FileDir = char(DirVec(k));
    [TimeAxis,AppearenceTime] = AppearenceDistribution(FileDir);
    TotalAppearenceTime = [TotalAppearenceTime; AppearenceTime];
end