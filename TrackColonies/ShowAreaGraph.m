function ShowAreaGraph(DirName,handle,XScaleHr)
% function ShowAreaGraphByData(XScaleHr,handle,...
%                       IgnoredColonies,Area,Times,Colors,Description)
%
% Show the area graph using data sent as arguments.
% XScaleHr -  
% handle -handle to plot in
% IgnoredColonies - Colonies status
% Area - colonies area data
% Times - time axis
% Colors - colors data
% Description - string
    if nargin < 1
        DirName = uigetdir;
        if isequal(DirName,0)
            return;
        end
    end

    if nargin<2
        handle=gca;
    end
    
    if nargin<3
        XScaleHr=0;
    end
    
    dataFileStr=GetDataName(DirName);
    data=load(dataFileStr);
    
    % Get File name by time
    times=GetTimes(data);
    
    Lrgb=GetPlateLrgb(DirName);
    
    VecCen=data.Centroid;
    NColonies=size(VecCen,2);
    for j=1:NColonies
        % find first center mass
        CurrVecCenX=VecCen(:,j,1);
        appIdx=find(CurrVecCenX~=0,1,'first');
        centerX=VecCen(appIdx,j,1);
        centerY=VecCen(appIdx,j,2);
        % Get current first center
        Colors(j,:)=Lrgb(round(centerY),round(centerX),:);
    end
    
    % Show  area
    ShowAreaGraphByData(XScaleHr,handle,...
                       data.IgnoredColonies,data.Area,times,...
                       Colors,data.Description)
end