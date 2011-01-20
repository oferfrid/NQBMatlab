clear;
addpath D:\Irit\Matlab\Utilities
 
%% 32 data
%--------------------------------------------------------------------------
disp('---------------------- 32 ------------------')
FullFileName = 'C:\Documents and Settings\Irit\My Documents\Lab\TimeLapse\ScannerTemperature\GrowthRate32.xls';

% reading data
[Measurments32, Temperature32, Time32] = ReadTecanData(FullFileName);

% Wells to analyze
plateWellIDs  = reshape(1:96,[12 8]);
ColsToAnalyze = 1:12;
MeasErr       = [44 63 71 80];
WellInd       = plateWellIDs(ColsToAnalyze,:);
WellInd       = WellInd(:);
WellInd32     = setdiff(WellInd, MeasErr);

DivTime32 = CalcDivTime(Measurments32, Time32, WellInd32, 0);

%% 32_ii data
%--------------------------------------------------------------------------
disp('-------------------- 32_ii -----------------')
FullFileName = 'C:\Documents and Settings\Irit\My Documents\Lab\TimeLapse\ScannerTemperature\GrowthRate32_ii.xls';

% reading data
[Measurments32_ii, Temperature32_ii, Time32_ii] = ReadTecanData(FullFileName);

% Wells to analyze
plateWellIDs  = reshape(1:96,[12 8]);
ColsToAnalyze = 1:12;
MeasErr       = [1 9 29 57 61 63 68 69 73 75];
WellInd       = plateWellIDs(ColsToAnalyze,:);
WellInd       = WellInd(:);
WellInd32_ii     = setdiff(WellInd, MeasErr);

DivTime32_ii = CalcDivTime(Measurments32_ii, Time32_ii, WellInd32_ii, 0);

%% 37 data
%--------------------------------------------------------------------------
disp('---------------------- 37 ------------------')
FullFileName = 'C:\Documents and Settings\Irit\My Documents\Lab\TimeLapse\ScannerTemperature\GrowthRate37.xls';

% reading data
[Measurments37, Temperature37, Time37] = ReadTecanData(FullFileName);

% Wells to analyze
plateWellIDs  = reshape(1:96,[12 8])';
RowsToAnalyze = 2:12;
MeasErr       = [11 12 24 35 47 58 65 71 95];
WellInd       = plateWellIDs(:,RowsToAnalyze);
WellInd       = WellInd(:);
WellInd37     = setdiff(WellInd, MeasErr);

DivTime37 = CalcDivTime(Measurments37, Time37, WellInd37, 0);


%% 37.5 data
%--------------------------------------------------------------------------
disp('-------------------- 37.5 ------------------')
FullFileName = 'C:\Documents and Settings\Irit\My Documents\Lab\TimeLapse\ScannerTemperature\GrowthRate375.xls';

% reading data
[Measurments375, Temperature375, Time375] = ReadTecanData(FullFileName);

% Wells to analyze
plateWellIDs  = reshape(1:96,[12 8])';
RowsToAnalyze = 1:11;
MeasErr       = [27 28 62 91];
WellInd       = plateWellIDs(:,RowsToAnalyze);
WellInd       = WellInd(:);
WellInd375    = setdiff(WellInd, MeasErr);

DivTime375 = CalcDivTime(Measurments375, Time375, WellInd375, 0);


%% 38 data
%--------------------------------------------------------------------------
disp('---------------------- 38 ------------------')
FullFileName = 'C:\Documents and Settings\Irit\My Documents\Lab\TimeLapse\ScannerTemperature\GrowthRate38.xls';

% reading data
[Measurments38, Temperature38, Time38] = ReadTecanData(FullFileName);

% Wells to analyze
plateWellIDs  = reshape(1:96,[12 8])';
RowsToAnalyze = 1:11;
MeasErr       = [82 95];
WellInd       = plateWellIDs(:,RowsToAnalyze);
WellInd       = WellInd(:);
WellInd38     = setdiff(WellInd, MeasErr);

DivTime38 = CalcDivTime(Measurments38, Time38, WellInd38, 0);

%% plot hist of division time
figure;
subplot(5,1,1);
hist(DivTime32,40)
mean32 = mean(DivTime32);
title('Division time at 32^oC - 3 days starved','FontSize',14);
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',...
             mean32,std(DivTime32));
text(30,16,txt);
axis([16 34 0 20]);

subplot(5,1,2);
hist(DivTime32_ii,40)
mean32 = mean(DivTime32_ii);
title('Division time at 32^oC - not starverd','FontSize',14);
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',...
             mean32,std(DivTime32));
text(30,16,txt);
axis([16 34 0 20]);

subplot(5,1,3);
hist(DivTime37,40)
mean37 = mean(DivTime37);
title('Division time at 37^oC','FontSize',14);
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',...
             mean37,std(DivTime37));
text(30,16,txt);
axis([16 34 0 20]);

subplot(5,1,4);
hist(DivTime375,40)
mean375 = mean(DivTime375);
title('Division time at 37.5^oC','FontSize',14);
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',...
            mean375,std(DivTime375));
text(30,7,txt);
axis([16 34 0 11]);

subplot(5,1,5);
hist(DivTime38,40)
mean38 = mean(DivTime38);
title('Division time at 38^oC','FontSize',14);
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',...
            mean38,std(DivTime38));
text(30,10,txt);
axis([16 34 0 15]);
xlabel('Time [minutes]');
