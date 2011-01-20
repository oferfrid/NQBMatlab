function [WellTime WellMeas] = ReadWalacMultipleData(filename, NumMeasurements)
%% [WellTime WellMeas] = readwalacdata(filename)
% -------------------------------------------------------------------
% Purpose: Read Walac xls file from walac.
%
% Description: The function gets file name and returns the measurements
%           results
%          The function analyzes file with more than one measurement.
%          **** The function assumes MULTY types of measurements! ****
%
% Arguments: filename - Excel file name in walac format.
%          NumMeasurements - number of different types of measurements
%          (od, yfp, cherry...)
% 
% Returns: WellTime - time vector (in minutes) of the measurement
%          WellMeas - a matrix with results X wells.
%         
% -------------------------------------------------------------------
% Ofer Fridman, 01.01.2008
% Updated: (1)  Irit Levin Reisman. 07.2008
%       allow reading of several types of measurments
% 

%% constants
HeaderCols = 4;

%% reading data from excel
newData1 = importdata(filename);
fields = fieldnames(newData1.data);
data = newData1.data.(fields{1});

stepSize = 2*NumMeasurements;
tests = (size(data,2) - HeaderCols)/stepSize; % number of measurments each cycle

% finding number of plates
NumPlates = max(data(:,1));
if NumPlates>1
    NumWells = find(data(:,1)>1,1,'first')-1;
else
    NumWells = length(data(:,1));
end

% finding number of cycles
repetitions = sort(unique(data(:,2))); % number of cycles
if length(repetitions)>1
    NumWells = find(data(:,2)>1,1,'first')-1;
end


%% reshaping data
TimeRowind=(HeaderCols+1):2:(tests*stepSize+HeaderCols); % there is a time coloumn for every measurment type
MeasRowind = zeros(NumMeasurements, tests);
for k = 1:NumMeasurements
    MeasRowind(k,:) = (HeaderCols+2*k):stepSize:(tests*stepSize+HeaderCols);
end
%WellMeas = zeros(size(data,1)/96*3,96, NumMeasurements);
WellMeas = zeros(size(data,1)/NumWells*tests ,NumWells);
WellTime = (reshape(data(1:NumWells:length(data),TimeRowind)',...
    [NumMeasurements, tests*length(data)/NumWells])*24*60)';
for i=1:NumWells
    for k = 1:NumMeasurements
        ind1=i:NumWells:length(data);
        WellMeas(:,i,k)=reshape(data(ind1,MeasRowind(k,:))',...
            [tests*length(data)/NumWells 1]);
    end
end
end
