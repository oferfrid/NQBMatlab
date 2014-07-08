function CropROI(SourceName,DestDirNames,BoardHint,Plates2Cut)
    %% Prepare destination doorectories
    DATA_FILE_NAME='data.mat';
    MOTIONS_FILE_SUFFIX='_motions.mat';
    
    numOfDests=length(DestDirNames);
    destsImgNum=zeros(1,numOfDests);
    for k=1:numOfDests
        % Create the destination directories if needed
        currDestDir=DestDirNames{1,k};
        [successMK,mgsMK,msgidMK] = mkdir(currDestDir);
        if ~successMK
            error(msgidMK, mgsMK);
        end
        
        % Load the data file if exists and keep how many images are there
        dataFileStr=fullfile(currDestDir,DATA_FILE_NAME);
        dataFlag=dir(dataFileStr);
        if ~isempty(dataFlag)
            currData=load(dataFileStr);
            currData=currData.data;
            destsImgNum(k)=size(currData,1);
        end
    end
    
    %% Get the source data
    
    flag= strfind(SourceName,'.');
    SourceDir=SourceName;
    if ~isempty(flag)
        [SourceDir, ~ ,~]=fileparts(SourceName);
    end;
    
    % Load source images
    SourceImages=dir(SourceName);
    [~ ,idx]=sort({SourceImages.date});
    SrtdSrcImages=SourceImages(idx);
    SrcImgNames={SrtdSrcImages.name};
    
    % Load motions data
    FirstImgName=SrcImgNames{1};
    [~, fname, ~]=fileparts(FirstImgName); 
    motionFileName=[fname MOTIONS_FILE_SUFFIX];
    motionsFileStr=fullfile(SourceDir,motionFileName);
    motionsFlag=dir(motionsFileStr);
    
    motionSize=0;
    
    if length(motionsFlag)>0
       motionsTmp=load(motionsFileStr);
       motions=motionsTmp.motions;
       all_u=cell2mat(motions(:,2));
       all_v=cell2mat(motions(:,3));
       motionNames=motions(:,1);
       motionSize=size(all_u,1);
    end
    
    %% Calc ROI Boarders
    % load first image
    firstImageStr=fullfile(SourceDir,SrcImgNames{1});
    inputImage=imread(firstImageStr);
    inputImage=inputImage(:,:,1:3);
    
    ImageSize = [size(inputImage,2) size(inputImage,1)];% in px
    
    load(BoardHint,'BoardHint');    
    alignmentArea=[BoardHint.AlignmentArea(1)*ImageSize(1) BoardHint.AlignmentArea(2)*ImageSize(2) BoardHint.AlignmentArea(3)*ImageSize(1) BoardHint.AlignmentArea(4)*ImageSize(2)]; 
    rects = FindPlates(inputImage,BoardHint);
    
    %% Align and cut images
    
    % Get the starting point (this is the minimum of images number in 
    % all destination folders
    startingIdx=min(destsImgNum);
    if startingIdx==0
        startingIdx=1;     
    end
    
    startNext=startingIdx+1;
    SrcImgNum=length(SrcImgNames);
    numOfImages=SrcImgNum-startingIdx+1;
    
    % Check for difference between source and motion
    if motionSize>0      
        motionSource=SrcImgNames(1:motionSize);
        if ~isequal(motionSource,motionNames)
            diff=setdif(motionNames,motionSource);
            msg=['Difference between motions file and source images: ' ...
                diff];
            error('Prepare:CropROI', 
                    'It seems that a new image that');
        end
    end
    
    % Loading first image
    disp([datestr(now)   '   Align and Cut']);

    %initialize a progress bar
    progress_bar = waitbar(0);
    progress = startNext;
        
    if (numOfImages>1)
        final_u=zeros(SrcImgNum,1);
        final_v=zeros(SrcImgNum,1);
        final_data_names=cell(SrcImgNum,numOfDests);

        if (motionSize>0)
            final_u(2:startingIdx)=all_u(2:startingIdx);
            final_v(2:startingIdx)=all_v(2:startingIdx);
        end

        cum_u=sum(final_u(1:startingIdx));
        cum_v=sum(final_v(1:startingIdx));

         % Align and cut from base to the end
        imgCurr=imread(fullfile(SourceDir,SrcImgNames{startingIdx}));
        imgCurr=imgCurr(:,:,1:3);
        imgCurrD = im2double(imgCurr);
        imgCurrGray = rgb2gray(imgCurrD(:,:,1:3));
        BaseCropped = imcrop(imgCurrGray, alignmentArea);
        alignedImg=imgCurr;

        for i=startNext:SrcImgNum
            % Base crop
            [destNames]=saveROI(alignedImg,DestDirNames,SrcImgNames{i-1},...
                                Plates2Cut,startingIdx,destsImgNum,rects);
            final_data_names(i-1,:)= destNames;

            progress = progress + 1;
            waitbar(progress/numOfImages, progress_bar, ...
            sprintf('Calculating Motion: image %d/%d', i,numOfImages));

            imgNext=imread(fullfile(SourceDir,SrcImgNames{i}));
            imgNext=imgNext(:,:,1:3);
            imgNextD = im2double(imgNext);
            imgNextGray = rgb2gray(imgNextD(:,:,1:3));
            NextCropped = imcrop(imgNextGray, alignmentArea);

            % Check if we need to calculate motion to
            % next (actually current i) image 
            if i<=motionSize
                % get next motion
                u=all_u(i);
                v=all_v(i);
            else
                % align current next
                [u v] = fullPyrMotion_trans(BaseCropped, NextCropped);
                final_u(i)=u;
                final_v(i)=v;
            end

            cum_u=cum_u+u;
            cum_v=cum_v+v;

            BaseCropped = NextCropped;
            imgCurr=imgNext;

           % align image
           alignedImg=imdilate(imgCurr,translate(strel(1),...
                               [-round(cum_v) -round(cum_u)]));    
        end

        % Handle last image
        [destNames]=saveROI(alignedImg,DestDirNames,SrcImgNames{i},...
                            Plates2Cut,startingIdx,destsImgNum,rects);
        final_data_names(i,:)= destNames;

        %% Save relevant data

        % Save motion file
        motions = cell(length(SrcImgNames),3);
        motions(:,1)=SrcImgNames;
        motions(:,2)=num2cell(final_u);
        motions(:,3)=num2cell(final_v);
        save(motionsFileStr,'motions');

        % Save data file in each destination
        for i=1:numOfDests
            data(:,1)=final_data_names(:,i);
            data(:,2)={SrtdSrcImages.datenum};
            dataFileStr=fullfile(DestDirNames{i},DATA_FILE_NAME);
            save(dataFileStr,'data');
        end
    end
    
    close(progress_bar)
end

