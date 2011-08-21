function [TimeAxis,TotalDistr]=AddHistograms(DirVec, bin, plotHist)
% [TimeAxis,TotalDistr]=AddHistograms(DirVec, plotHist)
% -------------------------------------------------------------------------
% Purpose: This function calculates the common distribution of severeal
%   plates from the same experiment.
% 
% Description: calls AppearenceDistribution for each plate and adds
% 
% Arguments: DirVec - A cell array of the names of the directories
%          bin - bins every BIN samples (1 - binned per sample)
%          plotHist(optional) - ploting the histogram or not
%
% Returns: TotalDistr - the sum of the histograms
%          TimeAxis
% -------------------------------------------------------------------------
% Irit Levin. 01.2007
% update: 03.08
% using hist so that the pictures from both scanners, which have a different 
% time axis, would be calculated into the same histogram


[TimeAxis,TotalAppearenceTime]=GetAppearanceTimes(DirVec);

if nargin == 2
    plotHist = false;
end

%     TimeAxis = TimeAxis(1:bin:end);
startTime = min(TimeAxis);
endTime = max(TimeAxis);
TimeAxis = [startTime:bin:endTime]';
TotalDistr = hist(TotalAppearenceTime, TimeAxis);

% plot the histogram
if plotHist
    FileDir = char(DirVec(k));
    ShowAppearenceDist(TimeAxis ,TotalAppearenceTime, FileDir, nbins);
end