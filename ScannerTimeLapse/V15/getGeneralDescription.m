function [GenDescription, GenDir] = getGeneralDescription(DirName)
%% [GenDescription, GenDir] = getGeneralDescription(DirName)
% -------------------------------------------------------------------------
% Purpose: getting the description for a whole experiment (not per plate)
% Description: assumes that the descriptions has the format xxxxx{(s#p#)}
%       and that the directories are of format ######_#_#
% Arguments: DirName
% Returns: GenDescription - general description
%       GenDir - general Dir name
% -------------------------------------------------------------------------
description = getDescription(DirName);
plateNloc = findstr( description,'_{(s' );
if ~isempty(plateNloc)
    description = description(1:plateNloc-1);
end
GenDescription = description;

[pathstr, NameDir] = fileparts(DirName);
plateNloc = findstr( NameDir,'_' );
DirDesc = NameDir;
if ~isempty(plateNloc)
    DirDesc = NameDir(1:plateNloc(2)-1);
end
GenDir = DirDesc;