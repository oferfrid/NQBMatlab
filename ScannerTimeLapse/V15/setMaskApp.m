function setMaskApp(DirName)
    global state;
    
    resultsDir=fullfile(DirName,'Results');
    if ~exist(resultsDir,'dir')
        mkdir(resultsDir);
    end
    
    handles=createGUI(DirName);
    fullMaskName=fullfile(DirName,'Results','mask.mat');
    
    if exist(fullMaskName,'file')
        state.mask_opt=1;
        finalMask = load(fullMaskName);
        state.mask=finalMask.mask;  
        showMaskedImage(handles.picax,state.mask)
        enableAreaMaskButtons(handles);
    else
        state.mask_opt=0;
        loadCircleState(handles,DirName);
        disableAreaMaskButtons(handles);
    end
end

function [handles]=createGUI(DirName)

    global state;

     ProcessPictures(DirName,1);
    
    [cdir cname ctype]=fileparts(mfilename('fullpath'));
    
    imagesNames=dir(fullfile(DirName,'Pictures','*.tif'));
    colonyImage=imread(fullfile(DirName,'Pictures',imagesNames(1,1).name));

    % figure
    handles.fig=figure('units','pixels',...
                 'position',[50 50 600 600],...
                 'name','SetMaskApp',...
                 'resize','off');
             
    b = findall(handles.fig,'ToolTipString','Save Figure');
    set(b,'ClickedCallback',@(objectH,eventH)saveMask(objectH,eventH,DirName));
             
    % toolbar
    set(handles.fig,'toolbar','figure');
    ht = uitoolbar(handles.fig);
    [icon map]=imread(strcat(cdir,'\Icons\MaskCircle.png'));
    maskCircleButton = uipushtool('Parent',ht,'CData',icon,...
                                    'Tag','CircMask');
                      
    [icon map]=imread(strcat(cdir,'\Icons\MaskArea.png'));
    maskAreaButton = uipushtool('Parent',ht,'CData',icon,...
                                  'Tag','AreaButton','Separator','on');
    
    [icon map]=imread(strcat(cdir,'\Icons\IncludeArea.png'));
    InAreaButton = uipushtool('Parent',ht,'CData',icon,...
                                  'Tag','ControlMaskInclude','Enable','off');
    
    [icon map]=imread(strcat(cdir,'\Icons\ExcludeArea.png'));
    ExAreaButton = uipushtool('Parent',ht,'CData',icon,...
                                  'Enable','off','Tag','ControlMaskExclude');
                              
    figcolor=get(handles.fig,'color');  
    
    imgLength=length(colonyImage);
    
    % axes
    handles.picax = axes('units','pixels',...
                   'position',[0 0 600 600],...
                   'fontsize',8,...
                   'nextplot','add','Tag','PICAX',...
                   'xlim',[0 imgLength],'ylim',[0 imgLength]);
               
    CImage = imread(fullfile(DirName,'Pictures',imagesNames(end,1).name));
    axes(handles.picax);
    %set(imageH,'visible','off');
    
    LRGB_Dir = fullfile(DirName,'LRGB');
    dirOutput = dir(fullfile(LRGB_Dir,'*.mat'));
    FileVec   = {dirOutput.name}';
    image=load(fullfile(LRGB_Dir,char(FileVec(end))));
    state.lrgb=image.L;
    tmp=edge(double(state.lrgb),'canny');
    CImage(find(tmp~=0))=255;
    imageH=imshow(CImage,[]);
    set(imageH,'Tag','Image0');
     
     
   set(maskAreaButton,'ClickedCallback',...
                  @(objH,eventH)handleMaskAreaButton(...
                                          objH,eventH,handles,CImage));
   set(maskCircleButton,'ClickedCallback',...
                  @(objH,eventH)handleMaskCircButton(...
                                      objH,eventH,handles,CImage,DirName));
                                      
   set(InAreaButton,'ClickedCallback',...
               @(objH,eventH)handleAddPolygon(objH,eventH,handles));
              
   set(ExAreaButton,'ClickedCallback',...
            @(objH,eventH)handleRemovePolygon(objH,eventH,handles));
end

function loadCircleState(handles,DirName)
    global state;
    axes(handles.picax);
    
    CircFile  = dir(fullfile(DirName,'Results','CircParams.mat'));
    CircExist = size(CircFile,1);
    
    if CircExist
        load(fullfile(DirName,'Results','CircParams'));
    else
        %% constatnts
        r = 436;    % the relevant radius in the plate in pixels
        x = 526; y=526;
    end
    
    state.circ = imellipse(gca, [x-r y-r 2*r 2*r]);
    set(state.circ,'Tag',DirName);
    setFixedAspectRatioMode(state.circ, 1)
end

function handleMaskAreaButton(objH,eventH,handles,ClearImage)
    global state;

    if (state.mask_opt~=1)
        state.mask_opt=1;    
        currImageH=findobj(handles.picax,'Tag','Image0');
        state.mask=state.circ.createMask(currImageH);        
        enableAreaMaskButtons(handles);
        showMaskedImage(handles.picax,state.mask);
    end
end

function handleMaskCircButton(objH,eventH,handles,ClearImage,DirName)
    global state;

    if (state.mask_opt~=0)
        state.mask_opt=0;        
        disableAreaMaskButtons(handles);
        prevImage=findobj(handles.picax,'Tag','Image');
        if ~isempty(prevImage)
            delete(prevImage);
        end
        imageH=imshow(ClearImage,[]);
        set(imageH,'Tag','Image');
        loadCircleState(handles,DirName);
    end
end

function enableAreaMaskButtons(handles)
    h=findobj(handles.fig,'Tag','ControlMaskInclude');
    set(h,'Enable','on');
    h=findobj(handles.fig,'Tag','ControlMaskExclude');
    set(h,'Enable','on');
    h=findobj(handles.fig,'Tag','PolygonROI');
    set(h,'Enable','on');
end

function disableAreaMaskButtons(handles)
    h=findobj(handles.fig,'Tag','ControlMaskInclude');
    set(h,'Enable','off');
    h=findobj(handles.fig,'Tag','ControlMaskExclude');
    set(h,'Enable','off');
    h=findobj(handles.fig,'Tag','PolygonROI');
    set(h,'Enable','off');
end

function showMaskedImage(picaxes,mask)
    axes(picaxes);
    image=getimage(findobj(picaxes,'Tag','Image0'));
    currImageH=findobj(picaxes,'Tag','Image');
    if ~isempty(currImageH)
        delete(currImageH);
    end
    image(:,:,1)=double(image(:,:,1))+50*double(mask);
    image(:,:,2)=double(image(:,:,2))+50*double(mask);
    image(:,:,3)=double(image(:,:,3))+50*double(mask);
    h=imshow(image);
    set(h,'Tag','Image');
end

function handleAddPolygon(objH,eventH,handles)
    addPolygon(handles);
end

function addPolygon(handles)
    global state;
    onesMask=ones(size(state.mask));
    currImageH=findobj(handles.picax,'Tag','Image0');
    poly=impoly(handles.picax);
    
    if ~isempty(poly)
        currMask=poly.createMask(currImageH);
        state.mask = (onesMask-currMask).*state.mask+currMask;
        showMaskedImage(handles.picax,state.mask);
    end
end

function handleRemovePolygon(objH,eventH,handles)
    removePolygon(handles);
end

function removePolygon(handles)
    global state;
    onesMask=ones(size(state.mask));
    currImageH=findobj(handles.picax,'Tag','Image0');
    poly=impoly(handles.picax);
    
    if ~isempty(poly)
        currMask=poly.createMask(currImageH);
        state.mask = (onesMask-currMask).*state.mask+zeros(size(currMask));
        showMaskedImage(handles.picax,state.mask);
    end
end

function saveMask(objectH,eventH,DirName)
   	global state;
    if (state.mask_opt==0)
        position = getPosition(state.circ);
        r=position(1,4)/2;
        x=position(1,1)+r;
        y=position(1,2)+r;
        save(fullfile(DirName,'Results','CircParams'),'x','y','r');
        
        % if mask exists save it as prev mask
        fullMaskName=fullfile(DirName,'Results','mask.mat');
        if exist(fullMaskName,'file')
            fullPrevName=fullfile(DirName,'Results','prevmask.mat');
            delete(fullPrevName);
            movefile(fullMaskName,fullPrevName);
        end
    else
        mask=state.mask;
        save(fullfile(DirName,'Results','mask'),'mask');
    end
end

function [image]=getImage(axes)
    image=getimage(findobj(axes,'Tag','Image0'));
end

