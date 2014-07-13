function Out = Images2Colonies(SourceDir,lastPicFlag,TH)
    if nargin<2
        lastPicFlag=false;
    end
    
    if nargin<3
       TH=0.2;
    end
    
    %DefCirc % to do
    
    DATA_FILE_NAME='data.mat';
    
    % Load data file
    data=load(fullfile(SourceDir,DATA_FILE_NAME));
    FilesProp=data.FilesProp;
    
    % Load background
    firstImageName=FilesProp{1,1};
    firstImageStr=fullfile(SourceDir,firstImageName);
    background=imread(firstImageStr);    
    
    % Load relevant area's mask todo: is that needed?
    numberOfImages=length(FilesProp);
    [rows, cols, ~]=size(background);
    
    if lastPicFlag
        relevantArea=ones(rows,cols);
        Images2Process = [1 numberOfImages];
    else
        
        relevantArea=GetMask(data,rows,cols);
        Images2Process = 1:numberOfImages;
    end
    
    % Determine stretching limits using last image
    lastImageName=FilesProp{numberOfImages,1};
    lastImageStr=fullfile(SourceDir,lastImageName);
    lastImage=imread(lastImageStr);
    clnLastImg=cleanImage(lastImage,background);
  
    limits=stretchlim(clnLastImg(relevantArea>0));
    
    % initialize a progress bar
    progress_bar = waitbar(0);
    % Process each picture in the data file
    Min_Area       = 10;        % minimal area for thr colony to be added
    coloniesFirstCM = [];
    for k=Images2Process
        msg = sprintf('Processing picture %d/%d', k,numberOfImages);
        waitbar(k/numberOfImages, progress_bar, msg);
        
        % Load current image
        currImageName=data.FilesProp{k,1};
        currImageStr=fullfile(SourceDir,currImageName);
        currImage=imread(currImageStr);
        clnImg=cleanImage(currImage,background);
        
        % Process the image to bw colonies map
        clnImg=im2double(clnImg);
        clnImg=imadjust(clnImg,limits,[]);
        clnImgBW = im2bw(clnImg,TH);
        clnImgBW = medfilt2(clnImgBW);
        clnImgBW = relevantArea.*im2double(clnImgBW);
       
        
        % find colonies according to previous image
        curentL = bwlabel(clnImgBW);
        curentStat  = regionprops(curentL, 'basic');    %'basic' is Area, Centroid, BoundingBox
        IsNewColony = true(length(curentStat),1);
        % Match all old coloneis in the new frame
        for i=1:length(coloniesFirstCM)
            curentStatID = curentL(coloniesFirstCM(i).Y,coloniesFirstCM(i).X);
            if curentStatID~=0 %old colonie
                IsNewColony(curentStatID) = false;
                Area(i,k)=curentStat(curentStatID).Area;
                BBox(i,k,:) = curentStat(curentStatID).BoundingBox;
                Centroid(i,k,:) = curentStat(curentStatID).Centroid;
            end
        end
        %add new coloneis
        sufficientArea = false(length(curentStat),1);
        sufficientArea( [curentStat.Area]>=Min_Area,1) =true;
        NewColoniesStat = curentStat(IsNewColony&sufficientArea);
        
        for i=1:length(NewColoniesStat)
            NewColonyIndex = length(coloniesFirstCM)+1;
            Area(NewColonyIndex,k)=NewColoniesStat(i).Area;
            BBox(NewColonyIndex,k,:) = NewColoniesStat(i).BoundingBox;
            Centroid(NewColonyIndex,k,:) = NewColoniesStat(i).Centroid;
            coloniesFirstCM(NewColonyIndex).X=round(NewColoniesStat(i).Centroid(1));
            coloniesFirstCM(NewColonyIndex).Y=round(NewColoniesStat(i).Centroid(2));
        end
    end
    close(progress_bar);

      if lastPicFlag
        Out = curentL;
      else
        % Calculate the close to border colonies
        ColoniesStatus=ones(numberOfImages);
        relevantColonies = FindColoniesInWorkingArea(relevantArea,Centroid);
        ColoniesStatus=~relevantColonies;
    
        save(fullfile(SourceDir,DATA_FILE_NAME),...
                       'Area','BBox','Centroid','ColoniesStatus''-append');

      end
end

function [clnImg] = cleanImage(Image,BG)
    clnImg=rgb2gray(imsubtract(Image,BG));
end

