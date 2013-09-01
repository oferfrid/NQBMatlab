function ScanLabApp(FileDir,TimeGap,forMovie,XScaleHr)
close(findobj('name', 'APP'));

h.fig=figure('units','pixels',...
              'position',[50 50 1150 655],...
              'name','APP',...
              'resize','off');  
buildToolBar(h,FileDir);
h.picax = axes('units','pixels',...
            'position',[50 70 500 500],...
            'fontsize',8,...
            'nextplot','add','Tag','PICAX','xlim',[0 500],'ylim',[0 500],...
            'ButtonDownFcn',@tryme,'xlim',[0 1051],'ylim',[0 1051]);
        
h.graphax = axes('units','pixels',...
                 'position',[600 70 500 500],...
                 'fontsize',8,...
                 'nextplot','add','Tag','GRAPHAX');
             
[min, max,times]=getSliderTimeData(FileDir,TimeGap);
sliderStep = [1, 1]/(max-min);

h.bwcheck = uicontrol('style','checkbox','units','pixels',...
                    'position',[170,600,100,15],'string','RGB picture',...
                    'Tag','bwcolor pics','Value',1);

h.previewgroup = uibuttongroup('Units', 'pixels','Tag','ButtonGroup'); 
h.radio(1) = uicontrol('Style', 'radiobutton', ...
                       'Units',    'pixels', ...
                       'Position', [50, 630, 90, 22], ...
                       'String',   'Plate analysis', ...
                       'Value',    1,...
                       'parent',h.previewgroup,...
                       'HandleVisibility','off',...
                       'Tag','Plate analysis');
h.radio(2) = uicontrol('Style', 'radiobutton', ...
                       'Units','pixels', ...
                       'Position',[170, 630, 90, 22], ...
                       'String','Plate picture', ...
                       'Value',2,...
                       'parent',h.previewgroup,...
                       'HandleVisibility','off',...
                       'Tag','Plate picture');
set(h.previewgroup,'SelectedObject',h.radio(2));
                   
h.numcheck = uicontrol('style','checkbox','units','pixels',...
                    'position',[50,600,100,15],'string','show numbers',...
                    'Tag','includeNumber','Value',1);
                
h.worktxt = uicontrol('style','text','units','pixels',...
                      'position',[500,600,50,20],'string','working!',...
                      'Tag','workingtxt','ForegroundColor','r',...
                      'Visible','off');
                              

h.sl = uicontrol('style','slide',...
                 'unit','pix',...
                 'position',[50 20 500 30],...
                 'min',min,'max',max,'val',max,...
                 'SliderStep',sliderStep,...
                 'Callback',@(ObjH, EventData)sliderCallBack...
                                       (ObjH, EventData, times,FileDir,h));
                                        
addlistener(h.sl,'ContinuousValueChange',@(ObjH, EventData) sliderChange...
                                           (ObjH, EventData, times,...
                                            FileDir,h));
set(h.previewgroup,'SelectionChangeFcn',...
      @(ObjH, EventData)previewChanged(ObjH, EventData, times,FileDir,h));

set(h.numcheck,'Callback',@(ObjH, EventData)includeNumbersChanged...
                                       (ObjH, EventData,times,FileDir,h));
                                
set(h.bwcheck,'Callback',@(ObjH, EventData)RGBFlagChanged...
                                       (ObjH, EventData,times,FileDir,h));
                                        
initAreaGraph(h.graphax,FileDir,h.graphax,h.picax);
initPics(h.picax,FileDir);

handleTimeChange(times(max),FileDir,h);
fclose('all');
end

function buildToolBar(handles,FileDir)
    b = findall(handles.fig,'ToolTipString','Edit Plot');
    set(b,'Visible','Off');
    set(handles.fig,'toolbar','figure');
    ht = uitoolbar(handles.fig);
    hpt = uipushtool(ht,'Tag','1,2,3...');
end

function [min, max,times]=getSliderTimeData(FileDir,TimeGap)
     TimeAxisDir=fullfile(FileDir, 'Results', 'TimeAxis');
     load(TimeAxisDir);
     times=TimeAxis(TimeAxis <= TimeGap);
     FileNum  = find(times,1,'last');
        
     min=1;
     max=FileNum;
     fclose('all'); 
end

function initPics(handle,FileDir)
    h=gca;
    axes(handle);
    
    PlotPlate(0, FileDir, 1, 0,handle);
    initImg=findobj(handle, 'Tag', 'ImageColony');
    if (~isempty(initImg))
        set(initImg,'Tag','ImageColony0');
    end;
                
    fclose('all');
    
    if (~isempty(h))
        axes(h);
    end;
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
    idx = round(get (ObjH, 'Value'));
    time=times(idx);
    
    handleTimeChange(time,FileDir,handles);
    drawnow;
    set(handles.worktxt,'Visible','off');
end

function sliderCallBack(ObjH, EventData, times,FileDir,handles)
    set(handles.worktxt,'Visible','on');
    val =round(get(ObjH,'Value'));
    time=times(val);
    handleTimeChange(time,FileDir,handles);
    set(handles.worktxt,'Visible','off');
end

function handleTimeChange(time,FileDir,handles)
    previewOption=getPreviewOption(handles);
    textFlag=getIncludeTextFlag(handles);
    updateAreaGraphCurrLine(time,handles.graphax);
    selNumStr=getSelectedColonyByLine(handles.graphax);
    
    axes(handles.picax);
    
    handlePlatePlot(handles,time,FileDir,previewOption);
    
    deleteNumbersText(handles);
  
    if (textFlag)
        handleNumbersPlot(time,handles,FileDir,selNumStr);
    end
    
    currImageHandle = findobj(handles.picax, 'Tag', 'ImageColony');
    if (~isempty(currImageHandle))
        set(currImageHandle,'ButtonDownFcn',...
            @(hObject, eventdata)imageColonySelected...
                            (hObject,eventdata,handles,time,FileDir));
    end;
   
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

function imageColonySelected(hObject, eventdata,handles,time,FileDir)
    p = get (handles.picax,'CurrentPoint');
    coordx=round(p(1,1));
    coordy=round(p(1,2));
    currLRGBFileDir=getCurrentLRGBfileDir(handles,time,FileDir);
    load(currLRGBFileDir);
    L(coordy,coordx)
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

function [selectedText]=getSelectedColonyText(picH)
    selectedText=findobj(picH,'Type','text','EdgeColor','white');
end

function [prevOption]=getPreviewOption(h)
    selstr=get(get(h.previewgroup,'SelectedObject'),'Tag');
    switch selstr
        case 'Plate analysis', prevOption=1;
        case 'Plate picture', prevOption=2;
        otherwise, prevOption=0;
    end
end

function [bwFlag]=getBWFlag(handles)
    bwFlag=1;
    if (get(handles.bwcheck,'Value') == get(handles.bwcheck,'Max'))
        bwFlag=0;
    end  
end

function [textFlag]=getIncludeTextFlag(handles)
    textFlag=0;
    if (get(handles.numcheck,'Value') == get(handles.numcheck,'Max'))
        textFlag=1;
    end  
end

function [selNumStr]=getSelectedColonyByLine(handle)
    selNumStr='none';
    selectedLine=findobj(handle,'Type','line','Selected','on');
    if (~isempty(selectedLine))
        tag=get(selectedLine,'Tag');
        selNumStr=tag(7:end);
    end
end

function previewChanged(ObjH, EventData,times,FileDir,handles)
    set(handles.worktxt,'Visible','on');
    prevOption=getPreviewOption(handles);
    if (prevOption==1)
        set(handles.bwcheck,'Visible','off');
    elseif (prevOption==2)
        set(handles.bwcheck,'Visible','on');
    end
    
    updatePlotPlate(times,FileDir,handles);
    
    set(handles.worktxt,'Visible','off');
end

function includeNumbersChanged(ObjH, EventData,times,FileDir,handles)
    set(handles.worktxt,'Visible','on');
    if (get(handles.numcheck,'Value') == get(handles.numcheck,'Max'))
        val =round(get(handles.sl,'Value'));
        time=times(val);
        selNumStr=getSelectedColonyByLine(handles.graphax);
        axes(handles.picax);
        handleNumbersPlot(time,handles,FileDir,selNumStr);
    else
        deleteNumbersText(handles);
    end
    set(handles.worktxt,'Visible','off');
end

function updatePlotPlate(times,FileDir,handles)
    previewOption=getPreviewOption(handles);
    idx = round(get (handles.sl, 'Value'));
    time=times(idx);
    handlePlatePlot(handles,time,FileDir,previewOption);
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
               %% loading excluded bacteria file
                ResDir    = fullfile(FileDir, 'Results');
                ExcludedBacteria = [];
                dirOutput = dir(fullfile(ResDir,'ExcludedBacteria.txt'));
                if size(dirOutput,1)
                        ExcludedBacteria = load(fullfile(ResDir,'ExcludedBacteria.txt'));
                end
                ExcludedBacteria = setdiff(ExcludedBacteria, colonyNumber);
                WriteFilterBacteria(FileDir, ExcludedBacteria);
                set(objH,'Color',[1 1 1]);
           else
               FilterBacteria(FileDir,[colonyNumber]);
               set(objH,'Color',[1 1 0]);
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

function handlePlatePlot(handles,time,FileDir,previewOption)
    axesHandlesToChildObjects=findobj(...
                    handles.picax, 'Tag', 'ImageColony');
    
    
    if (~isempty(axesHandlesToChildObjects))
        delete(axesHandlesToChildObjects);
    end;
    
    if (previewOption==1)
        PlotPlateAnalysis(time, FileDir, 0,handles.picax);
    elseif (previewOption==2)
       isBW=getBWFlag(handles);
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

function RGBFlagChanged(ObjH, EventData,times,FileDir,handles)
    set(handles.worktxt,'Visible','on'); 
    updatePlotPlate(times,FileDir,handles);
    set(handles.worktxt,'Visible','off');
end

function [currLRGBFileDir]=getCurrentLRGBfileDir(handles,time,FileDir)
    % magic number - 5
    spacing_arg = ['%0', num2str(5),'s'];
    padded_string=sprintf(spacing_arg, num2str(time));
    currLRGBFileDir=strcat(FileDir,'\LRGB\L1_',padded_string,'.mat');
end