function CropROI(SourceName,DestDirNames,BoadHint,Plates2Cut)
    %% Find ROI
    % This section responsible to find the relevant rois in the image
    % using the board hint
    
    %% Align and cut ROI
    AlignandCut(SourceName,DestDirNames,Plates2Cut,CropInf);
end

