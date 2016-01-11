function  [divtime rsquare] =  fitexpgrowth( lowerlimitind,upperlimitind,WellTime,MeasNoBG,WellVec )
%% divtime =  fitexpgrowth( lowerlimitind,upperlimitind,WellTime,MeasNoBG,WellVec )
% -------------------------------------------------------------------
% Purpose: Find the division time in exponential growth.
%
% Description: The function gets matrix with results after removing the 
%          background and the start & end of the exponential growth
%          and than calculates the division time.
%
% Arguments: lowerlimitind - a vector with the start indexes of the exponential
%                            growth
%            upperlimitind - a vector with the end indexes of the exponential
%                            growth.
%            WellTime - time vector (in minutes) of the measurement.
%            MeasNoBG - a matrix with results X wells of results with no
%                     background
%            WellVec - uses for debugging, the name of the wall to display on
%                      the plot (if no data supplied no debug plot will be
%                      shown
%
% Returns: divtime - a vector of the calculated deviation time.
%          rsquare - a vector of coefficient of determination 
%         
% -------------------------------------------------------------------
% Ofer Fridman, 01.01.2008
 s = warning('query', 'all');
 warning('off','MATLAB:Axes:NegativeDataInLogAxis');
 warning('off','MATLAB:log:logOfZero');
 
divtime=zeros([size(MeasNoBG,2) 1]);
rsquare=zeros([size(MeasNoBG,2) 1]);
for    wellid =1:size(MeasNoBG,2);
    
    
    st_ = [1e-5 0.03];
    ft_ = fittype('exp1');

    X=WellTime(lowerlimitind(wellid):upperlimitind(wellid));
    Y=MeasNoBG(lowerlimitind(wellid):upperlimitind(wellid),wellid);

    if max(Y)/min(Y)<10
        warning('MATLAB:fitexpgrowth','Growth estimated on less than one order of magnitude, at wellid %d', wellid);
    end

    [cfun,gof] = fit(X,Y,ft_,'Startpoint',st_);
    %Confidence =confint(cf_,0.95);

    divtime(wellid) = log(2)/cfun.b;
    rsquare(wellid) = gof.rsquare;
    if nargin > 4
        figure;
        semilogy(WellTime,MeasNoBG(:,wellid),'.b');
        hold on;
        title(WellVec(wellid));
        semilogy(WellTime(upperlimitind(wellid)),MeasNoBG(upperlimitind(wellid),wellid),'or');
        semilogy(WellTime(lowerlimitind(wellid)),MeasNoBG(lowerlimitind(wellid),wellid),'or');


        h = semilogy(WellTime,cfun.a.*exp(WellTime.*cfun.b) ,'-r');
        set(h,'LineWidth',2);
        ylim([1e-4 1]);
        txt = sprintf('Division time: %1.2f (min) \nCoefficient: %1.4f',divtime(wellid),rsquare(wellid));
        text(WellTime(round(end/3)),1e-2,txt);

    end
end
   warning(s)
end
