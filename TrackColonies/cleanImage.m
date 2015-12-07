function clnImg = CleanImage(I,bg)
%% Img = cleanImg(I,bg)
% --------------------------------------------------------------
% purpose: reading a picture file and sharpening it
%
% Arguments: I   - rgb image
% Returns:   bg - rgb background
% --------------------------------------------------------------
% Nir Dick 2015

clnImg = rgb2gray(imsubtract(I,bg));

%%
% figure;
% subplot(1, 2, 1); imshow(I*5); title('I');
% subplot(1, 2, 2); imshow(background*5); title('background');
% figure;
% imshow(clnImg); title('clnImg');
