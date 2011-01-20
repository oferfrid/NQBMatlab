function AlignAll(FileDir,FileName)
%

% initializations
% rect: [xmin ymin width height]
rect_SCell1 = [10 890 500 1000];
rect_SCell2 = [20 940 400 900];
rect_offset = [(rect_SCell2(1)-rect_SCell1(1)) 
               (rect_SCell2(2)-rect_SCell1(2))];

% finding all the files
DirName    = FileDir;
DirAligned = [DirName,'A'];
[successMK,mgsMK,msgidMK] = mkdir(DirAligned);
if ~successMK
    error(msgidMK, mgsMK);
end
dirOutput  = dir(fullfile(DirName,FileName));
FileVec    = {dirOutput.name}';
NumOfFiles = size(FileVec,1);

% reading the first picture
FullFileName = fullfile(DirName, char(FileVec(1)));
SCell1_4 = imread(FullFileName);
SCell1   = SCell1_4(:,:,1:3);
FullFileName = fullfile(DirAligned, char(FileVec(1)));
imwrite(SCell1,FullFileName,'tif');

for k=2:NumOfFiles
    msg = sprintf('processing picture %d/%d', k, NumOfFiles);
    disp(msg);
    % reading the picture to align
    FullFileName = fullfile(DirName, char(FileVec(k)));
    SCell2_4 = imread(FullFileName);
    SCell2   = SCell2_4(:,:,1:3);
    [r1,c1,p1] = size(SCell1);
    [r2,c2,p2] = size(SCell2);
    
    % registring the images with a sub image, so that it won't take too
    % much time.
    %subSCell1 = SCell1(400:950,10:350,:);
    %subSCell2 = SCell2(450:900,20:250,:);

    %figure; imshow(imcrop(SCell1,rect_SCell1));
    %figure; imshow(imcrop(SCell2,rect_SCell2));
    % registering the SCell2 according to SCell1
    [xb,xe,yb,ye] = AlignImages(imcrop(SCell1,rect_SCell1),...
                                imcrop(SCell2,rect_SCell2));

    % Claculating the total offset of the picture
    xoffset = xb-rect_offset(1);
    yoffset = yb-rect_offset(2);
    if xoffset>0
        xbegin = 1;
        xend   = c2-xoffset+1;
        rcvrXb = xoffset;
        rcvrXe = c2;
    else
        xbegin = -xoffset+1;
        xend   = c2;
        rcvrXb = 1;
        rcvrXe = c2+xoffset;
    end
    if yoffset>0
        ybegin = 1;
        yend   = r2-yoffset+1;
        rcvrYb = yoffset;
        rcvrYe = r2;
    else
        ybegin = -yoffset+1;
        yend   = r2;
        rcvrYb = 1;
        rcvrYe = r2+yoffset;
    end
%     xbegin  = max(xoffset,1);
%     xend    = min(xoffset+c2,c2);
%     ybegin  = max(yoffset,1);
%     yend    = min(yoffset+r2,r2);

    % creating the aligned image
    recovered_SCell2 = uint8(zeros(r1,c1,p1));
    recovered_SCell2(rcvrYb:rcvrYe,rcvrXb:rcvrXe,:) = ...
              SCell2(ybegin:yend,xbegin:xend,:);
    %figure, imshow(recovered_SCell2)
    SCell1 = recovered_SCell2;
    
    % saving the aligned file
    FullFileName = fullfile(DirAligned, char(FileVec(k)));
    imwrite(recovered_SCell2,FullFileName,'tif');
end