function [TimeAxis, TotalDistr, Time , logDC] = ...
    GatherData(FullPath, DirName, ScannerPlateVec, TimeLimit, ShowPlot, bin)
%% [TimeAxis, TotalDistr, Time , logDC] = ...
%   GatherData(FullPath, DirName, ScannerPlateVec, TimeLimit, ShowPlot, bin)
% -------------------------------------------------------------------------
% Purpose: activating hist, death curve, and plate statistics
% Arguments: FullPath - string
%       DirName - String
%       ScannerPlateVec - line 1 scaner, line 2 plate
%       TimeLimit - for the death curve
%       ShowPlot - boolean.
%       bin - bin the histogram every BIN points 
% Returns: TimeAxis + TotalDistr: disrtibution of experiment
%       Time + logDc: time till TimeLimit and Death Curve for experiment
% -------------------------------------------------------------------------
% Irit Levin Reisman. 6.2008

DirVec = createDirVec(FullPath, DirName, ScannerPlateVec);

[TimeAxis, TotalDistr]=AddHistograms(DirVec, bin, ShowPlot);
[Time, logDC, Hist] = plotDeathCurve(DirVec, TimeLimit, bin, ShowPlot);

if ShowPlot
    PlateVec = unique(ScannerPlateVec(2,:));
    ScannerVec = unique(ScannerPlateVec(1,:));
    DirMat = createDirMat({FullPath}, {DirName}, PlateVec, ScannerVec);
%     APS = ShowPlatesStatistics(DirMat);
end