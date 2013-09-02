function CalibratedImage = CalibrateImage(FileToCalibrate, ScannerNo)
%% CalibrateImage(FileToCalibrate, ScannerNo)
% -------------------------------------------------------------------------
% Arguments: FileToCalibrate - full path of the image to calibrate
%       ScannerNo - Number of scanner
% Returns: CalibratedImage - An RGB image after calibration
% -------------------------------------------------------------------------
% Irit L. Reisman 07.12

%% loading the calibraton factors
CalibrationFactorsFileName = sprintf('ClibrationFactors%02d.mat', ScannerNo);

CalibrationConstants = load(CalibrationFactorsFileName);
CalibrationFactor = CalibrationConstants.CalibrationFactor;
BlackPixCalib     = CalibrationConstants.BlackPixCalib;
BlackPixNotCalib  = CalibrationConstants.BlackPixNotCalib;

Im = im2double(imread(FileToCalibrate));

%% calculating the transformation
% CalibratedImage = (Im-BlackNCMat).* CalibFMat + BlackMat; 
% Due to the size of the image the calculation is done in step by step.

BlackNCMat = ((repmat(BlackPixNotCalib, size(Im,1),1)));
CalibratedImage = Im-BlackNCMat; 
clear BlackNCMat;

CalibFMat = ((repmat(CalibrationFactor, size(Im,1),1)));
CalibratedImage = CalibratedImage.* CalibFMat; 
clear CalibFMat;

BlackMat = ((repmat(BlackPixCalib, size(Im,1),1)));
CalibratedImage = CalibratedImage + BlackMat; 