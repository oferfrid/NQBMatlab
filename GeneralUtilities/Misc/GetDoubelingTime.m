function DoubelingTime = GetDoubelingTime(ReadsTime ,Reads,Dilutions,ODTH, Colour)
%DoubelingTime = GetDoubelingTime(ReadsTime ,Reads,Dilutions,ODTH)
%   ReadsTime - time of measurements
%   Reads - rows: reads in time. cols: different wells.
%   dilution - each well's dilution
%   ODThresh - OD Cuttoff for calculation
%% find spikes 
if nargin>4
    DoPlot = true;
else
    DoPlot = false;
end

TH = 0.03;


for c=1:size(Reads,2)
    %figure;
    sOD= smooth(Reads(:,c),5);
    Included{c} = abs(sOD./Reads(:,c)-1)<TH;
end

%% find the limits
if nargin<4
    ODTH = 0.4;
end

T = nan(size(Reads,2),1);

for c=1:size(Reads,2)
    
        Lind = find(Reads((Included{c}),c)<ODTH,1,'last');
        Hind = find(Reads((Included{c}),c)>ODTH,1,'first');
        
        if (~isnan(Lind)&~isnan(Hind))
            T(c) = interp1(Reads([Lind Hind],c) ,ReadsTime([Lind Hind]),ODTH);
        end
        
       % color = getPlotColors(8,r);
       % plot(t(Included{ind}),OD((Included{ind}),ind),'color',color);
       % hold on;
end

%%
% uniqueDilutions = unique(Dilutions);
% NofDilution = size(uniqueDilutions,2);
% Dilutions = 10.^(-(0:(NofDilution-1)));


% D = repmat(-log(Dilutions),[8 1]);
D = -log2(Dilutions);



[p,S] = polyfit(D(~isnan(T)),T(~isnan(T)),1);


DoubelingTime=p(1);

%%
if DoPlot
    hold on
    plot(D(:),T(:),'o','Color',Colour,'LineWidth',2);
    plot(D(:), p(1).*D(:)+p(2),'Color',Colour,'LineWidth',2);
    xlabel('log2(Dilution)')
    ylabel('Time')
end


end

