function CalibrateScanner(CalibratedFileName, NotCalibratedFileName, FilesPath, ScannerNo)
%% CalibrateScanner(CalibratedFileName, NotCalibratedFileName, FilesPath)
% -------------------------------------------------------------------------
% 1. Calibrate the first scanner using TWAIN (the same gui as in gimp).
% 2. Scan a picture with the relevant resolution (300 dpi) using the other
%    scanner.
% 3. Calibrate the other scanner using TWAIN.
% 4. Scan a picture with the same resolution, to get the correct calibrated
%    image.
% 5. Use this function to determain the calibration function using these
%    two images.
% Arguments: CalibratedFileName - the image scanned in step 4.
%       NotCalibratedFileName - The image scanned in step 2.
%       FilesPath - Path of the images and of the result file
%       ScannerNo - the number of scanner (determained by the USB)
% Output: CalibX.mat - a file in FilePath that includes the calculated
%       factors for calibration. (X=ScannerNo)
% -------------------------------------------------------------------------
% Irit L. Reisman 07.12

%% loading the images
Calib    = imread(fullfile(FilesPath, CalibratedFileName));
NotCalib = imread(fullfile(FilesPath, NotCalibratedFileName));

%% Croping a subimage that includes only a white and black stripe 
% (otherwise it is too big to convert to double which is necessary for
% calculating the calibration factor
display('crop a subimage that includes black and white stipes (all the columns)');
[CalibCrop rectSub] = imcrop(Calib);
NotCalibCrop = imcrop(NotCalib, rectSub);

clear Calib
clear NotCalib

CalibCrop = im2double(CalibCrop);
NotCalibCrop = im2double(NotCalibCrop);
%% getting the black and white parts
display('mark the white stripe');
[whiteCalib rectW]= imcrop(CalibCrop);
display('mark the black stripe');
[blackCalib rectB] = imcrop(CalibCrop);
% [whiteCalib rectW]= imcrop(Calib12, rectW);
% [blackCalib rectB] = imcrop(Calib12, rectB);

whiteNotCalib = imcrop(NotCalibCrop, rectW);
blackNotCalib = imcrop(NotCalibCrop, rectB);

%% getting the black an d white values
BlackPixCalib = median(blackCalib(:,:,:),1);
WhitePixCalib = median(whiteCalib(:,:,:),1);

BlackPixNotCalib = median(blackNotCalib(:,:,:),1);
WhitePixNotCalib = median(whiteNotCalib(:,:,:),1);

%% calculating the transformation
CalibrationFactor = (WhitePixCalib   -BlackPixCalib)./...
                    (WhitePixNotCalib-BlackPixNotCalib);

CalibFMat = ((repmat(CalibrationFactor, size(NotCalibCrop,1),1)));
BlackMat = ((repmat(BlackPixCalib, size(NotCalibCrop,1),1)));
BlackNCMat = ((repmat(BlackPixNotCalib, size(NotCalibCrop,1),1)));


%% Applying the transformation on the cropped image
% this is only needed to see that it was transformed well
CalibratedPic = (NotCalibCrop-BlackNCMat).* CalibFMat + BlackMat; 

%% figures the cropped images
figure; 
subplot(3,1,1);imshow(NotCalibCrop);
title('cropped image BEFORE calibation')
subplot(3,1,2);imshow(CalibratedPic);
title('cropped image AFTER calibation')
subplot(3,1,3);imshow(CalibCrop);
title('cropped image calibrated by scanner')

%% figures the intensity of an arbitrary white and black line (RGB)
figure;
h = subplot(3,1,1); hold on;
plot(NotCalibCrop(10,:,1),'b');plot(NotCalibCrop(10,:,2),'b');plot(NotCalibCrop(10,:,3),'b');
child_handles = findobj(h,'Type','line');
Lh(1)=child_handles(1);
plot(CalibratedPic(10,:,1),'r');plot(CalibratedPic(10,:,2),'r');plot(CalibratedPic(10,:,3),'r');
child_handles = findobj(h,'Type','line');
Lh(2)=child_handles(1);
plot(CalibCrop(10,:,1),'k');plot(CalibCrop(10,:,2),'k');plot(CalibCrop(10,:,3),'k');
child_handles = findobj(h,'Type','line');
Lh(3)=child_handles(1);
title('white line')
legend(Lh,{'Not calibrated','Manual calibration','Scanner clibration'})
    
subplot(3,1,2); hold on;
plot(NotCalibCrop(end-10,:,1),'b');plot(NotCalibCrop(end-10,:,2),'b');plot(NotCalibCrop(end-10,:,3),'b');
plot(CalibratedPic(end-10,:,1),'r');plot(CalibratedPic(end-10,:,2),'r');plot(CalibratedPic(end-10,:,3),'r');
plot(CalibCrop(end-10,:,1),'k');plot(CalibCrop(end-10,:,2),'k');plot(CalibCrop(end-10,:,3),'k');
title('black line')

subplot(3,1,3); hold on;
plot(CalibrationFactor(1,:,1),'r'); plot(CalibrationFactor(:,:,2),'g'); plot(CalibrationFactor(:,:,3),'b');
title('calibration factor')

%% Plots the difference between the scanner's calibrated image and the manualy calibrated image
figure;
imshow(imsubtract(CalibCrop, CalibratedPic));
title('scanner calibratted - my calibration')

%% saving the calibration factors
CalibrationFactorsFileName = sprintf('ClibrationFactors%02d.mat', ScannerNo);
save(fullfile(FilesPath, CalibrationFactorsFileName), ...
    'CalibrationFactor', 'BlackPixCalib', 'BlackPixNotCalib');
