function PlotPlateAnalysis(TimeGap, DirName, ForMovie,Handle,Lrgb)
    
    if nargin < 2
        DirName = uigetdir;
        if isequal(DirName,0)
            return;
        end
    end
     
    if nargin < 3
        ForMovie=0;
    end
    
    if nargin < 4
        Handle=gca;
    end
    
    if nargin < 5
        Lrgb=[];
    end

    % Load data file
    dataFileStr=GetDataName(DirName);
    data=load(dataFileStr);
    
    % Convert time gap to file name
    times=data.FilesDateTime;
    idx=find(times<=TimeGap,1,'last');
    filesName=data.FilesName;
    fileName=filesName{idx};
    
    % Get  processing data
    th=data.TH;
    limits=data.Limits;
    
    % Get background
    bg=imread(fullfile(DirName,filesName{1}));
    
    % Get mask
    [r c]=size(bg);
    relevantArea=GetMask(data,r,c);
    
    % Get Lrgb
    if isempty(Lrgb)
        image=imread(fullfile(DirName,fileName));
        Lrgb=image2Lrgb(image,bg,limits,th,relevantArea);
    end
    
    % Get title
    coloniesNumber=size(data.Centroid,2);
    title=GetTitle(times(idx)-times(1),coloniesNumber,data.Description);

    PlotPlateAnalysisByData(DirName,fileName,Handle,limits,th,...
                            bg,relevantArea,Lrgb,title,ForMovie);
end

