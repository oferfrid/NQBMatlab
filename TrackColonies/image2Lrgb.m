function Lrgb = image2Lrgb(Image,Background,Limits,TH,RelevantArea)
    L=im2L(Image,Background,Limits,TH,RelevantArea);
    L=bwlabel(L);
    Lrgb = label2rgb(L,'jet', 'k', 'shuffle');
    Lrgb=im2double(Lrgb);
end

