function description = getDescription(DirName)
%% 
% description = getDescription(DirName)
% -------------------------------------------------------------------------
% Purpose: returns the description of the experiment
% -------------------------------------------------------------------------
% Irit L. Reisman. 02.2008

%%
description = '';
FileInLibrary = dir(fullfile(DirName, 'Results','LogFile.txt'));
if size(FileInLibrary,1)
    fid = fopen(fullfile(DirName, 'Results','LogFile.txt'));
    for i=1:3
        description = fgetl(fid);
    end
    if isempty(description)
        [pathstr, NameDir] = fileparts(DirName);
        description = NameDir;
    end
else
    [pathstr, NameDir] = fileparts(DirName);
    description = NameDir;
end