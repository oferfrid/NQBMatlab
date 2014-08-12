function Out = Images2Colonies(SourceDir,lastPicFlag,TH)
    if nargin<2
        lastPicFlag=false;
    end
    
    if nargin<3
       TH=GetDefaultTH;
    end
    
    %DefCirc % to do
    
    DATA_FILE_NAME=GetDefaultDataName;
    
    % Load data file
    data=load(fullfile(SourceDir,DATA_FILE_NAME));
    
    
    % Load background
    firstImageName=data.FilesName{1};
    firstImageStr=fullfile(SourceDir,firstImageName);
    background=imread(firstImageStr);    
    
    % Load relevant area's mask todo: is that needed?
    numberOfImages=length(data.FilesName);
    [rows, cols, ~]=size(background);
    
    if lastPicFlag
        relevantArea=ones(rows,cols);
        Images2Process = [1 numberOfImages];
    else
        
        relevantArea=GetMask(data,rows,cols);
        Images2Process = 1:numberOfImages;
    end
    
    % Determine stretching limits using last image
    lastImageName=data.FilesName{end};
    lastImageStr=fullfile(SourceDir,lastImageName);
    lastImage=imread(lastImageStr);
    clnLastImg=cleanImage(lastImage,background);
  
    Limits=stretchlim(clnLastImg(relevantArea>0));
    
    % initialize a progress bar
    progress_bar = waitbar(0);
    % Process each picture in the data file
    Min_Area       = 10;        % minimal area for thr colony to be added
    coloniesFirstCM = [];
    for k=Images2Process
        msg = sprintf('Processing picture %d/%d', k,numberOfImages);
        waitbar(k/numberOfImages, progress_bar, msg);
        
        % Load current image
        currImageName=data.FilesName{k};
        currImageStr=fullfile(SourceDir,currImageName);
        currImage=imread(currImageStr);

        % find colonies according to previous image
        clnImgBW=im2L(currImage,background,Limits,TH,relevantArea);
        curentL = bwlabel(clnImgBW);
        curentStat  = regionprops(curentL, 'basic');    %'basic' is Area, Centroid, BoundingBox
        IsNewColony = true(length(curentStat),1);
        % Match all old coloneis in the new frame
        for i=1:length(coloniesFirstCM)
            curentStatID = curentL(coloniesFirstCM(i).Y,coloniesFirstCM(i).X);
            if curentStatID~=0 %old colonie
                IsNewColony(curentStatID) = false;
                Area(k,i)=curentStat(curentStatID).Area;
                BBox(k,i,:) = curentStat(curentStatID).BoundingBox;
                Centroid(k,i,:) = curentStat(curentStatID).Centroid;
            end
        end
        %add new coloneis
        sufficientArea = false(length(curentStat),1);
        sufficientArea( [curentStat.Area]>=Min_Area,1) =true;
        NewColoniesStat = curentStat(IsNewColony&sufficientArea);
        
        for i=1:length(NewColoniesStat)
            NewColonyIndex = length(coloniesFirstCM)+1;
            Area(k,NewColonyIndex)=NewColoniesStat(i).Area;
            BBox(k,NewColonyIndex,:) = NewColoniesStat(i).BoundingBox;
            Centroid(k,NewColonyIndex,:) = NewColoniesStat(i).Centroid;
            coloniesFirstCM(NewColonyIndex).X=round(NewColoniesStat(i).Centroid(1));
            coloniesFirstCM(NewColonyIndex).Y=round(NewColoniesStat(i).Centroid(2));
        end
    end
    close(progress_bar);

      if lastPicFlag
        Out = curentL;
      else
        % Calculate the close to border colonies
        relevantColonies = FindColoniesInWorkingArea(relevantArea,coloniesFirstCM);
        IgnoredColonies =double(~relevantColonies);
    
        save(fullfile(SourceDir,DATA_FILE_NAME),...
                       'Area','BBox','Centroid','IgnoredColonies','TH',...
                       'Limits','-append');

      end
end

function [clnImg] = cleanImage(Image,BG)
    clnImg=rgb2gray(imsubtract(Image,BG));
end

