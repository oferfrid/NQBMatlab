
%% function setMaskApp(DirName)
% -------------------------------------------------------------------------
% Purpose: Run the set mask application
%
% Arguments: DirName - the base directory of pictures and results
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function setMaskApp(SourceDir)
    global state;
 
    % Load data file
   state.data=load(GetDataName(SourceDir));
   state.saved=1; 
    
%     resultsDir=fullfile(SourceDir,'Results');
%     if ~exist(resultsDir,'dir')
%         mkdir(resultsDir);
%     end
%     
    handles=createGUI(SourceDir);
    %fullMaskName=fullfile(DirName,'Results','mask.mat');
            
    if isfield(state.data, 'FullMask')
        state.mask_opt=1;
        state.mask=state.data.FullMask;
        showMaskedImage(handles.picax,state.mask)
        enableAreaMaskButtons(handles);
    else
        state.mask_opt=0;
        loadCircleState(handles);
        disableAreaMaskButtons(handles);
    end
end

%% function createGUI(DirName)
% -------------------------------------------------------------------------
% Purpose: create the gui of the application
%
% Arguments: DirName - the base directory of pictures and results
%
% output: handles - the gui's handlers
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function [handles]=createGUI(SourceDir)

    global state;

     L=Images2Colonies(SourceDir,true);
    
    ImageName=state.data.FilesName{1};
    ImageStr=fullfile(SourceDir,ImageName);
    colonyImage=imread(ImageStr);   
   
    [cdir,~,~]=fileparts(mfilename('fullpath'));

    % figure
    handles.fig=figure('units','pixels',...
                 'position',[50 50 600 600],...
                 'name','SetMaskApp',...
                 'resize','off');
             
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
               
    CImage = imread(fullfile(SourceDir,state.data.FilesName{end}));
    axes(handles.picax);
    %set(imageH,'visible','off');
    

    state.lrgb=L;
    tmp=edge(double(state.lrgb),'canny');
    CImage(find(tmp~=0))=255;
    imageH=imshow(CImage,[]);
    set(imageH,'Tag','Image0');
     
     
   set(maskAreaButton,'ClickedCallback',...
                  @(objH,eventH)handleMaskAreaButton(...
                                          objH,eventH,handles));
   set(maskCircleButton,'ClickedCallback',...
                  @(objH,eventH)handleMaskCircButton(...
                                      objH,eventH,handles,CImage,SourceDir));
                                      
   set(InAreaButton,'ClickedCallback',...
               @(objH,eventH)handleAddPolygon(objH,eventH,handles));
              
   set(ExAreaButton,'ClickedCallback',...
            @(objH,eventH)handleRemovePolygon(objH,eventH,handles));
        
   set(handles.fig,'CloseRequestFcn',@(objectH,eventH)closeGUI(objectH,eventH,SourceDir,handles));
        
   % Save
   b = findall(handles.fig,'ToolTipString','Save Figure');
   set(b,'ClickedCallback',@(objectH,eventH)saveMask(objectH,eventH,SourceDir,handles));
end

%% function loadCircleState(handles,DirName)
% -------------------------------------------------------------------------
% Purpose: loading the dragable ellipse data stored in CircParams.mat file
%
% Arguments: DirName - the base directory of pictures and results
%            handles - the handles for the gui
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function loadCircleState(handles)
    global state;
    axes(handles.picax);
    
    if isfield(state.data, 'CircleMask')
        x=state.data.CircleMask.X;
        y=state.data.CircleMask.Y;
        r=state.data.CircleMask.R;
    else
        x=state.data.PlateCirc.X;
        y=state.data.PlateCirc.Y;
        r=state.data.PlateCirc.R;
    end
   
    state.circ = imellipse(gca, [x-r y-r 2*r 2*r]);
    addNewPositionCallback(state.circ,@(p)trackChange(p,handles));
    %set(state.circ,'Tag',DirName);
    setFixedAspectRatioMode(state.circ, 1)
end

%% function handleMaskAreaButton(objH,eventH,handles)
% -------------------------------------------------------------------------
% Purpose: Change the application such that it will show the a 0-1 binary
% ellipse using the data in mask.mat file
%
% Arguments: handles - the handles for the gui
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function handleMaskAreaButton(objH,eventH,handles)
    global state;

    if (state.mask_opt~=1)
        state.mask_opt=1;    
        currImageH=findobj(handles.picax,'Tag','Image0');
        state.mask=state.circ.createMask(currImageH);        
        enableAreaMaskButtons(handles);
        showMaskedImage(handles.picax,state.mask);
        changeSavedSign(0,handles);
        state.saved=0;
    end
end

%% function handleMaskCircButton(objH,eventH,handles,ClearImage,DirName)
% -------------------------------------------------------------------------
% Purpose: Change the application such that it will show the draggable
% ellipse stored in the CircParams.mat file
%
% Arguments: handles - the handles for the gui
%            ClearImage - the background image
%            DirName - the base directory of pictures and results
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
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
        loadCircleState(handles);
        changeSavedSign(0,handles);
        state.saved=0;
    end
end

%% function enableAreaMaskButtons(handles)
% -------------------------------------------------------------------------
% Purpose: Enable the add/remove buttons for change the area matrix
%
% Arguments: handles - the handles for the gui
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function enableAreaMaskButtons(handles)
    h=findobj(handles.fig,'Tag','ControlMaskInclude');
    set(h,'Enable','on');
    h=findobj(handles.fig,'Tag','ControlMaskExclude');
    set(h,'Enable','on');
    h=findobj(handles.fig,'Tag','PolygonROI');
    set(h,'Enable','on');
end

%% function disableAreaMaskButtons(handles)
% -------------------------------------------------------------------------
% Purpose: Disable the add/remove buttons for change the area matrix
%
% Arguments: handles - the handles for the gui
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function disableAreaMaskButtons(handles)
    h=findobj(handles.fig,'Tag','ControlMaskInclude');
    set(h,'Enable','off');
    h=findobj(handles.fig,'Tag','ControlMaskExclude');
    set(h,'Enable','off');
    h=findobj(handles.fig,'Tag','PolygonROI');
    set(h,'Enable','off');
end

%% function showMaskedImage(picaxes,mask)
% -------------------------------------------------------------------------
% Purpose: Show the the image with brighted masked area
%
% Arguments: picaxes - the background picture
%            mask    - 0/1 binary mask
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
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

%% function handleAddPolygon(objH,eventH,handles)
% -------------------------------------------------------------------------
% Purpose: Encapsulating add polygon for event listener
%
% Arguments: handles - gui handlers
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function handleAddPolygon(objH,eventH,handles)
    addPolygon(handles);
end

%% function addPolygon(handles)
% -------------------------------------------------------------------------
% Purpose: Add an area polygon to the mask
%
% Arguments: handles - gui handlers
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function addPolygon(handles)
    global state;
    onesMask=ones(size(state.mask));
    currImageH=findobj(handles.picax,'Tag','Image0');
    poly=impoly(handles.picax);
    
    if ~isempty(poly)
        currMask=poly.createMask(currImageH);
        state.mask = (onesMask-currMask).*state.mask+currMask;
        showMaskedImage(handles.picax,state.mask);
        changeSavedSign(0,handles);
        state.saved=0;
    end
end

%% function handleRemovePolygon(objH,eventH,handles)
% -------------------------------------------------------------------------
% Purpose: Encapsulating remove polygon for event listener
%
% Arguments: handles - gui handlers
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function handleRemovePolygon(objH,eventH,handles)
    removePolygon(handles);
end

%% function addPolygon(handles)
% -------------------------------------------------------------------------
% Purpose: Remove an area polygon from the mask
%
% Arguments: handles - gui handlers
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function removePolygon(handles)
    global state;
    onesMask=ones(size(state.mask));
    currImageH=findobj(handles.picax,'Tag','Image0');
    poly=impoly(handles.picax);
    
    if ~isempty(poly)
        currMask=poly.createMask(currImageH);
        state.mask = (onesMask-currMask).*state.mask+zeros(size(currMask));
        showMaskedImage(handles.picax,state.mask);
        changeSavedSign(0,handles);
        state.saved=0;
    end
end

%% function saveMask(objectH,eventH,DirName,handles)
% -------------------------------------------------------------------------
% Purpose: Save the mask. If the user changes the aspect ratio of the
% draggable circle to an ellipse ater saving the draggable ellipse will
% become an area mask.
%
% Arguments:    DirName - base directory
%               handles - gui handlers
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function saveMask(objectH,eventH,SourceDir,handles)
   	global state;
    if (state.mask_opt==0)
        
        position = getPosition(state.circ);
        
        % check if the user transormed the circle to an ellipse
        height=position(1,4);
        width=position(1,3);
        if width~=height
            % Move to mask state
            handleMaskAreaButton(objectH,eventH,handles);
            saveMasktoFile(state.mask,SourceDir);
        else
            CircleMask.R = position(1,4)/2;
            CircleMask.X = position(1,1)+CircleMask.R;
            CircleMask.Y = position(1,2)+CircleMask.R;
            
            % Load data file
            if isfield(state.data, 'FullMask')
                state.data = rmfield(state.data,'FullMask');
            end
            state.data.CircleMask = CircleMask;
            data = state.data;
            save(GetDataName(SourceDir),'-struct','data');
            %save(fullfile(DirName,'Results','CircParams'),'x','y','r');
        end
    else
        saveMasktoFile(state.mask,SourceDir);
    end
    
    changeSavedSign(1,handles);
    state.saved=1;
end

%% function getImage(axes)
% -------------------------------------------------------------------------
% Purpose: get the base image inside the axes
%
% Arguments:    axes - the axes of the gui
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function [image]=getImage(axes)
    image=getimage(findobj(axes,'Tag','Image0'));
end

%% function saveMasktoFile(mask,DirName)
% -------------------------------------------------------------------------
% Purpose: Save the mask to the DirName/Results directory
%
% Arguments:    mask - the binary mask
%               DirName - the base directory 
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function saveMasktoFile(FullMask,SourceDir)
    % Load data file
   save(GetDataName(SourceDir),'FullMask','-append');
end

%% function changeSavedSign(isSaved,handles)
% -------------------------------------------------------------------------
% Purpose: Set the name of the application to setAppMask [not saved] if
% unsaved changes exist
%
% Arguments:    isSaved - 0 for false 1 or true
%               handles - handlers for the gui 
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function changeSavedSign(isSaved,handles)
    if (isSaved)
        set(handles.fig,'name','setMaskApp')
    else
        set(handles.fig,'name','setMaskApp [not saved]')
    end
end

%% function trackChange(p,handles)
% -------------------------------------------------------------------------
% Purpose: sign that there are unsaved changes
%
% Arguments:    p - new position, not used
%               handles - handlers for the gui 
% -------------------------------------------------------------------------
% Nir Dick Feb. 2014
% -------------------------------------------------------------------------
function trackChange(p,handles)
    global state;
    
    changeSavedSign(0,handles);
    state.saved=0;
end

function closeGUI(objectH,eventH,SourceDir,handles)
   global state;
   selection='No';
   if ~state.saved
       selection = questdlg('Changes have been made but not saved. Save changes?',...
          'Close Request Function',...
          'Yes','No','Cancel','Cancel'); 
   end

   if ~strcmp(selection,'Cancel')
       if strcmp(selection,'Yes')
           saveMask(objectH,eventH,SourceDir,handles);
       end
       delete(gcf);
   end
end
