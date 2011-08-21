function coupling = MatchColonies(L, Areas, PrevCM)
% coupling = MatchColonies(L, Areas, PrevCM)
% -------------------------------------------------------------------------
% Purpose: Matching the colonies from the previous picture to the new one
%
% Description: looking at the CM the first time a colony has apeared, and
%       checking what in the matching number on the L matrix to it.
%       If there is a an are on L that wasn't matched - it is concidered as
%       a new colony (if it is bigger then a threshold of 10 pxl).
%
% Arguments: L - The labeled picture
%       Area - the area of each colonie found
%       PrevCM - a 2D matrix with the CM of each colony in the first time
%       it apeared
%
% Returns: coupling - the order of the colonies in the current picture.
% -------------------------------------------------------------------------
% Irit Levin. September 2006.

% Constants
Min_Area       = 10;        % minimal area for thr colony to be added

% Initializations
PrevNColonies = size(PrevCM,1);
NComponents = max(L(:));                
coupling    = zeros(PrevNColonies,1);   % Order of colonies
OldColony   = zeros(NComponents,1);     % indication for old colonies

% for each previous colony, checking the same area in the next frame
for k=1:PrevNColonies
    if PrevCM(k,1)~=0
        % placing the Centre Mass on the L picture, and matching the number
        coupling(k) = L(round(PrevCM(k,2)),round(PrevCM(k,1)));
        if coupling(k)~= 0
            OldColony(coupling(k)) = 1;
        end
    end
end

% adding the new colonies that are bigger then the minimal threshold
NewColony = find(OldColony == 0);
if ~isempty(NewColony)
    NewBigCol = NewColony(Areas(NewColony) >= Min_Area);
    coupling  = [coupling; NewBigCol];
end