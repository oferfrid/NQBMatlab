function rects = FindPlates( inputImage,BordHint)
    %rects = FindPlates( inputImage,BordHint)
    % return the bounding rectangel of the plates in the image
    % inputImage: the source image from the scanner
    % BordHint: a list of all relative centers and radiuses of the bord.
    % created by Ofer Fridman 08/07/2014
    ImageSize = [size(inputImage,2) size(inputImage,1)];% in px

    Sensitivity = 0.99;
    Method = 'PhaseCode';
    ObjectPolarity = 'Dark';
    
    


    centers= nan(size(BordHint,1),2);
    radii = nan(size(BordHint,1),1);
    rects = cell(size(BordHint,1),1);
    for i=1:size(BordHint,1)

        EdgeThreshold = 0.5;
        EdgeThresholdLim = [0.17 0.7];
        
        HintCenter  = BordHint(i,1:2).*ImageSize;
        HintRadius = sqrt(BordHint(i,3).^2*(ImageSize(1)*ImageSize(2)));
        RadiusTolerence=0.02;
        MinMaxRadius = round(HintRadius *[1-RadiusTolerence 1+RadiusTolerence]);
        
        CropExtra = 1.05;
        CropRadius = CropExtra*HintRadius;

        PlateRect = [HintCenter(1)-CropRadius,HintCenter(2)-CropRadius,2*CropRadius,2*CropRadius ];

        PlateImage = imcrop(inputImage,PlateRect);

        OutDelta = nan;
        MaxIteration = 20;
         iterations = 0; 
         while (OutDelta~=0 && iterations<MaxIteration)
             iterations = iterations+1;
             [center,radi] = imfindcircles(PlateImage,MinMaxRadius,...
                        'Sensitivity',Sensitivity,...
                        'EdgeThreshold',EdgeThreshold,...
                        'Method',Method,...
                        'ObjectPolarity',ObjectPolarity);
             OutDelta = length(radi)-1;
             if OutDelta ~=0
                if OutDelta>0
                     EdgeThresholdLim(1) = EdgeThreshold;
                else 
                     EdgeThresholdLim(2) = EdgeThreshold;
                end
                EdgeThreshold = mean(  EdgeThresholdLim);
             else 
                 break;
             end
         end

         if iterations == MaxIteration
             throw (MException('FindPlates:NoConvergence','No Convergence Number of iterations exceeded'));
         end
    centers(i,:) = [center(1)+PlateRect(1) center(2)+PlateRect(2) ];
    radii(i) = radi;
    rects{i} = [centers(i,1)-radii(i),centers(i,2)-radii(i),2*radii(i),2*radii(i) ];

    end
end

