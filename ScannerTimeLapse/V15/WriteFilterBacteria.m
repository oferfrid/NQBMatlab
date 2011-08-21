function WriteFilterBacteria(DirName, ExcludedBacteria)
% WriteFilterBacteria(DirName, ExcludedBacteria)
% -------------------------------------------------------------------------
% Purpose: creating the excluded bacteria file
% Arguments: DirName- full directory name
%       excludedBact - An array of the numbers of the bacteria to be excluded
% Output File: DirName\Results\ExcludedBacteria.txt
% -------------------------------------------------------------------------
% Irit L. Reisman. 03.2008

ResDir    = fullfile(DirName, 'Results');
% oldExcludedBact = [];
% dirOutput = dir(fullfile(ResDir,'ExcludedBacteria.txt'));
% if size(dirOutput,1)
%     oldExcludedBact = load(fullfile(ResDir,'ExcludedBacteria.txt'));
% end
% NewExcludedBacteria = union(oldExcludedBact, excludedBact);
fid = fopen(fullfile(ResDir,'ExcludedBacteria.txt'), 'w');
fprintf(fid, '%d\n', ExcludedBacteria);
fclose(fid);
