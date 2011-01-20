%% read data
clear all;
[WellTime WellMeas] = readwalacdata('MGHY MGY 32-2.xls');

%% analyze data plase (on plate)
plateWellIDs=reshape(1:96,[12 8])';

MGYrowind=1:6 ;
MGHYrowind=7:12;
% MGYrowind=2:6 ;
% MGHYrowind=8:12;
MGYwellind= plateWellIDs(:,MGYrowind);
MGYwellind=MGYwellind(:);
MGHYwellind= plateWellIDs(:,MGHYrowind);
MGHYwellind = MGHYwellind(:);

%% remove BG
NOBGPoints=2:20;
WellMeasNoBG = WellMeas -  repmat(mean(WellMeas (NOBGPoints,:)),size(WellMeas,1),1)  ;
MGYMeasNoBG = WellMeasNoBG(:,MGYwellind);
MGHYMeasNoBG = WellMeasNoBG(:,MGHYwellind);

%% plot all data 
figure;
h1=semilogy(WellTime,MGYMeasNoBG,'r','YDataSource','WellMeasNoBG(MGYwellind,:)');
hold on;
h2=semilogy(WellTime,MGHYMeasNoBG,'b','YDataSource','WellMeasNoBG(MGHYwellind,:)');
legend([h1(1) h2(2)],{'MGY' 'MGHY'});

%% find  exp growth
[MGHYupperlimitind MGHYlowerlimitind ]= findexpgrowth(MGHYMeasNoBG,WellTime);
[MGYupperlimitind MGYlowerlimitind ]= findexpgrowth(MGYMeasNoBG,WellTime);

%% fit 

MGHYdivtime =  fitexpgrowth( MGHYlowerlimitind,MGHYupperlimitind ,WellTime,MGHYMeasNoBG);
MGYdivtime =  fitexpgrowth( MGYlowerlimitind,MGYupperlimitind ,WellTime,MGYMeasNoBG);

%% show hist 

figure;
subplot(2,1,1);
hist(MGHYdivtime,40)
title('MGHY Division time at 32^oC');
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',mean(MGHYdivtime),std(MGHYdivtime));
text(19,7,txt);
axis([18 28 0 12]);

subplot(2,1,2);
hist(MGYdivtime,40)
title('MGY Division time at 32^oC');
txt=sprintf('Division time mean  = %1.2f\nDivision time STD = %1.2f',mean(MGYdivtime),std(MGYdivtime));
text(19,7,txt);
axis([18 28 0 12]);
