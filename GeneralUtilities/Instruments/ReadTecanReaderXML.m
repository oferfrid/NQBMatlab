function Results = ReadTecanReaderXML(FullFileName)
%Results = ReadTecanReaderXML(FullFileName)
% Ofer Fridman 23.09.2012 

%% showing the "open file" ui, if it wasn't specified
if nargin == 0
[filename, pathname] = uigetfile({'*.xml;*.xml;','XML Files (*.xml)'},'Pick a file');
    if isequal(filename,0)
        return;
    end
    FullFileName = [pathname, filename];
end

%% read file
DOMnode= xmlread(FullFileName);



%% read start time
StartTimeText = char(DOMnode.getElementsByTagName('Section').item(0).getAttribute('Time_Start'));
StartTime = datenum(StartTimeText,'yyyy-mm-ddTHH:MM:SS');

Results{1}.StartTimeText = StartTimeText;
Results{1}.StartTime = StartTime;

%% Reading Label name
ReadingLabels = DOMnode.getElementsByTagName('ReadingLabel');

Results{1}.Labels = cell(ReadingLabels.getLength,1);

for l=1:ReadingLabels.getLength
    Results{1}.Labels{l}.Name = char(ReadingLabels.item(l-1).getAttribute('name'));
end

%% read wells

Datas = DOMnode.getElementsByTagName('Data');
Data = Datas.item(0);
Wells = Data.getElementsByTagName('Well');
for w=1:Wells.getLength
    Well = Wells.item(w-1);
    Pos = char(Well.getAttribute('Pos'));
    for l=1:ReadingLabels.getLength
        Results{1}.Labels{l}.Wells{w} =Pos;
    end
end

%% read wells results
%init arrays
for l=1:ReadingLabels.getLength
 Results{1}.Labels{l}.Time = zeros(Datas.getLength,1);
 Results{1}.Labels{l}.Temperature = zeros(Datas.getLength,1);
 Results{1}.Labels{l}.Measurments = zeros(Datas.getLength,Wells.getLength );
end

 for d=1:Datas.getLength
        Data = Datas.item(d-1);
        for l=1:ReadingLabels.getLength
            %Temperature
            Results{1}.Labels{l}.Temperature(d) = str2double(Data.getAttribute('Temperature'));
            %Time
            Time_Start =  char(Data.getAttribute('Time_Start'));
            Mpos = strfind(Time_Start(3:end-1),'M')+2;
             if isempty(Mpos)
                sec = str2double(Time_Start(3:end-1));
                min = 0;
             else
                min = str2double(Time_Start(3:Mpos-1));
                sec = str2double(Time_Start(Mpos+1:end-1));
             end
             Results{1}.Labels{l}.Time(d) = min+sec/60;
        end
        %Measurments
        Wells = Data.getElementsByTagName('Well');
            for w=1:Wells.getLength
                Well = Wells.item(w-1);
                for l=1:ReadingLabels.getLength
                    Measurment =  Well.getElementsByTagName('Single').item(l-1).getFirstChild.getNodeValue;
                    Results{1}.Labels{l}.Measurments(d,w)=str2double( Measurment);
                end
            end
 end

