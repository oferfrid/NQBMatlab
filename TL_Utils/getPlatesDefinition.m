function [XsRange, YsRange, RRange]=getPlatesDefinition(Board)
%% [XsRange, YsRange, RRange]=getPlatesDefinition(Board)
% -------------------------------------------------------------------------
% Purpose: getting the coordinates of the plates
% Arguments: Board number
% Returns: The range of the centre (x,y) and radius of each plate, to look
%       for.
% -------------------------------------------------------------------------
% Irit Levin Reisman. 04.09

%% loading BoardDefinitionFile
FileName = sprintf('BoardDefinitionFile_%02d', Board);
BoardDefFile = load(FileName);
Lxlim = BoardDefFile.Lxlim;
Uxlim = BoardDefFile.Uxlim;
Lylim = BoardDefFile.Lylim;
Uylim = BoardDefFile.Uylim;
Lrlim = BoardDefFile.Lrlim;
Urlim = BoardDefFile.Urlim;

NPlates = length(Lxlim);
XsRange = zeros(NPlates,Uxlim(1)-Lxlim(1)+1);
YsRange = zeros(NPlates,Uylim(1)-Lylim(1)+1);
RRange  = Lrlim:Urlim;

%% Getting parameters
for i=1:NPlates
    XsRange(i,:) = Lxlim(i):Uxlim(i);
    YsRange(i,:) = Lylim(i):Uylim(i);
end

