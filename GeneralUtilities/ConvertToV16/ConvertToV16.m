function ConvertToV16(odir,prefix)
%{
    This function will create a data file containing all previous version's
    results.
%}
    disp(['current dir is : ' odir]);
    
    % Verifying the plate number
    [parentDir,~,~]=fileparts(odir);
    [~,parentName,~]=fileparts(parentDir);
    plateNumStr=parentName(length(parentName));
    
    % File's name and date
    currFileName=fullfile(odir,'TimeAxis.mat');
    if exist(currFileName,'file')
        load(currFileName,'TimeAxis');
        FilesDateTime=TimeAxis;
        if size(FilesDateTime,2)>1
            FilesDateTime=FilesDateTime';
        end
        FilesPref=['P' plateNumStr '_%05.0f.tif'];
        FilesName= cellstr(num2str(TimeAxis,FilesPref));
    else
        printWarn('TimeAxis.mat',odir);
        return;
    end
    
    % Area, bounding box and centroid
    currFileName=fullfile(odir,'VecArea.mat');
    if exist(currFileName,'file')
        load(currFileName,'VecArea');
        Area=VecArea';
    else
        printWarn('VecArea.mat',odir);
        return;
    end
    
    currFileName=fullfile(odir,'VecCen.mat');
    if exist(currFileName,'file')
        load(currFileName,'VecCen');
        Centroid=permute(VecCen,[3 1 2]);
    else
        printWarn('VecCen.mat',odir);
        return;
    end
    
    % Description
    Description = '';
    FileInLibrary = dir(fullfile(odir,'LogFile.txt'));
    if size(FileInLibrary,1)
        fid = fopen(fullfile(odir,'LogFile.txt'));
        for i=1:3
            Description = fgetl(fid);
        end
        if isempty(Description)
            [~,nameDir] = fileparts(odir);
            Description = nameDir;
        end
    else
        [~,nameDir] = fileparts(odir);
        Description = nameDir;
    end
    
    %Limits and TH
    Limits=[0 1];
    FileInLibrary = dir(fullfile(odir,'TresholdVec.mat'));
    if size(FileInLibrary,1)
        load(fullfile(odir,'TresholdVec.mat'),'level');
        TH=level(1);
    else
        TH=[0.2];
    end
    
    % Exclude and close to border
    IgnoredColonies=zeros(size(Area,2),1);
    relevantColonies = FindColoniesInWorkingAreaN(parentDir);
    IgnoredColonies(relevantColonies)=1;
    IgnoredColonies=double(~IgnoredColonies);
    zeroAreaColonies=(Area(end,:)==0)';
    IgnoredColonies(zeroAreaColonies&~IgnoredColonies)=3;
    ExcludeFile= fullfile(odir, 'ExcludedBacteria.txt');
    ExcludedBacteria = load(ExcludeFile);
    IgnoredColonies(ExcludedBacteria)=2;
    
    newDirName=[parentName prefix];
    dataName=[newDirName '_data.mat'];
    
    newDir=fullfile(odir,newDirName);
    
    if ~exist(newDir,'dir')
        mkdir(newDir);
    end
    
    save(fullfile(newDir,dataName),'FilesName','FilesDateTime','Area',...
                                           'Centroid','Description','Limits','TH',...
                                           'IgnoredColonies');
    
    
    % mask
    fullInd=false;
    if exist(fullfile(odir,'mask.mat'))
        load(fullfile(odir,'mask.mat'),'mask');
        FullMask=mask;
        fullInd=true;
    elseif exist(fullfile(odir,'CircParams.mat'))
        load(fullfile(odir,'CircParams.mat'),'x','y','r');
        PlateCirc.X=x;
        PlateCirc.Y=y;
        PlateCirc.R=r;
    else
        PlateCirc.X=526;
        PlateCirc.Y=526;
        PlateCirc.R=436;
    end
    
    if fullInd  
        save(fullfile(newDir,dataName),'FullMask','-append');
    else
        save(fullfile(newDir,dataName),'PlateCirc','-append');
    end  
end

function CID = FindColoniesInWorkingAreaN(FileDir)
%% CID = FindColoniesInWorkingArea(FileDir)
% -------------------------------------------------------------------------
% Purpose: Returns the colony IDs in the working area.
% 
% Description: Checks the distance of the centre of the colonies from the 
%          borders 
% 
% Arguments: FileDir - The full path of the directory
%
% Returns: CID - An Array of colony IDs
% -------------------------------------------------------------------------
% Irit L. Reisman 08.2011

    %% Constants

    NearBorder = 15;        % proximity to the border

    %% loading the data
    DirName    = fullfile(FileDir, 'Results');
    CenFile    = fullfile(DirName, 'VecCen');
    CircFile   = fullfile(DirName, 'CircParams');

    Cen  = load(CenFile);

    VecCen = Cen.VecCen;

    CID=[];

    %% Mask exists
    fullMaskName=fullfile(FileDir,'Results','mask.mat');
    if exist(fullMaskName,'file')
        [localR,localC]=meshgrid(1:2*NearBorder+1,1:2*NearBorder+1);
        local=(localR-NearBorder-1).^2+(localC-NearBorder-1).^2<=...
                                                       (NearBorder*NearBorder);
        maxVal=sum(sum(local));

        load(fullMaskName);
        conved=conv2(double(mask),double(local),'same');
        NumColonies = size(VecCen,1);
        [rownum,colnum]=size(mask);
        [XX,YY] = meshgrid(1:rownum,1:colnum);


        for k=1:NumColonies
            % remove excluded
            if VecCen(k,1,end)~=0
                AppearenceIndex = find(VecCen(k,1,:),1,'first');

                if (conved(round(VecCen(k,2,AppearenceIndex)),...
                           round(VecCen(k,1,AppearenceIndex)))==maxVal)
                    CID=[CID k];
                end
            end
        end
    else
        if exist(CircFile)
            circ = load(CircFile);
        else
            circ.x=526;
            circ.y=526;
            circ.r=436;
        end
        
        %% Checking which colony is too close to the border
        NumColonies = size(VecCen,1);
        CM = zeros(NumColonies,2);
        for k=1:NumColonies
            AppearenceIndex = find(VecCen(k,1,:),1,'first');
            % a strage bug - there are colonies with CM (0,0) all experiment time
            if isempty(AppearenceIndex)
                CM(k,:) = [0,0];
            else
            % end patch
                CM(k,:) = VecCen(k,:,AppearenceIndex);
            end
        end

        %% excluding bacteria
        CM(VecCen(:,1,end)==0,:)  = 0;

        %% Calculating distance
        distFromCM  = sqrt((circ.x-CM(:,1)).^2+(circ.y-CM(:,2)).^2);
        CID = find(NearBorder < circ.r- distFromCM);
    end
end

function printWarn(fileName,odir)
    disp(['WARNING! WARNING! No ' fileName ' in ' odir]);
end
