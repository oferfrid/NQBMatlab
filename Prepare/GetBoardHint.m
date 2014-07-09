function BoardHint = GetBoardHint( inputImage,NumberOfPlates,PlateDiamiter)
    %BoardHint = GetBoardHint( inputImage,NumberOfPlates,PlateDiamiter)
    % returns  a list of all relative centers and radiuses of the Board.
    % inputImage: the source image from the scanner
    % NumberOfPlates: the number of plates in the Board
    % PlateDiamiter: in mm
    % this function postulate an A4 scanner sise.
    % created by Ofer Fridman 08/07/2014

[centers,radii] = FindAllPlates( inputImage,NumberOfPlates,PlateDiamiter);

ImageSize = [size(inputImage,2) size(inputImage,1)];% in px

ReletiveCenters = [centers(:,1)./ImageSize(1) centers(:,2)./ImageSize(2)];

ReletiveRadius =  sqrt( radii.^2/(ImageSize(1)*ImageSize(2)));

 sigfig = 0.1;

[~,index] = sortrows(round(ReletiveCenters./sigfig)*sigfig,[1 2]);

AlignmentArea=[870/ImageSize(1) 800/ImageSize(2) 900/ImageSize(1) 800/ImageSize(2)];

BoardHint.Centers = ReletiveCenters(index,:);
BoardHint.Radius = ReletiveRadius(index);
BoardHint.AlignmentArea = AlignmentArea;
BoardHint.RelativeMaskRadius = 0.8;

end

function [centers,radii] = FindAllPlates( inputImage,NumberOfPlates,PlateDiamiter)
  %[centers,radii] = FindAllPlates( inputImage,NumberOfPlates,PlateDiamiter)
    % returns  a centers and radiuses plates in the Board.
    % inputImage: the source image from the scanner
    % NumberOfPlates: the number of plates in the Board
    % PlateDiamiter: in mm
    % this function postulate an A4 scanner sise.
    % created by Ofer Fridman 08/07/2014

    A4ScannerSize = [297 210].*1.035; %in mm
    ImageSize = [size(inputImage,1) size(inputImage,2)];% in px

    ApproximateRadius = mean(ImageSize./A4ScannerSize*PlateDiamiter/2);

    RadiusTolerence=0.02;
    MinMaxRadius = round(ApproximateRadius *[1-RadiusTolerence 1+RadiusTolerence]);


    Sensitivity = 0.99;
    Method = 'PhaseCode';
    ObjectPolarity = 'Dark';
    EdgeThreshold = 0.5;
    EdgeThresholdLim = [0.17 0.7];

     OutDelta = nan;
     iterations = 0; 
     while (OutDelta~=0 || iterations<=20)

         iterations = iterations+1;
         [centers,radii] = imfindcircles(inputImage,MinMaxRadius,...
                    'Sensitivity',Sensitivity,...
                    'EdgeThreshold',EdgeThreshold,...
                    'Method',Method,...
                    'ObjectPolarity',ObjectPolarity);
         OutDelta = length(radii)-NumberOfPlates;
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

 if iterations == 20
     MException('FindPlates:NoConvergence','Number of iterations exceeded');
 end
 

  
end

