function [AllPlatesStat, SummeryForExp]=PlateStatisticsReport(DirMat, FileName)
%%PlateStatisticsReport(DirMat, FileName)
%--------------------------------------------------------------------------
% Purpose: creating a report comparing the statistics of each plate
% Arguments: All the parameters that return from ComparePlateStatistics       
%       DirMat - an array of DirVec (directory of each experiment)
%       FileName - Output file name.
% Returns: AllPlatesStat - N experiments, 6 plates , 7 statistical
%       parameters
%       SummeryForExp - N experiments, (avg std avg/std range) , 7 statistical
% Output: a report organizing all this data (FileName). open with excel.
%--------------------------------------------------------------------------
% Irit Levin Reisman. 6.2008

%% constants for places in APS matrix 
I_TOT = 1;
I_AVG = 2;
I_STD = 3;
I_SKW = 4;
I_MAX = 5;
I_MED = 6;
I_GRW = 7;

NDirVecs = size(DirMat, 1);

if isempty(FileName)
    FileName = 'StatisticsReport.txt';
end
fid = fopen(FileName, 'wt');


titles = {'Average';'Skewness';'Maximum';'Median';'Growth'};
indData = [I_AVG, I_SKW, I_MAX, I_MED, I_GRW];

%%
% creating the description vecs
% ------------------------------
descriptionVec = {};
DirDescVec ={};

for m = 1:NDirVecs
    DirVec = DirMat{m};
    [GenDescription, GenDir] = getGeneralDescription(char(DirVec(1)));
    descriptionVec(m,1) = {GenDescription};
    DirDescVec(m,1) = {GenDir};
end

%%
% calculating statistics for each plate
% -----------------------------------------------------
[AllPlatesStat, StatPerExp] = ComparePlateStatistics(DirMat);

%%
% calculating the summery - mean, std, std/mean, range
% -----------------------------------------------------
[ErrForPlate, ErrMat, fracErrMat, SummeryForExp]=...
    GetStatisticsSummery(AllPlatesStat, StatPerExp);

%% 
% generating the report
% -----------------------
for i = 1:length(titles)
    % title lines
    % -------------------------------------------
    fprintf(fid, '%s\n\n\tplate \t', char(titles(i)));
    fprintf(fid, '%d\t\t\t', [1:6]); 
    fprintf(fid, '\nexperiment\t\t');
    for j=1:6
        fprintf(fid, '%s \tErr \tErr/std\t', char(titles(i)));
    end
    fprintf(fid, 'avg \tstd \tstd/avg \trange\n');
    
    % data lines
    % ------------------------------------------------
    for n_data = 1:NDirVecs
        fprintf(fid, '%s\t%s\t',...
            char(descriptionVec(n_data)),char(DirDescVec(n_data)));
        % writing the place in the value the Error and the dErr
        for n_plate = 1:6
            fprintf(fid, '%5.2f \t%5.2f \t%2.3f\t',...
                AllPlatesStat(n_data,n_plate,indData(i)),...
                ErrMat(n_data,n_plate,indData(i)),...
                fracErrMat(n_data,n_plate,indData(i)));
        end
        
        % writing the summery - average, std, std/avg, range
        fprintf(fid, '%5.2f \t%5.2f \t%5.2f \t%5.2f \n',...
            SummeryForExp(n_data,1,indData(i)),...
            SummeryForExp(n_data,2,indData(i)),...
            SummeryForExp(n_data,3,indData(i)),...
            SummeryForExp(n_data,4,indData(i)) );
    end
    
    % writing grading summery - average , std
    % --------------------------------------------
    fprintf(fid, '\naverage error\t\t\t\t');
    fprintf(fid, '%2.3f\t\t\t', ErrForPlate(1,:,indData(i)));
    fprintf(fid, '\nstd error\t\t\t\t');
    fprintf(fid, '%2.3f\t\t\t', ErrForPlate(2,:,indData(i)));

   
    fprintf(fid, '\n\n\n\n'); 
end


fclose(fid);