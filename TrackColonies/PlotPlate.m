function PlotPlate(TimeGap, DirName, BW, forMovie,handle,limits)
% PlotPlate(TimeGap, DirName, BW, forMovie,handle,limits)
% Plotting the plate image of current time.
% arguments:
%       TimeGap - the current time we are looking at
%       DirName - plates directory
%       BW      - color or grayscale mode
%       for movie - for movie or not
%       handle - the gui handle we are plotting in
%       limits - stretching limits
% Nir Dick 2015

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
    times=GetTimes(data);
    idx=find(times<=TimeGap,1,'last');
    filesName=data.FilesName;
    fileName=filesName{idx};
    
    % Get title
    size(data.Centroid)
    coloniesNumber=size(data.Centroid,2);
    title=GetTitle(times(idx)-times(1),coloniesNumber,data.Description);
    
    % Get background
    bgname=filesName{1};
    bg=imread(fullfile(DirName,bgname));
    
    if BW
        limits=data.Limits;
    end
    
    PlotPlateByData(DirName,bgname,BW,title,forMovie,limits,handle,bg);
    hold on;
    PlotPlateByData(DirName,fileName,BW,title,forMovie,limits,handle,bg);
    hold off;
end
