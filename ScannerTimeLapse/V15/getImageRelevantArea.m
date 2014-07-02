%% function getImageRelevantArea(DirName,I,isBW)
% -------------------------------------------------------------------------
% Purpose: Return the image with black outside the relevant area.
%
% Arguments: DirName - The base directory
%            isBW - 1 if image is grayscale and 0 if not
%            I - the image
% Return: The image with black outside the relevant area
% -------------------------------------------------------------------------
% Nir Dick 4.2014
% -------------------------------------------------------------------------
function [ imgRelevant areaMask] = getImageRelevantArea(DirName,I,isBW)
    if isBW
        [rows cols] = size(I);
        areaMask=getRelevantAreaMask(DirName,rows,cols);
        imgRelevant=I.*areaMask;
    else
        [rows cols tmp] = size(I);
        areaMask=getRelevantAreaMask(DirName,rows,cols);
        imgRelevant=I.*cat(3,areaMask,areaMask,areaMask);
    end
end

