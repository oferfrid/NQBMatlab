function CutPicture(OrgFolder, destFolder, PlatesVec, circleVec)
%% CutPicture(OrgFolder, destFolder, PlatesVec, circleVec)
% ----------------------------------------------------------------------
% Purpose: Cutting a picture that countain N petree dishes to N files.
%
% Description : the function returns each plate in a different file. 
%          The cut is done according to the centre coordinates of each 
%          plate gine by FindPlates.
%          The original files are aligned with the motions file, and then 
%          cut. The result files are in sub-directories names PtreeN 
%          (N-plate number).
%
% Arguments : OrgFolder - original folder
%          destFolder - name of destination folder destFolder_#
%          PlatesVec - the plates to cut from the original picture
%          circleVec - the CM of the plates. assumes that the picture was
%                      taken in 300 DPI and therefore it is 1050pxl.
% output : NumOfPlates files Named 'P#_<minutes from start>.tif'
% ----------------------------------------------------------------------
% Irit Levin. September 2006
% ---------
% updates: 10.2008
% Irit Levin. Aligning pic with GM's procedure first.

%% Constants
disp([datestr(now)   '   Cutting Pictures']);
% Cen is the array of the centers of the plates
CEN(:,1) = circleVec(:,1);
CEN(:,2) = circleVec(:,2);
PicSize = 1050;         % each picture is 1050 pixels

%% Getting the file list and their dates
dirOutput = dir(fullfile(OrgFolder, '*.tif'));
FileVec   = {dirOutput.name}';
load(fullfile(destFolder,'TimeAxis'));
NumOfPlates = length(PlatesVec);

%% loading movements
mov = load(fullfile(destFolder,'motions.mat'));
motions = mov.motions;
acc_u = cumsum(motions(:, 1));
acc_v = cumsum(motions(:, 2));

%% getting the coordinates to cut the picture
x(1:2:11) = CEN(:,1)-PicSize/2;
x(2:2:12) = CEN(:,1)+PicSize/2;
y(1:2:11) = CEN(:,2)-PicSize/2;
y(2:2:12) = CEN(:,2)+PicSize/2;

%% Creating the destination folders
for k=1:NumOfPlates
    dirName = [destFolder,'_', num2str(PlatesVec(k))];
    [successMK,mgsMK,msgidMK] = mkdir(dirName);
    if ~successMK
        error(msgidMK, mgsMK);
    end
    picDir = fullfile(dirName, 'Pictures');
    [successMK,mgsMK,msgidMK] = mkdir(picDir);
    if ~successMK
        error(msgidMK, mgsMK);
    end
end

%% running over all the files
%initialize a progress bar
progress_bar = waitbar(0);
NumOfFiles = size(FileVec,1);
for k=1:NumOfFiles
    msg = ['Cutting picture ', num2str(k),'/',num2str(NumOfFiles)];
    waitbar(k/NumOfFiles, progress_bar, msg);
    
    FName = char(FileVec(k));
    FullFileName = fullfile(OrgFolder, FName);
    RGB = imread(FullFileName);
    RGB = RGB(:,:,1:3);
    % aligning picture
    RGB = imdilate(RGB,translate(strel(1),...
             [-round(acc_v(k)) -round(acc_u(k))]));
    % each file is cut into N files
    for j=1:NumOfPlates%2:size(X,1)
        Ptree = RGB(y(2*PlatesVec(j)-1):y(2*PlatesVec(j)),...
                    x(2*PlatesVec(j)-1):x(2*PlatesVec(j)),:);
        dirName = [destFolder ,'_',num2str(PlatesVec(j))];
        picDir = fullfile(dirName, 'Pictures');
        FileName = sprintf('P%1.0f_%05.0f.tif',PlatesVec(j),TimeAxis(k));
        FullName = fullfile(picDir ,FileName);
        imwrite(Ptree,FullName,'tif');
    end
end
close(progress_bar);