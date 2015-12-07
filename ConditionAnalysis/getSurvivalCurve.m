function [SurvivalCurveX, SurvivalCurveY] = getSurvivalCurve(SourceDirs,BeginTimes)
%%[Time, DC] = plotDeathCurve(DirVec)
% -------------------------------------------------------------------------
% Purpose: creating a death curve
% Arguments: DirVec - a cell array of the dir names
%       ShowPlot - (1) plot the results. (0) no plot [default]
% Returns: Time - Time axis till TimeLimit
%       DC - Death Curve
% -------------------------------------------------------------------------
% Irit Levin Reisman. 2015
    sentBegin=false;
    if nargin>1
        sentBegin=true;
    end
    
    if sentBegin
        totalAppearenceTime=getAppearanceTime(SourceDirs,BeginTimes);
    else
        totalAppearenceTime=getAppearanceTime(SourceDirs);
    end 
    SurvivalCurveX = sort(totalAppearenceTime.time);
    SurvivalCurveY  = length(totalAppearenceTime.time):-1:1;
end
