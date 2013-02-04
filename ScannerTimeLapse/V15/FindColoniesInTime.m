function FindColoniesInTime(DirName)
%%
% FindColoniesInTime(DirName)
% -------------------------------------------------------------------------
% Purpose: finding the colonies and matching them in time
%
% Description: The function ColoniesProperties uses the connected components
%       result to find the colonis properties. The function
%       matchColonies matches the colonies between the picutres.
%
% Arguments: DirName - the full directory name
%
% Input Files: DirName\LRGB\L#_00000.mat - the connected compnents result
%
% Output files: DirName\Results\...
%       VecArea - rows: colonies. cols: time. 
%       VecBBox - rows: colonies. cols: (x,y) of CM. pages: time
%       VecCen - rows: colonies. cols: (x,y,w,h). pages: time.
%       OrdColour - the colour of each component in the last frame
%       TimeAxis - a vector of the time from the begining in minutes
% -------------------------------------------------------------------------
% Irit Levin, 01.2008
% Irit L.Reisman - 01.2013 Bug fix - when subtracting the background there
%       are no colonies in the first image, and a line of zeros entered. 
%       (It doesn't count for any statistics, but it caused a problem when 
%       using the new close to border function.

%% variables
LRGB_dir = fullfile(DirName,'LRGB');
Res_dir  = fullfile(DirName,'Results');

%% getting the list of the files
dirOutput = dir(fullfile(LRGB_dir ,'L*.mat'));
FileVec = {dirOutput.name}';

%% getting the Time axis from the names of the files
% file name is 'L#_00000.mat' where 000000 is the number of seconds from
% the first picture
MinFromFirst = char(FileVec);
MinFromFirst = MinFromFirst(:,4:8);   
TimeAxis     = str2num(MinFromFirst);
save(fullfile(Res_dir,'TimeAxis'),'TimeAxis');

%% finding the colonies and their centre and radius at the fisrt frame
FullFileName = fullfile(LRGB_dir, char(FileVec(1)));
load (FullFileName);
[VecArea,VecBBox,VecCen] = ColoniesProperties(L);
FirstDetection = ~any(VecArea(:));

%% initialize a progress bar
progress_bar = waitbar(0);

%% finding the colonies in all the files, in the same area
NumOfFiles = size(FileVec,1);
for k=2:NumOfFiles   
    %%  reading the next file in the list
    msg = ['matching picture ', num2str(k),'/',num2str(NumOfFiles)];
    waitbar(k/NumOfFiles, progress_bar, msg);
    
    FullFileName = fullfile(LRGB_dir, char(FileVec(k)));
    load (FullFileName);
    
    %%  finding the colonies
    [Areas,BBoxes,Cens] = ColoniesProperties(L);
    
    %%  matching the colonies to the colonies in the previous picture
    ColonyExist = find(VecCen(:,1,k-1));
    Colony1st   = zeros(size(VecCen,1),1);
    PrevCM      = zeros(size(VecCen,1),2);
    for g = 1:size(ColonyExist,1)
        Colony1st(ColonyExist(g)) = ...
            find(VecBBox(ColonyExist(g),1,:),1,'first');
        PrevCM(ColonyExist(g),:) = ...
            VecCen(ColonyExist(g),:,Colony1st(ColonyExist(g)));
    end
    coupling = MatchColonies(L, Areas, PrevCM);
    ordArea = couple(Areas, coupling);
    ordBBox = couple(BBoxes, coupling);
    ordCen  = couple(Cens, coupling);
    
    %%  concatanating the data
    if (FirstDetection && any(coupling))
        ordArea = ordArea(2:end);
        ordCen  = ordCen(2:end,:);
        ordBBox = ordBBox(2:end,:);
        FirstDetection = 0;
    end
    VecArea(1:size(ordArea,1),k)   = ordArea;
    VecCen(1:size(ordCen,1),:,k)   = ordCen;
    VecBBox(1:size(ordBBox,1),:,k) = ordBBox;
    
end
close(progress_bar);

%%  Saving the data
save(fullfile(Res_dir,'VecArea'),'VecArea');
save(fullfile(Res_dir,'VecBBox'),'VecBBox');
save(fullfile(Res_dir,'VecCen') ,'VecCen');
    
%% Creating a list of the first pixel in each region, for the colour list
Lrgb = label2rgb(L, 'jet', 'k', 'shuffle');
PxlIdx = regionprops(L, 'PixelList');
ColoniesNum = size(PxlIdx,1);
FirstInReg  = zeros(ColoniesNum, 2);
ColourVec   = zeros(ColoniesNum, 3); 
for k=1:ColoniesNum
    FirstInReg(k,1) = PxlIdx(k).PixelList(1,1);
    FirstInReg(k,2) = PxlIdx(k).PixelList(1,2);
    ColourVec(k,:) = double(Lrgb(FirstInReg(k,2),FirstInReg(k,1),:))/255;
end
ordColour = couple(ColourVec, coupling);
save(fullfile(Res_dir,'ordColour') ,'ordColour');

%% Ploting the growth of the colonies
ShowPlate(TimeAxis(end), DirName, 0);
