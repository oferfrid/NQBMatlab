function Lrgb = image2Lrgb(Image,Background,Limits,TH,RelevantArea)
% Lrgb = image2Lrgb(Image,Background,Limits,TH,RelevantArea)
% Transforming an rgb image to bw image and assign a color for each
% connected  in the bw image. 
% arguments:
%       Image - the rgb image
%       Background - the rgb background
%       Limits - grayscale trectching info.
%       TH - colonies treshold
%       RelevantArea - mask binary image
% returns:
%       Lrgb - n*3 colormap

    L=im2L(Image,Background,Limits,TH,RelevantArea);
    L=bwlabel(L);
    Lrgb = label2rgb(L,'jet', 'k', 'shuffle');
    Lrgb=im2double(Lrgb);
end

