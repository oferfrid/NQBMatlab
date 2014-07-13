function PlotPlate(DirName,FilesName,TimeGap,Times,BW,...
                   forMovie,limits,handle,background,description)
if nargin < 5
    BW=1;
end  
               
if nargin < 6
    forMovie=false;
end               
               
if nargin < 7
    limits=[];
end
               
if nargin < 8
    handle=gca;
end

if nargin < 9
   % Load current background
   bgName=FilesName{1};
   background=imread(fullfile(DirName,bgName));
end

if nargin < 10
   description='';
end
               
%% Find the wanted image
FileNum  = find(Times <= TimeGap, 1, 'last');

%% Reading the picture, and the data files
currImageName = FilesName{FileNum};
currImage=imread(fullfile(DirName,currImageName));
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
FigTitle = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   description, TimeGap, length(FilesName));
title(handle,FigTitle);
