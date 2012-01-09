function clnImg = cleanImgNew(I,bg)
%% Img = cleanImg(I,bg)
% --------------------------------------------------------------
% purpose: reading a picture file and sharpening it
%
% Arguments: I   - A grayscale image
% Returns:   Img - An image clean from noises
% --------------------------------------------------------------
% Irit Levin (with Alex) 8.8.06
% --------------------------------------------------------------

% disksize = 50;
Ibg = rgb2gray(imsubtract(I,bg));
TH = 13/255;
Mask = im2bw( Ibg,TH);
clnImg =  medfilt2(Mask);
%%
% figure;
% subplot(1, 2, 1); imshow(I*5); title('I');
% subplot(1, 2, 2); imshow(background*5); title('background');
% figure;
% imshow(clnImg); title('clnImg');