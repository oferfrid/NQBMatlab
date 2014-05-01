function showAlHist(DirName)
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
    q=1;
    %% Calculate limits
    limHigh=[];
    limLow=[];
    for k=1:NumOfFiles
        FullFileName = fullfile(picDir, char(FileVec(k)));
        I = imread(FullFileName);
        
        % clean image
        clnImg = cleanImgNew(I,bg);
        clnImg=im2double(clnImg);
        clnImg=clnImg.*relevantArea;
        
        
        % stretch image
        limits=stretchlim(clnImg);
        limHigh=[limHigh limits(2)];
        limLow=[limLow limits(1)];
    end
    
    limits=[0; max(limHigh(2:end))]
    
    for k=1:NumOfFiles
        FullFileName = fullfile(picDir, char(FileVec(k)));
        I = imread(FullFileName);
        
        % clean image
        clnImg = cleanImgNew(I,bg);
        clnImg=im2double(clnImg);
        clnImg=clnImg.*relevantArea;
        
        % stretch image
        clnImg=imadjust(clnImg, limits,[]);
        hist(clnImg(:),0:0.01:1);
        hold on;
    end
        hold off;
end

