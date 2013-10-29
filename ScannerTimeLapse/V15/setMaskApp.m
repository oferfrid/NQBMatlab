function setMaskApp(DirName)
    handles=createGUI(DirName);
    
    if exist(fullfile(DirName,'Results','mask.mask'),'file')
    else
        loadCircleState(handles,DirName);
    end
    

end

function [handles]=createGUI(DirName)
    
    [cdir cname ctype]=fileparts(mfilename('fullpath'));
    
    imagesNames=dir(fullfile(DirName,'Pictures','*.tif'));
    colonyImage=imread(fullfile(DirName,'Pictures',imagesNames(1,1).name));

    % figure
    handles.fig=figure('units','pixels',...
                 'position',[50 50 750 750],...
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
                   'position',[0 0 750 750],...
                   'fontsize',8,...
                   'nextplot','add','Tag','PICAX',...
                   'xlim',[0 imgLength],'ylim',[0 imgLength]);
               
    CImage = imread(fullfile(DirName,'Pictures',imagesNames(end,1).name));
    Image =  rgb2gray(CImage(:, :, 1:3));
    BGImage =  rgb2gray(colonyImage(:, :, 1:3));
    ClearImage  = imsubtract(Image ,BGImage);
    axes(handles.picax);
    imageH=imshow(CImage,[]);
    set(imageH,'Tag','Image0');
    imageH=imshow(CImage,[]);
    set(imageH,'Tag','Image');
               
   set(maskAreaButton,'ClickedCallback',...
                  @(objH,eventH)handleMaskAreaButton(...
                                          objH,eventH,handles,CImage));
   set(maskCircleButton,'ClickedCallback',...
                  @(objH,eventH)handleMaskCircButton(...
                                      objH,eventH,handles,CImage,DirName));
                                      
   set(InAreaButton,'ClickedCallback',...
               @(objH,eventH)handleAddPolygon(objH,eventH,handles,CImage));
              
   set(ExAreaButton,'ClickedCallback',...
            @(objH,eventH)handleRemovePolygon(objH,eventH,handles,CImage));
end

function loadCircleState(handles,DirName)
    global state;
    state.mask_opt=0;
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
    setFixedAspectRatioMode(state.circ, 1)
end

function handleMaskAreaButton(objH,eventH,handles,ClearImage)
    global state;

    if (state.mask_opt~=1)
        state.mask_opt=1;    
        currImageH=findobj(handles.picax,'Tag','Image');
        state.mask=state.circ.createMask(currImageH);        
        enableAreaMaskButtons(handles);
        showMaskedImage(handles.picax,ClearImage,state.mask);
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

function showMaskedImage(picaxes,rawImage,finalMask)
    onesMask=ones(size(finalMask));
    tmp=(onesMask-finalMask).*0.7+finalMask;
    rgbImage = cat(3, tmp, tmp, tmp);
     
    prevImage=findobj(picaxes,'Tag','Image');
    
    axes(picaxes);
    
    imageH=imshow(im2double(rawImage).*rgbImage);
    set(imageH,'Tag','Image');
    
    if ~isempty(prevImage)
        delete(prevImage);
    end
    
end

function handleAddPolygon(objH,eventH,handles,rawImage)
    addPolygon(handles,rawImage);
end

function addPolygon(handles,rawImage)
    global state;
    onesMask=ones(size(state.mask));
    currImageH=findobj(handles.picax,'Tag','Image');
    poly=impoly(handles.picax);
    
    if ~isempty(poly)
        currMask=poly.createMask(currImageH);
        state.mask = (onesMask-currMask).*state.mask+currMask;
        showMaskedImage(handles.picax,rawImage,state.mask);
    end
end

function handleRemovePolygon(objH,eventH,handles,rawImage)
    removePolygon(handles,rawImage);
end

function removePolygon(handles,rawImage)
    global state;
    onesMask=ones(size(state.mask));
    currImageH=findobj(handles.picax,'Tag','Image');
    poly=impoly(handles.picax);
    
    if ~isempty(poly)
        currMask=poly.createMask(currImageH);
        state.mask = (onesMask-currMask).*state.mask+zeros(size(currMask));
        showMaskedImage(handles.picax,rawImage,state.mask);
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
    else
    end
end


