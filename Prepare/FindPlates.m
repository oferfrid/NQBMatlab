function [Rects PlateCirc] = FindPlates( inputImage,BoardHint)
    %rects = FindPlates( inputImage,BoardHint)
    % return the bounding rectangel of the plates in the image
    % inputImage: the source image from the scanner
    % BoardHint: a list of all relative centers and radiuses of the Board.
    % created by Ofer Fridman 08/07/2014
    ImageSize = [size(inputImage,2) size(inputImage,1)];% in px

    Sensitivity = 0.99;
    Method = 'PhaseCode';
    ObjectPolarity = 'Dark';
    
    


    PlateCirc =  cell(length(BoardHint.Radius),1);
    Rects = cell(length(BoardHint.Radius),1);
    for i=1:length(BoardHint.Radius)

        EdgeThreshold = 0.5;
        EdgeThresholdLim = [0.17 0.7];
        
        HintCenter  = BoardHint.Centers(i).*ImageSize;
        HintRadius = sqrt(BoardHint.Radius(i).^2*(ImageSize(1)*ImageSize(2)));
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
         PlateCirc{i}.X = center(1)+PlateRect(1);
         PlateCirc{i}.Y = center(2)+PlateRect(2);
         PlateCirc{i}.R = radi;
         Rects{i} = [PlateCirc{i}.X-PlateCirc{i}.R,PlateCirc{i}.Y-PlateCirc{i}.R,2*PlateCirc{i}.R,2*PlateCirc{i}.R ];
    
    end

end

