function CutPicture(OrgFolder, destFolder, PlatesVec, circleVec)
%% CutPicture(OrgFolder, destFolder, PlatesVec, circleVec)
% ----------------------------------------------------------------------
% Purpose: Cutting a picture that countain N petree dishes to N files.
%
% Description : the function returns each plate in a different file. 
%          The cut is done according to the centre coordinates of each 
%          plate ginev by FindPlates.
%          The original files are in the directory of aligned pictures.
%          The result files are in sub-directories names PtreeN (N-plate
%          number).
%
% Arguments : OrgFolder - original folder
%          destFolder - name of destination folder destFolder_#
%          PlatesVec - the plates to cut from the original picture
%          circleVec - the CM of the plates. assumes that the picture was
%                      taken in 300 DPI and therefore it is 1050pxl.
% output : NumOfPlates files Named 'P year month day T hour min sec.tif'
% ----------------------------------------------------------------------
% Irit Levin. September 2006

%% Constants
% Cen is the array of the centers of the plates
%CEN = [717, 647; 717, 1770; 717, 2892; 1902, 648; 1899, 1771; 1898, 2892];
CEN(:,1) = circleVec(:,1);
CEN(:,2) = circleVec(:,2);
PicSize = 1050;         % each picture is 1050 pixels

%% Getting the file list and their dates
dirOutput = dir(fullfile(OrgFolder, '*.tif'));
FileVec   = {dirOutput.name}';
load(fullfile(OrgFolder,'TimeAxis'));
NumOfPlates = length(PlatesVec);

%% Showing the first file, and marking the plates
FName = char(FileVec(1)); 
FullFileName = fullfile(OrgFolder, FName);
RGB = imread(FullFileName);
%imshow(RGB,'InitialMagnification','fit');

%% getting the coordinates to cut the picture
% [X,Y]=ginput(NumOfPlates*2)   % can be used if the fixed coorddinates
                                % don't fit. 
% x = round(X)
% y = round(Y)

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
NumOfFiles = size(FileVec,1);
for k=1:NumOfFiles
    msg = ['Processing picture ', num2str(k),'/',num2str(NumOfFiles)];
    disp(msg);
    FName = char(FileVec(k));
    FullFileName = fullfile(OrgFolder, FName);
    RGB = imread(FullFileName);
    % each file is cut into N files
    for j=1:NumOfPlates%2:size(X,1)
        Ptree = RGB(y(2*PlatesVec(j)-1):y(2*PlatesVec(j)),...
                    x(2*PlatesVec(j)-1):x(2*PlatesVec(j)),:);
        dirName = [destFolder ,'_',num2str(PlatesVec(j))];
        picDir = fullfile(dirName, 'Pictures');
        FileName = sprintf('P%1d_%05d.tif',PlatesVec(j),TimeAxis(k));
        FullName = fullfile(picDir ,FileName);
        imwrite(Ptree,FullName,'tif');
    end
end