function [Measurments, Temperature, Time] = ReadTecanMultipleData(FullFileName)
% [Measurments, Temperature, Time] = ReadTecanMultipleData(FullFileName)
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
%Ofer Fridman 31.12.2009 - Multiple data

Header_Line = 17;       % the last line of headers in the file. Maybe should be a parameter
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
impData     = impData.data;
startData   = find(impData(:,1)==1);
    for i=1:length(startData)
        endData = find(isnan(impData(startData(i):end,1)),1,'first');
        if isempty(endData)
        Time{i}        = impData(startData(i):end,2)/60;
        Temperature{i} = impData(startData(i):end,3);
        Measurments{i} = impData(startData(i):end,4:end);
        else
            endind=endData+startData(i)-2;
        Time{i}        = impData(startData(i):endind,2)/60;
        Temperature{i} = impData(startData(i):endind,3);
        Measurments{i} = impData(startData(i):endind,4:end);
        end
    end
