function MakePlateMovie(DirName,MovieName)
% function MakePlateMovie(DirName,MovieName)
% Creating movie with name MovieName from the images
% in the directory DirName.

    if nargin == 0
        DirName = uigetdir;
        if isequal(DirName,0)
            error('No dirctory name was entered');
        end
    end
    
    if nargin < 2
        MovieName='PlateMovie';
    end
    
    dataFileStr=GetDataName(DirName);
    data=load(dataFileStr);
    filesDates=data.FilesDateTime;

    % Capturing the names after showing the plate's analysis
    numOfPics = length(filesDates);
    writerObj = VideoWriter(fullfile(DirName,[MovieName '.mp4']));
    writerObj.FrameRate = 10;
    open(writerObj)
    
    Lrgb = GetPlateLrgb(DirName);
    for k=1:numOfPics
        fig  = figure;
        handle = gca;
        ShowPlate(filesDates(k),DirName,1,handle,Lrgb);
        F=getFrame(fig);
        writeVideo(writerObj,F);
        close;
    end
    close(writerObj);
    fclose('all');
end

