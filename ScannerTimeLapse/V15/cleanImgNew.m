function clnImg = cleanImgNew(I)
%% Img = cleanImg(I)
% --------------------------------------------------------------
% purpose: reading a picture file and sharpening it
%
% Arguments: I   - A grayscale image
% Returns:   Img - An image clean from noises
% --------------------------------------------------------------
% Irit Levin (with Alex) 8.8.06
% --------------------------------------------------------------

% disksize = 50;
disksize = 50;
background = imopen(I,strel('disk',disksize));
clnImg = imsubtract(I,background)*5;


%%
% figure;
% subplot(1, 2, 1); imshow(I*5); title('I');
% subplot(1, 2, 2); imshow(background*5); title('background');
% figure;
% imshow(clnImg); title('clnImg');