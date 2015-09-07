function L = im2L(Image,Background,limits,TH,relevantArea)
% L = im2L(Image,Background,limits,TH,relevantArea)
% Convert an rgb image to bw image according to the relevant image.
% arguments:
%       Image - an rgb image
%       Background - background of the rgb image
%                       (i.e. the data to be removed from the image)
%       limits - stretch info for grayscale image
%       TH - treshold for colonies identification
%       relevantArea - binary mask
% returns:
%       L - the bw image in relevant area

        clnImg=cleanImage(Image,Background);
        
        % Process the image to bw colonies map
        clnImg=im2double(clnImg);
        clnImg=imadjust(clnImg,limits,[]);
        clnImgBW = im2bw(clnImg,TH);
        clnImgBW = medfilt2(clnImgBW);
        L = relevantArea.*im2double(clnImgBW);
end

