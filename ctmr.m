function varargout = ctmr(varargin)
% CTMR M-file for ctmr.fig
%      CTMR, by itself, creates a new CTMR or raises the existing
%      singleton*.
%
%      H = CTMR returns the handle to a new CTMR or the handle to
%      the existing singleton*.
%
%      CTMR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CTMR.M with the given input arguments.
%
%      CTMR('Property','Value',...) creates a new CTMR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ctmr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ctmr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ctmr

% Last Modified by GUIDE v2.5 25-May-2009 11:08:08

% Begin initialization code - DO NOT EDIT

%     Copyright (C) 2009  D. Hermes, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
%   Version 1.1.0, released 26-11-2009

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ctmr_OpeningFcn, ...
                   'gui_OutputFcn',  @ctmr_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ctmr is made visible.
function ctmr_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ctmr (see VARARGIN)

% Choose default command line output for ctmr
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ctmr wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ctmr_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openct - select CT
function openct_Callback(hObject, eventdata, handles)
% hObject    handle to openct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear handles.data;
% use spm_select to get ct 
[ctName]=spm_select(1,'image');
handles.data.ctName=ctName;

% get the ct into a structure
handles.data.ctStruct=spm_vol(handles.data.ctName);

% from structure to data matrix and xyz matrix (voxel coordinates)
[handles.data.ctData]=spm_read_vols(handles.data.ctStruct);
%set maximum of data to 1 for imshow
handles.data.ctData=handles.data.ctData/max(max(max(handles.data.ctData)));

% make data.elecMap for electrode positions
handles.data.elecMap=zeros(size(handles.data.ctData));

handles.data.view=1;

p=spm_imatrix(handles.data.ctStruct.mat);
handles.data.voxelSize=abs(p(7:9));

guidata(hObject,handles);

% set start value of slicer and edit box
currentXYZ=round(size(handles.data.ctData)/2);
set(handles.edit1,'String',int2str(currentXYZ(3)));
% set(handles.edit2,'String',int2str(currentXYZ(2)));
% set(handles.edit3,'String',int2str(currentXYZ(1)));

set(handles.slider1,'Min',1,'Max',length(handles.data.ctData(1,1,:)),...
    'Value',currentXYZ(3),'SliderStep',[1,5]/length(handles.data.ctData(1,1,:)));
% set(handles.slider2,'Min',1,'Max',length(handles.data.ctData(1,:,1)),...
%     'Value',currentXYZ(2),'SliderStep',[1,5]/length(handles.data.ctData(1,:,1)));
% set(handles.slider3,'Min',1,'Max',length(handles.data.ctData(:,1,1)),...
%     'Value',currentXYZ(1),'SliderStep',[1,5]/length(handles.data.ctData(:,1,1)));

%set settings for electrode selection
set(handles.threshold,'String','0.90');
set(handles.max_size,'String','5');
set(handles.diff_th,'String','0.05');

set(handles.axes1,'DataAspectRatio',...
    [length(handles.data.ctData(1,:,1)) length(handles.data.ctData(:,1,1)) 1]);
% set(handles.axes2,'DataAspectRatio',...
%     [length(handles.data.ctData(:,1,1)) length(handles.data.ctData(1,1,:)) 1]);
% set(handles.axes3,'DataAspectRatio',...
%     [length(handles.data.ctData(1,:,1)) length(handles.data.ctData(1,1,:)) 1]);


imageUpdate(hObject,eventdata,handles);

function edit1_Callback(hObject, eventdata, handles, currentXYZ, ctData, ctXYZ)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

currentZ=str2double(get(hObject,'String'));
if currentZ>get(handles.slider1,'Min') && currentZ<get(handles.slider1,'Max');
    set(handles.slider1,'Value',currentZ);
end

imageUpdate(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
currentY=str2double(get(hObject,'String'));
if currentY>get(handles.slider2,'Min') && currentY<get(handles.slider2,'Max');
    set(handles.slider2,'Value',currentY);
end
imageUpdate(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
currentX=str2double(get(hObject,'String'));
if currentX>get(handles.slider3,'Min') && currentX<get(handles.slider3,'Max');
    set(handles.slider3,'Value',currentX);
end
imageUpdate(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.edit1,'String',round(get(hObject,'Value')));
imageUpdate(hObject,eventdata,handles);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit2,'String',round(get(hObject,'Value')));
imageUpdate(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.edit3,'String',round(get(hObject,'Value')));
imageUpdate(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function imageUpdate(hObject, eventdata, handles) 

currentZ=round(get(handles.slider1,'Value'));
% currentY=round(get(handles.slider2,'Value'));
% currentX=round(get(handles.slider3,'Value'));

%imshow ct
if isfield(handles.data,'elecMap') %if electrodes are there
    if handles.data.view==1
        rgbplaatje1=cat(3,0.5*handles.data.ctData(:,:,currentZ)+(handles.data.elecMap(:,:,currentZ)),...
            0.5*handles.data.ctData(:,:,currentZ),...
            0.5*handles.data.ctData(:,:,currentZ)+(handles.data.elecMap(:,:,currentZ)));
        imshow(rgbplaatje1,...
            'Parent',handles.axes1);
    elseif handles.data.view==2
        rgbplaatje2=cat(3,0.5*squeeze(handles.data.ctData(:,currentZ,:))+squeeze((handles.data.elecMap(:,currentZ,:))),...
            0.5*squeeze(handles.data.ctData(:,currentZ,:)),...
            0.5*squeeze(handles.data.ctData(:,currentZ,:))+squeeze((handles.data.elecMap(:,currentZ,:))));
        imshow(rgbplaatje2,...
            'Parent',handles.axes1);
    elseif handles.data.view==3     
        rgbplaatje3=cat(3,0.5*squeeze(handles.data.ctData(currentZ,:,:))+squeeze((handles.data.elecMap(currentZ,:,:))),...
            0.5*squeeze(handles.data.ctData(currentZ,:,:)),...
            0.5*squeeze(handles.data.ctData(currentZ,:,:))+squeeze((handles.data.elecMap(currentZ,:,:))));
        imshow(rgbplaatje3,...
            'Parent',handles.axes1);
    end
else
    if handles.data.view==1
        imshow(handles.data.ctData(:,:,currentZ),...
            'Parent',handles.axes1);
        hold on
    elseif handles.data.view==2
        imshow(squeeze(handles.data.ctData(:,currentZ,:)),...
            'Parent',handles.axes1);
        hold on
    elseif handles.data.view==3
        imshow(squeeze(handles.data.ctData(currentZ,:,:)),...
            'Parent',handles.axes1);
        hold on
    end
    colormap('gray');
end
% set(handles.axes1,'DataAspectRatio',...
%     [length(handles.data.ctData(:,1,1)) length(handles.data.ctData(1,:,1)) 1])
% 
% set(handles.axes2,'DataAspectRatio',...
%     [length(handles.data.ctData(:,1,1))/4 length(handles.data.ctData(1,1,:)) 1])
% 
% set(handles.axes3,'DataAspectRatio',...
%     [length(handles.data.ctData(1,:,1))/4 length(handles.data.ctData(1,1,:)) 1])
hold off


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=get(hObject,'CurrentPoint');
b=get(handles.axes1,'Position');
% c=get(handles.axes2,'Position');
% d=get(handles.axes3,'Position');
if handles.data.view==1
    if a(1)>b(1) && a(1)<b(1)+b(3) && a(2)>b(2) && a(2)<b(2)+b(4)
        % checks:
        %position.axes1=[a(1)-b(1) a(2)-b(2)]
        %get(handles.axes1,'CurrentPoint') 

        xy=get(handles.axes1,'CurrentPoint'); %current point x and y

        %check for click within image
        if xy(1,2)>5 && xy(1,2)<=length(handles.data.ctData(:,1,1))-5 && ...
            xy(1,1)>5 && xy(1,1)<=length(handles.data.ctData(1,:,1))-5 % I do not know for sure whether X and Y are correct here
            % if already an electrode in that position remove
            if handles.data.elecMap(round(xy(1,2)),round(xy(1,1)),round(get(handles.slider1,'Value')))>0;
                removeElec(hObject, eventdata, handles,xy);
            else
                drawElec(hObject, eventdata, handles,xy);
            end
        end
    else
        set(handles.display_feedback,'String','mis');
    end
elseif handles.data.view==2
    if a(1)>b(1) && a(1)<b(1)+b(3) && a(2)>b(2) && a(2)<b(2)+b(4)
       xy=get(handles.axes1,'CurrentPoint'); %current point x and y
        %check for click within image
        if xy(1,2)>5 && xy(1,2)<=length(handles.data.ctData(:,1,1))-5 && ...
            xy(1,1)>5 && xy(1,1)<=length(handles.data.ctData(1,1,:))-5 % I do not know for sure whether X and Y are correct here
            % if already an electrode in that position remove
            if handles.data.elecMap(round(xy(1,2)),round(get(handles.slider1,'Value')),round(xy(1,1)))>0;
                removeElec(hObject, eventdata, handles,xy);
            else
                drawElec(hObject, eventdata, handles,xy);
            end
        end
    else
        set(handles.display_feedback,'String','mis');
    end
elseif handles.data.view==3
    if a(1)>b(1) && a(1)<b(1)+b(3) && a(2)>b(2) && a(2)<b(2)+b(4)
       xy=get(handles.axes1,'CurrentPoint'); %current point x and y
        %check for click within image
        if xy(1,2)>5 && xy(1,2)<=length(handles.data.ctData(1,:,1))-5 && ...
            xy(1,1)>5 && xy(1,1)<=length(handles.data.ctData(1,1,:))-5 % I do not know for sure whether X and Y are correct here
            % if already an electrode in that position remove
            if handles.data.elecMap(round(get(handles.slider1,'Value')),round(xy(1,2)),round(xy(1,1)))>0;
                removeElec(hObject, eventdata, handles,xy);
            else
                drawElec(hObject, eventdata, handles,xy);
            end
        end
    else
        set(handles.display_feedback,'String','mis');
    end
end
 %     imshow(handles.data.elecMap(:,:,round(get(handles.slider1,'Value'))),...
    %         'Parent',handles.axes1);


function drawElec(hObject, eventdata, handles,xy) 

% function that draws electrode

% set stuff
threshold=str2double(get(handles.threshold,'String'));% 0.90 for clicking
radiusElect=str2double(get(handles.max_size,'String')); %5 in voxels, not mm
diffthreshold=str2double(get(handles.diff_th,'String'));% 0.05;

% value of CT scan were clicked
if handles.data.view==1
    current.CTvalue=handles.data.ctData(round(xy(1,2)),round(xy(1,1)),round(get(handles.slider1,'Value')));
elseif handles.data.view==2
    current.CTvalue=handles.data.ctData(round(xy(1,2)),round(get(handles.slider1,'Value')),round(xy(1,1)));
elseif handles.data.view==3
    current.CTvalue=handles.data.ctData(round(get(handles.slider1,'Value')),round(xy(1,2)),round(xy(1,1)));
end
if current.CTvalue>threshold
    % XYZ position in matrix were clicked
    if handles.data.view==1
        current.XYZ=[round(xy(1,2)) round(xy(1,1)) round(get(handles.slider1,'Value'))];
    elseif handles.data.view==2
        current.XYZ=[round(xy(1,2)) round(get(handles.slider1,'Value')) round(xy(1,1))];
    elseif handles.data.view==3
        current.XYZ=[round(get(handles.slider1,'Value')) round(xy(1,2)) round(xy(1,1))];
    end
    

    % make an empty matrix for electrode locations
    data.elecMap=zeros(size(handles.data.ctData));
    % put ones on a box of radiusElect aournd where there was clicked
    data.elecMap(...
        current.XYZ(1)-radiusElect:current.XYZ(1)+radiusElect,...
        current.XYZ(2)-radiusElect:current.XYZ(2)+radiusElect,...
        current.XYZ(3)-radiusElect:current.XYZ(3)+radiusElect)=1;
    % put a 2 at the point were there was clicked
    data.elecMap(...
        current.XYZ(1),current.XYZ(2),current.XYZ(3))=2;
    
    % make small matrix in a box of radiusElect around click to speed up calculation:
    minidata.ctData=handles.data.ctData(...
        current.XYZ(1)-radiusElect:current.XYZ(1)+radiusElect,...
        current.XYZ(2)-radiusElect:current.XYZ(2)+radiusElect,...
        current.XYZ(3)-radiusElect:current.XYZ(3)+radiusElect);
    minidata.elecMap=data.elecMap(...
        current.XYZ(1)-radiusElect:current.XYZ(1)+radiusElect,...
        current.XYZ(2)-radiusElect:current.XYZ(2)+radiusElect,...
        current.XYZ(3)-radiusElect:current.XYZ(3)+radiusElect);

    set(handles.display_feedback,'String','drawing electrode');

    %from matrix to vector
    minidata.ctDataV=minidata.ctData(:); 
    minidata.elecMapV=minidata.elecMap(:);
    
    % threshold image
    minidata.ctDataV_thresholded=minidata.ctDataV;
    minidata.ctDataV_thresholded(minidata.ctDataV<current.CTvalue-diffthreshold)=0;
    minidata.ctData_thresholded=minidata.ctData;
    minidata.ctData_thresholded(:)=minidata.ctDataV_thresholded;
    %label blobs in thresholded image
    minidata.ctData_thresholded_bwlabel=bwlabeln(minidata.ctData_thresholded);
    minidata.ctDataV_thresholded_bwlabel=minidata.ctData_thresholded_bwlabel(:);
    % get label where the mouse clicked:
    minidata.clickpointbool=(minidata.elecMapV==2);
    minidata.clickpointbwlabel=minidata.ctDataV_thresholded_bwlabel(minidata.clickpointbool); 
    minidata.correctlabelbool=(minidata.ctDataV_thresholded_bwlabel==minidata.clickpointbwlabel);

    % find blob with correct label
    minidata.current_electV=minidata.correctlabelbool';
    minidata.elecMap(:)=minidata.current_electV;
    
    % calculates Centre Of Mass for blob
    % disp('calculating COM')
    [com.sort_x,com.pos_x]=sort(minidata.elecMap,1);
    [com.sort_y,com.pos_y]=sort(minidata.elecMap,2);
    [com.sort_z,com.pos_z]=sort(minidata.elecMap,3);
    %datasorted
    com.x_find=round((sum(com.sort_x(:).*com.pos_x(:)))/(sum(com.sort_x(:))));
    com.y_find=round((sum(com.sort_y(:).*com.pos_y(:)))/(sum(com.sort_y(:))));
    com.z_find=round((sum(com.sort_z(:).*com.pos_z(:)))/(sum(com.sort_z(:))));
    
    % at COM put 1 in minidata for electrode position
    %com found, get XYZ coordinates of COM
    minidata.elecMap=zeros(size(minidata.elecMap));
    minidata.elecMap(com.x_find,com.y_find,com.z_find)=1;
    %com.x=minidata.ctXYZ(1,minidata.elecMap(:)==1);
    %com.y=minidata.ctXYZ(2,minidata.elecMap(:)==1);
    %com.z=minidata.ctXYZ(3,minidata.elecMap(:)==1);
    
    %draw circle around COM
    % get circle size in mm
    minidata.voxelsize=handles.data.voxelSize; %voxelsize
    % define new data:
    minidata.elecMap=zeros(size(minidata.ctData));
    for k=1:length(minidata.ctData(:,1,1))
        for m=1:length(minidata.ctData(1,:,1))
            for n=1:length(minidata.ctData(1,1,:))
                if ((k*minidata.voxelsize(1)-com.x_find*minidata.voxelsize(1))^2+...
                    (m*minidata.voxelsize(2)-com.y_find*minidata.voxelsize(2))^2+...
                    (n*minidata.voxelsize(3)-com.z_find*minidata.voxelsize(3))^2)<2 %radius
                    minidata.elecMap(k,m,n)=1;
                end
            end
        end
    end
    minidata.elecMap(com.x_find,com.y_find,com.z_find)=2;
    % put minidata back in image:
    data.elecMap(...
        current.XYZ(1)-radiusElect:current.XYZ(1)+radiusElect,...
        current.XYZ(2)-radiusElect:current.XYZ(2)+radiusElect,...
        current.XYZ(3)-radiusElect:current.XYZ(3)+radiusElect)=...
        minidata.elecMap;
    
    % set data
    handles.data.elecMap(handles.data.elecMap==1|data.elecMap==1)=1;
    handles.data.elecMap(data.elecMap==2)=2;
    set(handles.display_feedback,'String','found electrode');
    guidata(hObject,handles);
    imageUpdate(hObject,eventdata,handles);

else
    set(handles.display_feedback,'String',['CT value smaller threshold'])
end

function removeElec(hObject, eventdata, handles,xy) 
set(handles.display_feedback,'String','removing electrode');
% function that removes electrode
if handles.data.view==1
    current.XYZ=[round(xy(1,2)) round(xy(1,1)) round(get(handles.slider1,'Value'))];
elseif handles.data.view==2
    current.XYZ=[round(xy(1,2)) round(get(handles.slider1,'Value')) round(xy(1,1))];
elseif handles.data.view==3
    current.XYZ=[round(get(handles.slider1,'Value')) round(xy(1,2)) round(xy(1,1))];
end

data.elecMap=handles.data.elecMap;
data.elecMap(current.XYZ(1),current.XYZ(2),current.XYZ(3))=3;
data.elecMapV=data.elecMap(:);

%label blobs 
data.elecMap_bwlabel=bwlabeln(data.elecMap);
data.elecMapV_bwlabel=data.elecMap_bwlabel(:);

% get label where the mouse clicked:
data.clickpointbool=(data.elecMapV==3);
data.clickpointbwlabel=data.elecMapV_bwlabel(data.clickpointbool); 
data.correctlabelbool=(data.elecMapV_bwlabel==data.clickpointbwlabel);

% find blob with correct label
data.current_electV=data.correctlabelbool';
data.elecMapV(data.current_electV)=0;
data.elecMap(:)=data.elecMapV;

handles.data.elecMap=data.elecMap;
set(handles.display_feedback,'String','removed electrode');
guidata(hObject,handles);
imageUpdate(hObject,eventdata,handles);



function threshold_Callback(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double


% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_size_Callback(hObject, eventdata, handles)
% hObject    handle to max_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_size as text
%        str2double(get(hObject,'String')) returns contents of max_size as a double


% --- Executes during object creation, after setting all properties.
function max_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diff_th_Callback(hObject, eventdata, handles)
% hObject    handle to diff_th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_th as text
%        str2double(get(hObject,'String')) returns contents of diff_th as a double


% --- Executes during object creation, after setting all properties.
function diff_th_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diff_th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in view_results.
function view_results_Callback(hObject, eventdata, handles)
% hObject    handle to view_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[xvalues,yvalues,zvalues]=ind2sub(size(handles.data.elecMap),...
    find(handles.data.elecMap>1.5));

p=spm_imatrix(handles.data.ctStruct.mat);
xvalues=sign(p(7))*xvalues;
figure
plot3(xvalues,yvalues,zvalues,'.','markerSize',20);


% --- Executes on button press in save_els - SAVE button.
function save_els_Callback(hObject, eventdata, handles)
% hObject    handle to save_els (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataOut=handles.data.ctStruct;
outputdir= spm_select(1,'dir','select output directory');
    
for filenummer=1:100
    outputnaam=strcat([outputdir 'electrodes' int2str(filenummer) '.img']);
    dataOut.fname=outputnaam;

    if ~exist(dataOut.fname)
        set(handles.display_feedback,'String',strcat(['saving ' outputnaam]));
        % save the data
        spm_write_vol(dataOut,handles.data.elecMap);
        break
    end
end

% --- Executes on button press in load_els. - LOAD button
function load_els_Callback(hObject, eventdata, handles)
% hObject    handle to load_els (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[els]=spm_select(1,'image','load electrodes.img file');
elsStruct=spm_vol(els);
[handles.data.elecMap]=spm_read_vols(elsStruct);

guidata(hObject,handles);
imageUpdate(hObject,eventdata,handles);

function display_feedback_Callback(hObject, eventdata, handles)
% hObject    handle to display_feedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_feedback as text
%        str2double(get(hObject,'String')) returns contents of display_feedback as a double


% --- Executes during object creation, after setting all properties.
function display_feedback_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_feedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in select_view.
function select_view_Callback(hObject, eventdata, handles)
% hObject    handle to select_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_view contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_view

currentXYZ=round(size(handles.data.ctData)/2);
contents = get(hObject,'String');
if isequal(contents{get(hObject,'Value')},'view 1');
    handles.data.view=1;
    % set slider to half
    set(handles.slider1,'Min',1,'Max',length(handles.data.ctData(1,1,:)),...
        'Value',currentXYZ(3),'SliderStep',[1,5]/length(handles.data.ctData(1,1,:)));
    imageUpdate(hObject,eventdata,handles);
elseif isequal(contents{get(hObject,'Value')},'view 2');
    handles.data.view=2;
    % set slider to half
    set(handles.slider1,'Min',1,'Max',length(handles.data.ctData(1,:,1)),...
        'Value',currentXYZ(3),'SliderStep',[1,5]/length(handles.data.ctData(1,:,1)));
    imageUpdate(hObject,eventdata,handles);
elseif isequal(contents{get(hObject,'Value')},'view 3');
    handles.data.view=3;
    % set slider to half
    set(handles.slider1,'Min',1,'Max',length(handles.data.ctData(:,1,1)),...
        'Value',currentXYZ(3),'SliderStep',[1,5]/length(handles.data.ctData(:,1,1)));
    imageUpdate(hObject,eventdata,handles);
end

guidata(hObject,handles);




% --- Executes during object creation, after setting all properties.
function select_view_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


