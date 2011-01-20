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
% is working on  any number of  walls  - Ofer Fridman, 19.7.2008

% showing the "open file" ui, if it wasn't specified
if nargin == 0
    [FileName, FilePath] = uigetfile('*.xls');
    if isequal(FileName,0)
        return;
    end
    filename = [FilePath, FileName];
end

newData1 = importdata(filename);
fields = fieldnames(newData1.data);
data = newData1.data.(fields{1});
wells=find(data(2:end,2)>data(1:end-1,2),1,'first');

tests = (size(data,2) - 4)/2;

TimeRowind=5:2:(tests*2+4);
MeasRowind=6:2:(tests*2+4);
%WellMeas = zeros(size(data,1)/96*tests,96);
WellTime = ((reshape(data(1:wells:length(data),TimeRowind)',[tests*length(data)/wells 1])')*24*60)';
for i=1:wells
  ind1=i:wells:length(data);
  WellMeas(:,i)=reshape(data(ind1,MeasRowind)',[tests*length(data)/wells 1]);
end
end
