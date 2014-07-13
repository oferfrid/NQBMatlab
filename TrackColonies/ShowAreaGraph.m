function ShowAreaGraph(XScaleHr,handle,...
                       IrrelevantColonies,Area,Time,Colores,Description)
    %% arguments
    if nargin<2
        XScaleHr = 0;
    end

    if (nargin<3)
        handle=gca;
    end
    
    %% Prepare data for plotting
    % Remove iirelevant colonies (close to border or excluded)
    irrelevantColonies=find(IrrelevantColonies);
    Area(irrelevantColonies,:)=0;
    
    coloniesNum=size(Area,1);
    
    mark = repmat({'none'},coloniesNum,1);
    MarkerFC = repmat('r',coloniesNum,1);

    mark(irrelevantColonies) = {'o'};
    MarkerFC(irrelevantColonies) = 'k';

    %% displaying the data on a graph
    % figure;

    if XScaleHr
        scl = 60;
        sclUnits = '(hr)';
    else
        scl = 1;
        sclUnits = '(min)';
    end

    for k=1:coloniesNum
        plot(handle,Time/scl ,Area(k,:),...
            'Color' ,Colores(k,:), 'Marker' ,char(mark(k)), ...
            'MarkerSize', 2, 'MarkerEdgeColor', MarkerFC(k),...
            'XdataSource','Time','YdataSource',...
            ['Area(',num2str(k),',:)'],'Tag',strcat('colony',num2str(k)));
        hold on;
    end

    title(handle,['The area of each colony as a function of the time - ',...
                 Description]);
    xlabel(handle,['Time ' sclUnits]);
    ylabel(handle,'Area (pixels)');
    hold off;
    

end

