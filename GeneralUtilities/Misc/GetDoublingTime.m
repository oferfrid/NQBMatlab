function DoublingTime = GetDoublingTime(ReadsTime ,Reads,Dilutions,ODTH, Colour)
%GrowthRate = GetGrowthRate(ReadsTime ,Reads,Dilutions,ODTH)
%   ReadsTime - time of measurements
%   Reads - rows: reads in time. cols: different wells.
%   dilution - each well's dilution
%   ODThresh - OD Cuttoff for calculation
%   Coulor - The color of the graph (optional. If not stated then no plotting)
%% find spikes 
if nargin>4
    DoPlot = true;
end

TH = 0.03;


for c=1:size(Reads,2)
    sOD= smooth(Reads(:,c),5);
    Included{c} = abs(sOD./Reads(:,c)-1)<TH;
end

%% find the limits
if nargin<4
    ODTH = 0.4;
end

T = nan(size(Reads,2),1);

for c=1:size(Reads,2)
    IncReads = Reads(Included{c},c);
    
        Lind = find(IncReads<ODTH,1,'last');
        Hind = find(IncReads>ODTH,1,'first');
        
        if (~isnan(Lind)&~isnan(Hind))
            T(c) = interp1(IncReads([Lind Hind]) ,ReadsTime([Lind Hind]),ODTH);
        end
end

%%
D = -log2(Dilutions);

[p,S] = polyfit(D(~isnan(T)),T(~isnan(T)),1);

DoublingTime=p(1);

%%
if DoPlot
    hold on
    plot(D(:),T(:),'o','Color',Colour,'LineWidth',2);
    plot(D(:), p(1).*D(:)+p(2),'Color',Colour,'LineWidth',2);
    xlabel('log2(Dilution)')
    ylabel('Time')
end


end

