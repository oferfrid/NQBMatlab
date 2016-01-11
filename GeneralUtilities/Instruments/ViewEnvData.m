function [DateTime Pressure PressureSP Humidity HumiditySP Temperature TemperatureSP Steam] =ViewEnvData(fileName,timeback)
% [DateTime Pressure PressureSP Humidity HumiditySP Temperature TemperatureSP Steam] =ViewEnvData(fileName,timeback)

% showing the "open file" ui, if it wasn't specified
if nargin == 0
    [FileName, FilePath] = uigetfile('*.csv');
    if isequal(FileName,0)
        return;
    end
    fileName = [FilePath, FileName];
end


% Import the file
newData1 = importdata(fileName);

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
 data=newData1.(vars{1});
text=newData1.(vars{2});
texttime={text{2:(length(data)+1),1}};
time=datenum(texttime,'dd/mm/yyyy HH:MM:ss') ;


DateTime=(time-time(1))*24 ;
Pressure=data(:,1);
PressureSP=data(:,2);
Humidity=data(:,3);
HumiditySP=data(:,4);
Temperature=data(:,5);
TemperatureSP=data(:,6);
Steam=data(:,7);

%figure;



ax(1) = subplot(3,1,1);




plot(DateTime,Humidity,'-b.',DateTime,HumiditySP,'k:');
%set(get(AX(1),'Ylabel'),'String','Humidity') 
%set(get(AX(2),'Ylabel'),'String','Steam') 
ylabel('Humidity [%]');


  maxx=max(DateTime);
  minx=min(DateTime);

if nargin == 2
if     length(timeback) == 1
maxx=max(DateTime);
minx = maxx - timeback;
end
if     length(timeback) ==2
    maxx=timeback(2);
minx = timeback(1);
end
end

xlim([minx maxx]);

ax(2) =subplot(3,1,2);
plot(DateTime,Steam,'-b.');


xlim([minx maxx]);

ylabel('Steam [%]');
ax(3) =subplot(3,1,3);
plot(DateTime,TemperatureSP,'k:',DateTime,Temperature,'-b.');

xlim([minx maxx]);

ylabel('Temperature [^oC]');
xlabel('Time [H]') ;

linkaxes([ax(3) ax(2) ax(1)],'x');