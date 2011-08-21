function [TimeAxis,AppearenceMinute] = AppearenceDistribution(FileDir)
% [TimeAxis,AppearenceMinute] = AppearenceDistribution(FileDir)
% -------------------------------------------------------------------------
% Purpose: This function calculates when each colony started apearing
% 
% Description: The function checkes which colonies have survived, and for
%   them, it checkes, when were they first detected
% 
% Arguments: FileDir - The directory of the data
%
% Returns: TimeAxis - times of frames
%   AppearenceMinute - a vector of the appearence minute of each colony
% -------------------------------------------------------------------------
% Irit Levin. 12.2006
% Update: 03.08
% returns a vector of the appearence minute instead of How many colonies
% showed up in each frame

% Constants
r = 440;       % the radius of the plate
NearBorder = 15;        % proximity to the border

% Loading data and initializations
DirName = fullfile(FileDir, 'Results');
load(fullfile(DirName,'VecArea'));
load(fullfile(DirName,'TimeAxis'));
load(fullfile(DirName,'CircParams'));
load(fullfile(DirName,'VecCen'));
load(fullfile(DirName,'ExcludedBacteria.txt'));

%DistrVec = zeros(size(TimeAxis,1),1);

% excluding bacteria
VecArea(ExcludedBacteria,:)   = 0;
VecCen(ExcludedBacteria,:,:)  = 0;

% Checking which colonies are too close to the border
% colonies that have disapeared will be out of border (0-Xcm)^2+(0-Ycm)^2
CM = VecCen(:,:,end);
distBorder  = sqrt((x(1)-CM(:,1)).^2+(y(1)-CM(:,2)).^2);
NotCloseToBorder = find(distBorder<r-NearBorder);

% Claculating the distribution
AppearenceMinute = zeros(length(NotCloseToBorder),1);
for k=1:length(NotCloseToBorder)
    % ApearenceMinute = find(VecArea(NotCloseToBorder(k),:),1);
    AppearenceIndex = find(VecArea(NotCloseToBorder(k),:),1);
    AppearenceMinute(k) = TimeAxis(AppearenceIndex);
    % DistrVec(ApearenceMinute) = DistrVec(ApearenceMinute)+1;
end