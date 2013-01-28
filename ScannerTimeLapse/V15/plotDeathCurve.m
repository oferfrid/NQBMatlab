function [Time, DC] = plotDeathCurve(DirVec,ShowPlot)
%%[Time, DC] = plotDeathCurve(DirVec)
% -------------------------------------------------------------------------
% Purpose: creating a death curve
% Arguments: DirVec - a cell array of the dir names
%       ShowPlot - (1) plot the results. (0) no plot [default]
% Returns: Time - Time axis till TimeLimit
%       DC - Death Curve
% -------------------------------------------------------------------------
% Irit Levin Reisman. 2007
% Ofer Fridman 2013 - remove the bining.

if nargin<2
    ShowPlot = 0;
end
[~,TotalAppearenceTime]=GetAppearanceTimes(DirVec);
Time = sort(TotalAppearenceTime);
DC  = length(TotalAppearenceTime):-1:1;

% plot figure
if ShowPlot
    figure; semilogy(Time, DC);
    tit = sprintf('Death curve for %s',...
                  getGeneralDescription( char(DirVec(1)) ) ); 
    title(tit)
    xlabel('Time [minutes]');
    ylabel('Number of colonies not emerged');
end