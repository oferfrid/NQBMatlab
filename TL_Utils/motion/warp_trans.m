function warped = warp_trans(img, u, v, nan2zero, interpMethod)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%warp_trans - warps an imgage using back-warping. The translation 
% parameters are given.
%
%img - grayscale image to warp
%u - x translation
%v - y translation
    
%prepare a mesh grid of lookups into the original image. use u,v
%translation values to move the grid to the target.
[sizeY sizeX] = size(img);
XI = u + repmat([1:sizeX],   sizeY, 1);
YI = v + repmat([1:sizeY]', 1, sizeX);

%interpolate (bilinear interpolation)
warped = interp2(img, XI, YI, interpMethod);

%set all invalid values (pixels that we don't have image data for them) to 
% 0 (black).
if (nan2zero)
    warped(isnan(warped)) = 0;
end
