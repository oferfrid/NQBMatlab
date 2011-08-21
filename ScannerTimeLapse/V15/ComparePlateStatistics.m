function [AllPlatesStat, StatPerExp] = ComparePlateStatistics(DirMat)
%% [AllPlatesStat, StatPerExp] = ComparePlateStatistics(DirMat)
% -------------------------------------------------------------------------
% Purpose: orgenizing all the statistic about the experiment by plate and 
%       experiment 
% Arguments: A cell array of DirVecs (also vertical cell array)
% Returns: AllPlatesStat - matrix of all data 
%       (N experiments x 6 plates x 7 parameters)
%       StatPerExp - statistics for whole exp 
%       (N experiments x 1 x 7 parameters)
% -------------------------------------------------------------------------
% Irit Levin Reisman. 5.2008

%% constants for places in APS matrix 
% I_TOT = 1;
% I_AVG = 2;
% I_STD = 3;
% I_SKW = 4;
% I_MAX = 5;
% I_MED = 6;
% I_GRW = 7;

NDirVecs = size(DirMat, 1);
NPlates = 6;
NParams = 7;
AllPlatesStat = zeros(NDirVecs, NPlates ,NParams); 
StatPerExp =  zeros(NDirVecs, 1 ,NParams); 

 
%%
% putting the statistics from all the experiments and all the plates in a
% matrix: cols - plate no, rows - experiment, pages - avg, std, max, median.
for m = 1:NDirVecs
    DirVec = DirMat{m};
    grwRate = zeros(1 , NPlates);
    for n_plate = 1:size(DirVec,1)
        [TimeAxis ,Distr]=AddHistograms(DirVec(n_plate), 0);
        StatVec(n_plate) = ExperimentStatistics(TimeAxis(:), Distr(:));
        grwRate(n_plate) = ...
            mean(getGrowthRate(char(DirVec(n_plate)), 20, 0));
    end
    APS = StatVec2AllPlatesStat(DirVec, StatVec);
    AllPlatesStat(m, :, 1:end-1) = APS;
    AllPlatesStat(m, :, end) = grwRate;
    clear StatVec;
    
    % claculating stat for whole experiment
    [TimeAxis ,Distr] = AddHistograms(DirVec, 0);
    TotalStatExp = ExperimentStatistics(TimeAxis(:), Distr(:));
    StatPerExp(m,1,1:end-1) = Stat2ExpStat(TotalStatExp);
    StatPerExp(m,1,end) = mean(grwRate);
end

end %ComparePlateStatistics 
%%
% % sorting the data - cols - experiment. each row contains
% % the plate that got the row number grade. For example, if 
% % idxAvg(3, 5)=2, that means that in experiment #5 plate 2 average
% % distribution is 3rd fastest
% [sortedAvg, idxAvg]=sort(AllPlatesStat(:,:,I_AVG));
% dataExist = (sortedAvg > 0);
% idxAvg = idxAvg.*dataExist;
% [sortedSkw, idxSkw]=sort(AllPlatesStat(:,:,I_SKW));
% idxSkw = idxSkw.*dataExist;
% [sortedMax, idxMax]=sort(AllPlatesStat(:,:,I_MAX));
% idxMax = idxMax.*dataExist;
% [sortedMed, idxMed]=sort(AllPlatesStat(:,:,I_MED));
% idxMed = idxMed.*dataExist;
% idxSorted(:,:,1) = idxAvg;
% idxSorted(:,:,2) = idxSkw;
% idxSorted(:,:,3) = idxMax;
% idxSorted(:,:,4) = idxMed;
% 
% %%
% % this matrix is a different way to see this data:
% % each row is a plate, and it contains the grade. For Example
% % derby(3, 5, 1)=2 means that in experiment #5 plate 3
% % average distribution is 2nd fastest
% derby = zeros(6,NDirVecs,4);
% for k=1:size(AllPlatesStat, 2)
%     % sorting by average
%     [r, c, v]   = find(AllPlatesStat(:,k,I_AVG));
%     sortedV     = sort(v);
%     for l=1:length(sortedV)
%         ind   = find( AllPlatesStat(:,k,I_AVG) == sortedV(l) );
%         derby(ind, k, 1) = l;
%     end
%     
%     % sorting by skewness
%     [r, c, v]   = find(AllPlatesStat(:,k,I_SKW));
%     sortedV     = sort(v);
%     for l=1:length(sortedV)
%         ind   = find( AllPlatesStat(:,k,I_SKW) == sortedV(l) );
%         derby(ind, k, 1) = l;
%     end
%     
%     % sorting by max
%     [r, c, v]   = find(AllPlatesStat(:,k,I_MAX));
%     sortedV     = sort(v);
%     for l=1:length(sortedV)
%         ind   = find( AllPlatesStat(:,k,I_MAX) == sortedV(l) );
%         derby(ind, k, 2) = l-(length(ind)-1);
%     end
%     
%     % sorting by median
%     [r, c, v]   = find(AllPlatesStat(:,k,I_MED));
%     sortedV     = sort(v);
%     for l=1:length(sortedV)
%         ind   = find( AllPlatesStat(:,k,I_MED) == sortedV(l) );
%         derby(ind, k, 3) = l;
%     end
% end
% 
% %%
% % finding the average grading for each plate, by (1) avg, (2) skewness,
% % (3) max, (4)med
% grading = zeros(6,2,3);
% for k=1:size(derby, 1)
%     [r, c, v]   = find(derby(k,:,1));
%     grading(k, 1, 1) = mean(v);
%     grading(k, 2, 1) = std(v);
%     [r, c, v]   = find(derby(k,:,2));
%     grading(k, 1, 2) = mean(v);
%     grading(k, 2, 2) = std(v);
%     [r, c, v]   = find(derby(k,:,3));
%     grading(k, 1, 3) = mean(v);
%     grading(k, 2, 3) = std(v);
% end


%% ------------------------------------------------------------------------
% -------------------------------------------------------------------------
function APS = StatVec2AllPlatesStat(DirVec, StatVec)
    NPlates = 6;
    NParams = 6;    
    APS = zeros(1, NPlates, NParams);
    for k=1:size(DirVec,1)
        dirName = char(DirVec(k));
        plate   = str2num(dirName(end));
        APS(1, plate, 1) = StatVec(k).total;
        APS(1, plate, 2) = StatVec(k).Avg;
        APS(1, plate, 3) = StatVec(k).std;
        APS(1, plate, 4) = StatVec(k).skw;
        APS(1, plate, 5) = StatVec(k).max;
        APS(1, plate, 6) = StatVec(k).median;
    end
end

%% ------------------------------------------------------------------------
% -------------------------------------------------------------------------
function StatPerExp = Stat2ExpStat(TotalStatExp)
    NParams = 6;    
    StatPerExp = zeros(1, 1, NParams);
    StatPerExp(1, 1, 1) = TotalStatExp.total;
    StatPerExp(1, 1, 2) = TotalStatExp.Avg;
    StatPerExp(1, 1, 3) = TotalStatExp.std;
    StatPerExp(1, 1, 4) = TotalStatExp.skw;
    StatPerExp(1, 1, 5) = TotalStatExp.max;
    StatPerExp(1, 1, 6) = TotalStatExp.median;
end