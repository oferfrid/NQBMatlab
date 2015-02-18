function PlotPlate(TimeGap, DirName, BW, forMovie,handle,limits)
    if nargin < 2
        DirName = uigetdir;
        if isequal(DirName,0)
            return;
        end
    end

    if nargin < 3
        BW = true;
    end

    if nargin < 4
        forMovie = false;
    end

    if nargin<5
        handle=gca;
    end

    if nargin <6
        limits=[0 1];
    end
    
    dataFileStr=GetDataName(DirName);
    data=load(dataFileStr);
    
    % Get File name by time
    times=data.FilesDateTime;
    idx=find(times<=TimeGap,1,'last');
    filesName=data.FilesName;
    fileName=filesName{idx};
    
    % Get title
    size(data.Centroid)
    coloniesNumber=size(data.Centroid,2);
    title=GetTitle(times(idx)-times(1),coloniesNumber,data.Description);
    
    % Get background
    bg=imread(fullfile(DirName,filesName{1}));
    
    PlotPlateByData(DirName,fileName,BW,title,forMovie,limits,handle,bg);
end