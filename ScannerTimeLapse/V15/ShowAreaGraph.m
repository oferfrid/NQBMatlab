function ShowAreaGraph(FileDir)
%% ShowAreaGraph(FileDir)
% -------------------------------------------------------------------------
% Purpose: displaying the Area Vs Time graph
% Decription : The function reads the AreaVec file and plots The area of
%       each colony in time, with colour it apears in the last plate.
% Arguments: FileDir - The data directory
% -------------------------------------------------------------------------

%% Constants
r          = 440;       % the radius of the plate
NearBorder = 15;        % proximity to the border

%% loading the data
DirName    = fullfile(FileDir, 'Results');
AreaFile   = fullfile(DirName, 'VecArea');
CenFile    = fullfile(DirName, 'VecCen');
AxisFile   = fullfile(DirName, 'TimeAxis');
ColourFile = fullfile(DirName, 'ordColour');
CircFile   = fullfile(DirName, 'CircParams');
ExcludeFile= fullfile(DirName, 'ExcludedBacteria.txt');

load(AreaFile);
load(CenFile);
load(AxisFile);
load(ColourFile);
load(CircFile);
load(ExcludeFile);

%% excluding bacteria
VecArea(ExcludedBacteria,:)   = 0;
VecCen(ExcludedBacteria,:,:)  = 0;

%% Checking which colony is too close to the border
AreaSize = size(VecArea,1);
TimeSize = size(TimeAxis,1);

mark = repmat({'none'},AreaSize,1);
MarkerFC = repmat('r',AreaSize,1);

CM = VecCen(:,:,end);
distFromCM    = sqrt((x(1)-CM(:,1)).^2+(y(1)-CM(:,2)).^2);
CloseToBorder = (distFromCM < r & distFromCM > r -NearBorder);
mark(CloseToBorder) = {'o'};
MarkerFC(CloseToBorder) = 'k';

%% displaying the data on a graph
AreaSize = size(VecArea,2);
TimeSize = size(TimeAxis,1);
% MinLen = min(AreaSize, TimeSize);
% figure;
% for k=1:size(VecArea,1)
%     line(TimeAxis(1:MinLen),VecArea(k,1:MinLen),...
%         'Color' ,ordColour(k,:), 'Marker' ,mark(k), ...
%         'MarkerSize', 2, 'MarkerEdgeColor', MarkerFC(k));
% end
%figure;
for k=1:size(VecArea,1)
    plot(TimeAxis,VecArea(k,:),...
        'Color' ,ordColour(k,:), 'Marker' ,char(mark(k)), ...
        'MarkerSize', 2, 'MarkerEdgeColor', MarkerFC(k),...
        'XdataSource','TimeAxis','YdataSource',['VecArea(',num2str(k),',:)']);
    hold on;
end
[pathstr, name, ext] = fileparts(FileDir);
title(['The area of each colony as a function of the time - ',...
       getDescription(FileDir)]);
xlabel('Time [minutes]');
ylabel('Area [pixels]');
hold off;
