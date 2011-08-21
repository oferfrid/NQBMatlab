function [TimeAxis,TotalDistr]=AddHistogramsBar(DirVec, plotHist)
% [TimeAxis,TotalDistr]=AddHistogramsBar(DirVec, plotHist)
% -------------------------------------------------------------------------
% Purpose: This function calculates the common distribution of severeal
%   plates from the same experiment.
% 
% Description: calls AppearenceDistribution for each plate and adds
% 
% Arguments: DirVec - A cell array of the names of the directories
%          plotHist(optional) - ploting the histogram or not
%
% Returns: TotalDistr - the sum of the histograms
%          TimeAxis
% -------------------------------------------------------------------------
% Irit Levin. 01.2007
% update: 03.08
% using hist so that the pictures from both scanners, which have a different 
% time axis, would be calculated into the same histogram

DirNum = size(DirVec,1);

% Calculating the distribution for all the directories
TotalAppearenceMinute = [];
for k=1:DirNum
    FileDir = char(DirVec(k));
    [TimeAxis,AppearenceMinute] = AppearenceDistribution(FileDir);
    TotalAppearenceMinute = [TotalAppearenceMinute; AppearenceMinute];
end

if nargin == 1
    plotHist = false;
end

TotalDistr = hist(TotalAppearenceMinute, TimeAxis);
% plot the histogram
if plotHist
    %ShowAppearenceDist(TimeAxis ,TotalAppearenceMinute, FileDir);
    ShowAppearenceDistBar(TimeAxis ,TotalDistr , FileDir);
end