function CropROI(SourceName,DestDirNames,BoardFileName,Plates2Cut,updateFlag)
    %CropROI(SourceName,DestDirNames,BoardFileName,Plates2Cut)
    
    if nargin<5
        updateFlag=ones(1,length(Plates2Cut));
    end
    
    %% Prepare destination doorectories
    DATA_FILE_NAME='data.mat';
    MOTIONS_FILE_SUFFIX='_motions.mat';
    
    numOfDests=length(DestDirNames);
    destsImgNum=zeros(1,numOfDests);
    currData=cell(1,numOfDests);
    for k=1:numOfDests
        % Create the destination directories if needed
        currDestDir=DestDirNames{k};
        [successMK,mgsMK,msgidMK] = mkdir(currDestDir);
        if ~successMK
            error(msgidMK, mgsMK);
        end
        
        % Load the data file if exists and keep how many images are there
        dataFileStr=fullfile(currDestDir,DATA_FILE_NAME);
        dataFlag=dir(dataFileStr);
        if ~isempty(dataFlag)
            currNames=load(dataFileStr,'FilesName');
            currData{k}=currNames.FilesName;
            destsImgNum(k)=length(currNames.FilesName);
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
    [~ ,idx]=sort([SourceImages.datenum]);
    SrtdSrcImages=SourceImages(idx);
    SrcImgNames={SrtdSrcImages.name};
    
    % Load motions data
    FirstImgName=SrcImgNames{1};
    [~, fname, ~]=fileparts(FirstImgName); 
    motionFileName=[fname MOTIONS_FILE_SUFFIX];
    motionsFileStr=fullfile(SourceDir,motionFileName);
    motionsFlag=dir(motionsFileStr);
    
    if isempty(motionsFlag)
        otherMotionFileName=['*' MOTIONS_FILE_SUFFIX];
        otherMotionsFileStr=fullfile(SourceDir,otherMotionFileName);
        otherMotionsFlag=dir(otherMotionsFileStr);
        if ~isempty(otherMotionsFlag)
            disp 'Warning! there exists a motions file which is not relevant to the first image:';
            disp(['first image name is: ' FirstImgName ', existed motion file is: ' otherMotionsFlag.name ]);
        end
    end
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
    
    load(BoardFileName,'BoardHint');    
    alignmentArea=[BoardHint.AlignmentArea(1)*ImageSize(1) BoardHint.AlignmentArea(2)*ImageSize(2) BoardHint.AlignmentArea(3)*ImageSize(1) BoardHint.AlignmentArea(4)*ImageSize(2)]; 
    [rects,PlatePos] = FindPlates(inputImage,BoardHint);

    %% Align and cut images
    
    % Get the starting point (this is the minimum of images number in 
    % all destination folders
    startingIdx=min(destsImgNum);
    
    SrcImgNum=length(SrcImgNames);
    numOfImages=SrcImgNum-startingIdx;
    
    if startingIdx==0
        startingIdx=1;     
    end
    
    startNext=startingIdx+1;
    
    % Check for difference between source and motion
    valid=1;
    
    imagesNum=size(SrcImgNames,2);
    if motionSize>imagesNum
         diff=setdiff(motionNames,SrcImgNames);
         disp 'Less images then calculated motions. Problem might be in:';
         disp(diff);
         valid=0;
    end
    
    if motionSize>0 && valid      
        motionSource=SrcImgNames(1:motionSize)';
        if ~isequal(motionSource,motionNames)
            diff1=setdiff(motionSource,motionNames);
            diff2=setdiff(motionNames,motionSource);
            disp 'Broken hierarchy in images according to motions. problem might be in ';
            disp(diff1);
            disp(diff2);
            valid=0;
        end
    end
    
    if valid
        % Loading first image
        disp([datestr(now)   '   Align and Cut']);

        %initialize a progress bar
        progress_bar = waitbar(0);
        progress = startNext;

        if (numOfImages>=1)
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
            imgCurrGray = rgb2gray(imgCurr(:,:,1:3));
             imgCurrGray = im2double(imgCurrGray);
            BaseCropped = imcrop(imgCurrGray, alignmentArea);
            alignedImg=imgCurr;
            
            if startNext>2
                for i=1:numOfDests
                    currDestNames=currData{i};
                    final_data_names(1:startNext-2,i)=...
                                             currDestNames(1:startNext-2);
                end
            end
            
            for i=startNext:SrcImgNum
                % Base crop
                [destNames]=saveROI(alignedImg,DestDirNames,SrcImgNames{i-1},...
                                    Plates2Cut,i-1,destsImgNum,rects);
                final_data_names(i-1,:)= destNames;

                progress = progress + 1;
                waitbar(progress/numOfImages, progress_bar, ...
                sprintf('Calculating Motion: image %d/%d', i-startNext+1,numOfImages));

                imgNext=imread(fullfile(SourceDir,SrcImgNames{i}));
                imgNext=imgNext(:,:,1:3);
                imgNextGray = rgb2gray(imgNext(:,:,1:3));
                imgNextGray = im2double(imgNextGray);
                NextCropped = imcrop(imgNextGray, alignmentArea);

                % Check if we need to calculate motion to
                % next (actually current i) image 
                if i<=motionSize
                    % get next motion
                    u=all_u(i);
                    v=all_v(i);
                    final_u(i)=u;
                    final_v(i)=v;
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
                                Plates2Cut,SrcImgNum,destsImgNum,rects);
            final_data_names(i,:)= destNames;
            
            progress = progress + 1;
            waitbar(progress/numOfImages, progress_bar, ...
            sprintf('Calculating Motion: image %d/%d', numOfImages,numOfImages));

            %% Save relevant data

            % Save motion file
            motions = cell(length(SrcImgNames),3);
            motions(:,1)=SrcImgNames;
            motions(:,2)=num2cell(final_u);
            motions(:,3)=num2cell(final_v);
            save(motionsFileStr,'motions');

            % Save data file in each destination
            for i=1:numOfDests
                FilesName=final_data_names(:,i);
                FilesDateTime=[SrtdSrcImages.datenum];
                dataFileStr=fullfile(DestDirNames{i},DATA_FILE_NAME);
                PlateCirc.X = PlatePos{i}.X - rects{i}(1);
                PlateCirc.Y = PlatePos{i}.Y - rects{i}(2);
                PlateCirc.R = PlatePos{i}.R*BoardHint.RelativeMaskRadius;
                if updateFlag(i)==1
                    if exist(dataFileStr, 'file')
                      save(dataFileStr,'FilesName','FilesDateTime','PlateCirc','-append');
                    else
                      save(dataFileStr,'FilesName','FilesDateTime','PlateCirc');
                    end
                end
            end
        end

        close(progress_bar)
    end
end
