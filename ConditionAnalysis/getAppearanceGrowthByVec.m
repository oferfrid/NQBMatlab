function [ColoniesGrowth, ColoniesAppearance,ColoniesIndices,AreaGap,...
                               NotBigEnough,MergedBeforUpper]=...
                                 getAppearanceGrowthByVec(FileDirVec,lb,ub)
%% [ColoniesGrowth, ColoniesAppearance,ColoniesIndices,AreaGap,...
%                               NotBigEnough,MergedBeforUpper]=...
%                                getAppearanceGrowthByVec(FileDirVec,lb,ub)
% -------------------------------------------------------------------------
% Purpose: This function calculates the growth rate of each colony for each
%          directory in the FileDirVec
% 
% Description: For each directory, the function call to
% getAppearanceGrowth function with the lb and ub.
% 
% Arguments: FileDir - Cell array of directories. 
%            lb - lower bound size in pixels
%            ub - upper bound size in pixels
%
% Returns: A set of cell arrays that contain for each directory the
% relevant data:
%           ColoniesIndices - The indices of colonies that entered to
%                            statistics.
%          AreaGap - The diffrence between the first area that exceeded lb
%          and the first area that exceeded ub for each colony that entered
%          to statistics.
%
%          ColoniesGrowth - vector of the times it take for each colony to
%                               reach from lb size to ub size.
%          ColoniesAppearance - Colony's first appearance
%
%          NotBigEnough - colonies with last area < ub (not in statistics)
%
%          MergedBeforUpper - colonies that merged before exceeding the ub
%                             (not in statistics)
% -------------------------------------------------------------------------
% Nir Dick. 9.2013
    
    dirNum=length(FileDirVec);
    for j=1:dirNum
        [ColoniesGrowth{j}, ColoniesAppearance{j},ColoniesIndices{j},...
            AreaGap{j}, NotBigEnough{j},MergedBeforUpper{j}]=...
                                  getAppearanceGrowth(FileDirVec{j},lb,ub);
    end
end

