function DirVec = createDirVec(FullPath, DirName, ScannerPlateVec)
%% DirVec = createDirVec(FullPath, DirName, ScannerPlateVec)
%-------------------------------------------------------------------------
% Purpose: DirVec cell array
% Arguments: FullPath - string
%       DirName - String
%       ScannerPlateVec - line 1 scaner, line 2 plate
% Returns: TimeAxis + TotalDistr: disrtibution of experiment
%       Time + logDc: time till TimeLimit and Death Curve for experiment
% -------------------------------------------------------------------------
% Irit Levin Reisman. 6.2008

DirVec={};
for k=1:size(ScannerPlateVec, 2)
    FullDirName = sprintf('%s%s_%1d_%1d', ...
        FullPath, DirName, ScannerPlateVec(1,k), ScannerPlateVec(2,k));
    DirVec(k,1) = {FullDirName};
end