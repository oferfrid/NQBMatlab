function PlotPlate(DirName,FileName,BW,Title,forMovie,limits,handle,...
                  background)

if nargin < 3
    BW=1;
end 

if nargin < 4
    Title='';
end  
               
if nargin < 5
    forMovie=false;
end               
               
if nargin < 6
    limits=[0 1];
end
               
if nargin < 7
    handle=gca;
end

            
%% Reading the picture, and the data files
currImage=imread(fullfile(DirName,FileName));
if (BW)
    clnImg=CleanImage(currImage,background);
else
    clnImg=currImage;
end

%% showing the plate

% resize for movie
if forMovie
    clnImg = imresize(clnImg, 0.5);
end

if ~isempty(limits)
    clnImg = imadjust(clnImg, limits,[]);
end

% Nir - handle added and Tag and axis image
himage=imshow(clnImg,[],'Parent',handle);
set(himage,'Tag','ImageColony');
set(himage, 'AlphaData', 0.5);

%% Title
title(handle,Title);
