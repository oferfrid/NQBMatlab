function L = im2L(Image,Background,limits,TH,relevantArea)
        clnImg=CleanImage(Image,Background);
        
        % Process the image to bw colonies map
        clnImg=im2double(clnImg);
        clnImg=imadjust(clnImg,limits,[]);
        clnImgBW = im2bw(clnImg,TH);
        clnImgBW = medfilt2(clnImgBW);
        L = relevantArea.*im2double(clnImgBW);
end

