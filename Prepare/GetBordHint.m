function BordHint = GetBordHint( inputImage,NumberOfPlates,PlateDiamiter)
    %BordHint = GetBordHint( inputImage,NumberOfPlates,PlateDiamiter)
    % returns  a list of all relative centers and radiuses of the bord.
    % inputImage: the source image from the scanner
    % NumberOfPlates: the number of plates in the bord
    % PlateDiamiter: in mm
    % this function postulate an A4 scanner sise.
    % created by Ofer Fridman 08/07/2014

[centers,radii] = FindAllPlates( inputImage,NumberOfPlates,PlateDiamiter);

ImageSize = [size(inputImage,2) size(inputImage,1)];% in px

ReletiveCenters = [centers(:,1)./ImageSize(1) centers(:,2)./ImageSize(2)];

ReletiveRadius =  sqrt( radii.^2/(ImageSize(1)*ImageSize(2)));

 sigfig = 0.1;

[~,index] = sortrows(round(ReletiveCenters./sigfig)*sigfig,[1 2]);

BordHint = [ ReletiveCenters(index,:) ReletiveRadius(index)];
end

