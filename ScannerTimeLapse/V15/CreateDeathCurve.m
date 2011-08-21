function DeathCurve = CreateDeathCurve(Hist)
%% DC = CreateDeathCurve(Hist)
% -------------------------------------------------------------------------
% Purpose: creating death curve from histogram
% Arguments: Hist
% Returns: DeathCurve - death curve
% -------------------------------------------------------------------------
% Irit Levin Reisman. 11.2008

accumulatedHist = cumsum(Hist);
DeathCurve      = max(accumulatedHist) - accumulatedHist;