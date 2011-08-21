function [x,y,r]=getPlateCentre(DirName)
circParams = load(fullfile(DirName,'Results','CircParams.mat'));
x = circParams.x;
y = circParams.y;
r = circParams.r;