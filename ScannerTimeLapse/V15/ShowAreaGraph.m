% Nir - changed
function ShowAreaGraph(FileDir, XScaleHr)
%% ShowAreaGraph(FileDir)
% -------------------------------------------------------------------------
% Purpose: displaying the Area Vs Time graph
% Decription : The function reads the AreaVec file and plots The area of
%       each colony in time, with colour it apears in the last plate.
% Arguments: FileDir - The data directory
%       XScaleHr - X scale in minutes (0-default), for X Scale in hours
%                  insert 1.
% -------------------------------------------------------------------------
% Irit L.Reisman - 01.2013 
% using FindColoniesInWorkingArea

%% arguments
if nargin<2
    XScaleHr = 0;
end

%% loading the data
DirName    = fullfile(FileDir, 'Results');
AreaFile   = fullfile(DirName, 'VecArea');
AxisFile   = fullfile(DirName, 'TimeAxis');
ColourFile = fullfile(DirName, 'ordColour');
ExcludeFile= fullfile(DirName, 'ExcludedBacteria.txt');

load(AreaFile);
load(AxisFile);
load(ColourFile);
load(ExcludeFile);

%% excluding bacteria
VecArea(ExcludedBacteria,:)   = 0;

%% Checking which colony is too close to the border
CID = FindColoniesInWorkingArea(FileDir);
NColonies = size(VecArea,1);

CloseToBorder = setdiff(CID, [1:NColonies]');

mark = repmat({'none'},NColonies,1);
MarkerFC = repmat('r',NColonies,1);

mark(CloseToBorder) = {'o'};
MarkerFC(CloseToBorder) = 'k';

%% displaying the data on a graph
% figure;

if XScaleHr
    scl = 60;
    sclUnits = '(hr)';
else
    scl = 1;
    sclUnits = '(min)';
end

for k=1:NColonies
    % Nir - added tag
    plot(TimeAxis/scl ,VecArea(k,:),...
        'Color' ,ordColour(k,:), 'Marker' ,char(mark(k)), ...
        'MarkerSize', 2, 'MarkerEdgeColor', MarkerFC(k),...
        'XdataSource','TimeAxis','YdataSource',...
        ['VecArea(',num2str(k),',:)'],'Tag',strcat('colony',num2str(k)));
    hold on;
end

title(['The area of each colony as a function of the time - ',...
       getDescription(FileDir)]);
xlabel(['Time ' sclUnits]);
ylabel('Area (pixels)');
hold off;
