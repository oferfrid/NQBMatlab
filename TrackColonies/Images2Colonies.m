function Images2Colonies(SourceDir,lastPicFlag,TH)
    if nargin<2
        lastPicFlag=0;
    end
    
    if nargin<3
       TH=0.2;
    end
    
    DefCirc % to do
    
    DATA_FILE_NAME='data.mat'
    
    % Load data file
    data=imload(fullfile(SourceDir,DATA_FILE_NAME));
    data=data.data;
    
    % Load background
    firstImageName=data{1,1};
    firstImageStr=fullfile(SourceDir,firstImageName);
    background=imread(firstImageStr);    
    
    % Determine stretching limits using last image
    dataLength=length(data);
    lastImageName=data{dataLength,1};
    lastImageStr=fullfile(SourceDir,lastImageName);
    lastImage=imread(lastImageStr);
    clnLastImg=cleanImage(lastImage,background);
    
    limits=stretchlim(clnLastImg);
    
    % Load relevant area's mask
    [rows cols]=size(background);
    if lastPicFlag
        relevantArea=ones(rows,cols);
    else
        relevantArea=GetMask(SourceDir,rows,cols,DefCirc);
    end
    
    % Process each picture in the data file
    for k=1:dataLength
        msg = sprintf('Processing picture %d/%d', k,dataLength);
        waitbar(k/dataLength, progress_bar, msg);
        
        % Load current image
        currImageName=data{k,1};
        currImageStr=fullfile(SourceDir,currImageName;
        currImage=imread(currImageStr);
        clnImg=cleanImage(currImage,background)
        
        % Process the image to bw colonies map
        clnImg=im2double(clnImg);
        clnImg=imadjust(clnImg,limits,[]);
        clnImgBW = im2bw(clnImg,TH);
        clnImgBW = medfilt2(clnImgBW);
        clnImgBW = relevantArea.*im2double(clnImgBW);
        L = bwlabel(clnImgBW);
        
        % find colonies according to previous image
    end
    
    % Save result files
end

function [clnImg] = cleanImage(Image,BG)
    clnImg=rgb2gray(imsubstruct(Image,BG));
end

