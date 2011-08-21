function [CM, ColonyNum]= WhichColony(TimeGap, Area, FileDir)
%% [CM, ColonyNum]= WhichColony(TimeGap, Area, FileDir)
% -----------------------------------------------------------------------
% Purpose: The function gives back the bounding box coordinates for a 
%       specified line in the final graph.
%
% Arguments: TimeGap - Time elapsed from the begining. X coordinate of the
%       graph.
%       Area - The area of the colonie. Y X coordinate of the graph.
%       FileDir - the directory
%
% Input Files: VecArea - A matrix of all the colonies and their areas in time.
%       VecCen - A 3D matrix of all the colonies and their C.M in time.
%       TimeAxis
% Returns: CM - the Centre Mass coordinates of the colony.
% -----------------------------------------------------------------------
% Irit Levin. 5.9.2006
% -----------------------------------------------------------------------

%% File list
DirName = fullfile(FileDir, 'Results');

%% Calculating the time difrences in minutes from the file names
load(fullfile(DirName,'VecArea'));
load(fullfile(DirName,'VecCen'));
load(fullfile(DirName,'TimeAxis'));
FileNum   = find(TimeAxis == TimeGap);

%% Finding the bounding box of the relevant colony
ColonyNum = find(VecArea(:,FileNum)==Area);
CM = VecCen(ColonyNum,:,FileNum);