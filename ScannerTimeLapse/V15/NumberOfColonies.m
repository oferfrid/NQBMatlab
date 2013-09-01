function NColonies = NumberOfColonies(FileDir)
%% NColonies = NumberOfColonies(FileDir)
% -------------------------------------------------------------------------
% Purpose: Counts the colonies in the Plate.
% 
% Description: calls FindColoniesInWorkingArea 
% 
% Arguments: FileDir - The full path of the directory
%
% Returns: NColonies - Number of Colonies
% -------------------------------------------------------------------------
% Irit L. Reisman 08.2011

ExcludeFile= fullfile(FileDir, 'Results', 'ExcludedBacteria.txt');
ExcludedBacteria = load(ExcludeFile);
CID = FindColoniesInWorkingArea(FileDir);
unfilteredColonies = setdiff(CID, ExcludedBacteria);
NColonies = length(unfilteredColonies);