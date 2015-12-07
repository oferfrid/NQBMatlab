function motions = calcMotions(baseImageName, imageIndices, motionMethod)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%Calculates the relative motions in a sequence of images
% uses Translation or Rotation+translation
%basseImageName - base filename path (in sprintf style)
%imageIndices - vector of numbers to substitute in the baseImageName
%motionMethod - 'trans' for translation, 'transrot' for
% translaation+rotation
%motions (when using 'trans') - a matrix of length(imageIndices)x2, each row 
% contains the [u v] translation relative to the previous image. 
% The first row is [0 0]
%motions (when using 'transrot') - a cell-array that contains
% 2d-transformation matrices. the transformation matrix between the 3rd and
% the 4th images will be in motions{4}.

%initialize the result structure
if (strcmp(motionMethod, 'trans'))
    motions = [0 0];
else
    motions = {};
end

%initialize a progress bar
progress_bar = waitbar(0);
%initialize a counter of processed images
progress = 0;

%read the first image as "last_image" (the image of the last iteration)
last_img = my_im_read(sprintf(baseImageName, imageIndices(1)), 2);

%iterate through images' indices
for im_idx = imageIndices(2:end)
    %get the filename of the current image
    imfile = sprintf(baseImageName, im_idx);
    
    %update progress bar
    progress = progress + 1;
    waitbar(progress/length(imageIndices), progress_bar, ...
        sprintf('Calculating Motion: image#%d', im_idx));
    
    %read the current image
    curr_img = my_im_read(imfile, 2);
    
    %calculate motion in multi-resolution using the selected motion
    %calculation method.
    if (strcmp(motionMethod, 'trans'))
        [u v] = pyrMotion_trans(last_img, curr_img);
        %add the translation valuses into the result vector
        motions = [motions; u v];
    else
        mat = pyrMotion_rot(last_img, curr_img);
        %add transformation matrix into the result cell-array
        motions{im_idx} = mat;
    end
    
    %the the current image as the image of the last iteration
    last_img = curr_img;
end

close(progress_bar);