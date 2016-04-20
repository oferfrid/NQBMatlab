function CropROI(SourceName,DestDirNames,BoardFileName,Plates2Cut,isSpecific,changeAlign)
    %CropROI(SourceName,DestDirNames,BoardFileName,Plates2Cut)
    % This is the main function for preparing the time lapse images.
    % The methoid align the scanner's images and the cut the selected plates images.
    % The function create a motion file holding the alignment data for
    % being able to add images. If an image was added in the middle of already proccessed
    % images an error will be raised.
    % arguments:
    % SourceName - The scanner's images directory. Please keep the following
    %               format: sourcedir/filesformat. the filesformat can be an
    %               empty string or a string with the format "name.type", both
    %               "name" and "type" are expressions that may imclude hints like *
    %               as long as the dir() procedure will accept the SourceName.
    % DestDirNames - Destination for prepared plate images.
    % BoardFileName - The board hint file. This file is being created using
    %                  createBoardHint procedure
    % Plates2Cut - array of wanted plates to be prepared
    % updateFlag (default 1) - 1 - update data file, 0 - no
    % isSpecific - an arguments says if to allign by cutted plate area
    % Nir Dick 2015
    if nargin<6
        changeAlign=0;
    end
    
    if nargin<5
        isSpecific=0;
    end
    
    if isSpecific && length(Plates2Cut)>1
        disp('Problem, Plates has length greater then 1 but specific mode was chosen');
        return;
    end
    
    %% Prepare destination doorectories
    DATA_FILE_NAME='data.mat';
    MOTIONS_FILE_SUFFIX='_motions.mat';
    
    numOfDests=length(DestDirNames);
    destsImgNum=zeros(1,numOfDests);
    currData=cell(1,numOfDests);
    PrevCutData=cell(numOfDests,1);
    for k=1:numOfDests
        % Create the destination directories if needed
        currDestDir=DestDirNames{k};
        [successMK,mgsMK,msgidMK] = mkdir(currDestDir);
        if ~successMK
            error(msgidMK, mgsMK);
        end
        
        % Load the data file if exists and keep how many images are there
        dataFileStr=GetDataName(currDestDir);
        dataFlag=dir(dataFileStr);
        if ~isempty(dataFlag)
            currNames=load(dataFileStr,'FilesName');
            currData{k}=currNames.FilesName;
            destsImgNum(k)=length(currNames.FilesName);
            PrevCutData{k}=load(dataFileStr,'PrevCut');
            PrevCutData{k}=PrevCutData{k}.PrevCut;
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
    motionsFlag=[];
    motions=[];
    if isSpecific
        if ~isempty(PrevCutData{1})
            motionsFlag=1;
            motions=PrevCutData{1}.Motions;
        end  
    else
        motionFileName=[fname MOTIONS_FILE_SUFFIX];
        motionsFileStr=fullfile(SourceDir,motionFileName);
        motionsFlag=dir(motionsFileStr);
        if length(motionsFlag)>0       
            motionsTmp=load(motionsFileStr);
            motions=motionsTmp.motions;
        end
    end
    
    motionSize=0;
    
    if length(motionsFlag)>0
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
    [rects,PlatePos] = FindPlates(inputImage,BoardHint);
    
    if changeAlign
        imshow(inputImage);
        h = imrect;
        alignmentArea=wait(h);
    else 
        if isSpecific
            pcirc=PlatePos{Plates2Cut};
            x1=pcirc.X-pcirc.R/sqrt(2);
            y1=pcirc.Y-pcirc.R/sqrt(2);
            w=2*pcirc.R/sqrt(2);
            h=2*pcirc.R/sqrt(2);
            alignmentArea=[x1,y1,w,h];
        else
            alignmentArea=[BoardHint.AlignmentArea(1)*ImageSize(1) BoardHint.AlignmentArea(2)*ImageSize(2) BoardHint.AlignmentArea(3)*ImageSize(1) BoardHint.AlignmentArea(4)*ImageSize(2)]; 
        end
    end

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
    
    % validate that we continue the previous alignment area
    for j=1:numOfDests
        if length(PrevCutData{j})
           if alignmentArea~=PrevCutData{j}.AlignmentArea
                valid=0;
                disp(['plate ' num2str(Plates2Cut(j)) ' has different alignment area']);
                break;
           end
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
            if ~isSpecific
                save(motionsFileStr,'motions');
            end

            % Save data file in each destination
            for i=1:numOfDests
                FilesName=final_data_names(:,i);
                FilesDateTime=[SrtdSrcImages.datenum];
                dataFileStr=GetDataName(DestDirNames{i});
                PlateCirc.X = PlatePos{i}.X - rects{i}(1);
                PlateCirc.Y = PlatePos{i}.Y - rects{i}(2);
                PlateCirc.R = PlatePos{i}.R*BoardHint.RelativeMaskRadius;
                PrevCut.Motions=motions;
                PrevCut.BoardHint=BoardHint;
                PrevCut.AlignmentArea=alignmentArea;
                if exist(dataFileStr, 'file')
                  save(dataFileStr,'FilesName','FilesDateTime','PlateCirc','PrevCut','-append');
                else
                  save(dataFileStr,'FilesName','FilesDateTime','PlateCirc','PrevCut');
                end
            end
        end

        close(progress_bar)
    end
end

