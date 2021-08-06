function varargout = Controls(varargin)
% CONTROLS MATLAB code for Controls.fig
%      CONTROLS, by itself, creates a new CONTROLS or raises the existing
%      singleton*.
%
%      H = CONTROLS returns the handle to a new CONTROLS or the handle to
%      the existing singleton*.
%
%      CONTROLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLS.M with the given input arguments.
%
%      CONTROLS('Property','Value',...) creates a new CONTROLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Controls_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Controls_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Controls

% Last Modified by GUIDE v2.5 20-Sep-2018 23:02:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Controls_OpeningFcn, ...
                   'gui_OutputFcn',  @Controls_OutputFcn, ...
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


% --- Executes just before Controls is made visible.
function Controls_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Controls (see VARARGIN)

% Choose default command line output for Controls
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Controls wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global portPresent
global s;
global connected;
set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTick',[]);
set(handles.text10,'Foregroundcolor',[1,0,0]);
portPresent=false;
s="";
connected=false;
movegui(gcf,'center');

if ~isequal(size(seriallist,2),0)
    set(handles.portListCombobox,'String',seriallist)
    portPresent=true;
end

% --- Outputs from this function are returned to the command line.
function varargout = Controls_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles)
% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global portPresent;
global s;
global connected;

if ~connected
    if portPresent
        disp("Connecting...");
        index = get(handles.portListCombobox,'Value');
        items = get(handles.portListCombobox,'String');

        if isequal(size(items,2),2)
            %disp(items{index});
            s=serial(items{index});  
        else
            %disp(items);
            s=serial(items);
        end
        
        fopen(s);
        set(s,'DataBits',8);
        set(s,'StopBits',1);
        set(s,'BaudRate', 9600);
        set(s,'Parity','none');
        set(s,'Timeout',1);
        
        connected=true;
        h = animatedline('Color','r');
        axes1 = gca;
        axes1.YGrid = 'on';
        axes1.YLim = [0 100];

        startTime = datetime('now'); 
        set(handles.text10,'String','Connected');
        set(handles.text10,'Foregroundcolor',[0,1,0]);
        
        target=animatedline('Color', 'g');
        set(handles.axes1,'YTick',[0:10:100]);
        drawnow;
        
        while connected
            try
                temp=fgets(s);
                temp=str2double(temp);
                disp(temp)
                % Uncomment everything below if you can display the
                % distance in the MATLAB console.
                
                t =  datetime('now') - startTime;
                addpoints(h,datenum(t),temp)
                %Setpoint
                addpoints(target,datenum(t), 45);
                drawnow;
                axes1.XLim = datenum([t-seconds(15) t]);
                
                datetick('x','keeplimits')

            catch
                fclose(s);
                connected=false;
            end
            
            drawnow;
        end
        
    else
        msgbox('No port selected');
        %disp("Can't connect.");
    end
else
    msgbox('Already connected');
    %disp("Already connected!");
end

% --- Executes on selection change in portListCombobox.
function portListCombobox_Callback(hObject, eventdata, handles)
% hObject    handle to portListCombobox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns portListCombobox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from portListCombobox


% --- Executes during object creation, after setting all properties.
function portListCombobox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portListCombobox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global s;
global connected;

if connected
    connected=false;
    fclose(s);   
    set(handles.text10,'String','Not connected.');
    set(handles.text10,'Foregroundcolor',[1,0,0]);
end
disp('Program closed.');
delete(hObject);
