function [relevantArea] = getRelevantAreaMask(DirName,rows,cols)
    fullMaskName=fullfile(DirName,'Results','mask.mat');
    
    % Mask
    if exist(fullMaskName,'file')
        relevantArea = load(fullMaskName);
        relevantArea = relevantArea.mask;
    % Working with a circled area
    else
        load(fullfile(DirName,'Results', 'CircParams'));
        a = repmat([1:rows]', 1, cols);
        b = repmat([1:cols] , rows ,1);
        dist=sqrt((a-x(1)).^2+(b-y(1)).^2);
        relevantArea = dist<=r;
    end
end

