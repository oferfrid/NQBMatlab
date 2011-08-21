function [Time, DC, Hist] = plotDeathCurve(DirVec, TimeLimit, nbins, ShowPlot)
%%[Time, DC, Hist] = plotDeathCurve(DirVec, TimeLimit, ShowPlot)
% -------------------------------------------------------------------------
% Purpose: creating a death curve
% Arguments: DirVec - a cell array of the dir names
%       TimeLimit - cutting the data at this time
%       nbins
%       ShowPlot - (1) plot the results. (0) no plot [default]
% Returns: Time - Time axis till TimeLimit
%       DC - Death Curve
%       Hist - Histogram of appearance
% -------------------------------------------------------------------------
% Irit Levin Reisman. 2007

if nargin<3
    ShowPlot = 0;
end

[T,H]=AddHistograms(DirVec, nbins);
[I,v]=find(T(:) < TimeLimit, 1, 'last');
Time = T(1:I);
Hist = H(1:I);

DC = CreateDeathCurve(Hist);

% plot figure
if ShowPlot
    figure; semilogy(Time, DC);
    tit = sprintf('Death curve for %s',...
                  getGeneralDescription( char(DirVec(1)) ) ); 
    title(tit)
    xlabel('Time [minutes]');
    ylabel('Number of colonies not emerged');
end