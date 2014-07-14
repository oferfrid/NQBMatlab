function himage = PlotPlateAnalysis(DirName,FileName,handle,Limits,TH,...
                                    Background,Mask,Lrgb,Title,forMovie)
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

