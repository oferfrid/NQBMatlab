function color =getPlotColors(NumberOfColors,ind)
%function color =getPlotColors(NumberOfColors,ind)


%r= (ind-1)/NumberOfColors;
       %g=abs((ind-1)/NumberOfColors*2 -1);
       %b=1 - (ind-1)/NumberOfColors;
       %color = [ r g b];
       
       
       y=jet;
       colorind = round((ind-1)/(NumberOfColors-1)*63 +1);
       color = y(colorind,:);
end