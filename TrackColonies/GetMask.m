function relevantArea = GetMask(SourceDir,Rows,Cols,DefCirc)
    fullMaskName=fullfile(SourceDir,'mask.mat');
    fullCircsName=fullfile(SourceDir,'CircParams');
    if exist(fullMaskName,'file')
        relevantArea = load(fullMaskName);
        relevantArea = relevantArea.mask;
    % Working with a circled area
    else
        if exist(fullMaskName,'file')
            load(fullCircsName);
        else
            x=DefCirc.x;
            y=DefCirc.y;
            r=DefCirc.r;
        end
        
        indMat(:,:,1) = repmat([1:Rows]', 1, Cols);
        indMat(:,:,2) = repmat([1:Cols] , Rows ,1);
        dist = sqrt((indMat(:,:,2)-x(1)).^2+(indMat(:,:,1)-y(1)).^2);
        relevantArea = dist<=r;
    end
end

