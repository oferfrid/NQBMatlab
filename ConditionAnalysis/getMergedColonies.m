function [result] = getMergedColonies(VecCen)
%% [result] = getMergedColonies()
% -------------------------------------------------------------------------
% Purpose: This function return for each colony the first time it merged.
% 
% Description: for each colony, thius function caculate the index (!) of
% the first time it merged in the time axis.
%
% Arguments: DirName - the directory of the VecCen file.
%
% Returns: result - an array of all colonies and for each colony the
% relevant index or 0 if colony didn't merge.
% -------------------------------------------------------------------------
% Nir Dick. 9.2013
    
    coloniesNum=size(VecCen,2);
    timesNum=size(VecCen,1);
    
    result=zeros(coloniesNum,1);
    
    % For each colony search the first time the center exists
    % not only for current colony and remove this data's area from the
    % tmp area vec
    for j=1:coloniesNum
        for k=1:timesNum
            % Get colony center
            cen=[VecCen(k,j,1) VecCen(k,j,2)];
            if ((cen(1) ~= 0) || (cen(2) ~= 0))
                cenColoniesNum=...
                      sum(VecCen(k,:,1)==cen(1,1)&VecCen(k,:,2)==cen(1,2));
                  
                if (cenColoniesNum>1)
                    result(j,1)=k;
                    break;
                end
            end
        end
    end
end

