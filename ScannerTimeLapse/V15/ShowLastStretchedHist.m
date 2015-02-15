function ShowLastStretchedHist(DirName)
    %% Prepeare data to calc histograms
    % getting the list of the files
    picDir    = fullfile(DirName, 'Pictures');
    dirOutput = dir(fullfile(picDir,'*.tif'));
    FileVec   = {dirOutput.name}'; 
    
    NumOfFiles = size(FileVec,1);
    
    % Get background
    FullFileName = fullfile(picDir, char(FileVec(1)));
    bg = imread(FullFileName);
        
    % getting relevant area mask
    [rows,cols,tmp]=size(bg);
    relevantArea=getRelevantAreaMask(DirName,rows,cols);
    
    %% Calculate limits of last image
    FullFileName = fullfile(picDir, char(FileVec(NumOfFiles)));
    I = imread(FullFileName);

    % clean image
    clnImg = cleanImgNew(I,bg);
    clnImg=im2double(clnImg);

    % stretch image
    limits=stretchlim(clnImg(relevantArea>0));
    
    % Please leave the or loop as it is, sometimes I want to see 
    % the histogram of all the images.
    for k=NumOfFiles:NumOfFiles
        FullFileName = fullfile(picDir, char(FileVec(k)));
        I = imread(FullFileName);
        
        % clean image
        clnImg = cleanImgNew(I,bg);
        clnImg=im2double(clnImg);
        
        % stretch image
        clnImg=imadjust(clnImg, limits,[]);
        hist(clnImg(:),0:0.01:1);
        hold on;
    end
    hold off;
end

