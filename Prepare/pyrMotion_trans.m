function [u v] = pyrMotion_trans(im1, im2, mask)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%pyrMotion - calculates motion between two grayscale images. uses
% multi-resolution translation-only iterative LK algorithm.
% assumes images are of the same size.
%
%im1, im2 - the two images.
%[u v] - the resulting translation parameters to apply on im2.

%create the pyramids of two images. Give a maximum of 10 levels 
% (very large on purpose), as the actual number of levels is automatically 
% determined by GaussianPyramids, so that there are no levels of less than 
% 32x32 pixels.
p1 = GaussianPyramid(im1, 10, 2);
p2 = GaussianPyramid(im2, 10, 2);
if (exist('mask'))
    pm = GaussianPyramid(mask, 10, 2);
end

%initialize the translation result to start from 0,0
translation = [0;0];

%initialize margin to start from 2. LK calculations will not use the
% first/last 2 rows/columns.
margin = 2;

%iterate through pyramid levels, starting from top, not including the
% lowest level (very slow and extra accuracy is not needed)
for i = length(p1):-1:3  %%MM%% was: 3
    %multiply margin and translation by two, to convert the value for the 
    % lower-level (the 2x larger image).
    margin = margin * 2;
    translation = 2 * translation;
    
    %calculate the translation motion using iterative LK.
    if (exist('mask'))
        [translation(1) translation(2)] = motion_trans(p1{i}, p2{i}, translation, margin, pm{i});
    else
        [translation(1) translation(2)] = motion_trans(p1{i}, p2{i}, translation, margin);
    end
end

%update the translation result, for the real size of the image (the lower
% level big image was not used above).
translation = 2 * translation;

%return the parameters
u = translation(1);
v = translation(2);