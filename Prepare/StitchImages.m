function mosaic = StitchImages(baseImageName, imageIndices, motions, ...
motionMethod, stitchMethod, overlapStripWidth, ...
    displaySeamsOnImg, displayStitchProcess);
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%StitchImages - stitches the images with the calculated motions into a
    % mosaic.
    %
    %basseImageName - base filename path (in sprintf style)
    %imageIndices - vector of numbers to substitute in the baseImageName
    %motions - the motions parameters, in the same format that calcMotions
    % retuens. Note that this parameter has a different type when using
    % different motionMethods.
    %motionMethod - 'trans' for translation, 'transrot' for
    % translaation+rotation.
    %all other parameters, see CalcMotionAndStitch
    %mosaic - the resulting mosaic

    %When displaying stitch process, open a new figure so that the stitch 
    % process can be viewed.
    if (displayStitchProcess)
        figure('Name', 'Stitch Process');
    end
    
    %create the mosaic with the height is of the first image, and the 
    % total mosaic width, assuming all images are of the same size.
    % When using rotation, we don't pre-allocate the memory to simplify 
    % the code here, this was checked not to be a performance issue.
    img1 = my_im_read(sprintf(baseImageName, imageIndices(1)), 3);
    if (strcmp(motionMethod, 'trans'))
        mosaic = zeros([size(img1,1) size(img1,2)-fix(sum(motions(:,1))) 3]);
    else
        mosaic = zeros([size(img1,1) 0 3]);
    end
    % paste the first image into the mosaic.
    mosaic(:,1:size(img1,2),:) = img1;

    %Create a seams mask. The mask is a logical matrix that accumulates the
    % seams for the whole stitch. This method is more accurate because it 
    % displays all the seams, and doesn't overwrite areas with new seams. 
    % It's also important not to merge the seams into the mosaic before the
    % end, because it changes the panorama and will change the input for 
    % the mincut algorithm (as if the original panorama had a distinctive 
    % seam on it)
    if (displaySeamsOnImg)
        seams_mask = logical(zeros([size(mosaic,1) size(mosaic,2)]));
    end

    %initizlize a pointer that holds the current end of the mosaic. It
    % points in the mosaic to the next column that has not been used yet.
    column = size(img1,2)+1;
    
    %initializes accumulated translations, for 'trans' motionMethod
    % accumulated_skipped is used in mincut to ensure minimum translation
    %  between images. it holds the x-translation from the last stitching 
    %  point. 
    % accumulated_y is the accumulated translation in Y.
    % accumulated_x is the accumulated translation in X.
    accumulated_y = 0;
    accumulated_x = 0;
    accumulated_skipped = 0;

    %initializes accumulated translations, for 'transrot' motionMethod
    % accumulated is the equivalent of accumulated_x and accumulated_y (it
    %  is a transform matrix of 3x3).
    % accumulated_skipped_hom is the equivalent of accumulated_skipped. it 
    %  is a transform matrix and is used when using motionMethod of
    %  'transrot'.
    accumulated_skipped_hom = eye(3);
    accumulated = eye(3);

    %iterate through images
    for i = 2:length(imageIndices)
        %update the accumulated translations.
        if (strcmp(motionMethod, 'trans'))
            accumulated_skipped = accumulated_skipped + motions(i,1);
            accumulated_x = accumulated_x + motions(i,1);
            accumulated_y = accumulated_y + motions(i,2);
        else
            mat = inv(motions{imageIndices(i)});
            accumulated = accumulated * mat;
            accumulated_skipped_hom = accumulated_skipped_hom * mat;

            % accumulated_x and accumulated_skipped are updated here
            % even tough we use transform matrices, in order to maintain 
            % the same code below for both 'trans' and 'transrot'.
            accumulated_skipped = -accumulated_skipped_hom(1,3);
            accumulated_x = -accumulated(1,3);
        end
        
        %skip images if using mincut and the accumulated translation is too
        % small. If we are on the last image - stitch it anyway.
        if (strcmp(stitchMethod,'mincut') && (i<length(imageIndices)) ...
           && (-accumulated_skipped <= overlapStripWidth / 2))
            continue
        else
            %if we are stitching the image, reset the accumulated_skipped.
            accumulated_skipped_hom = eye(3);            
            accumulated_skipped = 0;
        end

        %if we get here, we need the image, so we read it (RGB)
        img = my_im_read(sprintf(baseImageName, imageIndices(i)), 3);
        
        %stabilize the image using the accumulated translation.
        if (strcmp(motionMethod, 'trans'))
            stabilized = stabilizeRGB_trans(img, accumulated_x, accumulated_y);
        else
            stabilized = stabilizeRGB_rot(img, accumulated);
        end
        
        %Basic Stitching
        if (strcmp(stitchMethod,'basic'))
            %calculate the offset from column to paste the image. the
            % second offset is used to access the stabilized image. either
            % offset2=offset1 or offset2=offset1+1. It is necessary to
            % handle cases when the size does not divide by 2 in a
            % consistent manner.
            offset1 = floor((column+fix(accumulated_x))/2);
            offset2 = ceil((column+fix(accumulated_x))/2);

            %paste the image into the mosaic in the right place
            mosaic(:, column-offset1: ...
                column-offset1+size(stabilized,2)-offset2,:) = ...
                stabilized(:,offset2:end,:);

        %Mincut Stitching
        elseif (strcmp(stitchMethod,'mincut'))
            %calculate the center of image and the corresponding absolute
            % offset in the mosaic. I use the floor value: the strip size 
            % is exactly overlapStripWidth+1 it doesn't have to be 
            % perfectly symmetrical arround the center, as long as the
            % centers of the stitched and the mosaic overlap.
            center_of_image = floor((size(stabilized,2)/2));
            center_of_overlap = (-fix(accumulated_x) + center_of_image );
            
            %check that I don't get out of the overlapping range. This can 
            % happen if the overlapStripWidth is too large or the
            % translation is too large relative to the last stitch.
            if ((center_of_image-overlapStripWidth < 1) || ...
                (center_of_overlap+overlapStripWidth) >= column)
                %break the execution. This is a critical error.
                error 'overlapStripWidth is larger than image or mosaic'
            end
            
            %prepare the subimages for the mincut. sub_left is the mosaic 
            % and sub_right is the image.
            sub_left  = mosaic(:,center_of_overlap - overlapStripWidth: ...
                center_of_overlap + overlapStripWidth,:);
            sub_right = stabilized(:,center_of_image-overlapStripWidth: ...
                center_of_image+overlapStripWidth,:);
            %calculate square difference on color channels
            sub_diff  = (sub_left-sub_right).^2;
            sub_diff = sub_diff(:,:,1) + sub_diff(:,:,2) + sub_diff(:,:,3);
            %prepare the horizontal and vertical edges and nodes
            horizontalEdges = sub_diff(:,1:end-1) + sub_diff(:,2:end);
            verticalEdges = sub_diff(1:end-1,:) + sub_diff(2:end,:);
            sourceNodes = [transpose(1:size(sub_diff,1)) ...
                transpose(ones(1,size(sub_diff,1)))];
            sinkNodes = [transpose(1:size(sub_diff,1)) ...
                size(sub_diff,2)*transpose(ones(1,size(sub_diff,1)))];
            
            %find the min-cut/max-flow segmentation
            segmentation = findMinCut(horizontalEdges, verticalEdges, ...
                int32(sourceNodes), int32(sinkNodes));
            %stitch the images (don't display the seams, I do it manually
            % as explained above.)
            stitched = stitch(sub_left, sub_right, segmentation, 0);
            
            %paste the image into the mosaic (from the center to the end).
            % this is needed because the mincut stitch is only for the
            % overlapping area.
            mosaic(:, center_of_overlap: ...
                center_of_overlap+size(stabilized,2)-center_of_image,:) = ...
                stabilized(:,center_of_image:end,:);

            %paste the mincut stitched sub-image, overwriting part of the
            % pasted image.
            mosaic(:, center_of_overlap-overlapStripWidth: ...
                center_of_overlap+overlapStripWidth,:) = stitched;

            %merge the seams pattern into seams mask
            if (displaySeamsOnImg)
                seam = [segmentation(:,1:end-1)~=segmentation(:,2:end), ...
                    zeros(   size(segmentation,1), 1)] | ...
                       [segmentation(1:end-1,:)~=segmentation(2:end,:); ...
                    zeros(1, size(segmentation,2)   )];
                
                %expand seams matrix. When stitching with 'transrot' size is
                % not pre-allocated, so we need to expand the matrix before 
                % accessing it. When stitching with translation size is 
                % pre-allocated and this line does nothing.
                seams_mask(1,size(mosaic,2)) = 0;
                
                %Add the seam with logical or, not overwriting the other
                % seams.
                seams_mask(:,center_of_overlap-overlapStripWidth: ...
                    center_of_overlap+overlapStripWidth) = ...
                seams_mask(:,center_of_overlap-overlapStripWidth: ...
                    center_of_overlap+overlapStripWidth) | seam;
            end
        end

        %update the column pointer
        column = -fix(accumulated_x) + size(stabilized,2);

        %display process
        if (displayStitchProcess)
            if (displaySeamsOnImg)
                %merge seams only for display
                imshow(merge_seams_mask(mosaic, seams_mask));
            else
                imshow(mosaic);
            end
        end
    end
    
    %merge seams mask into image before returning it, if required
    if (displaySeamsOnImg)
        mosaic = merge_seams_mask(mosaic, seams_mask);
    end
end

function merged = merge_seams_mask(mosaic, seams_mask)
    %merge_seams_mask - a sub-function that merges the seams mask into the
    % mosaic. The seam is marked with the inverted R,G,B values of the
    % color.
    %
    %mosaic - the mosaic
    %seams_mask - a logical seams mask
    %merged - the resulting seams+mosaic
    seams_mask_rgb = repmat(seams_mask(:,1:size(mosaic,2)), [1 1 3]);
    mosaic(seams_mask_rgb) = 1-mosaic(seams_mask_rgb);
    merged = mosaic;
end