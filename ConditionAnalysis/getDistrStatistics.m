function [Stat] = getDistrStatistics(Distr)
% Stat = ExperimentStatistics(Distr)
% -------------------------------------------------------------------------
% Purpose: checking statistical parmeters for a histogram
% Arguments: TimeAxis - Time
%       Distr - appearance time for each bacteria (not a histogram)
% Returns: Stat.total
%              .Avg
%              .std
%              .skw
%              .mode
%              .median
%              .stdMed
% -------------------------------------------------------------------------
% Irit Levin Reisman. 2015
    Stat.total = length(Distr);
    Stat.Avg   = mean(Distr);
    Stat.std   = std(Distr);
    Stat.skw   = skewness(Distr);
%     h          = hist(Distr, TimeAxis);
%     [val, Ind] = max(h);
%   Stat.max   = TimeAxis(Ind);
    Stat.mode  = mode(Distr);
    Stat.median= median(Distr);
    Stat.stdMed= sqrt(sum((Distr - Stat.median).^2)/Stat.total);
end
