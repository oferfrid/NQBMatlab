function pyr = GaussianPyramid(Img, nLevels, filterLevel)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%GaussianPyramid constructs a gaussian pyramid from an image. The upper
%level of the pyramid is not smaller than 32x32, if too many levels are
%given it prepares the right number of levels so that images are not too
%small.
%
%Img - the input image (grayscale, double).
%nLevels - the number of levels in the pyramid.
%filterLevel - pascal level for the gaussian filter (see createFilter)
%returns a cell array with nLevels number images, the filrst level is the
%original image.

%reduce the nLevels if there are too many levels. minimum number of pixels 
% per dimension is 32.
if (size(Img,1)/2^(nLevels-1) < 16)
    nLevels = floor(log2(size(Img,1))-4);
end
if (size(Img,2)/2^(nLevels-1) < 16)
    nLevels = floor(log2(size(Img,2))-4);
end
if (nLevels < 1)
    error 'nLevels < 1, or picture too small'
end

%create the bluring gaussian filter
filter = createFilter(filterLevel);

%put the original image in the first level
pyr{1} = Img;

%create the higher levels
for pyrLevel = 1:(nLevels-1)
    %create the smaller image
    blurred = imfilter(pyr{pyrLevel}, filter, 'replicate');
   
    %subsample: take every second pixel
    subsampled = blurred(1:2:end, 1:2:end);
    
    %put the resulting level in the pyramid
    pyr{pyrLevel+1} = subsampled;
end