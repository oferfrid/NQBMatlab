function [TimeAxis, Histogram, Time, DC, Stat] = ...
    getExperimentResults(DirVec, TimeLimit, ShowPlot, bin)
%% [TimeAxis, Histogram, Time, DC, Stat] = ...
%   getExperimentResults(DirVec, TimeLimit, ShowPlot, bin)
% -------------------------------------------------------------------------
% Purpose: activating hist, death curve, and plate statistics
% Arguments: DirVec - string
%       TimeLimit - for the death curve
%       ShowPlot - boolean.
%       bin - bin the histogram every BIN points 
% Returns: TimeAxis + TotalDistr: disrtibution of experiment
%       Time + DC: time till TimeLimit and Death Curve for experiment
%       Stat : experiment statistics
% -------------------------------------------------------------------------
% Irit Levin Reisman. 04.2009


[TimeAxis,TotalAppearenceTime]=GetAppearanceTimes(DirVec);
Stat = getStatistics(TimeAxis, TotalAppearenceTime); 
[TimeAxis, Histogram] = AddHistograms(DirVec, bin, ShowPlot);
[Time, DC] = plotDeathCurve(DirVec, TimeLimit, bin, ShowPlot);