function relevantArea = GetMask(Data,Rows,Cols)
    if  isfield(Data,'FullMask')
        relevantArea = Data.FullMask;
    % Working with a circled area
    else
        if  isfield(Data,'CircleMask')
            x=Data.CircleMask.X;
            y=Data.CircleMask.Y;
            r=Data.CircleMask.R;
        else
            x=Data.PlateCirc.X;
            y=Data.PlateCirc.Y;
            r=Data.PlateCirc.R;
        end
        indMat(:,:,1) = repmat((1:Rows)', 1, Cols);
        indMat(:,:,2) = repmat( 1:Cols , Rows ,1);
        dist = sqrt((indMat(:,:,2)-x(1)).^2+(indMat(:,:,1)-y(1)).^2);
        relevantArea = dist<=r;
    end
end
