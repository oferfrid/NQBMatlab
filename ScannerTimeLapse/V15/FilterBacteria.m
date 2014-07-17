function FilterBacteria(DirName, FilterBact,excludeFlag)
% FilterBacteria(DirName, FilterBact)
% -------------------------------------------------------------------------
% Purpose: creating the excluded bacteria list by the user
% Arguments: DirName - full directory name
%       excludedBact(optional) - An array of the numbers of 
%       the bacteria to be excluded
%       excludeFlag(optional)  - send 0 to include colony and 
%                                otherwise exclude (default 1)
% Output File: DirName\Results\ExcludedBacteria.txt
% -------------------------------------------------------------------------
% Irit L. Reisman. 03.2008
% Update 3.9.2013 Nir Dick - Added excludeFlag argument

%% getting the dirctory
if ~exist('DirName', 'var')
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
end

if ~exist('excludeFlag', 'var')
    excludeFlag=1;
end

%% loading excluded bacteria file
ResDir    = fullfile(DirName, 'Results');
ExcludedBacteria = [];
dirOutput = dir(fullfile(ResDir,'ExcludedBacteria.txt'));
if size(dirOutput,1)
    ExcludedBacteria = load(fullfile(ResDir,'ExcludedBacteria.txt'));
end

%% getting the bactria to filter from the user
if ~exist('FilterBact', 'var')
%%  Loading the timeAxis file  
    TimeAxis = 0;    
    load(fullfile(ResDir, 'TimeAxis'));
    FileNum  = length(TimeAxis);

%%  if the cleaned image is still saved, reads it from the file instead of
  % cleaning it (which takes a lot of time)
    tmpClnImgDir = dir(fullfile(DirName, 'tmpCleanImg'));
    tmpClnImgExist = size(tmpClnImgDir,1);
    if tmpClnImgExist
        FullPName = fullfile(DirName, 'tmpCleanImg', tmpClnImgDir(FileNum).name);
        clnImg = double(imread(FullPName))/255;
    else
        FullPName = fullfile(DirName,'Pictures',PName);
        I = rgb2gray(double(imread(FullPName))/(255));
        clnImg = cleanImg(I);
    end

%%  showing the picture and the results
    figure; imshow(clnImg);
    ShowPlate(TimeAxis(FileNum),DirName,0);

%%  selecting the bacteria to exclude
    disp('already Excluded bactria:');
    disp(ExcludedBacteria);
    selectedBacteria = input('insert a bacteria number to exclude (end=-1) :');
    while (selectedBacteria ~= -1)
        ExcludedBacteria = union(ExcludedBacteria, selectedBacteria);
        selectedBacteria = input('insert a bacteria number to exclude (end=-1) :');
    end
    
%%  Taking out of the excluded bacteria list
    disp('Excluded bactria:');
    disp(ExcludedBacteria);
    selectedBacteria = input('Bactria you want to take out of exclution list (end=-1) :');
    while (selectedBacteria ~= -1)
        ExcludedBacteria = setdiff(ExcludedBacteria, selectedBacteria);
        selectedBacteria = input('Bactria you want to take out of exclution list (end=-1) :');
    end
else
    if (excludeFlag)
        ExcludedBacteria = union(ExcludedBacteria, FilterBact);
    else
        ExcludedBacteria = setdiff(ExcludedBacteria, FilterBact);
    end
end

%% writing the excluded bacteria to a file
disp('Excluded bacteria:');
disp(ExcludedBacteria);
WriteFilterBacteria(DirName, ExcludedBacteria);
