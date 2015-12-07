function [image,map] = my_im_read(filename, conversion)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%MY_IM_READ reads image from graphic file. uses imread.
%   [X,MAP] = MY_IM_READ(FILENAME, 1) reads an image (all supported formats
%   in imread) and converts it to indexed image with 256 colors map
%   [A = MY_IM_READ(FILENAME, 2) reads an image (all supported formats
%   in imread) and converts it to intensity (grayscale) image. values are
%   in doubles.
%   [A = MY_IM_READ(FILENAME, 3) reads an image (all supported formats
%   in imread) and converts it to an RGB image. values are
%   in doubles.

%get the original image's colortype
inf = imfinfo(filename);
colortype = inf.ColorType;
%read the original image
[orig_image, orig_map] = imread(filename);

%by default the image is untouched and the original image and colormap 
%(if exists) are returned. if a conversion is needed it is performed by 
%the switch clause below
image = orig_image;
map = orig_map;

%convert the image to the specified type
switch conversion
    case 1 %converting to indexed
        switch colortype
            case 'grayscale'
                [image,map] = gray2ind(orig_image,256);
            case 'truecolor'
                [image,map] = rgb2ind(orig_image,256);
            %if image is already indexed, it doesn't change
        end
        %256-colors indexed images represent their color values in doubles 
        % and the indexes in uint8

    case 2 %converting to grayscale
        switch colortype
            case 'truecolor'
                image = rgb2gray(orig_image);
            case 'indexed'
                image = ind2gray(orig_image, orig_map);
            %if image is already grayscale, it doesn't change
        end
        %convert to doubles
        image = im2double(image);
        %get rid of map which is unneeded in this case
        map = [];
        
    case 3 %converting to RGB
        switch colortype
            case 'grayscale'
                %there is no direct conversion...
                [image,map] = gray2ind(orig_image, 256);
                image = ind2rgb(image,map);
            case 'indexed'
                image = ind2rgb(orig_image, orig_map);
            %if image is already truecolor, it doesn't change
        end
        %convert to doubles
        image = im2double(image);
        %get rid of map which is unneeded in this case
        map = [];
        
    otherwise
        disp 'ERROR: Unknown conversion type. see help.'
end