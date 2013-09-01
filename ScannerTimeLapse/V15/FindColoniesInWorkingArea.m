function CID = FindColoniesInWorkingArea(FileDir)
%% CID = FindColoniesInWorkingArea(FileDir)
% -------------------------------------------------------------------------
% Purpose: Returns the colony IDs in the working area.
% 
% Description: Checks the distance of the centre of the colonies from the 
%          borders 
% 
% Arguments: FileDir - The full path of the directory
%
% Returns: CID - An Array of colony IDs
% -------------------------------------------------------------------------
% Irit L. Reisman 08.2011

%% Constants
NearBorder = 15;        % proximity to the border

%% loading the data
DirName    = fullfile(FileDir, 'Results');
CenFile    = fullfile(DirName, 'VecCen');
CircFile   = fullfile(DirName, 'CircParams');

Cen  = load(CenFile);
circ = load(CircFile);

VecCen = Cen.VecCen;

%% Checking which colony is too close to the border
NumColonies = size(VecCen,1);
CM = zeros(NumColonies,2);
for k=1:NumColonies
    AppearenceIndex = find(VecCen(k,1,:),1,'first');
    % a strage bug - there are colonies with CM (0,0) all experiment time
    if isempty(AppearenceIndex)
        CM(k,:) = [0,0];
    else
    % end patch
        CM(k,:) = VecCen(k,:,AppearenceIndex);
    end
end

%% excluding bacteria
CM(VecCen(:,1,end)==0,:)  = 0;

%% Calculating distance
distFromCM  = sqrt((circ.x-CM(:,1)).^2+(circ.y-CM(:,2)).^2);
CID = find(NearBorder < circ.r- distFromCM);
