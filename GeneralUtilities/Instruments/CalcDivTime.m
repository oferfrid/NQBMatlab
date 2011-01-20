function DivTime = CalcDivTime(Measurments, TimeVec, WellInd, showFit)
addpath D:\Irit\Matlab\Utilities
LinesForBG  = 15;
CoeffTH     = 0.993;

%% subtarct background
BG          = mean(Measurments(2:LinesForBG,:));
MeasNoBG    = Measurments - repmat(BG, size(Measurments,1), 1);

%% find exp growth
[upperLimit lowerLimit]= findexpgrowth(MeasNoBG(:,WellInd),TimeVec);

%% fit 
if showFit
    [DivTime, Coeff] = fitexpgrowth( lowerLimit ,upperLimit, ...
                                     TimeVec ,MeasNoBG(:,WellInd),WellInd);
else
    [DivTime, Coeff] = fitexpgrowth(lowerLimit ,upperLimit ,...
                                    TimeVec ,MeasNoBG(:,WellInd));
end
for k=1:length(Coeff)
    if Coeff(k) < CoeffTH
        warning('coefficient for well %d = %f', WellInd(k), Coeff(k));
    end    
end
