function varargout = ExptMan(varargin)
% EXPTMAN Application M-file for ExptMan.fig
%    FIG = EXPTMAN launch ExptMan GUI.
%    EXPTMAN('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 28-May-2003 11:56:02

global STIM H_EXPTMAN

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    H_EXPTMAN=fig;

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    %----------------------------------
    %Initialization Code
    
    %Use the settings used previously
    if exist('ExptMan.mat','file')==2
        load('ExptMan') %Load the settings
        
        %Position in the screen
        if exist('Position','var')==1 
            mypos=get(fig,'Position');
            mypos(1:2)=Position(1:2);
            set(fig,'Position',mypos);
        end
    end   
    %Make sure that the figure is visible on the screen
    movegui(fig,'onscreen');

    %%% Set the 'Stim Type' popup menu
    StimType=StimTypeList; %Returns a cell array 'StimType'
    if ~isempty(StimType)
        set(handles.pop_stimtype,'String',StimType(:,1));
    else
        set(handles.pop_stimtype,'String','(Empty)');
    end
    
    %Initialize the STIM
    STIM=[];
    
    %% Disable the UI controls when the check is off
    set(handles.check_savedata,'value',0);   
    myhandles=[handles.edit_path handles.edit_seriesno ...
            handles.push_browsepath handles.text_lastseriesno ...
            handles.text_last handles.text_seriesno handles.text_path ...
            handles.text_MaxVolt handles.edit_MaxVolt];
    set(myhandles,'Enable','off');

    %----------------------------------
    
    
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions to control externally
% --------------------------------------------------------------------
function UpdateRepNo(RepCount)
global H_EXPTMAN

handles = guihandles(H_EXPTMAN);
set(handles.text_repno,'string',num2str(RepCount));

function UpdateCondNo(StimIdx)
global H_EXPTMAN

handles = guihandles(H_EXPTMAN);
set(handles.text_condno,'string',num2str(StimIdx));


function ShowMessage(Str)
global H_EXPTMAN

handles = guihandles(H_EXPTMAN);
set(handles.text_message,'string',Str);

function ShowCurrentGain(Str)
global H_EXPTMAN

handles = guihandles(H_EXPTMAN);
set(handles.text_currentgain,'string',Str);

function MonitorClosed
global H_EXPTMAN

handles = guihandles(H_EXPTMAN);
set(handles.toggle_monitor,'value',0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function varargout = UpdateNCond
%Update the number of conditions set in STIM

global STIM H_EXPTMAN

%myh=H_EXPTMAN;
myh=findobj('Tag','fig_exptman');
if ~isempty(myh)
    myhandles=guihandles(myh);
    set(myhandles.text_noofcond,'String',num2str(size(STIM,1)));
end


% --------------------------------------------------------------------
function varargout = myclosereq(h, eventdata, handles, varargin)
global H_EXPTMAN
%Close request

%Make sure to exit
button = questdlg('Are you sure to exit?',...
'You pressed Exit button','Yes','No','No');
if strcmp(button,'No')
    return;
end

%Close all the relevant windows
close ([findobj('Tag','fig_wavemon') findobj('Tag','fig_spikemon') ....
        findobj('Tag','fig_rasterplot') findobj('Tag','fig_psth') ]);
close(findobj('Tag','figure_gaincontroller'))

%Store the current status
Position=get(H_EXPTMAN,'Position');
save ExptMan Position

%Close the monitor
Monitor('CloseMonitor');

%Close the figure
closereq;

% --------------------------------------------------------------------
function Go
global H_EXPTMAN

%Run the series
global RunSeriesStatus CommandStatus STIM
if isempty(RunSeriesStatus)
    RunSeriesStatus='idle';
end

%Current string of the 'GO' button of ExptMan
if ~isempty(H_EXPTMAN)
    hdlsExptMan=guihandles(H_EXPTMAN);
    ButtonStr=get(hdlsExptMan.push_go,'String');
end

%Set the actiong
switch lower(RunSeriesStatus)
case 'idle' %The program is not running
    set(hdlsExptMan.push_go,'String','STOP');
    CommandStatus='run';
    disp(STIM);assignin('base','STIM',STIM);%Shotaro %Show the list of stim on the workspace
    Rtn=RunSeries;
case 'running' %The program is running
    errordlg('Program is already running','Error','modal');
    set(hdlsExptMan.push_go,'String','STOP');
    return;
otherwise %Unrecognized status
    error('Unrecognized status of RunSeries.');
end

% --------------------------------------------------------------------
function Stop
global H_EXPTMAN

%Run the series
global RunSeriesStatus CommandStatus
if isempty(RunSeriesStatus)
    RunSeriesStatus='idle';
end

%Current string of the 'GO' button of ExptMan
if ~isempty(H_EXPTMAN)
    hdlsExptMan=guihandles(H_EXPTMAN);
    ButtonStr=get(hdlsExptMan.push_go,'String');
end

%Set the actiong
switch lower(RunSeriesStatus)
case 'idle' %The program is not running
    set(hdlsExptMan.push_go,'String','GO');
    return;
case 'running' %The program is running
    CommandStatus='stop';
    return;
otherwise %Unrecognized status
    error('Unrecognized status of RunSeries.');
end

% --------------------------------------------------------------------
function LastSeriesNo
global ExptManParam H_EXPTMAN


myh=H_EXPTMAN;
if ~isempty(myh)
    myhandles=guihandles(myh);
    set(myhandles.text_lastseriesno,'String',num2str(ExptManParam.SeriesNo));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = push_go_Callback(h, eventdata, handles, varargin)
%Go button is pressed

global ExptManParam STIM Gain

mystr=get(h,'String');
if strcmpi(mystr,'GO')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get the parameters specified in the window
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %File path and series number
    if get(handles.check_savedata,'Value') %Only if 'Save Data' is checked
        
        %Warn if the external gain is set
        if ~isempty(Gain)
            if any(Gain)
                myh=warndlg('The current gain setting will be not recorded.','External gain is set');
                uiwait(myh);
            end
        end

        mypath=get(handles.edit_path,'String');
        if exist(mypath,'dir')~=7
            msgbox('The path does not exist','Error','error');
            return;
        end
        ExptManParam.Path=mypath;
        
        myseriesno=str2num(get(handles.edit_seriesno,'String'));
        if isempty(myseriesno)
            errordlg('Invalid Series Number','Error','modal');
            return;
        elseif myseriesno<0
            errordlg('Invalid Series Number','Error','modal');
            return;
        end
        ExptManParam.SeriesNo=myseriesno;
        
        %Make the directory if it does not exist
        DirName=sprintf('#%d',ExptManParam.SeriesNo);
        SaveDir=fullfile(ExptManParam.Path,DirName);
        if exist(SaveDir,'dir')~=7 
            [status,msg]=mkdir(ExptManParam.Path,DirName);
            if ~status
                error(['Failure to make directory ' SaveDir ' : ' msg]);
            end
        else
            %Ask if the contents could be cleared
            button = questdlg({'Delete the contents of ',[SaveDir '?']},...
                'The directory already exists','Yes','No','Cancel','Yes');
            if strcmp(button,'Yes')
                delete(fullfile(SaveDir,'*.*'));               
            elseif strcmp(button,'Cancel')
                return;
            end
        end
                
        %Maximum voltage for storing the data
        maxvolt=str2num(get(handles.edit_MaxVolt,'String'));
        if isempty(maxvolt)
            errordlg('Invalid Max Volt','Error','modal');
            return;
        elseif maxvolt(1)<=0
            errordlg('Invalid Max Volt (> 0 mV)','Error','modal');
            return;
        end
        ExptManParam.MaxVolt=maxvolt;

    else
        ExptManParam.Path=[];
        ExptManParam.SeriesNo=[];
    end
    
    %STIM matrix
    if isempty(STIM)
        errordlg('Stim has not been set','Error','modal');
        return;
    end
    
    %Flag for frozen stimuli
    ExptManParam.Frozen=get(handles.check_frozen,'Value');
    
    %Flag for random-order presentation
    ExptManParam.RandOrder=get(handles.check_randomorder,'Value');
    
    %ISI
    myisi=str2num(get(handles.edit_isi,'String'));
    if isempty(myisi)
        errordlg('Invalid ISI','Error','modal');
        return;
    end
    ExptManParam.ISI=myisi;
    
    %NRep
    mynrep=str2num(get(handles.edit_noofrep,'String'));
    if isempty(mynrep)
        errordlg('Invalid #Rep','Error','modal');
        return;
    elseif mynrep<0
        errordlg('Invalid #Rep','Error','modal');
        return;
    end
    ExptManParam.NRep=mynrep;
    
    %Flag for Left and Right chan
    ExptManParam.LChan=get(handles.check_l,'Value');
    ExptManParam.RChan=get(handles.check_r,'Value');
    if ~ExptManParam.LChan & ~ExptManParam.RChan
        errordlg('Both L and R channels are off','Error','modal');
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run the series
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Go;
else %Stop the series
    Stop;
end
    
% --------------------------------------------------------------------
function varargout = push_pause_Callback(h, eventdata, handles, varargin)
% Pause the series




% --------------------------------------------------------------------
function varargout = push_exit_Callback(h, eventdata, handles, varargin)
%Quit the program
global RunSeriesStatus

if strcmpi(RunSeriesStatus,'running')
    %    msgbox('Press STOP before exiting the program.','','modal');
    beep
    disp('Press STOP before exiting the program.');
else
    %Close the window
    ExptMan('myclosereq',gcbo,[],guidata(gcbo));
end



% --------------------------------------------------------------------
function varargout = push_reset_Callback(h, eventdata, handles, varargin)
%Reset the GO button
global RunSeriesStatus CommandStatus H_EXPTMAN

RunSeriesStatus='idle';
CommandStatus='stop';

%Current string of the 'GO' button of ExptMan
hExptMan=H_EXPTMAN;
hdlsExptMan=guihandles(hExptMan);
set(hdlsExptMan.push_go,'String','GO');



% --------------------------------------------------------------------
function varargout = edit_path_Callback(h, eventdata, handles, varargin)

mypath=get(h,'String');
if exist(mypath,'dir')~=7
    msgbox('The path does not exist','Error','error');
    set(h,'String','Retype correct path, here');
end


% --------------------------------------------------------------------
function varargout = push_browsepath_Callback(h, eventdata, handles, varargin)
%Browse to set the path
global ExptManParam

if isempty(ExptManParam)
    startpath=pwd;
elseif ~isfield(ExptManParam,'Path')
    startpath=pwd;
elseif isempty(ExptManParam.Path)
    startpath=pwd;
else
    startpath=ExptManParam.Path;
end
newpath = uigetdir(startpath,'Path for the animal');
set(handles.edit_path,'String',newpath);

% [newfile,newpath] = uiputfile('dummy.mat','Path for the animal');
% set(handles.edit_path,'String',newpath);


% --------------------------------------------------------------------
function varargout = edit_seriesno_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = check_savedata_Callback(h, eventdata, handles, varargin)

%% Disable the UI controls when the check is off
myhandles=[handles.edit_path handles.edit_seriesno ...
            handles.push_browsepath handles.text_lastseriesno ...
            handles.text_last handles.text_seriesno handles.text_path ...
            handles.text_MaxVolt handles.edit_MaxVolt];
if get(h,'Value')
    set(myhandles,'Enable','on');
else
    set(myhandles,'Enable','off');
end


% --------------------------------------------------------------------
function varargout = pop_stimtype_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = push_setstim_Callback(h, eventdata, handles, varargin)
%Open a window for setting stimuli

%Update the number of conditions in the ExptMan
ExptMan('UpdateNCond'); 

%Get the current selection
str=get(handles.pop_stimtype,'String');
idx=get(handles.pop_stimtype,'Value');
myStimType=str{idx};

%Open the setting window
feval(['Set' myStimType]); %The progam of the setting window is 'Set'+StimType


% --------------------------------------------------------------------
function varargout = push_stimbrowser_Callback(h, eventdata, handles, varargin)
%Browse the stim parameters in memeory using OPENVAR

BrowseStim; %Open the stim browser


% --------------------------------------------------------------------
function varargout = edit_noofrep_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = push_clear_Callback(h, eventdata, handles, varargin)
%Clear the stim parameters in memeory

global STIM
STIM=[];

set(handles.text_noofcond,'String',0);



% --------------------------------------------------------------------
function varargout = edit_cutthresh_Callback(h, eventdata, handles, varargin)

set(handles.push_setmonitparam,'Enable','on');


% --------------------------------------------------------------------
function varargout = radio_rms_Callback(h, eventdata, handles, varargin)

%Toggle between the radio buttons
set(handles.radio_rms,'Value',1);
set(handles.radio_volts,'Value',0);

set(handles.push_setmonitparam,'Enable','on');


% --------------------------------------------------------------------
function varargout = radio_volts_Callback(h, eventdata, handles, varargin)

%Toggle between the radio buttons
set(handles.radio_rms,'Value',0);
set(handles.radio_volts,'Value',1);

set(handles.push_setmonitparam,'Enable','on');



% --------------------------------------------------------------------
function varargout = check_randomorder_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit_isi_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = check_l_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = check_r_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = toggle_monitor_Callback(h, eventdata, handles, varargin)

if get(h,'value')
    monitor
else
    Monitor('CloseMonitor');
end


% --------------------------------------------------------------------
function varargout = push_InitializeTDT_Callback(h, eventdata, handles, varargin)

%Warning that Initializing can make noise
%h=msgbox({'Disconnect earphone to protect ears','from noise generated in the initialization process'},...
%'Initializing TDT devices','warn','modal');
%uiwait(h);
global IdxFsRP2 IdxFsRA16

%Initialize TDT devices
h=SampleRateTDT;
waitfor(h);
drawnow;
if isnan(IdxFsRP2) | isnan(IdxFsRA16)
    return;
end

%Repeat initialization as it often fails to change Fs
set(handles.text_fsrp2,'String','Initializing');
set(handles.text_fsra16,'String','Initializing');
InitializeTDT;
InitializeTDT;

FsRP2=RP2PlayEz('GetFs');
set(handles.text_fsrp2,'String',num2str(FsRP2));
FsRA16=RA16RecordEz('GetFs');
set(handles.text_fsra16,'String',num2str(FsRA16));
set(handles.push_go,'Enable','on');



% --------------------------------------------------------------------
function varargout = edit_MaxVolt_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = check_frozen_Callback(h, eventdata, handles, varargin)


% --- Executes on button press in push_gaincontroller.
function push_gaincontroller_Callback(hObject, eventdata, handles)
% hObject    handle to push_gaincontroller (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Open the gain controller
GainController
