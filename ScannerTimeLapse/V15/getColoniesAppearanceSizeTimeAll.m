function [TotColoniesIndices, TotAppearanceTime, TotlbSizeTime, TotubSizeTime] = getColoniesAppearanceSizeTimeAll(DirVec, lb, ub)
%% [TotColoniesIndices, TotAppearanceTime, TotlbSizeTime, TotubSizeTime] =
%                getColoniesAppearanceSizeTimeAll(DirVec, lb, ub)
% -------------------------------------------------------------------------
% Purpose: This function calculates the growth rate of each colony
% 
% Description: The function checkes which colonies have survived, and for
%   them, it checkes, when were they first detected
% 
% Arguments: DirVec - Cell array of the directories of the data
%       lb - lower bound size in pixels
%       ub - upper bound size in pixels
%
% Returns: ColoniesGrowth - vector of the times it take for each colony to
%       reach from lb size to ub size.
% -------------------------------------------------------------------------
% Irit Levin. 12.2009

%% initializations
TotAppearanceTime = [];
TotlbSizeTime = [];
TotubSizeTime = [];
TotColoniesIndices = [];

%% gather data from all DirVec
for k=1:length(DirVec)
    [ColoniesIndices, AppearanceTime, lbSizeTime, ubSizeTime] = ...
        getColoniesAppearanceSizeTime(DirVec{k}, lb, ub);
    
    CurrDir = DirVec{k};
    ind_ = strfind(CurrDir,'_');
    ScannerNo = str2double(CurrDir(ind_(1)+1:ind_(2)-1));
    PlateNo   = str2double(CurrDir(ind_(2)+1:end));

    ColonyID = ones(length(ColoniesIndices),3);
    ColonyID(:,1) = ColonyID(:,1)*ScannerNo;
    ColonyID(:,2) = ColonyID(:,2)*PlateNo;
    ColonyID(:,3) = ColoniesIndices;
    TotColoniesIndices = [TotColoniesIndices; ColonyID];
    TotAppearanceTime = [TotAppearanceTime;AppearanceTime];
    TotlbSizeTime = [TotlbSizeTime; lbSizeTime];
    TotubSizeTime = [TotubSizeTime; ubSizeTime];
end

