function AlignandCut(SourceName,DestDirNames,Plates2Cut,CropInf)

    alignmentArea=[870 800 900 800];

    %% Prepare destination doorectories
    DATA_FILE_NAME='data.mat';
    MOTIONS_FILE_SUFFIX='_motions.mat';
    
    numOfDests=length(DestDirNames);
    dataFiles=cell(1,numOfDests);
    destsImgNum=zeros(numOfDests);
    for k=1:numOfDests
        % Create the destination directories if needed
        currDestDir=DestDirNames(k);
        [successMK,mgsMK,msgidMK] = mkdir(currDestDir);
        if ~successMK
            error(msgidMK, mgsMK);
        end
        
        % Load the data file if exists and keep how many images are there
        dataFileStr=fullfile(currDestDir,DATA_FILE_NAME);
        dataFlag=dir(dataFileStr);
        if ~isempty(dataFlag)
            currData=load(dataFileStr);
            dataFiles{1,k}=currData.data;
            destsImgNum=size(currData,1);
        end
    end
    
    %% Get the source data
    % Load source images
    SourceImages=dir(SourceName);
    [dummy idx]=sort({SourceImages.date});
    SrtdSrcImages=SourceImages(idx);
    SrcImgNames={SrtdSrcImages.name};
    
    % Load motions data
    all_u=0;
    all_v=0;
    motionNames={};
    motionSize=0;
    
    FirstImgName=SrcImgNames(1);
    motionFileName=[FirstImgName MOTIONS_FILE_SUFFIX];
    motionsFileStr=fullfile(currDestDir,motionFileName);
    motionsFlag=dir(motionsFileStr);
    
    if ~isEmpty(motionsFlag)
       motionsTmp=load(motionsFileStr);
       motions=motionsTmp.motions;
       all_u=cell2mat(motions(:,2));
       all_v=cell2mat(motions(:,3));
       motionNames=motions(:,1);
       motionSize=size(all_u,1);
    end
    
    %% Align and cut images
    
    % Get the starting point (this is the minimum of images number in 
    % the destination folders
    startingIdx=min(destsImgNum);
    if startingIdx==0
        startingIdx=1;     
    end
    
    % Loading first image
    disp([datestr(now)   '   Align and Cut']);
    
    %initialize a progress bar
    progress_bar = waitbar(0);
    progress = 0;
    
    % Align and cut from base to the end
    startNext=startingIdx+1;
    SrcImgNum=length(SrcImgNames);
    numOfImages=SrcImgNum-startNext;
    if (motionSize<SrcImgNum)
        diff=SrcImgNum-motionSize;
        all_u=padarray(all_u,diff,'post');
        all_v=padarray(all_v,diff,'post');
    end
    
    % Load base image
    imgCurr=imread(fullfile(srcDirName,SrcImgNames{startingIdx}));
    imgCurrD = im2double(imgCurr);
    imgCurrGray = rgb2gray(imgCurrD(:,:,1:3));
    BaseCropped = imcrop(imgCurrGray, alignmentArea);
    alignedImg=imgCurr;
    cum_u=sum(all_u(1:startingIdx));
    cum_v=sum(all_v(1:startingIdx));
    
    for i=startNext:SrcImgNum
        % Base crop
        CropImage()
        
        progress = progress + 1;
        waitbar(progress/NumOfFiles, progress_bar, ...
        sprintf('Calculating Motion: image %d/%d', i,numOfImages));

        imgNext=imread(fullfile(srcDirName,SrcImgNames{i}));
        imgNextD = im2double(imgNext);
        imgNextGray = rgb2gray(imgNextD(:,:,1:3));
        NextCropped = imcrop(imgNextGray, alignmentArea);
        
        % Check if we need to calculate motion to
        % next (actually current i) image 
        if i<=motionSize
            % Check that both base and next images names appear in the
            % motion file in the right place
            if ~(strcmp(SrcImgNames{i-1},motionNames{i-1}))
                error('Prepare:AlignandCut',...
                      ['Base names : ' SrcImgNames{i-1} ' ' motionNames{i-1}]);
            end
            
            if ~(strcmp(SrcImgNames{i},motionNames{i}))
                error('Prepare:AlignandCut',...
                      ['Next names : ' SrcImgNames{i} ' ' motionNames{i}]);
            end
            
            % get next motion
            u=all_u(i);
            v=all_v(i);
        else
            % align current next
            [u v] = fullPyrMotion_trans(BaseCropped, NextCropped);
            all_u(i)=u;
            all_v(i)=v;
        end
        
        cum_u=cum_u+u;
        cum_v=cum_v+v;
        
        BaseCropped = NextCropped;
        imgCurr=imgNext;
            
       % align image
       alignedImg=imdilate(imgCurr,translate(strel(1),...
                           [-round(cum_v) -round(cum_u)]));    
    end
    
    %% Save relevant data
        
end

