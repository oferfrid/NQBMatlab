function [upperind lowerind ]=findexpgrowth(MeasNoBG,WellTime,WellVec)
%% [upperind lowerind ]=findexpgrowth(MeasNoBG,WellTime,WellVec)
% -------------------------------------------------------------------
% Purpose: Find the indexes of the exponential growth.
%
% Description: The function gets matrix with results after removing the 
%          background.
%          The function analyzes the data and finds the more likely start
%          & end of the exponential growth
%
% Arguments: MeasNoBG - a matrix with results X wells of resolts with no
%                       background
%            WellTime - time vector (in minutes) of the measurement.
%            WellVec - uses for debuging, the name of the wall to desply on
%                      the plot (if no data supllied no debug plot wil be shown)
%
% Returns: upperind - a vetor with the end indexes of the exponantial
%                     growth
%          lowerind - a vetor with the start indexes of the exponantial
%                     growth
%         
% -------------------------------------------------------------------
% Ofer Fridman, 01.01.2008

 s = warning('query', 'all');
 warning('off','MATLAB:Axes:NegativeDataInLogAxis');
 warning('off','MATLAB:log:logOfZero');
  
StartMeasuringPointTH           = 2.7e-3;
StartlookingForDiff1MaxPointTH  = 1e-2;
EndMeasuringPointFromMaxTH      = 0.8;

upperind = zeros(size(MeasNoBG,1),1);
lowerind = zeros(size(MeasNoBG,1),1);

    for wellid=1:size(MeasNoBG,2);
        StartMeasuringPointind = find(MeasNoBG(:,wellid)<=(StartMeasuringPointTH),1,'last') + 1;
        StartlookingForDiff1MaxPointind = find(MeasNoBG(:,wellid)<=(StartlookingForDiff1MaxPointTH),1,'last') + 1;
       
        diff1MeasNoBG=diff(log(smooth( MeasNoBG(:,wellid),25)));
       
        [C,I] = max(diff1MeasNoBG((StartlookingForDiff1MaxPointind+1):end));
        diff1maxind=I+StartlookingForDiff1MaxPointind ;
        EndMeasuringPointind=find(diff1MeasNoBG>diff1MeasNoBG(diff1maxind)*EndMeasuringPointFromMaxTH,1,'last');

        upperind(wellid)= EndMeasuringPointind;
        lowerind(wellid)=StartMeasuringPointind;
        
            if nargin > 2
               
         
                figure;
                subplot(2,1,1);
                semilogy(WellTime,MeasNoBG(:,wellid),'-+b');
                hold on;
              
                title(WellVec(wellid));
            
                semilogy(WellTime(StartMeasuringPointind),MeasNoBG(StartMeasuringPointind,wellid),'or');
                semilogy(WellTime(StartlookingForDiff1MaxPointind),MeasNoBG(StartlookingForDiff1MaxPointind,wellid),'og');
                semilogy(WellTime(EndMeasuringPointind),MeasNoBG(EndMeasuringPointind,wellid),'om');

                subplot(2,1,2);
                plot(WellTime(1:end-1),diff1MeasNoBG,'-+b');
                hold on;
                plot(WellTime(StartMeasuringPointind),diff1MeasNoBG(StartMeasuringPointind),'or');
                plot(WellTime(StartlookingForDiff1MaxPointind),diff1MeasNoBG(StartlookingForDiff1MaxPointind),'og');
                plot(WellTime(EndMeasuringPointind),diff1MeasNoBG(EndMeasuringPointind),'om');
                ylim([0 0.15]);
              
            end
      
    end
    warning(s)
    end