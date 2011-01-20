function [Measurments, Temperature, Time] = ReadTecanData(FullFileName)
% [Measurments, Temperature, Time] = ReadTecanData(FullFileName)
% -------------------------------------------------------------------------
% Purpose: reads data from the Excel file of the Tecan
% 
% Arguments : FullFileName(optional) - path and Excel file
%
% Returns : Measurments - rows: number of measurment
%                         cols: wells from 1 - 96
%       Temperature - the temperature in each measurment (meas x 1)
%       Time - The time of each measurment (in minutes)(meas x 1)
%       
% Exclamier : since it was done by one example, it might need adjustments
% -------------------------------------------------------------------------
% Irit Levin 01.01.2008

Header_Line = 17;       % the last line of headers in the file. Maybe should be a parameter
LinesForBG  = 10;       % Number of measurements defined as background
Measurments = [];
Temperature = [];
Time        = [];

% showing the "open file" ui, if it wasn't specified
if nargin == 0
    [FileName, FilePath] = uigetfile('*.xls');
    if isequal(FileName,0)
        return;
    end
    FullFileName = [FilePath, FileName];
end

% reading the data
impData     = importdata(FullFileName, ' ', Header_Line);
startData   = find(impData.data(:,1)==1);
AllData     = impData.data(startData:end,:);
Time        = AllData(:,2)/60;
Temperature = AllData(:,3);
Measurments = AllData(:,4:end);