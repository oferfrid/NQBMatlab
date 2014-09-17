function [ColoniesIndices,ColoniesGrowth,AreaGap,NotBigEnough,RemovedMerged]=...
                                                getColoniesGrowthRate(dataInfo, lb, ub)
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
    if isstruct(dataInfo)
        data=dataInfo;
    % Data info is the location of the file
    else
        data=load(fullfile(dataInfo,DATA_FILE_NAME));
    end
    
    allColonies = find(data.IgnoredColonies==0);
    
    % Return an array of not big enough colonies
    NotBigEnough=find(data.Area(end,:)<ub);
    NotBigEnough=intersect(NotBigEnough,allColonies);
    indicesBeforeMerged=setdiff(allColonies,NotBigEnough);
    
    %% Remove colonies that merged between lb to ub and for the rest 
    % calculate rate
    RemovedMerged=[];
    ColoniesGrowth=[];
    ColoniesIndices=[];
    AreaGap=[];
    allMerged=getMergedColonies(data.Centroid);
    CINum=length(indicesBeforeMerged);
    for j=1:CINum
        currCol=indicesBeforeMerged(j);
        mergeTimeIdx=allMerged(currCol);
        
        removeMerged=0;
        
        % Check if current colony merged while growing from lb to ub
        if mergeTimeIdx>0  
            % Doesn't make sense, but stil we cant calcullate prev
            % index in this case
            if (mergeTimeIdx==1)
                removeMerged=1;
            else
                % Get area of current colony before merging time
                currArea=data.Area(mergeTimeIdx-1,currCol);
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
            lbIndex = find(data.Area(:,currCol)>=lb,1,'first');
            ubIndex = find(data.Area(:,currCol)>=ub,1,'first');
            ColoniesIndices=[ColoniesIndices;currCol];
            ColoniesGrowth=...
                [ColoniesGrowth;data.FilesDateTime(ubIndex)-data.FilesDateTime(lbIndex)];
            AreaGap=...
               [AreaGap;data.Area(ubIndex,currCol)-VecArea(lbIndex,currCol)];
        end
    end

end
