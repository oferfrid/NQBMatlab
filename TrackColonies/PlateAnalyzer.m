function PlateAnalyzer(FileDir,LogFile,StartTime)
    global state;
    
    % Close previous opened screen
    close(findobj('name', 'ScanLagAPP'));
    
    %% Load data and relevant images
    DATA_FILE_NAME='data.mat';
    
    if nargin<2
        LogFile=fullfile(FileDir,'LogFile.txt');
    end

    if nargin<3
        fid = fopen(LogFile);
        firstLine=fgets(fid);
        fclose(fid);

        % get the time from the first line
        [startIndex,endIndex] = regexpi(firstLine,...
                                        '\d\d\d\d/\d\d/\d\d \d\d:\d\d:\d\d');
        StartTime=firstLine(startIndex:endIndex);
    end

    StartTime=datenum(StartTime,'yyyy/mm/dd HH:MM:SS');
    
    % Load data and create time axis
    dataFileStr=fullfile(FileDir,DATA_FILE_NAME);
    data=load(dataFileStr);
    times=cell2mat(data.FilesProp(:,2));
    times=(times-StartTime);
    min=1;
    max=length(times);
    state.time=times(max);
    sliderStep = [1, 1]/(max-min);

    % find current icons directory

    [cdir cname ctype]=fileparts(mfilename('fullpath'));
    
    % Load background
    FilesProp=data.FilesProp;
    firstImageName=FilesProp{1,1};
    firstImageStr=fullfile(FileDir,firstImageName);
    background=imread(firstImageStr);    
    
    % Load relevant area's mask todo: is that needed?
    numberOfColonies=length(FilesProp);
    [rows, cols, ~]=size(background);
    relevantArea=GetMask(data,rows,cols);
    
    % Determine stretching limits using last image
    lastImageName=FilesProp{numberOfColonies,1};
    lastImageStr=fullfile(FileDir,lastImageName);
    lastImage=imread(lastImageStr);
    clnLastImg=cleanImage(lastImage,background);
  
   % Calculate limits using last image
    state.limitsBW=stretchlim(clnLastImg(relevantArea>0));
    state.limitsC=stretchlim(lastImage);
    
    % Calculating colores or the area graph
    colores=jet(numberOfColonies);
    indicesS=randperm(numberOfColonies);
    colores=colores(indicesS,:);
    
     FilesName=FilesProp(:,1);
     description='';
   
    state.bw=0;
    state.numbers=1;
    state.pic=1;
    
    %% Create gui
    h.fig=figure('units','pixels',...
                  'position',[50 50 1150 655],...
                  'name','ScanLagAPP',...
                  'resize','off');
    figcolor=get(h.fig,'color');  
    h.picax = axes('units','pixels',...
                'position',[50 70 500 500],...
                'fontsize',8,...
                'nextplot','add','Tag','PICAX',...
                'xlim',[0 1051],'ylim',[0 1051]);

    h.graphax = axes('units','pixels',...
                     'position',[600 70 500 500],...
                     'fontsize',8,...
                     'nextplot','add','Tag','GRAPHAX');

    set(h.fig,'KeyPressFcn',@(src,e)KeyPressFcn(src,e,h,FileDir,times));


    h.worktxt = uicontrol('style','text','units','pixels',...
                          'position',[500,600,50,20],'string','working!',...
                          'Tag','workingtxt','ForegroundColor','r',...
                          'Visible','off','BackgroundColor',figcolor);

    h.sl = uicontrol('style','slide',...
                     'unit','pix',...
                     'position',[50 20 500 30],...
                     'min',min,'max',max,'val',max,...
                     'SliderStep',sliderStep);                                  
    set(h.sl,'Callback',@(ObjH, EventData)sliderCallBack...
                             (ObjH, EventData, times,FileDir,h,...
                              FilesName,times,background,description,...
                              data.Centroid,data.ColoniesStatus));
    addlistener(h.sl,'ContinuousValueChange',@(ObjH, EventData) sliderChange...
                                               (ObjH, EventData, times,...
                                                FileDir,h,...
                                                FilesName,times,...
                                                background,description,...
                                                data.Centroid,data.ColoniesStatus));

    h.edc = uicontrol('style','text','unit','pix','position',[10 620 100 20],...
                     'fontsize',10,'String','Find colony no.',...
                     'backgroundcolor',figcolor);

    h.ed = uicontrol('style','edit','unit','pix','position',[110 620 60 20],...
                     'fontsize',10);           

    [icon map]=imread(strcat(cdir,'\Icons\Search.png'));

    h.search= uicontrol('style','pushbutton',...
                     'unit','pix',...
                     'position',[180 620 20 20],...
                     'CData',icon,'Callback',@(objH,e)search(objH,e,h));  

    % Create tool bar
    buildToolBar(h,FileDir,times,cdir,data,colores,background,...
                description,FilesName);  

    % Sohw graph
    initAreaGraph(h,FileDir,0,data,times,colores);

    % Show pic
    initPics(times(1),h.picax,FileDir,FilesName,times,...
             state.limitsBW,background,description);
         
    handleTimeChange(times,FileDir,h,FilesName,times,...
                     background,description,data.Centroid,data.ColoniesStatus);
end

%% function buildToolBar(handles,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: Build the toolbar for the ScanLagApp 
%
% Arguments: handles - The set of gui handles
%            FileDir - the results file directory
%            times - vector of times
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function buildToolBar(handles,FileDir,times,dir,data,colores,background,...
                      description,filesname)
    set(handles.fig,'toolbar','figure');
    
    % Remove unwanted icons
    
    b = findall(handles.fig,'ToolTipString','Edit Plot');
    set(b,'Visible','Off');
    
    % Add icons to the toolbar
    
    ht = uitoolbar(handles.fig);
    [icon map]=imread(strcat(dir,'\Icons\NumbersIn.png'));
    numbersh = uipushtool('Parent',ht,'CData',icon,'Tag','NumbersIn');
    
    [icon map]=imread(strcat(dir,'\Icons\Analysis.png'));
    analysish = uipushtool('Parent',ht,'CData',icon,'Tag','PreviewMenuA',...
                     'TooltipString','Show analysis mode','Separator','on');
                 
    [icon map]=imread(strcat(dir,'\Icons\Picture.png'));
    pictureh = uipushtool('Parent',ht,'CData',icon,'Tag','PreviewMenuP',...
                     'TooltipString','Show picture mode');
                 
    [icon map]=imread(strcat(dir,'\Icons\BW.png'));
    colorh = uipushtool('Parent',ht,'CData',icon,'Tag','ColorMenu');
                 
    set(analysish,'ClickedCallback',...
                   @(h,e)analysisClickedCallback(h,e,pictureh,...
                   handles,FileDir,times));
               
    set(pictureh,'ClickedCallback',...
                   @(h,e)pictureClickedCallback(h,e,analysish,...
                   handles,FileDir,times));
               
    set(colorh,'ClickedCallback',...
                   @(h,e)colorClickedCallback(h,e,handles,FileDir,...
                   times,dir,filesname,background,description));
                      
    [icon map]=imread(strcat(dir,'\Icons\Include.png'));
    includeh = uipushtool('Parent',ht,'CData',icon,'Tag','IncludeMenu',...
                          'Separator','on');
   
    [icon map]=imread(strcat(dir,'\Icons\Exclude.png'));
    excludeh = uipushtool('Parent',ht,'CData',icon,'Tag','ExcludeMenu');
    
    set(numbersh,'ClickedCallback',...
                   @(h,e)numbersClickedCallback(h,e,handles,...
                                                times,data.Centroid,...
                                                data.ColoniesStatus));
                                            
    set(excludeh,'ClickedCallback',...
                @(h,e)excludeClickedCallback(h,e,handles,FileDir,...
                data,times,colores));
            
    set(includeh,'ClickedCallback',...
                @(h,e)includeClickedCallback(h,e,handles,FileDir,...
                data,times,colores));
end

% %% function [min, max,times]=getSliderTimeData(FileDir)
% % -------------------------------------------------------------------------
% % Purpose: Get the time data for the silder when building it 
% %
% % Arguments: FileDir - Directory of time axis
% % Outputs: min - the minimum value for the slider
% %          max - the maximum value of the slider
% %          times - the times for the slider
% % -------------------------------------------------------------------------
% % Nir Dick Sept. 2013
% % -------------------------------------------------------------------------
% function [min, max,times]=getSliderTimeData(FileDir,StartTime)
%      TimeAxisDir=fullfile(FileDir, 'Results', 'TimeAxis');
%      load(TimeAxisDir);
%      times=TimeAxis;
%      FileNum  = find(times,1,'last');   
%      min=1;
%      max=FileNum;
% end

%% function initPics(handle,FileDir)
% -------------------------------------------------------------------------
% Purpose: show the first plate image (i.e. black picture with empty plate)
%
% Arguments: startTime - Directory of time axis
%            handle - the first scan time
%            FileDir - Directory of the data files
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function initPics(startTime,handle,FileDir,ImagesName,Times,Limits,...
                  Background,Description)
    h=gca;
    axes(handle);
    
    PlotPlate(FileDir,ImagesName,startTime,Times,1,0,Limits,handle,...
              Background,Description);
               
    initImg=findobj(handle, 'Tag', 'ImageColony');
    if (~isempty(initImg))
        set(initImg,'Tag','ImageColony0');
    end;
    
    if (~isempty(h))
        axes(h);
    end
end

%% function initAreaGraph(handles,FileDir)
% -------------------------------------------------------------------------
% Purpose: Show the area graph
%
% Arguments: handles - Dall the ralevant handles
%            FileDir - the directory of the results
%            keepScaleFlag - an indication if tosave previous scaling or
%            not.
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function initAreaGraph(handles,FileDir,keepScaleFlag,Data,Times,Colores)
    global state;
    if nargin<3
        keepScaleFlag=0;
    end
    h=gca;
    axes(handles.graphax);
    
    prevxlim=get(handles.graphax,'xlim');
    prevylim=get(handles.graphax,'ylim');
    
    ShowAreaGraph(0,gca,Data.ColoniesStatus,Data.Area,Times,Colores,'');
    
    allLines = findobj(handles.graphax,'Type','line');
    
    % Add selection listener to all the lines in the graph
    if (~isempty(allLines))
        set(allLines,'ButtonDownFcn',...
               @(objH, eventH)lineSelected(objH, eventH,handles));

    end;
    
    if (~isempty(prevxlim)&&~isempty(prevylim)&&keepScaleFlag)
        set(handles.graphax,'xlim',prevxlim,'ylim',prevylim);
    end
            
    
    % Go back to current axes
    if (~isempty(h))
        axes(h);
    end;
end

%% function sliderChange(ObjH, EventData, times,FileDir,handles) 
% -------------------------------------------------------------------------
% Purpose: This handler manage the slider's value changing event.
%          (arise when dragging the slider)
%
% Arguments: times - list of all available times 
%            FileDir - the directory of the results
%            handles - the relevant handles
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function sliderChange(ObjH, EventData, times,FileDir,handles,...
                      FilesName,Times,Background,Description,...
                      VecCen,ColoniesStatus) 
    global state;
    set(handles.worktxt,'Visible','on');
    
    % update state's time
    val =round(get(ObjH,'Value'));
    state.time=times(val);
    
    % handle the time change
    handleTimeChange(times,FileDir,handles,FilesName,Times,...
                     Background,Description,VecCen,ColoniesStatus);
    drawnow;
    set(handles.worktxt,'Visible','off');
end

%% function sliderChange(ObjH, EventData, times,FileDir,handles) 
% -------------------------------------------------------------------------
% Purpose: The ButtonDownFcn event handler of the slider
%
% Arguments: times - list of all available times 
%            FileDir - the directory of the results
%            handles - the relevant handles
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function sliderCallBack(ObjH,EventData,times,FileDir,handles,...
                        FilesName,Times,Background,Description,...
                        VecCen,ColoniesStatus)
    global state;
    set(handles.worktxt,'Visible','on');
    
    % update state's time
    val =round(get(ObjH,'Value'));
    state.time=times(val);
    
    handleTimeChange(times,FileDir,handles,FilesName,Times,...
                     Background,Description,VecCen,ColoniesStatus);
    set(handles.worktxt,'Visible','off');
end

%% function handleTimeChange(times,FileDir,handles)
% -------------------------------------------------------------------------
% Purpose: This function should be called when the time was changed in the
% slider. The method get the current state and change the gui according to
% it.
%
% Arguments: times - list of all available times 
%            FileDir - the directory of the results
%            handles - the relevant handles
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function handleTimeChange(times,FileDir,handles,FilesName,Times,...
                          Background,Description,VecCen,ColoniesStatus)
    % Get the current state 
    state=getState(handles,times);
    previewOption=state.pic;
    numberingFlag=state.numbers;
    time=state.time;
    
    % Move the time line to the new state
    updateAreaGraphCurrLine(time,handles.graphax);
    
    % Get selected colony (in order to keep the selected one on the screen)
    selNumStr=getSelectedColonyByLine(handles.graphax);
    
    axes(handles.picax);
    
    % Change the picture according to the state
    handlePlatePlot(handles,time,FileDir,state,FilesName,Times,...
                    Background,Description);
                
    
    % delete old numbering
    deleteNumbersText(handles);
  
    if (numberingFlag)
        % Print new numbering
        handleNumbersPlot(time,selNumStr,VecCen,ColoniesStatus,Times,handles);
    end
   
     fclose('all');
end

%% function updateAreaGraphCurrLine(time,graphAxes)
% -------------------------------------------------------------------------
% Purpose: This function update the position of the time line of the area
% graph.
%
% Arguments: time - current time
%            graphAxes - the graph axes
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function updateAreaGraphCurrLine(time,graphAxes)
    currLine = findobj(graphAxes, 'Tag', 'AreaCurrTimeLine');
    if (~isempty(currLine))
        delete(currLine);
    end;
    m=get(graphAxes,'YLim');
    hold(graphAxes,'on');
    pH=plot(graphAxes,[time,time],[m(1,1),m(1,2)],':k');
    hold(graphAxes,'off');
    set(pH,'Tag','AreaCurrTimeLine');
end

%% handleColonySelection(colonyNumber, graphH,picH)
% -------------------------------------------------------------------------
% Purpose: This function handles the event of selecting some colony number
%
% Arguments: colonyNumber - the selected colony number
%            graphH       - the graph axes
%            picH         - the picture handler
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function handleColonySelection(colonyNumber, graphH,picH)
    downplayPrevText(picH);
    highlightTextByNum(num2str(colonyNumber),picH);
    selectLine(num2str(colonyNumber),graphH);
end

%% selectLine(colonyNumberStr,graphH)
% -------------------------------------------------------------------------
% Purpose: Select wanted line (of wanted colony) in the area graph
%
% Arguments: colonyNumberStr - the colony's number
%            graphH       - the graph axes
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function selectLine(colonyNumberStr,graphH)
    set (graphH,'Selected','off');
    prevLine = findobj(graphH,'Selected','on');
    currLine = findobj(graphH,'Tag',strcat('colony',colonyNumberStr));
    if (~isempty(currLine))
            if (~isempty(prevLine))
                set(prevLine,'Selected','off','LineWidth',1);
            end;
        set(currLine,'Selected','on','LineWidth', 5);
    end;
    uistack(currLine,'top');
end

%% function lineSelected(objH,eventH,handles)
% -------------------------------------------------------------------------
% Purpose: The handler of the the line selection event in the area graph
%
% Arguments: handles - relevant handles of the graph
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function lineSelected(objH,eventH,handles)
    tag=get(objH,'Tag');
    cNumStr=tag(7:end);
    
    downplayPrevText(handles.picax);
    highlightTextByNum(cNumStr,handles.picax);
    selectLine(cNumStr,handles.graphax);
end

%% function highlightTextByNum(cNumStr,picH)
% -------------------------------------------------------------------------
% Purpose: Sign in gui that sent colony is selected.
%
% Arguments: cNumStr - the colony's number
%            picH - the pictures axes.
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function highlightTextByNum(cNumStr,picH)
    currText=findobj(picH,'Type','text','String',cNumStr);
    
    if (~isempty(currText))
        highlightText(currText);
    end;
end

%% function highlightText(textH)
% -------------------------------------------------------------------------
% Purpose: Highlight text. current - a white square around the text
%
% Arguments: textH - the text to highlight
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function highlightText(textH)
    set(textH,'EdgeColor','white');
end

%% function downplayText(textH))
% -------------------------------------------------------------------------
% Purpose: cancel text highlighting
%
% Arguments: textH
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function downplayText(textH)
    set(textH,'EdgeColor','none');
end

%% function downplayPrevText(picH)
% -------------------------------------------------------------------------
% Purpose: cancel previous selected colony's highlighting (without knowing
% what colony actually was selected.
%
% Arguments: picH - picture axes
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function downplayPrevText(picH)
    prevText=findobj(picH,'Type','text','EdgeColor','white');
    
    if (~isempty(prevText))
        downplayText(prevText);
    end;
end

%% function getSelectedColonyByLine(handle)
% -------------------------------------------------------------------------
% Purpose: Get the selected colony's number by the area graph.
%
% Arguments: handle - graph axes
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function [selNumStr]=getSelectedColonyByLine(handle)
    selNumStr='none';
    selectedLine=findobj(handle,'Type','line','Selected','on');
    if (~isempty(selectedLine))
        tag=get(selectedLine,'Tag');
        selNumStr=tag(7:end);
    end
end

%% function updatePlotPlate(times,FileDir,handles)
% -------------------------------------------------------------------------
% Purpose: Update the plate plotting by current state
%
% Arguments: times - times vec
%            FileDir - the file directory
%            handles - the handles of the gui
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function updatePlotPlate(times,FileDir,handles,FilesName,Times,...
                         Background,Description)
    state=getState(handles,times);
    val =round(get(handles.sl,'Value'));
    time=times(val);
    handlePlatePlot(handles,time,FileDir,state,FilesName,Times,...
                    Background,Description);
                
    textsNumH=findobj(handles.picax,'Type','text');
    
    % Since we didnt change the numbering, but plotted a new image,
    % we need to move the numbers above the image
    uistack(textsNumH,'top');
end

%% function textNumberSelected(objH, eventH,graphH,FileDir)
% -------------------------------------------------------------------------
% Purpose: the handler of selecting a number in the picture
%
% Arguments: graphH - graph axes
%            FileDir - the data directory
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function textNumberSelected(objH, eventH,graphH)
    selectionType=get(gcbf,'SelectionType');
    colonyNumber=str2num(get(objH,'String'));
    switch selectionType
        case 'open'
            % nothing for double click
        case 'normal',
            picH=get(objH,'Parent');
            handleColonySelection(colonyNumber,graphH,picH); 
    end 
end

%% function deleteNumbersText(handles)
% -------------------------------------------------------------------------
% Purpose: clean all numbers text
%
% Arguments: handles - the handles of the gui
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function deleteNumbersText(handles)
    axesHandlesToChildObjects = findobj(handles.picax, 'Type', 'text');
    if ~isempty(axesHandlesToChildObjects)
        delete(axesHandlesToChildObjects);
    end
end

%% function handlePlatePlot(handles,time,FileDir,state)
% -------------------------------------------------------------------------
% Purpose: Update the plate plotted by current state
%
% Arguments: time - wanted time
%            FileDir - the file directory
%            handles - the handles of the gui
%            state - the current state of the program
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function handlePlatePlot(handles,time,FileDir,state,FilesName,Times,...
                         Background,Description)
    
    % Delete current picture
    axesHandlesToChildObjects=findobj(...
                    handles.picax, 'Tag', 'ImageColony');
    
    if (~isempty(axesHandlesToChildObjects))
        delete(axesHandlesToChildObjects);
    end;
    
    % Check the state for what picture option the user want
    if (state.pic==0)
        % Plot analysis
        PlotPlateAnalysis(time, FileDir, 0,handles.picax);
    elseif (state.pic==1)
       % Plot picture
       if state.bw
           limits=state.limitsBW;
       else 
           limits=state.limitsC;
       end
       
       PlotPlate(FileDir,FilesName, time, Times, state.bw, 0,...
                     limits,handles.picax,Background,Description);
    end;
end

%% function handleNumbersPlot(time,handles,FileDir,selNumStr)
% -------------------------------------------------------------------------
% Purpose: Handle the plotting of the numbers
%
% Arguments: time - wanted time
%            FileDir - the file directory
%            handles - the handles of the gui
%            selNumStr - selected colony's number
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function handleNumbersPlot(time,selNumStr,VecCen,ColoniesStatus,Times,handles)
    % Plot the numbers for current time
    PlotPlateColoniesNumbers(time,VecCen,ColoniesStatus,Times,0);
                              
    % Set the handler for selection event for each number
    textNumbers = findobj(handles.picax, 'Type', 'text');

    if (~isempty(textNumbers))
        colonyNum = size(textNumbers,1);
        
        set(textNumbers,'ButtonDownFcn',...
                  @(objH, eventH)textNumberSelected(...
                            objH, eventH,handles.graphax));
        
        % Highlight the selected
        selected=findobj(handles.picax, 'Type', 'text','String',selNumStr);
        if (~isempty(selected))
            highlightText(selected);
        end
    end
end

%% function analysisClickedCallback(h,e,oldH,handles,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: Handle the choosing of the show analysis event
%
% Arguments: times - time axis
%            FileDir - the file directory
%            handles - the handles of the gui 
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function analysisClickedCallback(h,e,oldH,handles,FileDir,times)
    global state;
    state.pic=0;
    updatePlotPlate(times,FileDir,handles);
    colorH=findobj('Tag','ColorMenu');
    
    % disable the BW/COLOR button (since it's relevant to picture option
    % only)
    set(colorH,'Enable','off');
end

%% function pictureClickedCallback(h,e,oldH,handles,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: Handle the choosing of the show picture event
%
% Arguments: times - time axis
%            FileDir - the file directory
%            handles - the handles of the gui 
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function pictureClickedCallback(h,e,oldH,handles,FileDir,times)
    global state;
    state.pic=1;
    updatePlotPlate(times,FileDir,handles);
    colorH=findobj('Tag','ColorMenu');
    set(colorH,'Enable','on');
end

%% function numbersClickedCallback(h,e,handles,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: Handle the showing and hiding of numbers
%
% Arguments: times - time axis
%            FileDir - the file directory
%            handles - the handles of the gui 
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function numbersClickedCallback(h,e,handles,Times,...
                                VecCen,ColoniesStatus)
    global state;
    set(handles.worktxt,'Visible','on');
    
    % change the wanted state
    state.numbers=1-state.numbers;
    
    % Sow numbwes option
    if (state.numbers)
        selNumStr=getSelectedColonyByLine(handles.graphax);
        axes(handles.picax);
        handleNumbersPlot(state.time,selNumStr,VecCen,ColoniesStatus,...
                          Times,handles);
    % Hide numbers option
    else
        deleteNumbersText(handles);
    end

    set(handles.worktxt,'Visible','off');    
end

%% function colorClickedCallback(h,e,handles,FileDir,times,iconsdir)
% -------------------------------------------------------------------------
% Purpose: Handle the choosing of BW/Color option whan showing the picture
%
% Arguments: times - time axis
%            FileDir - the file directory
%            handles - the handles of the gui 
%            iconsdir - directory of icons
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function colorClickedCallback(h,e,handles,FileDir,times,iconsdir,...
                              FilesName,Background,Description)
    global state;
    set(handles.worktxt,'Visible','on');
    
    state.bw=1-state.bw;
    
    % switch between icons
    if (state.bw)
       [icon map]=imread(strcat(iconsdir,'\Icons\Color.png'));
    else
       [icon map]=imread(strcat(iconsdir,'\Icons\BW.png'));
    end
    set(h,'CDATA',icon);
    
    % Update picture
    updatePlotPlate(times,FileDir,handles,FilesName,times,...
                         Background,Description);
                     
    set(handles.worktxt,'Visible','off'); 
end

%% function getState(handles,times)
% -------------------------------------------------------------------------
% Purpose: This function build a state data structure representing the
% wanted state of the system. the state contains the current time, the
% picture / analysis preview option and, the BW / Color options for the
% picture preview and the hide/show flag of the numbering.
%
% Arguments: times - time axis
%            handles - the handles of the gui 
%
% Return: The state struct
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function [state1]=getState(handles,times)
    global state;
    state1=state;
end

%% function search(objH,e,handles)
% -------------------------------------------------------------------------
% Purpose: This is the searching event handler
%
% Arguments: handles - the handles of the gui 
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function search(objH,e,handles)
    % Get the searched "colony" 
    str=get(handles.ed,'string');
    [colonyNumber,status]=str2num(str);
    % if the text is a number, search for the colony with that number
    if (status)
        colonyflag=findobj(handles.picax,'Type','text','string',str);
        if (size(colonyflag,1)>0)
            % Select it
            handleColonySelection(colonyNumber,handles.graphax,handles.picax);
        end
    end
    
    set(handles.ed,'string','');
end

%% function setcolonyTextColor(colonyNumStr,handles,color)
% -------------------------------------------------------------------------
% Purpose: color colony's text in wanted color
%
% Arguments: colonyNumStr - the wanted colony
%            handles - gui handles
%            color - wanted color
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function setcolonyTextColor(colonyNumStr,handles,color)
    colonyTextH=findobj(handles.picax,'Type','text','string',colonyNumStr);
    if (~isempty(colonyTextH))
        set(colonyTextH,'color',color);
    end
end

%% function excludeClickedCallback(h,e,handles,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: The excluding event handler
%
% Arguments: FileDir - data directory
%            handles - gui handles
%            times - time axis
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function excludeClickedCallback(h,e,handles,FileDir,Data,Times,Colores)
    excludeSelected(handles,FileDir,Data,Times,Colores);
end

%% function excludeSelected(handles,FileDir)
% -------------------------------------------------------------------------
% Purpose: exclude selected colony
%
% Arguments: FileDir - data directory
%            handles - gui handles
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function excludeSelected(handles,FileDir,Data,Times,Colores)
    % Get selected colony
    colonyNumber=getSelectedColonyByLine(handles.graphax);
    
    if ~strcmp(colonyNumber,'none')
        % Exclude colony
        Data.ColoniesStatus([str2num(colonyNumber)])=2;

        % Color the number so it will sign that it was excluded
        setcolonyTextColor(num2str(colonyNumber),handles,[1 1 0])

        % update area graph
        initAreaGraph(handles,1,Data,Times,Colores);
        handleColonySelection(str2num(colonyNumber),...
                                          handles.graphax,handles.picax);
                                      
        % Save change to file
        ColoniesStatus=Data.ColoniesStatus;
        save(fullfile(FileDir,'data.mat'),'ColoniesStatus');
    end
end

%% function includeClickedCallback(h,e,handles,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: The including event handler
%
% Arguments: FileDir - data directory
%            handles - gui handles
%            times - time axis
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function includeClickedCallback(h,e,handles,FileDir,Data,Times,Colores)
    includeSelected(handles,FileDir,Data,Times,Colores);
end

%% function includeSelected(handles,FileDir)
% -------------------------------------------------------------------------
% Purpose: include selected colony
%
% Arguments: FileDir - data directory
%            handles - gui handles
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function includeSelected(handles,FileDir,Data,Times,Colores)
    % Get selected colony
    colonyNumber=getSelectedColonyByLine(handles.graphax);
   
    if ~strcmp(colonyNumber,'none')
        % Include colony
        Data.ColoniesStatus([str2num(colonyNumber)])=0;

        % Color the number so it will sign that it was'nt excluded
        setcolonyTextColor(num2str(colonyNumber),handles,[1 1 1])

        % update area graph
        initAreaGraph(handles,FileDir,1,Data,Times,Colores);
        handleColonySelection(str2num(colonyNumber),...
                                          handles.graphax,handles.picax);
        
        % Save change to file
        ColoniesStatus=Data.ColoniesStatus;
        save(fullfile(FileDir,'data.mat'),'ColoniesStatus');
    end
end

%% function KeyPressFcn(src,e,h,FileDir,times)
% -------------------------------------------------------------------------
% Purpose: The figure's key pressed event handler. Here the keyboard
% shortcuts are being defined.
%
% Arguments: FileDir - data directory
%            h - gui handles
%            times - time axis
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function KeyPressFcn(src,e,h,FileDir,times)
    mod=e.Modifier;
    key=e.Key;
    
    % Check for eclude option
    if ((strcmp(key,'e'))&&(size(mod,1)==1)&&(size(mod,2)==1)&&...
         strcmp(mod,'control'))
        excludeSelected(h,FileDir);
    % Check for include option
    elseif ((strcmp(key,'i'))&&(size(mod,1)==1)&&(size(mod,2)==1)&&...
         strcmp(mod,'control'))
        includeSelected(h,FileDir);
    end
    
end

