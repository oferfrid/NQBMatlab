function [xbegin, xend, ybegin, yend] = AlignImages(Img1, Img2)
% -------------------------------------------------------------------------
% Purpose : Aligning Pictures
%
% Description: Registering an Image Using Normalized Cross-Correlation
% 
% -------------------------------------------------------------------------
% Mostly copied from ipexnormxcorr2. Adjusted by Irit Levin. 02.2007

%% Initializations
Img1R = size(Img1,1);
Img1C = size(Img1,2);
Img2R = size(Img2,1);
Img2C = size(Img2,2);

%% Step 2: Choose Subregions of Each Image
% It is important to choose regions that are similar. The image |sub_onion|
% will be the template, and must be smaller than the image |sub_peppers|. 
% You can get these sub regions using either the non-interactive script
% below *or* the interactive script.

% non-interactively
% rect: [xmin ymin width height]
rect_Img2 = [20 30 Img2C-80 Img2R-80];
rect_Img1 = [ 1  1 Img1C    Img1R   ];
sub_Img2  = imcrop(Img2,rect_Img2);
sub_Img1  = imcrop(Img1,rect_Img1);

% OR 
   
% interactively
%[sub_Img2,rect_Img2] = imcrop(Img2); % choose the pepper below the Img2
%[sub_Img1,rect_Img1] = imcrop(Img1); % choose the whole Img2

% display sub images
%figure, imshow(sub_Img2(:,:,1))
%figure, imshow(sub_Img1(:,:,1)) 

%% Step 3: Do Normalized Cross-Correlation and Find Coordinates of Peak
% Calculate the normalized cross-correlation and display it as a surface
% plot. The peak of the cross-correlation matrix occurs where the
% sub_images are best correlated. |normxcorr2| only works on grayscale
% images, so we pass it the red plane of each sub image.

c = normxcorr2(sub_Img2(:,:,1),sub_Img1(:,:,1));
%figure, surf(c), shading flat

%% Step 4: Find the Total Offset Between the Images
% The total offset or translation between images depends on the location of
% the peak in the cross-correlation matrix, and on the size and position of
% the sub images.

% offset found by correlation
[max_c, imax] = max(abs(c(:)));
[ypeak, xpeak] = ind2sub(size(c),imax(1));
corr_offset = [(xpeak-size(sub_Img2,2)) 
               (ypeak-size(sub_Img2,1))];

% relative offset of position of subimages
rect_offset = [(rect_Img1(1)-rect_Img2(1)) 
               (rect_Img1(2)-rect_Img2(2))];

% total offset
offset = corr_offset + rect_offset;
xoffset = offset(1);
yoffset = offset(2);

%% Step 5: See if the Img2 Image was Extracted from the Img1 Image
% Figure out where |Img2| falls inside of |Img1|. 

xbegin = round(xoffset+1);
xend   = round(xoffset+ size(Img2,2));
ybegin = round(yoffset+1);
yend   = round(yoffset+size(Img2,1));

% % extract region from Img1 and compare to Img2
% extracted_Img2 = Img1(ybegin:yend,xbegin:xend,:);
% if isequal(Img2,extracted_Img2) 
%    disp('Img2.png was extracted from Img1.png')
% end

%% Step 6: Pad the Img2 Image to the Size of the Img1 Image
% Pad the |Img2| image to overlay on |Img1|, using the offset
% determined above.

recovered_Img2 = uint8(zeros(size(Img1)));
recovered_Img2(ybegin:yend,xbegin:xend,:) = Img2;
%figure, imshow(recovered_Img2)

%% Step 7: Transparently Overlay Img2 Image on Img1 Image
% Create transparency mask to be opaque for Img2 and semi-transparent
% elsewhere.

% [m,n,p] = size(Img1);
% mask = ones(m,n); 
% i = find(recovered_Img2(:,:,1)==0);
% mask(i) = .2; % try experimenting with different levels of 
%               % transparency
% 
% % overlay images with transparency
% figure, imshow(Img1(:,:,1)) % show only red plane of Img1
% hold on
% h = imshow(recovered_Img2); % overlay recovered_Img2
% set(h,'AlphaData',mask)
