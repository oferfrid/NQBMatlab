function h = LrgbShow(Lrgb, clnImg, x, y, r, NColonies)
% LrgbShow(Lrgb, clnImg, x, y, r, NColonies)
% -----------------------------------------------------------------------
% Purpose: displaying the plate with the different components in different
%       colours.
% 
% Description: the function displays the image and over it the labeled
%       components. it also draws the circle of search.
%
% Arguments: Lrgb - the labeled picture
%       clnImg - the image
%       x,y,r - the centre and the radius of the search
%       NColonies - number of colonies (for the title)
%
% Returns: h - a handle to the figure
% -----------------------------------------------------------------------
% Irit Levin. September 2006.

% h = figure; 
h = gcf;
imshow(clnImg,[],'InitialMagnification','fit'), hold on;
himage = imshow(Lrgb,'InitialMagnification','fit');
set(himage, 'AlphaData', 0.5);
circle([x,y],r ,500,'r-');
CircArea = pi*r^2;
ftitle = [num2str(NColonies), ' colonies found, on an area of ', ...
         num2str(CircArea)];
title(ftitle);
