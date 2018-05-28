function varargout = Monitor4(varargin)
% MONITOR4 Application M-file for Monitor4.fig
%    FIG = MONITOR4 launch Monitor4 GUI.
%    MONITOR4('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 03-Mar-2003 19:07:14

global Monitor4Setting Monitor4Handles 

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end
    
    %Keep the handles of the figure
    Monitor4Handles=handles;
    
    %Initialize the setting structure
    Monitor4('Initialize')
    
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
drawnow; %update the figure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Subfunctions for running external commands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% Set default Monitor4Setting values
% --------------------------------------------------------------------
function DefaultSetting
global Monitor4Setting Monitor4Handles ExptManParam

    %%%%%%%%%%%%%%%%%%%%%%%
    %Waveform amplitude voltage (ms) as 100 %
    Monitor4Setting.VoltageFor100Percent=1; %
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %Parameters of the bandpass filter
    Monitor4Setting.FilterOrder=3; %IIR filter order
    Monitor4Setting.FilterPassband=[300 5000]; %Passband of the IIR filter
    Monitor4Setting.FilterB=[]; %Filter coefficients B
    Monitor4Setting.FilterA=[]; %Filter coefficients A
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %Settings for waveform
    Monitor4Setting.Waveform.Flag=1; %Flag for whether the plot is active
    Monitor4Setting.Waveform.XLim=[]; %XLim; [] for default
    Monitor4Setting.Waveform.YLim=[]; %YLim; [] for default
    Monitor4Setting.Waveform.ReverseFlag=0; %Flag for whether the amplitude should be reversed
    Monitor4Setting.Waveform.FilterFlag=1; %Flag for bandpass filtering
    Monitor4Setting.Waveform.XData=[]; %XData
    Monitor4Setting.Waveform.YData=[]; %YData
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %Settings for spikes
    Monitor4Setting.Spikes.Flag=1; %Flag for whether the plot is active
    Monitor4Setting.Spikes.XLim=[-1 2]; %XLim; [] for default
    Monitor4Setting.Spikes.YLim=[-50 50]; %YLim; [] for default
    Monitor4Setting.Spikes.CutThresh=[20]; %Cutoff threshold for spike detection; [] for default
    
    Monitor4Setting.Spikes.Criterion1.Flag=0; %Flag for whether applying criterion 1
    Monitor4Setting.Spikes.Criterion1.t=[0.5]; %Time of the criterions; [] for default
    Monitor4Setting.Spikes.Criterion1.Hi=[100]; %Upper threshold; [] for default
    Monitor4Setting.Spikes.Criterion1.Lo=[-100]; %Lower threshold; [] for default
    
    Monitor4Setting.Spikes.Criterion2.Flag=0; %Flag for whether applying criterion 1
    Monitor4Setting.Spikes.Criterion2.t=[1]; %Time of the criterions; [] for default
    Monitor4Setting.Spikes.Criterion2.Hi=[100]; %Upper threshold; [] for default
    Monitor4Setting.Spikes.Criterion2.Lo=[-100]; %Lower threshold; [] for default
    
    Monitor4Setting.Spikes.XData=[];
    Monitor4Setting.Spikes.YDataFail=[];
    Monitor4Setting.Spikes.YDataPass=[];
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %Settings for raster plot
    Monitor4Setting.Raster.Flag=1; %Flag for whether the plot is active
    Monitor4Setting.Raster.XData=[]; %
    Monitor4Setting.Raster.YData=[]; %
    Monitor4Setting.Raster.ZData=[]; %Data matrix to display
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %Settings for PSTH
    Monitor4Setting.PSTH.Flag=1; %Flag for whether the plot is active
    Monitor4Setting.PSTH.XLim=[]; %XLim; [] for default
    Monitor4Setting.PSTH.XData=[]; %
    Monitor4Setting.PSTH.YData=[]; %
    Monitor4Setting.PSTH.ZData=[]; %Data matrix to display
    
% --------------------------------------------------------------------
% Reset data
% --------------------------------------------------------------------
function ResetData
global Monitor4Setting Monitor4Handles ExptManParam

if ~isempty(Monitor4Setting)
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %Settings for waveform
        Monitor4Setting.Waveform.XData=[]; %XData
        Monitor4Setting.Waveform.YData=[]; %YData
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %Settings for spikes
        Monitor4Setting.Spikes.XData=[];
        Monitor4Setting.Spikes.YDataFail=[];
        Monitor4Setting.Spikes.YDataPass=[];
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %Settings for raster plot
        Monitor4Setting.Raster.XData=[]; %
        Monitor4Setting.Raster.YData=[]; %
        Monitor4Setting.Raster.ZData=[]; %Data matrix to display
        
        %%%%%%%%%%%%%%%%%%%%%%%
        %Settings for PSTH
        Monitor4Setting.PSTH.XData=[]; %
        Monitor4Setting.PSTH.YData=[]; %
        Monitor4Setting.PSTH.ZData=[]; %Data matrix to display
end

% --------------------------------------------------------------------
% Update the monitor4
% --------------------------------------------------------------------
function Update
global Monitor4Setting

    
if ~isempty(findobj('Tag','figure_Monitor4'))
    
    %Draw waveform
    if Monitor4Setting.Waveform.Flag
        Monitor4 DrawWaveForm;
    end
    %Spike waveform
    if Monitor4Setting.Spikes.Flag
        Monitor4 DrawSpikes;
    end
    %Raster
    if Monitor4Setting.Raster.Flag
        Monitor4 ShowRaster;
    end
    %PSTH
    if Monitor4Setting.PSTH.Flag
        Monitor4 ShowPSTH;
    end
    
end

% --------------------------------------------------------------------
% Plot a waveform
% --------------------------------------------------------------------
function DrawWaveForm
global Monitor4Setting Monitor4Handles

%Check if the figure is open
if ~ishandle(Monitor4Handles.figure_Monitor4)
    return;
end

%Get handles for lines
myh=findobj(Monitor4Handles.axes_Waveform,'Tag','WaveformLine');

%coordinates of the line
x=Monitor4Setting.Waveform.XData;
y=Monitor4Setting.Waveform.YData;
if isempty(x) | isempty(y) %If no data are supplied, draw nothing
    x=[]; y=[];
end

if isempty(myh)
    line(x,y,'Tag','WaveformLine','Parent',Monitor4Handles.axes_Waveform,...
        'LineStyle','-','Color','b');
else
    set(myh,'XData',x,'YData',y);
end


% --------------------------------------------------------------------
% Plot spikes
% --------------------------------------------------------------------
function DrawSpikes
global Monitor4Setting Monitor4Handles

%Check if the figure is open
if ~ishandle(Monitor4Handles.figure_Monitor4)
    return;
end

%Get handles for lines
hFail=findobj(Monitor4Handles.axes_Spikes,'Tag','SpikesLineFail');
delete(hFail);
hPass=findobj(Monitor4Handles.axes_Spikes,'Tag','SpikesLinePass');
delete(hPass);

%coordinates of the line for spikes that failed the criteria
xFail=Monitor4Setting.Spikes.XData;
yFail=Monitor4Setting.Spikes.YDataFail;
if isempty(xFail) | isempty(yFail) %If no data are supplied, draw nothing
    xFail=[];
    yFail=[];
end
hFail=line(xFail,yFail,'Tag','SpikesLineFail','Parent',Monitor4Handles.axes_Spikes,...
    'LineStyle','-','Color',[1 1 1]*.75);

%coordinates of the line for spikes that passed the criteria
xPass=Monitor4Setting.Spikes.XData;
yPass=Monitor4Setting.Spikes.YDataPass;
if isempty(xPass) | isempty(yPass) %If no data are supplied, draw nothing
    xPass=[];
    yPass=[];
end
hPass=line(xPass,yPass,'Tag','SpikesLinePass','Parent',Monitor4Handles.axes_Spikes,...
    'LineStyle','-','Color','b');


% --------------------------------------------------------------------
% Show raster
% --------------------------------------------------------------------
function ShowRaster
global Monitor4Setting Monitor4Handles

%Check if the figure is open
if ~ishandle(Monitor4Handles.figure_Monitor4)
    return;
end
%Get handles for lines
myh=findobj(Monitor4Handles.axes_Raster,'Tag','RasterImage');
%delete(myh);

%coordinates of the line
x=Monitor4Setting.Raster.XData;
y=Monitor4Setting.Raster.YData;
c=64*Monitor4Setting.Raster.ZData;
if isempty(x) | isempty(y) | isempty(c) %If no data are supplied, draw nothing
    x=[]; y=[];  c=[];
    myc=[];
else
    myc=c*64;
end

if ~isempty(myh)
    set(myh,'XData',x,'YData',y,'CData',myc);
else
    myh=image('XData',x,'YData',y,'CData',myc,'Parent',Monitor4Handles.axes_Raster,'Tag','RasterImage');
end
%Adjust limits
if isempty(myc)
    return;
end
dx=abs(x(2)-x(1));
dy=abs(y(2)-y(1));
set(Monitor4Handles.axes_Raster,'XLim',[min(x)-dx/2 max(x)+dx/2],'TickDir','out');
set(Monitor4Handles.axes_Raster,'YLim',[min(y)-dy/2 max(y)+dy/2]);

% --------------------------------------------------------------------
% Show PSTH
% --------------------------------------------------------------------
function ShowPSTH
global Monitor4Setting Monitor4Handles

%Check if the figure is open
if ~ishandle(Monitor4Handles.figure_Monitor4)
    return;
end
%Get handles for lines
myh=findobj(Monitor4Handles.axes_PSTH,'Tag','PSTHImage');

%Data handling
x=Monitor4Setting.PSTH.XData;
y=Monitor4Setting.PSTH.YData;
c=Monitor4Setting.PSTH.ZData;
if isempty(x) | isempty(y) | isempty(c) %If no data are supplied, draw nothing
    x=[];  y=[];   c=[];
    myc=[];
    maxc=0;
else
    maxc=max(c(:));
    if maxc>0
        myc=c/maxc*64;
    else
        myc=zeros(size(c));
    end
end

%Show the data by image
if ~isempty(myh)
    set(myh,'XData',x,'YData',y,'CData',myc);
else
    myh=image('XData',x,'YData',y,'CData',myc,'Parent',Monitor4Handles.axes_PSTH,'Tag','PSTHImage');
end
if isempty(myc)
    return;
end
dx=abs(x(2)-x(1));
%dy=abs(y(2)-y(1));
dy=1;
if strcmpi(get(Monitor4Handles.axes_PSTH,'XLimMode'),'auto') | ...
        isempty(Monitor4Setting.PSTH.XLim)
    set(Monitor4Handles.axes_PSTH,'XLim',[min(x)-dx/2 max(x)+dx/2]);
else
    set(Monitor4Handles.axes_PSTH,'XLim',Monitor4Setting.PSTH.XLim);
end

step=ceil(length(y)/10);
myytick=min(y):step:max(y);

set(Monitor4Handles.axes_PSTH,'YLim',[min(y)-dy/2 max(y)+dy/2],'TickDir','out','YTick',myytick);
%myytick=get(Monitor4Handles.axes_PSTH,'YTick');
%myytick=ceil(myytick);
%set(Monitor4Handles.axes_PSTH,'YTick',myytick,'YTickLabel',myytick);

%Indicate the stimulus number
%Get handles for lines
myh=findobj(Monitor4Handles.axes_PSTH,'Tag','StimIdx');
%coordinates of the point
myxlim=xlim(Monitor4Handles.axes_PSTH);
x=myxlim(2)+diff(myxlim)*0.02;
y=Monitor4Setting.PSTH.StimIdx;
if isempty(x) | isempty(y) %If no data are supplied, draw nothing
    x=[]; y=[];
end
if isempty(myh)
    line(x,y,'Tag','StimIdx','Parent',Monitor4Handles.axes_PSTH,...
        'LineStyle','none','Marker','<','MarkerSize',3,'MarkerFaceColor','r','MarkerEdgeColor','r','Clipping','off');
else
    set(myh,'XData',x,'YData',y);
end


%Arrange the color bar
myh=findobj(Monitor4Handles.axes_PSTHColorBar,'Tag','PSTHColorBarImage');
if ~isempty(myh)
    set(myh,'XData',1:64,'YData',1,'CData',1:64);
else
    myh=image('XData',1:64,'YData',1,'CData',1:64,...
        'Parent',Monitor4Handles.axes_PSTHColorBar,'Tag','PSTHColorBarImage');
end

if maxc>0
    mytick=[1 64];
    myticklabel=[0 maxc*1000];
else
    mytick=[1 64];
    myticklabel=[0 1];
end
set(Monitor4Handles.axes_PSTHColorBar,'XTick',mytick,'XTicklabel',myticklabel,'XLim',[0.5 64.5]);

% --------------------------------------------------------------------
% Close the monitor4 window
% --------------------------------------------------------------------
function CloseMonitor4
global Monitor4Handles

myh=findobj('Tag','figure_Monitor4');
if ~isempty(myh)
    delete (myh);
end

% --------------------------------------------------------------------
% Toggle off the button for the monitor4 in ExptMan
function varargout = myclosereq

Monitor4('CloseMonitor4');
if ~isempty(findobj('Tag','fig_exptmanM'))
    ExptManM('Monitor4Closed');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Subfunctions for internal use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% Initialize the structure for the settings
% --------------------------------------------------------------------
function Initialize
global Monitor4Setting Monitor4Handles ExptManParam

%Create structure for storing the settings if not exist already
if isempty(Monitor4Setting)
    Monitor4 DefaultSetting;
end %if isempty(Monitor4Setting)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the paramters
h=Monitor4Handles;
s=Monitor4Setting;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Colormap for the figure
set(h.figure_Monitor4,'ColorMap',jet(64));

%Voltage as 100%
set(h.edit_VoltageFor100Percent,'string',num2str(s.VoltageFor100Percent));

%Waveform
set(h.checkbox_Waveform,'value',s.Waveform.Flag);
set(h.edit_WaveXLim,'string',num2str(s.Waveform.XLim));
set(h.edit_WaveYLim,'string',num2str(s.Waveform.YLim));
if isempty(s.Waveform.XLim)
    set(h.axes_Waveform,'XLim',[0 1],'XLimMode','auto');
else
    set(h.axes_Waveform,'XLim',s.Waveform.XLim,'XLimMode','manual');
end
if isempty(s.Waveform.YLim)
    set(h.axes_Waveform,'YLim',[0 1],'YLimMode','auto');
else
    set(h.axes_Waveform,'YLim',s.Waveform.YLim,'YLimMode','manual');
end
set(h.checkbox_ReverseWave,'value',s.Waveform.ReverseFlag);
set(h.checkbox_FilterWave,'value',s.Waveform.FilterFlag);
ToggleWaveform;

%Spikes
set(h.checkbox_Spikes,'value',s.Spikes.Flag);
set(h.edit_SpikeXLim,'string',num2str(s.Spikes.XLim));
set(h.edit_SpikeYLim,'string',num2str(s.Spikes.YLim));
set(h.axes_Spikes,'XLim',s.Spikes.XLim);
set(h.axes_Spikes,'YLim',s.Spikes.YLim);
set(h.slider_SpikeCutThresh,'value',s.Spikes.CutThresh);
set(h.edit_SpikeCutThresh,'string',num2str(s.Spikes.CutThresh));
set(h.checkbox_SpikeCriterion1,'value',s.Spikes.Criterion1.Flag);
set(h.edit_SpikeT1,'string',num2str(s.Spikes.Criterion1.t));
set(h.slider_SpikeT1,'value',s.Spikes.Criterion1.t);
set(h.edit_SpikeHi1,'string',num2str(s.Spikes.Criterion1.Hi));
set(h.slider_SpikeHi1,'value',s.Spikes.Criterion1.Hi);
set(h.edit_SpikeLo1,'string',num2str(s.Spikes.Criterion1.Lo));
set(h.slider_SpikeLo1,'value',s.Spikes.Criterion1.Lo);
set(h.checkbox_SpikeCriterion2,'value',s.Spikes.Criterion2.Flag);
set(h.edit_SpikeT2,'string',num2str(s.Spikes.Criterion2.t));
set(h.slider_SpikeT2,'value',s.Spikes.Criterion2.t);
set(h.edit_SpikeHi2,'string',num2str(s.Spikes.Criterion2.Hi));
set(h.slider_SpikeHi2,'value',s.Spikes.Criterion2.Hi);
set(h.edit_SpikeLo2,'string',num2str(s.Spikes.Criterion2.Lo));
set(h.slider_SpikeLo2,'value',s.Spikes.Criterion2.Lo);
ToggleSpikes;

%Raster
set(h.checkbox_Raster,'value',s.Raster.Flag);
ToggleRaster;

%PSTH
set(h.checkbox_PSTH,'value',s.PSTH.Flag);
set(h.edit_PSTHXLim,'string',num2str(s.PSTH.XLim));
TogglePSTH;

%
set(h.figure_Monitor4,'ColorMap',hot);



% --------------------------------------------------------------------
% Toggle the plot for waveform
% --------------------------------------------------------------------
function ToggleWaveform
global Monitor4Setting Monitor4Handles

myh=[   Monitor4Handles.text_WaveXLim Monitor4Handles.edit_WaveXLim ...
        Monitor4Handles.text_WaveYLim Monitor4Handles.edit_WaveYLim ...
        Monitor4Handles.checkbox_ReverseWave Monitor4Handles.checkbox_FilterWave ...
        Monitor4Handles.text_WaveformXLabel Monitor4Handles.text_WaveformYLabel ...
    ];

Flag=get(Monitor4Handles.checkbox_Waveform,'value');
if Flag
    set(myh,'Enable','on');
    set(Monitor4Handles.axes_Waveform,'Color','w');
else
    set(myh,'Enable','off');
    set(Monitor4Handles.axes_Waveform,'Color',[.83 .81 .78]);
end

Monitor4Setting.Waveform.Flag=Flag;

% --------------------------------------------------------------------
% Toggle the plot for spikes
% --------------------------------------------------------------------
function ToggleSpikes
global Monitor4Setting Monitor4Handles

myh=[   Monitor4Handles.text_SpikeXLim Monitor4Handles.edit_SpikeXLim ...
        Monitor4Handles.text_SpikeYLim Monitor4Handles.edit_SpikeYLim ...
        Monitor4Handles.text_SpikeXLabel Monitor4Handles.text_SpikeYLabel ...
        Monitor4Handles.text_SpikeCutThresh Monitor4Handles.edit_SpikeCutThresh ...
        Monitor4Handles.checkbox_SpikeCriterion1 Monitor4Handles.checkbox_SpikeCriterion2 ...
    ];
myh1=[   Monitor4Handles.text_SpikeT1 Monitor4Handles.slider_SpikeT1 Monitor4Handles.edit_SpikeT1 ...
        Monitor4Handles.text_SpikeHi1 Monitor4Handles.slider_SpikeHi1 Monitor4Handles.edit_SpikeHi1 ...
        Monitor4Handles.text_SpikeLo1 Monitor4Handles.slider_SpikeLo1 Monitor4Handles.edit_SpikeLo1 ...
    ];
myh2=[   Monitor4Handles.text_SpikeT2 Monitor4Handles.slider_SpikeT2 Monitor4Handles.edit_SpikeT2 ...
        Monitor4Handles.text_SpikeHi2 Monitor4Handles.slider_SpikeHi2 Monitor4Handles.edit_SpikeHi2 ...
        Monitor4Handles.text_SpikeLo2 Monitor4Handles.slider_SpikeLo2 Monitor4Handles.edit_SpikeLo2 ...
    ];

Flag=get(Monitor4Handles.checkbox_Spikes,'value');
if Flag
    set(myh,'Enable','on');
    set(Monitor4Handles.axes_Spikes,'Color','w');
    ToggleSpikeCriterion1;
    ToggleSpikeCriterion2;
else
    set(myh,'Enable','off');
    set(myh1,'Enable','off');
    set(myh2,'Enable','off');
    set(Monitor4Handles.axes_Spikes,'Color',[.83 .81 .78]);
end
%Update the setting structure
Monitor4Setting.Spikes.Flag=Flag;

% --------------------------------------------------------------------
% Toggle settings for spike detection criterion 1
% --------------------------------------------------------------------
function ToggleSpikeCriterion1
global Monitor4Setting Monitor4Handles

myh=[   Monitor4Handles.text_SpikeT1 Monitor4Handles.slider_SpikeT1 Monitor4Handles.edit_SpikeT1 ...
        Monitor4Handles.text_SpikeHi1 Monitor4Handles.slider_SpikeHi1 Monitor4Handles.edit_SpikeHi1 ...
        Monitor4Handles.text_SpikeLo1 Monitor4Handles.slider_SpikeLo1 Monitor4Handles.edit_SpikeLo1 ...
    ];

Flag=get(Monitor4Handles.checkbox_SpikeCriterion1,'value');
if Flag
    set(myh,'Enable','on');
else
    set(myh,'Enable','off');
end

%Update the setting structure
Monitor4Setting.Spikes.Criterion1.Flag=Flag;
%Draw a line indicating criterion
DrawCriterionLines

% --------------------------------------------------------------------
% Toggle settings for spike detection criterion 2
% --------------------------------------------------------------------
function ToggleSpikeCriterion2
global Monitor4Setting Monitor4Handles

myh=[   Monitor4Handles.text_SpikeT2 Monitor4Handles.slider_SpikeT2 Monitor4Handles.edit_SpikeT2 ...
        Monitor4Handles.text_SpikeHi2 Monitor4Handles.slider_SpikeHi2 Monitor4Handles.edit_SpikeHi2 ...
        Monitor4Handles.text_SpikeLo2 Monitor4Handles.slider_SpikeLo2 Monitor4Handles.edit_SpikeLo2 ...
    ];

Flag=get(Monitor4Handles.checkbox_SpikeCriterion2,'value');
if Flag
    set(myh,'Enable','on');
else
    set(myh,'Enable','off');
end

%Update the setting structure
Monitor4Setting.Spikes.Criterion2.Flag=Flag;

%Draw a line indicating criterion
DrawCriterionLines

% --------------------------------------------------------------------
% Toggle the plot for raster
% --------------------------------------------------------------------
function ToggleRaster
global Monitor4Setting Monitor4Handles

Flag=get(Monitor4Handles.checkbox_Raster,'value');
if Flag
    set(Monitor4Handles.text_RasterXLabel,'Enable','on');
    set(Monitor4Handles.axes_Raster,'XColor','k','YColor','k');
else
    set(Monitor4Handles.text_RasterXLabel,'Enable','off');
    set(Monitor4Handles.axes_Raster,'XColor',[.83 .81 .78],'YColor',[.83 .81 .78]);
end

%Update the setting structure
Monitor4Setting.Raster.Flag=Flag;


% --------------------------------------------------------------------
% Toggle the plot for PSTH
% --------------------------------------------------------------------
function TogglePSTH
global Monitor4Setting Monitor4Handles

myh=[   Monitor4Handles.text_PSTHXLim Monitor4Handles.edit_PSTHXLim ...
        Monitor4Handles.text_PSTHXLabel Monitor4Handles.text_PSTHYLabel ...
        Monitor4Handles.text_PSTHColorBarLabel Monitor4Handles.pushbutton_PSTHRefresh...        
    ];

Flag=get(Monitor4Handles.checkbox_PSTH,'value');

if Flag
    set(myh,'Enable','on');
    set(Monitor4Handles.axes_PSTH,'XColor','k','YColor','k');
    set(Monitor4Handles.axes_PSTHColorBar,'XColor','k','YColor','k');
else
    set(myh,'Enable','off');
    set(Monitor4Handles.axes_PSTH,'XColor',[.83 .81 .78],'YColor',[.83 .81 .78]);
    set(Monitor4Handles.axes_PSTHColorBar,'XColor',[.83 .81 .78],'YColor',[.83 .81 .78]);
end

%Update the setting structure
Monitor4Setting.PSTH.Flag=Flag;

% --------------------------------------------------------------------
% Draw lines for criterions
% --------------------------------------------------------------------
function DrawCriterionLines
global Monitor4Setting Monitor4Handles

%Get handles for lines
h0s=findobj(Monitor4Handles.axes_Spikes,'Tag','CutThreshLine');
h0w=findobj(Monitor4Handles.axes_Waveform,'Tag','CutThreshLine');
h1=findobj(Monitor4Handles.axes_Spikes,'Tag','CriterionLine1');
h2=findobj(Monitor4Handles.axes_Spikes,'Tag','CriterionLine2');


%Cut threshold for waveform plot
%coordinates of the line
if ~isempty(Monitor4Setting.Waveform.XData)
    x=[min(Monitor4Setting.Waveform.XData) max(Monitor4Setting.Waveform.XData)];
    y=[1 1]*Monitor4Setting.Spikes.CutThresh;
else
    x=[];
    y=[];
end
if isempty(h0w)
    h0w=line(x,y,'Tag','CutThreshLine','Parent',Monitor4Handles.axes_Waveform,...
        'LineStyle','--','Color','k');
else
    set(h0w,'XData',x,'YData',y);
end

%Cut threshold for spike plot
%coordinates of the line
x=get(Monitor4Handles.axes_Spikes,'XLim');
y=[1 1]*Monitor4Setting.Spikes.CutThresh;
if isempty(h0s)
    h0s=line(x,y,'Tag','CutThreshLine','Parent',Monitor4Handles.axes_Spikes,...
        'LineStyle','--','Color','k');
else
    set(h0s,'XData',x,'YData',y);
end

if Monitor4Setting.Spikes.Criterion1.Flag %If the flag for the criterion is on
    %coordinates of the line
    x=[1 1]*Monitor4Setting.Spikes.Criterion1.t;
    y=[Monitor4Setting.Spikes.Criterion1.Lo Monitor4Setting.Spikes.Criterion1.Hi];
    if isempty(h1)
        h1=line(x,y);
        set(h1,'Tag','CriterionLine1','Parent',Monitor4Handles.axes_Spikes,...
            'LineStyle','-','Color','r','Marker','.','MarkerEdgeColor','auto');
    else
        set(h1,'XData',x,'YData',y);
    end
else %Delete the line if the flag is off
    if ~isempty(h1)
        delete(h1);
    end
end

if Monitor4Setting.Spikes.Criterion2.Flag %If the flag for the criterion is on
    %coordinates of the line
    x=[1 1]*Monitor4Setting.Spikes.Criterion2.t;
    y=[Monitor4Setting.Spikes.Criterion2.Lo Monitor4Setting.Spikes.Criterion2.Hi];
    if isempty(h2)
        h2=line(x,y);
        set(h2,'Tag','CriterionLine2','Parent',Monitor4Handles.axes_Spikes,...
            'LineStyle','-','Color',[0 0.75 0],'Marker','.','MarkerEdgeColor','auto');
    else
        set(h2,'XData',x,'YData',y);
    end
else %Delete the line if the flag is off
    if ~isempty(h2)
        delete(h2);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
function varargout = checkbox_Waveform_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

ToggleWaveform;


% --------------------------------------------------------------------
function varargout = checkbox_ReverseWave_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

Monitor4Setting.Waveform.ReverseFlag=get(h,'value'); %Update the setting structure



% --------------------------------------------------------------------
function varargout = checkbox_FilterWave_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

Monitor4Setting.Waveform.FilterFlag=get(h,'value'); %Update the setting structure


% --------------------------------------------------------------------
function varargout = edit_WaveXLim_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));

if length(myval)==1 %If only one number is specified, use that for upper and lower lim
    myval=[0 1]*abs(myval);
elseif length(myval(:))>2 %More than 2 numbers
    myval=[myval(1) myval(2)];
end
if any(isnan(myval)) %Not a number
    myval=[];
end
myval=sort(myval);

if isempty(myval) %Empty value indicates 'auto' mode
    set(handles.axes_Waveform,'XLimMode','auto');
else
    set(handles.axes_Waveform,'XLim',myval);
end

Monitor4Setting.Waveform.XLim=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_WaveYLim_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));

if length(myval)==1 %If only one number is specified, use that for upper and lower lim
    myval=[-1 1]*abs(myval);
elseif length(myval(:))>2 %More than 2 numbers
    myval=[myval(1) myval(2)];
end
if any(isnan(myval)) %Not a number
    myval=[];
end
myval=sort(myval);

if isempty(myval) %Empty value indicates 'auto' mode
    set(handles.axes_Waveform,'YLimMode','auto');
else
    set(handles.axes_Waveform,'YLim',myval);
end

Monitor4Setting.Waveform.YLim=myval; %Update the setting structure


% --------------------------------------------------------------------
function varargout = checkbox_Spikes_Callback(h, eventdata, handles, varargin)

ToggleSpikes;


% --------------------------------------------------------------------
function varargout = edit_SpikeXLim_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));

if length(myval)==1 %If only one number is specified, use that for upper and lower lim
    myval=[0 1]*abs(myval);
elseif length(myval(:))>2 %More than 2 numbers
    myval=[myval(1) myval(2)];
end
if any(isnan(myval)) %Not a number
    myval=[];
end
myval=sort(myval);

if isempty(myval) %Empty value indicates 'auto' mode
    set(handles.axes_Spikes,'XLimMode','auto');
else
    set(handles.axes_Spikes,'XLim',myval);
end

Monitor4Setting.Spikes.XLim=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_SpikeYLim_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));

if length(myval)==1 %If only one number is specified, use that for upper and lower lim
    myval=[-1 1]*abs(myval);
elseif length(myval(:))>2 %More than 2 numbers
    myval=[myval(1) myval(2)];
end
if any(isnan(myval)) %Not a number
    myval=[];
end
myval=sort(myval);

if isempty(myval) %Empty value indicates 'auto' mode
    set(handles.axes_Spikes,'YLimMode','auto');
else
    set(handles.axes_Spikes,'YLim',myval);
end

Monitor4Setting.Spikes.YLim=myval; %Update the setting structure



% --------------------------------------------------------------------
function varargout = slider_SpikeCutThresh_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value
set(handles.edit_SpikeCutThresh,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.CutThresh=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_SpikeCutThresh_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string'));
%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.CutThresh;
    set(handles.edit_SpikeCutThresh,'string',num2str(myval)); %Correct the edit box
elseif myval>100
    myval=100;
    set(handles.edit_SpikeCutThresh,'string',num2str(myval)); %Correct the edit box
elseif myval<-0
    myval=0;
    set(handles.edit_SpikeCutThresh,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.CutThresh;
    set(handles.edit_SpikeCutThresh,'string',num2str(myval)); %Correct the edit box
end

set(handles.slider_SpikeCutThresh,'value',myval); %Update the slider
Monitor4Setting.Spikes.CutThresh=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = checkbox_SpikeCriterion1_Callback(h, eventdata, handles, varargin)

ToggleSpikeCriterion1;


% --------------------------------------------------------------------
function varargout = slider_SpikeT1_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value
set(handles.edit_SpikeT1,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.Criterion1.t=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines

% --------------------------------------------------------------------
function varargout = edit_SpikeT1_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string')); %get the current value

%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.Criterion1.t;
    set(handles.edit_SpikeT1,'string',num2str(myval)); %Correct the edit box
elseif myval>2
    myval=2;
    set(handles.edit_SpikeT1,'string',num2str(myval)); %Correct the edit box
elseif myval<0
    myval=0;
    set(handles.edit_SpikeT1,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.Criterion1.t;
    set(handles.edit_SpikeT1,'string',num2str(myval)); %Correct the edit box
end

set(handles.slider_SpikeT1,'value',myval); %Update the slider
Monitor4Setting.Spikes.Criterion1.t=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = slider_SpikeHi1_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value

%Error handling -- Higher cutoff lower than the lower cutoff
myvalLo=get(handles.slider_SpikeLo1,'value');
if myval<myvalLo
    myval=myvalLo;
    set(h,'value',myval);
end

set(handles.edit_SpikeHi1,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.Criterion1.Hi=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines

% --------------------------------------------------------------------
function varargout = edit_SpikeHi1_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string')); %get the current value

%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.Criterion1.Hi;
    set(handles.edit_SpikeHi1,'string',num2str(myval)); %Correct the edit box
elseif myval>100
    myval=100;
    set(handles.edit_SpikeHi1,'string',num2str(myval)); %Correct the edit box
elseif myval<-100
    myval=-100;
    set(handles.edit_SpikeHi1,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.Criterion1.Hi;
    set(handles.edit_SpikeHi1,'string',num2str(myval)); %Correct the edit box
end

%Error handling -- Higher cutoff lower than the lower cutoff
myvalLo=str2num(get(handles.edit_SpikeLo1,'string'));
if myval<myvalLo
    myval=myvalLo;
    set(h,'string',num2str(myval));
end

set(handles.slider_SpikeHi1,'value',myval); %Update the slider
Monitor4Setting.Spikes.Criterion1.Hi=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = slider_SpikeLo1_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value

%Error handling -- Higher cutoff lower than the lower cutoff
myvalHi=get(handles.slider_SpikeHi1,'value');
if myval>myvalHi
    myval=myvalHi;
    set(h,'value',myval);
end

set(handles.edit_SpikeLo1,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.Criterion1.Lo=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_SpikeLo1_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string')); %get the current value

%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.Criterion1.Lo;
    set(handles.edit_SpikeLo1,'string',num2str(myval)); %Correct the edit box
elseif myval>100
    myval=100;
    set(handles.edit_SpikeLo1,'string',num2str(myval)); %Correct the edit box
elseif myval<-100
    myval=-100;
    set(handles.edit_SpikeLo1,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.Criterion1.Lo;
    set(handles.edit_SpikeLo1,'string',num2str(myval)); %Correct the edit box
end

%Error handling -- Higher cutoff lower than the lower cutoff
myvalHi=str2num(get(handles.edit_SpikeHi1,'string'));
if myval>myvalHi
    myval=myvalHi;
    set(h,'string',num2str(myval));
end

set(handles.slider_SpikeLo1,'value',myval); %Update the slider
Monitor4Setting.Spikes.Criterion1.Lo=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines




% --------------------------------------------------------------------
function varargout = checkbox_SpikeCriterion2_Callback(h, eventdata, handles, varargin)

ToggleSpikeCriterion2;


% --------------------------------------------------------------------
function varargout = slider_SpikeT2_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value
set(handles.edit_SpikeT2,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.Criterion2.t=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_SpikeT2_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string')); %get the current value

%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.Criterion2.t;
    set(handles.edit_SpikeT2,'string',num2str(myval)); %Correct the edit box
elseif myval>2
    myval=2;
    set(handles.edit_SpikeT2,'string',num2str(myval)); %Correct the edit box
elseif myval<0
    myval=0;
    set(handles.edit_SpikeT2,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.Criterion2.t;
    set(handles.edit_SpikeT2,'string',num2str(myval)); %Correct the edit box
end

set(handles.slider_SpikeT2,'value',myval); %Update the slider
Monitor4Setting.Spikes.Criterion2.t=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines




% --------------------------------------------------------------------
function varargout = slider_SpikeHi2_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value

%Error handling -- Higher cutoff lower than the lower cutoff
myvalLo=get(handles.slider_SpikeLo2,'value');
if myval<myvalLo
    myval=myvalLo;
    set(h,'value',myval);
end

set(handles.edit_SpikeHi2,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.Criterion2.Hi=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_SpikeHi2_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string')); %get the current value

%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.Criterion2.Hi;
    set(handles.edit_SpikeHi2,'string',num2str(myval)); %Correct the edit box
elseif myval>100
    myval=100;
    set(handles.edit_SpikeHi2,'string',num2str(myval)); %Correct the edit box
elseif myval<-100
    myval=-100;
    set(handles.edit_SpikeHi2,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.Criterion2.Hi;
    set(handles.edit_SpikeHi2,'string',num2str(myval)); %Correct the edit box
end

%Error handling -- Higher cutoff lower than the lower cutoff
myvalLo=str2num(get(handles.edit_SpikeLo2,'string'));
if myval<myvalLo
    myval=myvalLo;
    set(h,'string',num2str(myval));
end

set(handles.slider_SpikeHi2,'value',myval); %Update the slider
Monitor4Setting.Spikes.Criterion2.Hi=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = slider_SpikeLo2_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=get(h,'value'); %get the current value

%Error handling -- Higher cutoff lower than the lower cutoff
myvalHi=get(handles.slider_SpikeHi2,'value');
if myval>myvalHi
    myval=myvalHi;
    set(h,'value',myval);
end

set(handles.edit_SpikeLo2,'string',num2str(myval)); %Update the edit box
Monitor4Setting.Spikes.Criterion2.Lo=myval; %Update the setting structure

%Draw a line indicating criterion
DrawCriterionLines


% --------------------------------------------------------------------
function varargout = edit_SpikeLo2_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

myval=str2num(get(h,'string')); %get the current value

%Error handling
if length(myval)~=1 %Number should be a scalar
    myval=Monitor4Setting.Spikes.Criterion2.Lo;
    set(handles.edit_SpikeLo2,'string',num2str(myval)); %Correct the edit box
elseif myval>100
    myval=100;
    set(handles.edit_SpikeLo2,'string',num2str(myval)); %Correct the edit box
elseif myval<-100
    myval=-100;
    set(handles.edit_SpikeLo2,'string',num2str(myval)); %Correct the edit box
elseif isnan(myval) | ~isreal(myval)
    myval=Monitor4Setting.Spikes.Criterion2.Lo;
    set(handles.edit_SpikeLo2,'string',num2str(myval)); %Correct the edit box
end

%Error handling -- Higher cutoff lower than the lower cutoff
myvalHi=str2num(get(handles.edit_SpikeHi2,'string'));
if myval>myvalHi
    myval=myvalHi;
    set(h,'string',num2str(myval));
end

set(handles.slider_SpikeLo2,'value',myval); %Update the slider
Monitor4Setting.Spikes.Criterion2.Lo=myval; %Update the setting structure


%Draw a line indicating criterion
DrawCriterionLines



% --------------------------------------------------------------------
function varargout = checkbox_Raster_Callback(h, eventdata, handles, varargin)

ToggleRaster;


% --------------------------------------------------------------------
function varargout = checkbox_PSTH_Callback(h, eventdata, handles, varargin)

TogglePSTH;


% --------------------------------------------------------------------
function varargout = edit_PSTHXLim_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));

if length(myval)==1 %If only one number is specified, use that for upper and lower lim
    myval=[0 1]*abs(myval);
elseif length(myval(:))>2 %More than 2 numbers
    myval=[myval(1) myval(2)];
end
if any(isnan(myval)) %Not a number
    myval=[];
end
myval=sort(myval);

if isempty(myval) %Empty value indicates 'auto' mode
    set(handles.axes_PSTH,'XLimMode','auto');
else
    set(handles.axes_PSTH,'XLim',myval);
end

Monitor4Setting.PSTH.XLim=myval; %Update the setting structure




% --------------------------------------------------------------------
function varargout = pushbutton_PSTHRefresh_Callback(h, eventdata, handles, varargin)
global Monitor4Setting


%Clear the PSTH data
Monitor4Setting.PSTH.XData=[];
Monitor4Setting.PSTH.YData=[];
Monitor4Setting.PSTH.ZData=[];


% --------------------------------------------------------------------
function varargout = edit_VoltageFor100Percent_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));
%Illegal value -- use the current one
if isempty(myval) | any(isnan(myval))
    set(h,'string',num2str(Monitor4Setting.VoltageFor100Percent));
else
    Monitor4Setting.VoltageFor100Percent=myval(1);
end





% --------------------------------------------------------------------
function varargout = edit_FilterOrder_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));
%Illegal value -- use the current one
if isempty(myval)
    set(h,'string',num2str(Monitor4Setting.FilterOrder));
elseif myval(1)< 1 | any(isnan(myval))
    set(h,'string',num2str(Monitor4Setting.FilterOrder));
else
    Monitor4Setting.FilterOrder=myval(1);

    %Reset the coefficients
    Monitor4Setting.FilterB=[]; %Filter coefficients B
    Monitor4Setting.FilterA=[]; %Filter coefficients A
end


% --------------------------------------------------------------------
function varargout = edit_FilterPassband_Callback(h, eventdata, handles, varargin)
global Monitor4Setting

%Get the value
myval=str2num(get(h,'string'));

%Illegal value -- use the current one
if length(myval)~=2
    set(h,'string',num2str(Monitor4Setting.FilterPassband));
elseif any(isnan(myval)) | min(myval)<=0
    set(h,'string',num2str(Monitor4Setting.FilterPassband));
else
    Monitor4Setting.FilterPassband=sort(myval);

    %Reset the coefficients
    Monitor4Setting.FilterB=[]; %Filter coefficients B
    Monitor4Setting.FilterA=[]; %Filter coefficients A
end


