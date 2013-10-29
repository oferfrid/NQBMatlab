function [ColoniesGrowth, ColoniesAppearance,ColoniesIndices,AreaGap,...
                             NotBigEnough,MergedBeforUpper] = ...
                                      getAppearanceGrowth(FileDir, lb, ub)
%% [ColoniesGrowth, ColoniesAppearance] = getAppearanceGrowth(
%                                                          FileDir, lb, ub)
% -------------------------------------------------------------------------
% Purpose: This function calculates the growth rate and appearance time for
%   each relevant colony.
% 
% Description: This function calculates the growth rate and appearance time for
%   each relevant colony. Relevant colonies are the colonies that are not
%   excluded and far enough from the border. For colonies that that became
%   one we take data only till the first merging time.
% 
% Arguments: FileDir - The directory of the data
%       lb - lower bound size in pixels
%       ub - upper bound size in pixels
%
% Returns: ColoniesIndices - The indices of colonies that entered to
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
    ColoniesAppearance=[];
    if (lb>ub)
        disp 'Invalid arguments lb > up';
    else
        DirName = fullfile(FileDir, 'Results');
        load(fullfile(DirName,'VecArea'));
        load(fullfile(DirName,'TimeAxis'));

         [ColoniesIndices,ColoniesGrowth,AreaGap,...
                              NotBigEnough,MergedBeforUpper] =...
                                    getColoniesGrowthRate(FileDir, lb, ub);
        coloniesNum=size(ColoniesIndices,1);
        for k=1:coloniesNum
            AppearenceIndex = find(VecArea(ColoniesIndices(k),:),1,'first');
            ColoniesAppearance=...
                            [ColoniesAppearance;TimeAxis(AppearenceIndex)];
        end 
    end
end

