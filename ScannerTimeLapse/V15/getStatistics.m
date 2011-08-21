function Stat = getStatistics(TimeAxis, Distr)
% Stat = ExperimentStatistics(TimeAxis, Distr)
% -------------------------------------------------------------------------
% Purpose: checking statistical parmeters for a histogram
% Arguments: TimeAxis - Time
%       Distr - appearance time for each bacteria (not a histogram)
% Returns: Stat.total
%              .Avg
%              .std
%              .skw
%              .max
%              .median
%              .stdMed
% -------------------------------------------------------------------------
% Irit Levin Reisman. 2008
Stat.total = length(Distr);
Stat.Avg   = mean(Distr);
Stat.std   = std(Distr);
Stat.skw   = skewness(Distr);
h          = hist(Distr, TimeAxis);
[val, Ind] = max(h);
Stat.max   = TimeAxis(Ind);
Stat.median= median(Distr);
Stat.stdMed= sqrt(sum((Distr - Stat.median).^2)/Stat.total);