function [mosaic motions] = CalcMotionAndStitch(baseImageName, ...
    firstFileIndex, lastFileIndex, jump, stitchMethod, overlapStripWidth, ...
    displaySeamsOnPanorama, displayStitchProcess, motionMethod)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%This is the main function used almost directly from ex4. This function 
% calls the motion calculation and then calls the stitching function. This
% function has an additional parameter of motionMethod to select between 
% translation and translation+rotation.
%
%basseImageName - base filename path (in sprintf style)
%firstFileIndex - number of first image (to substitute in baseImageName)
%lastFileIndex - number of last image
%jump - jump value for image indices
%stitchMethod - method to use when stitching the panorama: 'basic'/'mincut'
%overlapStripWidth - This numeric param is used with 'mincut'. It is the 
% half of the width of the overlap area to be used when looking for mincut. 
% It also determines the minimum accumulated translation between to images 
% to stitch.
%displaySeamsOnPanorama - This boolean param is used with 'mincut'.
% when this param is 1, it displays the mincut seams whem displaying the
% progress and on the resulting mosaic.
%displayStitchProcess - This is a boolean param. When this param is 1, 
% it displays the stitching progress after each image is read and stitched
% to the panorama.
%motionMethod - 'trans' for translation, 'transrot' for
% translaation+rotation.
%mosaic - the resulting mosaic.
%motions - depends on motionMethod, see documentation of the return value 
% of calcMotions.

%do checks on parameters
if ((~strcmp(stitchMethod,'basic')) && (~strcmp(stitchMethod,'mincut')))
    error 'stitchmethod should be either "basic" of "mincut"'
end
if ((~strcmp(motionMethod,'trans')) && (~strcmp(motionMethod,'transrot')))
    error 'motionMethod should be either "trans" or "transrot"'
end
if (~strcmp(stitchMethod,'mincut'))
    displaySeamsOnPanorama = 0;
end

%convert image indices parameters into a vector of actual image numbers.
%ensure a minimum of two images to stitch.
imageIndices = firstFileIndex:jump:lastFileIndex;
if (length(imageIndices) <= 1)
    error 'num of images <= 1'
end

%calculate the motions between images
motions = calcMotions(baseImageName, imageIndices, motionMethod);

%stitch and create the mosaic
mosaic = StitchImages(baseImageName, imageIndices, motions, motionMethod, ...
    stitchMethod, overlapStripWidth, displaySeamsOnPanorama, ...
    displayStitchProcess);