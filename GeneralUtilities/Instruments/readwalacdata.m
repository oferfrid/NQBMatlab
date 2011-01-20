function [WellTime WellMeas] = readwalacdata(filename)
%% [WellTime WellMeas] = readwalacdata(filename)
% -------------------------------------------------------------------
% Purpose: Read Walac xls file from walac.
%
% Description: The function gets file name and returns the measurements
%           results
%          The function analyzes file with more than one measurement.
%          **** The function assumes only one type of measurement! ****
%
% Arguments: filename - Excel file name in walac format.
% 
% Returns: WellTime - time vector (in minutes) of the measurement
%          WellMeas - a matrix with results X wells.
%         
% -------------------------------------------------------------------
% Ofer Fridman, 01.01.2008

newData1 = importdata(filename);
fields = fieldnames(newData1.data);
data = newData1.data.(fields{1});

tests = (size(data,2) - 4)/2;

TimeRowind=5:2:(tests*2+4);
MeasRowind=6:2:(tests*2+4);

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


WellMeas = zeros(size(data,1)/NumWells*tests,NumWells);
WellTime = ((reshape(data(1:NumWells:length(data),TimeRowind)',[tests*length(data)/NumWells 1])')*24*60)';
for i=1:NumWells
  ind1=i:NumWells:length(data);
  WellMeas(:,i)=reshape(data(ind1,MeasRowind)',[tests*length(data)/NumWells 1]);
end
end
