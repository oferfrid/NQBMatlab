function ThermometerGraph(tot_mhour, tot_probe, tot_temperature, tot_p_type)
% ThermometerGraph(tot_mhour, tot_probe, tot_temperature, tot_p_type)
% -------------------------------------------------------------------------
% Purpose : showing a graph for the data from exported from the thermometer
% Arguments : The same as ReadThermometer returns.
% -------------------------------------------------------------------------
% Irit Levin. 10.01.2008

NDataSet = length(tot_mhour);

for k=1:NDataSet
    hourSet = tot_mhour{k};
    probSet = tot_probe{k};
    TempSet = tot_temperature{k};
    pTypeSet= tot_p_type{k};
    
    TimeVec = (datenum(hourSet, 'HH:MM:SS')-datenum(hourSet(1), 'HH:MM:SS'))*24*60;
    TempSet = tot_temperature{k};
%     figure;
    plot(TimeVec, TempSet);
    xlabel('Time [minutes]');
    ylabel('Temperature [^oC]');
    legend(probSet);
    title('Temperature in Time');
end