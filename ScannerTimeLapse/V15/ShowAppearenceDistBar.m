function ShowAppearenceDistBar(TimeAxis ,TotalDistr, FileDir)
%ShowAppearenceDistBar(TimeAxis ,TotalAppearenceMinute, FileDir)

%figure; hist(TotalAppearenceMinute,TimeAxis);

figure;bar(TimeAxis, TotalDistr);
tit = sprintf('Distribution of appearance for %s',...
              getGeneralDescription(FileDir)); 
title(tit);
%txt = sprintf('Total number \nof bacteria: %d', length(TotalAppearenceMinute));
txt = sprintf('Total number \nof bacteria: %d', sum(TotalDistr));
ylim_ = get(gca,'YLim');
xlim_ = get(gca,'XLim');
text(xlim_(2)*0.5, ylim_(2)*0.8 , txt);
xlabel('Time [minutes]');
ylabel('Number of colonies appeared');
xlim([TimeAxis(1),TimeAxis(end)+1])