function F = makeQuickMovie(DirName, Step, First, Last)
%%
% F = makeQuickMovie(DirName)
% -------------------------------------------------------------------------
% Purpose: making a movie of all the TimeLapse frames
% Description: going over all the pictures in the directory, showing them
%       with the colonis found on it.
% Arguments: DirName (optional) - the dirctory of the pictures
% Returns: F - a structure of all the frames
%          Step - take each Step frame
%          First - first frame
%          Last - Last Frame
% -------------------------------------------------------------------------
% Irit Levin, 01.2013

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

if (nargin == 0 || nargin == 1)
    Step = 1;
    First = 1;
    Last = length(FileVec);
end

if (nargin == 2)
    First = 1;
    Last = length(FileVec);
end

%% capturing each frame after ShowPlate
aviobj = avifile(fullfile(DirName, 'Results', 'QuickMovie.avi'));
for k = First:Step:Last
    figure;
    FileName = char(FileVec(k));
    Img      = imread(fullfile(DirName,'Pictures',FileName));
    GrayImg  = rgb2gray(Img(:,:,1:3));
    smallImg = imresize(GrayImg, 0.5);
    imshow(smallImg);
    F        = getframe(gcf);
    aviobj   = addframe(aviobj,F);
    close;
end
aviobj = close(aviobj);
%% showing and saving the movie
% movie(F,1);
% movie2avi(F,fullfile(DirName, 'Results', 'PlateMovie.avi'), 'fps', 8);
% % movie2avi(F,fullfile(DirName, 'Results', 'PlateMovie.avi'),...
% %     'compression','None' , 'fps', 8);
fclose('all');
