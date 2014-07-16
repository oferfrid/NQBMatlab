function ShowAreaGraph(XScaleHr,handle,...
                       IgnoredColonies,Area,Time,Colors,Description)             
    %% Prepare data for plotting
    % Remove iirelevant colonies (close to border or excluded)
    relevantColonies=~IgnoredColonies;
    coloniesNum=size(Area,2);

    %% displaying the data on a graph
    % figure;

    if XScaleHr
        scl = 60;
        sclUnits = '(hr)';
    else
        scl = 1;
        sclUnits = '(min)';
    end
    
    % Prepare plotting properties
    colNumStr=strtrim(cellstr(num2str((1:coloniesNum)')));
    allTag=strcat('colony',colNumStr);
    allTag=allTag(relevantColonies);
    XDataSource=cell(length(allTag),1);
    XDataSource(:)={'Time'};
    YDataSource=strcat('Area(',colNumStr,',:)');
    YDataSource=YDataSource(relevantColonies);
    colors=Colors(relevantColonies,:);
    % Plot
    set(0,'DefaultAxesColorOrder',colors);
    p=plot(handle,Time/scl ,Area(:,relevantColonies,:));
    
    % Set tag
    set(p,{'Tag'},allTag);
    set(p,{'XdataSource'},XDataSource);
    set(p,{'YdataSource'},YDataSource);
    
    title(handle,['The area of each colony as a function of the time - ',...
                 Description]);
    xlabel(handle,['Time ' sclUnits]);
    ylabel(handle,'Area (pixels)');
end

