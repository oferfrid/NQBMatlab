function [ColoniesIndices,ColoniesGrowth,AreaGap,...
                              NotBigEnough,RemovedMerged]=...
                                    getColoniesGrowthRate(FileDir, lb, ub)
%% ColonisGrowth = getColoniesGrowthRate(FileDir)
% -------------------------------------------------------------------------
% Purpose: This function calculates the growth rate of each colony
% 
% Description: The function checkes which colonies have survived, and for
%   them, it checkes, when were they first detected
% 
% Arguments: FileDir - The directory of the data
%       lb - lower bound size in pixels
%       ub - upper bound size in pixels
%
% Returns: ColoniesGrowth - vector of the times it take for each colony to
%       reach from lb size to ub size.
%       indicesBeforeMerged - Colony's index respectivly
% -------------------------------------------------------------------------
% Nir Dick. 9.2013

    %% Loading data and initializations
    DirName = fullfile(FileDir, 'Results');
    load(fullfile(DirName,'VecArea'));
    load(fullfile(DirName,'ExcludedBacteria.txt'));
    load(fullfile(DirName,'TimeAxis'));

    allColonies = FindColoniesInWorkingArea(FileDir);
    
    % Return an array of not big enough colonies
    NotBigEnough=find(VecArea(:,end)<ub);
    NotBigEnough=intersect(NotBigEnough,allColonies);
    
    % Remove excluded and not big enough
    indicesBeforeMerged=setdiff(allColonies,ExcludedBacteria);
    indicesBeforeMerged=setdiff(indicesBeforeMerged,NotBigEnough);
    
    %% Remove colonies that merged between lb to ub and for the rest 
    % calculate rate
    RemovedMerged=[];
    ColoniesGrowth=[];
    ColoniesIndices=[];
    AreaGap=[];
    allMerged=getMergedColonies(DirName);
    CINum=length(indicesBeforeMerged);
    for j=1:CINum
        currCol=indicesBeforeMerged(j);
        mergeTimeIdx=allMerged(currCol);
        
        removeMerged=0;
        
        % Check if current colony merged while growing from lb to ub
        if mergeTimeIdx>0  
            % Doesn't make sense, but stil....
            if (mergeTimeIdx==1)
                removeMerged=1;
            else
                % Get area of current colony before merging time
                currArea=VecArea(currCol,mergeTimeIdx-1);
                if currArea<ub
                    removeMerged=1;
                end
            end
            
        end
        
        % Add current colony to the removed colonies for merging reasons
        if (removeMerged)
            RemovedMerged=[RemovedMerged;currCol];
        % Add current colony to the result arrays
        else
            lbIndex = find(VecArea(currCol,:)>=lb,1,'first');
            ubIndex = find(VecArea(currCol,:)>=ub,1,'first');
            ColoniesIndices=[ColoniesIndices;currCol];
            ColoniesGrowth=...
                [ColoniesGrowth;TimeAxis(ubIndex)-TimeAxis(lbIndex)];
            AreaGap=...
               [AreaGap;VecArea(currCol,ubIndex)-VecArea(currCol,lbIndex)];
        end
    end

end
