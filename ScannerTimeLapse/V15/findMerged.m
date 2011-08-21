function mergedColonies = findMerged(DirName)
% mergedColonies = findMerged(DirName)
% -------------------------------------------------------------------------
% Purpose: finding which colonies have merged
% Description: assuming that if colonies have merged they will still be
%       merged in the last frame
% Arguments: DirName
% Returns: mergedColonies - an array of merged colonies
% -------------------------------------------------------------------------
% Irit Levin Reisman. 7.2008

mergedColonies = [];
CenFile    = fullfile(DirName, 'Results', 'VecCen');
ExcludeFile= fullfile(DirName, 'Results', 'ExcludedBacteria.txt');
load(CenFile);
load(ExcludeFile);
VecCen(ExcludedBacteria,:,:) = 0;

for i=1:size(VecCen,1)
    if (VecCen(i,:,end)~= [0 0])
        ind1 = find(VecCen(i,1,end)==VecCen(:,1,end));
        ind2 = find(VecCen(i,2,end)==VecCen(:,2,end));
        bothInd = intersect(ind1, ind2);
        % if intersection includes more then the colony itself
        if length(bothInd)>1
            mergedColonies = [mergedColonies; i];       
        end
    end
end