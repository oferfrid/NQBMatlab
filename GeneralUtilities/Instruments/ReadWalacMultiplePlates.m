function Measurments = ReadWalacMultiplePlates(FullFileName)
%% Measurments = ReadWalacMultiplePlates(FullFileName)
% -------------------------------------------------------------------
% Purpose: Read Walac xls file from walac.
%
% Description: The function gets file name and returns the measurements
%           results
%          The function analyzes file with only one measurement.
%
% Arguments: FullFileName - Excel file name in walac format.
% 
% Returns: 
%          Measurments - a matrix with results X wells.
%         
% -------------------------------------------------------------------
% Ofer Fridman, 01.01.2008
% Updated: (2)  Irit Levin Reisman. 07.2008
%       allow reading of several plates (1 parameter type)
% 

%% constants
HeaderCols = 4;

%% reading data from excel
newData1 = importdata(FullFileName);
fields = fieldnames(newData1.data);
data = newData1.data.(fields{1});

stepSize = 2;
% tests = (size(data,2) - HeaderCols)/stepSize; % number of measurments each cycle

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
MeasRowind = 6;


Measurments = zeros(NumPlates,NumWells);

for i=1:NumPlates
    for k=1:NumWells
        Measurments(i,k) = data((i-1)*NumWells+k,MeasRowind);
    end
end
