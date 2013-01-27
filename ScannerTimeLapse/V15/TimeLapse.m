function TimeLapse(DirName, Description ,  ProcessLastOnly  )
%% TimeLapse(DirName, Description)
% -----------------------------------------------------------------------
% Purpose: The function traces the canges in time of the colonies
%
% Description: The function creates a relevant circle if doesn't exist. 
%          It calls PreparePictures that creates the connected component
%          picture and the clean image.
%          It calls FindColoniesInTime that matches the components between
%          frames. It creates a movie out af all the frames, and plots a
%          graph of the growth of the colonie on the end.
%
% Arguments: DirName(optional) - Name of directory.
%          Description(optional) - A description of the experiment
%          ProcessLastOnly - process only the last image.
%
% Input files: 'P#_00000.tif' - the pictures.
% Output files: 'L#_00000.mat' - The connected components picture 
%           for each time step.
%          CircParams.mat - [x,y,r] coordinates of the centre of the plate,
%            and the radius.
%          VecArea.mat
%          VecBBox.mat
%          TimeAxis.mat
%          ordColour.mat - the colour of the colonies in the last frame
%          LogFile.txt - includes version, description, time
%          ExcludedBacteria.txt
% -----------------------------------------------------------------------
% Irit Levin, 8.2006
% updates:
% Irit Levin, 20.01.2008
%   1) Entring a full path instead of relative path (..\scans\dir)
%   2) seperating the processing of the pictures and the matching of the
%      colonies in time, into 2 functions.
% -----------------------------------------------------------------------

%% constatnts
ConfigurationFile;
VER = 1.5;  % version
r = 436;    % the relevant radius in the plate in pixels
x = 526; y=526;

%% getting the list of the files
if nargin == 1
    Description = '';
    ProcessLastOnly = 0;
end
if nargin == 0
    Description = '';
    DirName = uigetdir;
    if isequal(DirName,0)
        return;
    end
    ProcessLastOnly = 0;
end

%% getting the relevant area in the picture, unless a file already exists
% with the circle parameters
[successMK,mgsMK,msgidMK] = mkdir(DirName,'Results');
if ~successMK
    error(msgidMK, mgsMK);
end
CircFile  = dir(fullfile(DirName,'Results','CircParams.mat'));
CircExist = size(CircFile,1);
if CircExist
    load(fullfile(DirName,'Results','CircParams'));
else
    save(fullfile(DirName,'Results','CircParams'),'x','y','r');
end

%% creating the Excluded Bacteria file
fid = fopen(fullfile(DirName,'Results','ExcludedBacteria.txt'), 'w');
fclose(fid);

%% writing to a log file
logFile = fullfile(DirName,'Results','LogFile.txt');
logMsg = sprintf('TimeLapse version %2.2f \n\n%s\n', VER, Description);
writeLog(logFile, logMsg);

disp('-----------------------------------------------------------------');
disp([datestr(now), ' ', DirName, ' ', Description])

%% preparing the frames by saving the connected components
writeLog(logFile, 'preparing pictures');
disp('-----------------------------------------------------------------');
disp('PREPARING PICTURES');
ProcessPictures(DirName,ProcessLastOnly);

%% finding the colonies in all the files, in the same area
writeLog(logFile, 'matching colonies in time');
disp('-----------------------------------------------------------------');
disp('MATCHING THE COLONIES IN TIME');
FindColoniesInTime(DirName,ProcessLastOnly);

%% making a movie of the growth
% writeLog(logFile, 'making movie');
% disp('-----------------------------------------------------------------');
% disp('MAKING MOVIE');
% makePlateMovie(DirName);

%% Ploting the growth of the colonies
%ShowAreaGraph(DirName);

writeLog(logFile, '');
fclose('all');
