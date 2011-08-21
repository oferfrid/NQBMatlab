function [Areas,BBoxs,centroids] = ColoniesProperties(L)
%% [Areas,BBoxs,centroids] = ColoniesProperties(L)
% -------------------------------------------------------------------
% Purpose: finds the colonies in a scaned Petree plate.
%
% Description: The function gets a clean image. It turns it into a
%          binary image. bwlabel marks the different colonies from
%          a birnary image, using 'connected components' method.
%          The function returns the properties of the components found.
%
% Arguments: L - a 2D matrix, the size of the picture, with the labeled
%            components.
% 
% Returns: Areas - a vector with the number of pixels of each component.
%          BBoxs - a 2D matrix of the bounding box of each component.
%          centroids - a 2D matrix of the coordinated of the c.m. of each
%             component.
%          
% -------------------------------------------------------------------
% Irit Levin, 20.8.2006
% updated
% Irit Levin, 01.2008 - loading the L from a file


%% colonies (regions) properties
stat  = regionprops(L, 'basic');    %'basic' is Area, Centroid, BoundingBox

if ~isempty(stat)
    Areas = [stat.Area]';
    BBoxs = cat(1, stat.BoundingBox);
    centroids = cat(1, stat.Centroid);
else
    Areas = 0;
    BBoxs = [0 0 0 0];
    centroids = [0 0];
end