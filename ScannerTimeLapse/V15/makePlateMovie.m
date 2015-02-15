function F = makePlateMovie(DirName)
%%
% F = makePlateMovie(DirName)
% -------------------------------------------------------------------------
% Purpose: making a movie of all the TimeLapse frames
% Description: going over all the pictures in the directory, showing them
%       with the colonis found on it.
% Arguments: DirName (optional) - the dirctory of the pictures
% Returns: F - a structure of all the frames
% -------------------------------------------------------------------------
% Irit Levin, 01.2008

%% getting the directory name if it wasn't specified
if nargin == 0
    DirName = uigetdir;
    if isequal(DirName,0)
        error('No dirctory name was entered');
    end
end

%% getting a list of the files
dirOutput = dir(fullfile(DirName, 'Pictures', '*.tif'));
FileVec = {dirOutput.name}';

%% capturing each frame after ShowPlate
NumOfPics = length(FileVec);
% aviobj = avifile(fullfile(DirName, 'Results', 'PlateMovie.avi'));
writerObj = VideoWriter(fullfile(DirName, 'Results', 'PlateMovie.mp4'),'MPEG-4');
writerObj.FrameRate = 10;
open(writerObj);
for k = 1: NumOfPics
    fig  = figure;
    hndl = gca;
    msg      = sprintf('make movie: picture %d/%d', k, NumOfPics);
    disp(msg);
    FileName = char(FileVec(k));
    TimeGap  = str2num(FileName(4:8));
%     F        = ShowPlate(TimeGap, DirName, 1);
    ShowPlate(TimeGap, DirName, 1,hndl);
    F        = getframe(fig);
    writeVideo(writerObj,F);
%     aviobj   = addframe(aviobj,F);
    fclose('all');
    close;
end
close(writerObj);


%% showing and saving the movie
% movie(F,1);
% movie2avi(F,fullfile(DirName, 'Results', 'PlateMovie.avi'), 'fps', 8);
% % movie2avi(F,fullfile(DirName, 'Results', 'PlateMovie.avi'),...
% %     'compression','None' , 'fps', 8);
fclose('all');
