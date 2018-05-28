function [D, Stim] = StimulusDashboard(keyword, varargin);
% StimulusDashboard - dashboard of stimulus OUIs
%   StimulusDashboard('OUI') returns a paramset object containing the
%   generic uicontrols for checking stimulus parameters, playing/recording, etc.
%   StimulusDashboard('OUI', Yoffset) offsets all OUI elements by Yoffset 
%   points downwards. This is used to avoid any overlap with elements of other
%   OUIs on the dialog.
%
%   StimulusDashboard('current') returns the most recently tested paramset
%   taken from the OUI if that has passed all tests. If the most recent
%   tests failed, or if no paramset was tested, a void paramset is returned.
%
%   StimulusDashboard('previous') returns the last succesfull (correct)
%   paramset obtained from the current OUI, even if it was obtained
%   during a previous MatLab session.
%   
%   StimulusDashboard is also the callback function of the elements of the
%   OUI generated by the paramset returned by StimulusDashboard('OUI').
%   The action is delegated to other functions according to a fixed set
%   of descriptions. Consult the source code of StimulusDashboard for details.
%   
%    See also paramOUI, launchStimOUI.

persistent currentParam;

[hcn, figh] = gcbo; % handle of calling uicontrol and its parent figure
% make sure that callback figure is the current OUI
if ~isempty(figh), paramOUI(figh); end

if nargin<1, % must be callback by uicontrol or uimenu; use tag to find out which one
   keyword = get(hcn, 'tag');
end

switch lower(keyword),
case 'oui',
   D = localInitDashboard(varargin{:});
case 'current',
   D = currentParam;
   %=============callbacks from here=================
case {'play', 'playbutton', 'play2menuitem'},
   DoComputeWaveforms = 1;
   [D, Stim] = stimulusDashboard('check', DoComputeWaveforms); 
   if isvoid(D), return; end
   PRP = readOUI('playRecord'); % settings of stutter and repeat buttons
   stimulusDashboard('disable');
   Stim = localPlay(D,Stim, PRP);
   stimulusDashboard('enable');
   public(Stim); % hack for debugging
case {'stop', 'stopbutton', 'stop2menu'},
   DAhalt;
case {'checkbutton', 'check', 'check2menuitem'},
   OUIitemContextMenuCallback('enableall'); % clear temporary disabling of OUI items 
   PRP = readOUI('playRecord'); % settings of stutter and repeat buttons
   stimulusDashboard('disable');
   if nargin>1, DoComputeWaveforms = varargin{1}; else, DoComputeWaveforms = 0; end
   [currentParam, D, Stim] = localCheckAndUpdate(DoComputeWaveforms, PRP); % D is dataset
   curds(D); % hack for debugging: make temporary dataset D the current dataset
   if ~isvoid(currentParam), % store current params in .ouidef file
      OUIdefault('save', currentParam);
      OUIdefault('save', PRP, ['dashboard_for_' currentParam.name]);
   end
   stimulusDashboard('enable');
   public(Stim); % hack for debugging
case 'retrieveplayrecordparams',
   GD = ouiData; 
   OUIdefault('impose', GD.ParamData(2), ['dashboard_for_' GD.ParamData(1).name]);
case 'collectdashboardhandles',
   PRPhandles = OUIhandle({'Check' 'Close' 'Play' 'PlayRecord' 'repeat' 'stutter', ...
         'Check2' 'Play2' 'PlayRecord2' 'Action', ...
         'Defaults', 'ParamSave', 'ParamRetrieve'});
   OUIdata('set', 'PRPhandles', PRPhandles);
case {'enable', 'disable'},
   if isequal('enable', lower(keyword)), Mode = 'on'; else, Mode='off'; end
   hPRP = OUIdata('get', 'PRPhandles'); % handles of play button etc
   set(hPRP, 'enable', Mode);
   drawnow;
case {'paramsavemenuitem'},
   GD = ouiData; 
   StimParam = readOUI(GD.ParamData(1).name); % read but ignore disabled OUI items
   if isvoid(StimParam), return; end % something went wrong
   OUIdefault('save', StimParam, '?put'); 
   ouiitemcontextMenuCallback('enableall');
case 'paramretrievemenuitem',
   ouidefault('impose', [], '?get');
case {'closebutton' 'close'},
   % check if close button is enabled (note that close attempt may stem from Alt-F4 or X button)
   closeHandle = OUIhandle('close');
   if ~isequal('on', get(closeHandle, 'enable')), return; end % refuse to close if close button is disabled
   OUIpos('save');
   delete(figh);
otherwise,
   error(['Invalid keyword ''' keyword '''.'])
end


%=======================================================================================
%======locals===========================================================================
%=======================================================================================
function D = localInitDashboard(varargin);
% generic dashboard for stimulus dialogs
if nargin<1, Yoffset = 0;
else, Yoffset = varargin{1};
end
TThit2 = 'Hit button to ';
BigButt = [71 40]; % size of big button
D = paramset('Dashboard', 'PlayRecord', 'Play/Record Panel', 1, [430 Yoffset], mfilename);
D = AddParam(D,  'stutter    Off OnOff switchState inf');
D = AddParam(D,  'repeat     On OnOff switchState inf');
%====================================================
D = InitOUIgroup(D, 'messages', [120 Yoffset+10 120-1e6 60]);
D = defineReporter(D, 'stdmess', [15 5], [15-1e6 50]);
%====================================================
D = InitOUIgroup(D, 'CheckClose', [10 Yoffset+10 10-1e6 70], 'invisible');
D = addActionButton(D, 'Check', 'Check/Update', [20 25 BigButt], mfilename, ...
   'Check if current set of parameters will fly; update all info texts (dark red stuff).');
D = addActionButton(D, 'Close', 'Close', [330 25 BigButt], mfilename, ...
   'Close this dialog. This button is disabled during DA -> RIGHTclick for an emergency stop.');
%====================================================
D = InitOUIgroup(D, 'PlayRecordStop', [10 Yoffset+80 10-1e6 70], '');
D = addActionButton(D, 'Play', 'PLAY', [20 25 BigButt], mfilename, ...
   'Play stimulus without recording spikes.');
D = addActionButton(D, 'PlayRecord', 'PLAY/RECORD', [155 25 BigButt], mfilename, ...
   'Play stimulus and record spike times.');
D = addActionButton(D, 'Stop', 'STOP', [310 25 BigButt], mfilename, ...
   'Immediately interrupt any ongoing D/A and data collection.');
D = DefineQuery(D, 'repeat', [50 42], 'toggle', 'Repeat:', {'Off', 'On'}, ...
   [TThit2 'enable/disable repeat mode (Play only).' ]);
D = DefineQuery(D, 'stutter', [200 42], 'toggle', 'Stutter:', {'Off', 'On'}, ...
   [TThit2 'enable/disable stutter mode.' ]);
% ====== provide OUI with some generic menus
D = addMenu(D, 'Stop2', '&Stop', mfilename);
D = addMenu(D, 'Action', '&Action');
D = addMenuItem(D, 'Check2', 'Action', '&Check/Update', 'C', mfilename);
D = addMenuItem(D, 'Play2', 'Action', '_&Play', 'P', mfilename);
D = addMenuItem(D, 'PlayRecord2', 'Action', 'Play/&Record', 'R', mfilename);
D = addMenu(D, 'Defaults', '&Defaults');
D = addMenuItem(D, 'ParamSave', 'Defaults', ...
   'Save &current parameters', 'S', mfilename);
D = addMenuItem(D, 'ParamRetrieve', 'Defaults', ...
   'Get parameters from file', 'O', mfilename);
for ii=1:10,
   iistr = num2sstr(ii);
   tag = ['VarParamRetrieve' iistr];
   lab = ['&' iistr ' XX']; if ii==1, lab = ['_' lab]; end
   D = addMenuItem(D, tag, 'Defaults', lab, '', mfilename, 'visible', 'off');
end
D = addMenuItem(D, 'ParamSaveAsSearch', 'Defaults', ...
   '_Save as search stimulus', '', mfilename);
%------couleur locale
Reddish = [0.82 0.8 0.8];
D = AddInitCommand(D,  'Ouihandle', 'stdmess.text', nan, 'fontweight', 'bold');
D = AddInitCommand(D,  'Ouihandle', 'PlayRecordStop.frame', nan, 'backgroundcolor', Reddish);
D = AddInitCommand(D,  'Ouihandle', 'repeat.prompt', nan, 'backgroundcolor', Reddish);
D = AddInitCommand(D,  'Ouihandle', 'stutter.prompt', nan, 'backgroundcolor', Reddish);

function [StimParam, DS, ST] = localCheckAndUpdate(DoComputeWaveforms, PRP);
OUIreport('Checking stimulus parameters..',0); % 0=black text
[DS, ST] = deal(dataset, stimulus);  % pessimistic defaults: void objects
GD = ouiData; 
StimParam = readOUI(GD.ParamData(1).name); % the current stimulus paramset values
if isvoid(StimParam), return; end; % everything returned is void ...
stimChecker = StimParam.creator; % the pollutor pays for the cleansing
% Note: random seed is refreshed below by stimulusContext(1).
[DS, ST] = feval(stimChecker, 'check', StimParam, stimulusContext(1), DoComputeWaveforms);
if isvoid(DS), % void DS indicates that stimChecker failed; ..
   StimParam = paramset; % return all voids to make clear something went wrong
   ST = stimulus;
end
% whatever happened, the non-voidness of StimParam is an indication that all went right
if ~isvoid(StimParam), 
   OUIreport('Stimulus parameters OK',0); 
   StimDurReport(DS, PRP);
end

function Stim = localPlay(DS, Stim, PRP);
% provisory
doRepeat = PRP.repeat.as_logical;
firstTime = 1;
OUIreport('Preparing stimulus ...');
cleanap2;
Stim = Sam2ram(Stim);
X = DS.indepVar;
while firstTime | doRepeat,
   % play conditions one by one
   for icond=1:DS.Ncond,
      play(Stim, icond);
      if DAhalt('status'), % stop button pressed
         OUIreport('D/A interrupted',[0.8 0.4 0.13]);
         return;
      end
      Xstr = [num2sstr(DS.xval(icond)) ' ' X.Unit]; 
      OUIreport({['Playing subseq ' num2str(icond)], X.Name, ['  = ' Xstr]});
   end
   firstTime = 0;
end
DAwait;
OUIreport('Finished playing.');




