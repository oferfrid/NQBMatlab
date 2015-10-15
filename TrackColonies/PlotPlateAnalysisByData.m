function himage = PlotPlateAnalysisByData(...
                                    DirName,FileName,handle,Limits,TH,...
                                    Background,Mask,Lrgb,Title,forMovie)
%himage = PlotPlateAnalysisByData(DirName,FileName,handle,Limits,TH,...
%                                 Background,Mask,Lrgb,Title,forMovie)
% Plot the plate image of current time by data sent as arguments.
% arguments:
% DirName - Name of directory
% FileName - Name of the image to analyse and plot
% handle - the handle to plot in
% Limits - stretching limits (by it we proccessed the images)
% TH - treshold for the grayscale to bw image
% Background - the first image
% Mask - binary image of the area
% Lrgb - last Limage with color data
% Title - title
% forMovie - yes/no
% Nir Dick 2015

   if nargin<10
       forMovie=false;
   end
   
   %% Create current image's analysis
   % Load image,
   currImage=imread(fullfile(DirName,FileName));
   
   % Convert image to label file
   currBW=im2L(currImage,Background,Limits,TH,Mask);
   currBW = double(currBW~=0);
   currBW=cat(3,currBW,currBW,currBW);
   currRGB=Lrgb.*currBW;
   
    %% resize for movie
    if forMovie
        currRGB= imresize(currRGB, 0.5);
        Mask=imresize(Mask,0.5);
    end
    
    %% Show image
    hold on;
    
    edgeB=edge(Mask,'canny');
    currRGB(edgeB~=0)=255;
    himage = imshow(currRGB,'InitialMagnification','fit','Parent',handle);
    set(himage,'Tag','ImageColony');
    set(himage, 'AlphaData', 0.5);  
    
    %% Title
    title(handle,Title);
end

