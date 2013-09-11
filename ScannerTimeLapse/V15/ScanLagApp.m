function ScanLagApp(FileDir)
%% function ScanLagApp(FileDir)
% -------------------------------------------------------------------------
% Purpose: Run the gui of the ScanLag
%
% Arguments: FileDir - the base directory of pictures and results
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------

% Close previous opened screen
close(findobj('name', 'ScanLagAPP'));

% find current icons directory
             
[cdir cname ctype]=fileparts(mfilename('fullpath'));

% Create gui
h.fig=figure('units','pixels',...
              'position',[50 50 1150 655],...
              'name','ScanLagAPP',...
              'resize','off');
figcolor=get(h.fig,'color');  
h.picax = axes('units','pixels',...
            'position',[50 70 500 500],...
            'fontsize',8,...
            'nextplot','add','Tag','PICAX','xlim',[0 500],'ylim',[0 500],...
            'ButtonDownFcn',@tryme,'xlim',[0 1051],'ylim',[0 1051]);
        
h.graphax = axes('units','pixels',...
                 'position',[600 70 500 500],...
                 'fontsize',8,...
                 'nextplot','add','Tag','GRAPHAX');
             
[min, max,times]=getSliderTimeData(FileDir);
sliderStep = [1, 1]/(max-min);

                
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
                         (ObjH, EventData, times,FileDir,h));
addlistener(h.sl,'ContinuousValueChange',@(ObjH, EventData) sliderChange...
                                           (ObjH, EventData, times,...
                                            FileDir,h));
                                                                     
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
buildToolBar(h,FileDir,times,cdir);  

% Sohw graph
initAreaGraph(h.graphax,FileDir,h.graphax,h.picax);

% Show pic
initPics(times(1),h.picax,FileDir);
handleTimeChange(times,FileDir,h);

fclose('all');
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
function buildToolBar(handles,FileDir,times,dir)
    set(handles.fig,'toolbar','figure');
    
    b = findall(handles.fig,'ToolTipString','Edit Plot');
    set(b,'Visible','Off');
    
    
    ht = uitoolbar(handles.fig);
    [icon map]=imread(strcat(dir,'\Icons\NumbersIn.png'));
    numbersh = uipushtool('Parent',ht,'CData',icon,'Tag','NumbersIn',...
                          'UserData',1,'Separator','on');
    
    [icon map]=imread(strcat(dir,'\Icons\Analysis.png'));
    analysish = uipushtool('Parent',ht,'CData',icon,'Tag','PreviewMenuA',...
                     'TooltipString','Show analysis mode','Separator','on');
                 
    [icon map]=imread(strcat(dir,'\Icons\Picture.png'));
    pictureh = uipushtool('Parent',ht,'CData',icon,'Tag','PreviewMenuP',...
                     'TooltipString','Show picture mode');
                 
    [icon map]=imread(strcat(dir,'\Icons\BW.png'));
    colorh = uipushtool('Parent',ht,'CData',icon,'Tag','ColorMenu',...
                        'UserData',1);
                 
    set(analysish,'ClickedCallback',...
                   @(h,e)analysisClickedCallback(h,e,pictureh,...
                   handles,FileDir,times));
               
    set(pictureh,'ClickedCallback',...
                   @(h,e)pictureClickedCallback(h,e,analysish,...
                   handles,FileDir,times));
               
    set(colorh,'ClickedCallback',...
                   @(h,e)colorClickedCallback(h,e,handles,FileDir,...
                   times,dir));
                      
    [icon map]=imread(strcat(dir,'\Icons\Include.png'));
    includeh = uipushtool('Parent',ht,'CData',icon,'Tag','IncludeMenu',...
                          'Separator','on');
   
    [icon map]=imread(strcat(dir,'\Icons\Exclude.png'));
    excludeh = uipushtool('Parent',ht,'CData',icon,'Tag','ExcludeMenu');
    
    set(numbersh,'ClickedCallback',...
                   @(h,e)numbersClickedCallback(h,e,handles,...
                                                FileDir,times));
                                            
    set(excludeh,'ClickedCallback',...
                @(h,e)excludeClickedCallback(h,e,handles,FileDir,times));
            
    set(includeh,'ClickedCallback',...
                @(h,e)includeClickedCallback(h,e,handles,FileDir,times));
end

%% function [min, max,times]=getSliderTimeData(FileDir)
% -------------------------------------------------------------------------
% Purpose: Build the toolbar for the ScanLagApp 
%
% Arguments: FileDir - Directory of time axis
% Outputs: min - the minimum value for the slider
%          max - the maximum value of the slider
%          times - the times for the slider
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function [min, max,times]=getSliderTimeData(FileDir)
     TimeAxisDir=fullfile(FileDir, 'Results', 'TimeAxis');
     load(TimeAxisDir);
     times=TimeAxis;
     FileNum  = find(times,1,'last');   
     min=1;
     max=FileNum;
     fclose('all'); 
end

%% function initPics(handle,FileDir)
% -------------------------------------------------------------------------
% Purpose: Build the toolbar for the ScanLagApp 
%
% Arguments: FileDir - Directory of time axis
% -------------------------------------------------------------------------
% Nir Dick Sept. 2013
% -------------------------------------------------------------------------
function initPics(startTime,handle,FileDir)
    h=gca;
    axes(handle);
    
    PlotPlate(startTime, FileDir, 1, 0,handle);
    initImg=findobj(handle, 'Tag', 'ImageColony');
    if (~isempty(initImg))
        set(initImg,'Tag','ImageColony0');
    end;
                
    fclose('all');
    
    if (~isempty(h))
        axes(h);
    end
end

function initAreaGraph(handle,FileDir,graphH,picH)
    h=gca;
    axes(handle);
    ShowAreaGraph(FileDir);
    fclose('all');
    
    allLines = findobj(graphH,'Type','line');
    
    if (~isempty(allLines))
        lineNum = size(allLines,1);
        for i=1:lineNum
            set(allLines(i),'ButtonDownFcn',...
                   @(objH, eventH)lineSelected(objH, eventH,picH,graphH));
        end
    end;
    
    if (~isempty(h))
        axes(h);
    end;
end

function sliderChange(ObjH, EventData, times,FileDir,handles) 
    set(handles.worktxt,'Visible','on');
    handleTimeChange(times,FileDir,handles);
    drawnow;
    set(handles.worktxt,'Visible','off');
end

function sliderCallBack(ObjH, EventData, times,FileDir,handles)
    set(handles.worktxt,'Visible','on');
    handleTimeChange(times,FileDir,handles);
    set(handles.worktxt,'Visible','off');
end

function handleTimeChange(times,FileDir,handles)
    state=getState(handles,times);
    previewOption=state.pic;
    textFlag=state.numbers;
    time=state.time;
    updateAreaGraphCurrLine(time,handles.graphax);
    selNumStr=getSelectedColonyByLine(handles.graphax);
    
    axes(handles.picax);
    
    handlePlatePlot(handles,time,FileDir,state);
    
    deleteNumbersText(handles);
  
    if (textFlag)
        handleNumbersPlot(time,handles,FileDir,selNumStr);
    end
   
    fclose('all');
end

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


function handleColonySelection(colonyNumber, graphH,picH)
    downplayPrevText(picH);
    highlightTextByNum(num2str(colonyNumber),picH);
    selectLine(num2str(colonyNumber),graphH);
end

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
end

function lineSelected(objH,eventH,picH,graphH)
    tag=get(objH,'Tag');
    cNumStr=tag(7:end);
    
    downplayPrevText(picH);
    highlightTextByNum(cNumStr,picH);
    selectLine(cNumStr,graphH);
end

function highlightTextByNum(cNumStr,picH)
    currText=findobj(picH,'Type','text','String',cNumStr);
    
    if (~isempty(currText))
        highlightText(currText);
    end;
end

function highlightText(textH)
    set(textH,'EdgeColor','white');
end

function downplayText(textH)
    set(textH,'EdgeColor','none');
end

function downplayPrevText(picH)
    prevText=findobj(picH,'Type','text','EdgeColor','white');
    
    if (~isempty(prevText))
        downplayText(prevText);
    end;
end


function [selNumStr]=getSelectedColonyByLine(handle)
    selNumStr='none';
    selectedLine=findobj(handle,'Type','line','Selected','on');
    if (~isempty(selectedLine))
        tag=get(selectedLine,'Tag');
        selNumStr=tag(7:end);
    end
end

function updatePlotPlate(times,FileDir,handles)
    state=getState(handles,times);
    val =round(get(handles.sl,'Value'));
    time=times(val);
    handlePlatePlot(handles,time,FileDir,state);
    textsNumH=findobj(handles.picax,'Type','text');
    uistack(textsNumH,'top');
end

function textNumberSelected(objH, eventH,graphH,FileDir)
    selectionType=get(gcbf,'SelectionType');
    colonyNumber=str2num(get(objH,'String'));
    switch selectionType
        case 'open',
           textColor=get(objH,'Color');
           
           if (textColor==[1 1 0])

           else

           end
        case 'normal',
            picH=get(objH,'Parent');
            handleColonySelection(colonyNumber,graphH,picH); 
    end 
end

function deleteNumbersText(handles)
    axesHandlesToChildObjects = findobj(handles.picax, 'Type', 'text');
    if ~isempty(axesHandlesToChildObjects)
        delete(axesHandlesToChildObjects);
    end
end

function handlePlatePlot(handles,time,FileDir,state)
    axesHandlesToChildObjects=findobj(...
                    handles.picax, 'Tag', 'ImageColony');
    
    
    if (~isempty(axesHandlesToChildObjects))
        delete(axesHandlesToChildObjects);
    end;
    
    if (state.pic==0)
        PlotPlateAnalysis(time, FileDir, 0,handles.picax);
    elseif (state.pic==1)
       isBW=state.bw;
       PlotPlate(time, FileDir, isBW, 0,handles.picax);  
    end;
end

function handleNumbersPlot(time,handles,FileDir,selNumStr)
    PlotPlateColoniesNumbers(time, FileDir, 0);

    textNumbers = findobj(handles.picax, 'Type', 'text');

    if (~isempty(textNumbers))
        colonyNum = size(textNumbers,1);
        
        set(textNumbers,'ButtonDownFcn',...
                  @(objH, eventH)textNumberSelected(...
                            objH, eventH,handles.graphax,FileDir));
                        
        selected=findobj(handles.picax, 'Type', 'text','String',selNumStr);
        if (~isempty(selected))
            highlightText(selected);
        end
    end
end

function [currLRGBFileDir]=getCurrentLRGBfileDir(handles,time,FileDir)
    % magic number - 5
    spacing_arg = ['%0', num2str(5),'s'];
    padded_string=sprintf(spacing_arg, num2str(time));
    currLRGBFileDir=strcat(FileDir,'\LRGB\L1_',padded_string,'.mat');
end

function analysisClickedCallback(h,e,oldH,handles,FileDir,times)
    set(h,'UserData',1);
    set(oldH,'UserData',0);
    updatePlotPlate(times,FileDir,handles);
    colorH=findobj('Tag','ColorMenu');
    set(colorH,'Enable','off');
end

function pictureClickedCallback(h,e,oldH,handles,FileDir,times)
    set(h,'UserData',1);
    set(oldH,'UserData',0);
    state=getState(handles,times);
    updatePlotPlate(times,FileDir,handles);
    colorH=findobj('Tag','ColorMenu');
    set(colorH,'Enable','on');
end

function numbersClickedCallback(h,e,handles,FileDir,times)
    set(handles.worktxt,'Visible','on');
    numbersUD=1-get(h,'UserData');
    if (numbersUD)
        selNumStr=getSelectedColonyByLine(handles.graphax);
        axes(handles.picax);
        state=getState(handles,times);
        handleNumbersPlot(state.time,handles,FileDir,selNumStr);
    else
        deleteNumbersText(handles);
    end
    
    set(h,'UserData',numbersUD);

    set(handles.worktxt,'Visible','off');    
end

function colorClickedCallback(h,e,handles,FileDir,times,iconsdir)
    set(handles.worktxt,'Visible','on');
    colorUD=1-get(h,'UserData');
    if (colorUD)
       [icon map]=imread(strcat(iconsdir,'\Icons\BW.png'));
    else
       [icon map]=imread(strcat(iconsdir,'\Icons\Color.png'));
    end
    set(h,'CDATA',icon);
    set(h,'UserData',colorUD);
    updatePlotPlate(times,FileDir,handles);
    set(handles.worktxt,'Visible','off'); 
end

function [state]=getState(handles,times)        
    prevmode=findobj(handles.fig,'-regexp','Tag','PreviewMenu.+',...
                                                            'UserData',1);
    prevModeStr=get(prevmode,'Tag');
    if (strcmp(prevModeStr,'PreviewMenuA'))
        state.pic=0;
    else
        state.pic=1;
    end
    
    numbersFlag=findobj(handles.fig,'Tag','NumbersIn');
    state.numbers=get(numbersFlag,'UserData');
    
    numbersFlag=findobj(handles.fig,'Tag','ColorMenu');
    state.bw=1-get(numbersFlag,'UserData');
    
    val =round(get(handles.sl,'Value'));
    state.time=times(val);
end

function search(objH,e,handles)
    str=get(handles.ed,'string');
    [colonyNumber,status]=str2num(str);
    if (status)
        colonyflag=findobj(handles.picax,'Type','text','string',str);
        if (size(colonyflag,1)>0)
            handleColonySelection(colonyNumber,handles.graphax,handles.picax);
        end
    end
    
    set(handles.ed,'string','');
end

function setcolonyTextColor(colonyNumStr,handles,color)
    colonyTextH=findobj(handles.picax,'Type','text','string',colonyNumStr);
    if (~isempty(colonyTextH))
        set(colonyTextH,'color',color);
    end
end

function excludeClickedCallback(h,e,handles,FileDir,times)
    colonyNumber=getSelectedColonyByLine(handles.graphax);
    FilterBacteria(FileDir,[str2num(colonyNumber)],1);
    setcolonyTextColor(num2str(colonyNumber),handles,[1 1 0])
    initAreaGraph(handles.graphax,FileDir,handles.graphax,handles.picax);
    handleColonySelection(str2num(colonyNumber),...
                                      handles.graphax,handles.picax);
end

function includeClickedCallback(h,e,handles,FileDir,times)
    colonyNumber=getSelectedColonyByLine(handles.graphax);
    FilterBacteria(FileDir,[str2num(colonyNumber)],0);
    setcolonyTextColor(num2str(colonyNumber),handles,[1 1 1])
    initAreaGraph(handles.graphax,FileDir,handles.graphax,handles.picax);
    handleColonySelection(str2num(colonyNumber),...
                                      handles.graphax,handles.picax);
end

