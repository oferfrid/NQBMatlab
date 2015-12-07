function Out = Images2Colonies(SourceDir,lastPicFlag,TH)
% Out = Images2Colonies(SourceDir,lastPicFlag,TH)
% This method takes a series of plate's images in time and 
% identify , track and calculates the colonies growth 
% information using image analysis. The information is being
% stored in the data file.
%
% arguments:
%       SourceDir - The paltes images information.
%       lastPicFlag - (default 0) 0 - process all images,
%                                 1 - process last image only
%       TH - colonies treshold
% returns:
%       Out - last bw image
% Nir Dick (and Ofer Fridman) 2015
    if nargin<2
        lastPicFlag=false;
    end
    
    if nargin<3
       TH=GetDefaultTH;
    end
    
    DATA_FILE_NAME=GetDataName(SourceDir);
    
    % Load data file
    data=load(DATA_FILE_NAME);
    
    
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
        
        % Mark colonies with zero area at the end as not relevant
        zeroAreaColonies=(Area(end,:)==0);
        IgnoredColonies(zeroAreaColonies)=GetDefaultNoColonyCode;
        
        save(DATA_FILE_NAME,'Area','BBox','Centroid','IgnoredColonies',...
                            'TH','Limits','-append');

      end
end

function [clnImg] = cleanImage(Image,BG)
    clnImg=rgb2gray(imsubtract(Image,BG));
end

