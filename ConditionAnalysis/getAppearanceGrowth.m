function [AppearanceGrowth,NotBigEnough,Merged] = getAppearanceGrowth(SourceDirs, lb, ub,DataTimeFlag,BeginTimes)
% [ColoniesGrowth, ColoniesAppearance,ColoniesIndices,AreaGap,...
%                              NotBigEnough,MergedBeforUpper]
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
    substractFlag=0;
    dataFlag=0;
    if nargin==4
        substractFlag=1;
        dataFlag=DataTimeFlag;
    end
    
    if nargin==5
        substractFlag=1;
        
        if(~iscell(BeginTimes))
            BeginTimes = {BeginTimes};
        end
    end

    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    numOfSources=length(SourceDirs);

    % AppearanceGrowth init
    AppearanceGrowth.plate=[];
    AppearanceGrowth.id=[];
    AppearanceGrowth.growth=[]; 
    AppearanceGrowth.appearance=[];
    AppearanceGrowth.areaGap=[];

    % NotBigEnough init
    NotBigEnough.plate=[];
    NotBigEnough.id=[];

    % Merged init
    Merged.plate=[];
    Merged.id=[];

    for i=1:numOfSources
        currAppearance=[];
        if (lb>ub)
            disp 'Invalid arguments lb > up';
        else
            % Load data file
            FileDir=SourceDirs{i};
            data=load(GetDataName(FileDir));

            [currIndices,currGrowth,currGap,currNotBigEnough,currMerged]=...
                                    getColoniesGrowthRate(FileDir, lb, ub);
            coloniesNum=size(currIndices,1);
            for k=1:coloniesNum
                AppearenceIndex = find(data.Area(:,currIndices(k)),1,'first');
                currAppearance=[currAppearance;data.FilesDateTime(AppearenceIndex)];
            end 
        end
        
        if substractFlag
            currStarting=0;
            if dataFlag&&isfield(data,'StartingTime')
                currStarting=data.StartingTime;
            else
                currStarting=BeginTimes{i};
            end
            
            currAppearance=round((currAppearance-currStarting)*24*60);
        end
        
        % AppearanceGrowth building
        AppearanceGrowth.plate=[AppearanceGrowth.plate; i*ones(size(currIndices))];
        AppearanceGrowth.id=[AppearanceGrowth.id; currIndices];
        AppearanceGrowth.growth=[AppearanceGrowth.growth;currGrowth];
        AppearanceGrowth.appearance=[AppearanceGrowth.appearance;currAppearance];
        AppearanceGrowth.areaGap=[AppearanceGrowth.areaGap;currGap];

        % NotBigEnough building
        NotBigEnough.plate=[NotBigEnough.plate;i*ones(size(currNotBigEnough))];
        NotBigEnough.id=[NotBigEnough.id;currNotBigEnough];
        
        % Merged building
        Merged.plate=[Merged.plate;i*ones(size(currMerged))];
        Merged.id=[Merged.id;currMerged];
    end
end

