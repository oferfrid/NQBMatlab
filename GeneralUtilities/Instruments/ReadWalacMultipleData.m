function  [Measurments, Time, StartDateTime] = ReadWalacMultipleData(FullFileName, NumMeasurements)
%% [Measurments, Time, StartDateTime] = ReadWalacMultipleData(FullFileName, NumMeasurements)
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
%          Measurments - a matrix with results X wells.
%         
% -------------------------------------------------------------------
% Ofer Fridman, 01.01.2008
% Updated: (1)  Irit Levin Reisman. 07.2008
%       allow reading of several types of measurments
% 

%% constants
HeaderCols = 4;

%% reading data from excel
newData1 = importdata(FullFileName);
fields = fieldnames(newData1.data);
alldata = newData1.data.(fields{1});
%alldata = newData1.data;
stepSize = 2*NumMeasurements;
tests = (size(alldata,2) - HeaderCols)/stepSize; % number of measurments each cycle

% finding number of plates
NumPlates = max(alldata(:,1));
if NumPlates>1
    NumWells = find(alldata(:,1)>1,1,'first')-1;
else
    NumWells = length(alldata(:,1));
end

% finding number of cycles
repetitions = sort(unique(alldata(:,2))); % number of cycles
if length(repetitions)>1
    NumWells = find(alldata(:,2)>1,1,'first')-1;
end


%% reshaping alldata
TimeRowind=(HeaderCols+1):2:(tests*stepSize+HeaderCols); % there is a time coloumn for every measurment type
MeasRowind = zeros(NumMeasurements, tests);
for k = 1:NumMeasurements
    MeasRowind(k,:) = (HeaderCols+2*k):stepSize:(tests*stepSize+HeaderCols);
end
%WellMeas = zeros(size(alldata,1)/96*3,96, NumMeasurements);
Measurments = zeros(size(alldata,1)/NumWells*tests ,NumWells);
Time = (reshape(alldata(1:NumWells:length(alldata),TimeRowind)',...
    [NumMeasurements, tests*length(alldata)/NumWells])*24*60)';
for i=1:NumWells
    for k = 1:NumMeasurements
        ind1=i:NumWells:length(alldata);
        Measurments(:,i,k)=reshape(alldata(ind1,MeasRowind(k,:))',...
            [tests*length(alldata)/NumWells 1]);
    end
end

% remove NaN at the end
 indempty = find(~isnan( Measurments(:,1,end)),1,'last');
   Measurments= Measurments(1:indempty ,:,:);
    Time  = Time (1:indempty ,:);
% add the date and the time of the measurement to the out param
StartDateTime = datenum(newData1.textdata.Protocol{end,end}(max(strfind(newData1.textdata.Protocol{end,end},'.'))+1:end),'dd/mm/yyyy HH:MM:SS');
end
