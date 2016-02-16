function color =getPlotColors(NumberOfColors,ind, colorpmap_)
%function color =getPlotColors(NumberOfColors,ind)

y=jet;
if nargin==3
    y=colormap(colorpmap_);
end

%r= (ind-1)/NumberOfColors;
       %g=abs((ind-1)/NumberOfColors*2 -1);
       %b=1 - (ind-1)/NumberOfColors;
       %color = [ r g b];

%        colorind = round((ind-1)/(NumberOfColors-1)*63 +1);
       colorind = round((ind-1)/(NumberOfColors-1)*(size(y,1)-1) +1);
       color = y(colorind,:);
end