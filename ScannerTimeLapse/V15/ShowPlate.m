function F = ShowPlate(TimeGap, DirName, forMovie,handles)
%% function F = ShowPlate(TimeGap, DirName, forMovie)
% -------------------------------------------------------------------------
% Purpose: showing the result file of the plate with the marked colonies
%
% Arguments: TimeGap - Time since first picture.
%           FileDir(optional) - Directory of the files.
%           forMovie(optional) - true if this is for movie making purposes
%
% Returns: F - frame for movie
% -------------------------------------------------------------------------
% Irit Levin. 20.10.2006.
% updates
% Irit Levin. 13.01.2008
% Irit L. Reisman 01.09.2011. Seperating to PlotPlate, PlotePlateAnalysis
%                 and PlotPlateColoniesNumbers
% -------------------------------------------------------------------------


%% File list
if nargin == 1
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
    forMovie = false;
elseif nargin == 2
    forMovie = false;
end
BW=1;

% figure;
%PlotPlate(TimeGap, DirName, BW, forMovie,handles);
%PlotPlateAnalysis(TimeGap, DirName, forMovie,handles);
%PlotPlateColoniesNumbers(TimeGap, DirName, forMovie,handles);
%impixelinfo