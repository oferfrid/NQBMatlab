function Results = ReadTecanReader(FullFileName)
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
% Ofer Fridman 31.12.2009 - Multiple Lable data
% Ofer Fridman 22.08.2011 - Change to results to struct (suport multiple
% sheets)


%% showing the "open file" ui, if it wasn't specified
if nargin == 0
[filename, pathname] = uigetfile({'*.xls;*.xlsx;','Excel Files (*.xls,*.xlsx)'},'Pick a file');
    if isequal(filename,0)
        return;
    end
    FullFileName = [pathname, filename];
end


%% reading the data
impData     = importdata(FullFileName, ' ');


if   isstruct(impData.data)
    SheetNames = fieldnames(impData.data);
    for s=1:length(SheetNames)
        Data{s} =  getfield(impData.data, SheetNames{s});
        TextData{s} = getfield(impData.textdata, SheetNames{s});
        Results{s}.SheetName = SheetNames{s};
    end
    
else %for one Sheet Excel file
   Data{1} = impData.data; 
   TextData{1} = impData.textdata;
   Results{1}.SheetName = NaN;
end
  
 for s=1:length(Results)
     
    startData   = find(Data{s}(:,1)==1);
    startTextData =  find(strncmp('Cycle N',TextData{s}(:,1),6));
        SheetData = Data{s};
        SheetTextData = TextData{s};
    
        for i=1:length(startData)
            endData = find(isnan(SheetData(startData(i):end,1)),1,'first');
            if isempty(endData)
            Results{s}.Lables{i}.Time        = SheetData(startData(i):end,2)/60;
            Results{s}.Lables{i}.Temperature = SheetData(startData(i):end,3);
            Results{s}.Lables{i}.Measurments = SheetData(startData(i):end,4:end);
            else
                endind=endData+startData(i)-2;
            Results{s}.Lables{i}.Time        = SheetData(startData(i):endind,2)/60;
            Results{s}.Lables{i}.Temperature = SheetData(startData(i):endind,3);
            Results{s}.Lables{i}.Measurments = SheetData(startData(i):endind,4:end);
            end
            Results{s}.Lables{i}.Name = SheetTextData(startTextData(i)-1,1);
            Results{s}.Lables{i}.Wells = SheetTextData(startTextData(i),4:end);
            
        end
    
 end
