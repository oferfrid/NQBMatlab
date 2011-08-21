function ConvertToV12(DirName)
%%
% ConvertToV11(DirName)
% -------------------------------------------------------------------------
% Purpose: Converting the directory structure to V1.1
% Arguments: DirName - full directory of resuults to convert
% -------------------------------------------------------------------------
% Irit Levin, 01.2008

%% creating the directories
[successMK,mgsMK,msgidMK] = mkdir(DirName,'Results');
if ~successMK
    error(msgidMK, mgsMK);
end
[successMK,mgsMK,msgidMK] = mkdir(DirName,'LRGB');
if ~successMK
    error(msgidMK, mgsMK);
end
[successMK,mgsMK,msgidMK] = mkdir(DirName,'Pictures');
if ~successMK
    error(msgidMK, mgsMK);
end
%% moving the files
[successMV,mgsMV,msgidMV] = movefile(fullfile(DirName,'L*.mat'),fullfile(DirName,'LRGB'));
if ~successMV
    error(msgidMV, mgsMV);
end
[successMV,mgsMV,msgidMV] = movefile(fullfile(DirName,'*.mat'),fullfile(DirName,'Results'));
if ~successMV
    error(msgidMV, mgsMV);
end
[successMV,mgsMV,msgidMV] = movefile(fullfile(DirName,'*.tif'),fullfile(DirName,'Pictures'));
if ~successMV
    error(msgidMV, mgsMV);
end

%% creating files
fid = fopen(fullfile(DirName,'Results','ExcludedBacteria.txt'), 'w');
fclose(fid);
