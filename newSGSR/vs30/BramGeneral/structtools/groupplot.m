function groupplot(varargin)
%GROUPPLOT  make groupplot from structure-array.
%   GROUPPLOT(S, Xname, Yname) makes a groupplot for the supplied structure-array S.
%   For each row in the structure-array S the vector in the fieldname XName is plotted
%   versus the vector in the fieldname YName. This can be extended to more than one
%   structure-array by the following syntax:
%   GROUPPLOT(S1, Xname1, Yname1, S2, Xname2, Yname2, ..., SN, XnameN, YnameN)
%   and results in a plot of superimposed groupplots.
%
%   For branched structures fieldnames can be given using the dot as a fieldname
%   separator. Moreover fieldnames my contain arithmetic expressions. Any MATLAB
%   expression that returns a vector or cell-array with the same number of elements
%   in a field is valid. Fieldnames in these expressions must be enclosed between
%   dollar signs.
%
%   The figure generated by this program has the following features:
%   1. Clicking on a line plot reveals information on that line plot or results in the
%      execution of a MATLAB statement.
%   2. If multiple groupplots are superimposed, an extra menu item is present for
%      selecting groupplots to be displayed.
%
%   Optional properties and their values can be given as a comma-separated list.
%   To view a list of all possible properties and their default values, use 'factory'
%   as only input argument.

%B. Van de Sande 11-04-2005
%Merge with STRUCTPLOT.M ...

%----------------------------default parameters-------------------------------
DefParam.colors         = {'b', 'g', 'r', 'c', 'm', 'y'};
DefParam.linestyles     = {'-'};
%Marker symbols can be extended with the postfix 'f', 'u' or 'w'. If no postfix is supplied
%then then the surface color is transparent, this corresponds with the postfix 'u'.
%Adding an 'f' to the symbol will set the surface color equal to the color of the edges and
%adding a 'w' will set the surface color to white.
DefParam.markers        = {'o', '^', 'v', '*', '+', 'x', '<', '>', 's', 'd', 'p', 'h'};
%Logical indexation of vectors with abcissa and ordinate values. This is done separatly
%for each plot ...
DefParam.indexexpr      = '';
%List of fields to display when clicking on a curve ...
DefParam.infofields     = {};
%MATLAB statement to execute when clicking on a curve. Fieldnames in these statements
%must be enclosed between dollar signs and for branched structures fieldnames can be
%given using the dot as a fieldname separator ...
DefParam.execevalfnc    = '';
%Display statistical information ...
DefParam.dispstats      = 'yes';  %'yes' or 'no' ...
%Fit a cubic spline function through data ...
DefParam.fitfnc         = 'none'; %'none' or 'spline' ...
%Ratio which defines oversampling of fit function to be plotted ...
DefParam.fitsampleratio = 5;
%The name of the field that identifies the animal for a given structure-array row. A cell-
%array of strings can be supplied if this field is different for different structure-arrays ...
DefParam.animalidfield  = '';
%The set of fields that identify a cell of an animal for a given structure-array row.
%Specifying a character string or a cell-array of strings designates that this set of
%fields is identical for all supplied structure-arrays. When supplying a cell-array of
%cell-array of strings, every supplied structure-array can have a different set of fields ...
DefParam.cellidfield    = {};
DefParam.xlim           = [-Inf, +Inf];
DefParam.ylim           = [-Inf, +Inf];

%------------------------------main program-----------------------------------
%Checking input parameters ...
if (nargin == 1) & ischar(varargin{1}) & strcmpi(varargin{1}, 'factory')
%Display list of properties ...
    disp('List of factory defaults:');
    disp(DefParam);
    return;
elseif (nargin == 2) & ischar(varargin{1}) & strcmpi(varargin{1}, 'callback') 
%Invocation of callback function ...
    CallBackFunc(varargin{2}); return;
else
    [Data, Param] = ParseArgs(DefParam, varargin{:}); 
end

%Extract and calculate plot data ...
[Stats, Data, Param] = ExtractPlotData(Data, Param);

%Performing actual plotting ...
CreatePlot(Data, Stats, Param);

%-----------------------------local functions---------------------------------
function [Data, Param] = ParseArgs(DefParam, varargin)

%GROUPPLOT(S, Xname, Yname)
%GROUPPLOT(S1, Xname1, Yname1, S2, Xname2, Yname2, ..., SN, XnameN, YnameN)
if (nargin < 4)
    error('Invalid number of input parameters.'); 
end
%Property/value list can always be given as a structure instead of a comma-separated list.
%In order to interpret the parameter list correctly, a terminal structure needs to be
%evaluated separatly. Moreover a property can never be assigned a structure as value, which
%makes the parsing of the input parameters a bit easier ...
Sidx = find(cellfun('isclass', varargin, 'struct')); 
if ismember((nargin-1), Sidx)
    Sidx = Sidx(1:end-1); 
end

NS = length(Sidx); 
ArgList = varargin(1:NS*3); 
PropList = varargin(NS*3+1:end);
if ~ismember(1, Sidx) | ~all(ismember(1:(NS*3), [find(cellfun('isclass', ArgList, 'char')), Sidx]))
    error('Invalid syntax.');
end

%Evaluate additional list of properties and their values ...
Param = checkproplist(DefParam, PropList{:});
Param = CheckParam(Param, NS);

%Reorganizing input arguments ...
for n = 1:NS,
    idx = (3*n) - 2;
    [S, Xfield, Yfield] = deal(ArgList{idx:idx+2}); 
    
    [CData, FNames] = destruct(S);
    SName = evalin('caller', sprintf('inputname(%d);', idx)); 
    if isempty(SName), SName = sprintf('(Arg #%d)', n); end
    
    try, Xexpr = parseExpr(Xfield, FNames);
    catch, error(sprintf('''%s'' is not a valid expression.', Xfield)); end
    try, Yexpr = ParseExpr(Yfield, FNames);
    catch, error(sprintf('''%s'' is not a valid expression.', Yfield)); end
    
    if ~isempty(Param.indexexpr{n}),
        try, Idxexpr = ParseExpr(Param.indexexpr{n}, FNames);
        catch, error(sprintf('''%s'' is not a valid expression.', Param.indexexpr{n})); end
    else, Idxexpr = {}; end
        
    NFields = length(Param.infofields); idxInfoFields = [];
    for f = 1:NFields,
        idxInfoFields = [idxInfoFields, find(strcmp(FNames, Param.infofields{f}))];
    end
    if ~isempty(Param.execevalfnc{n}),
        try, Stat = ParseExpr(Param.execevalfnc{n}, FNames);
        catch, error(sprintf('''%s'' is not a valid statement.', Param.execevalfnc{n})); end
    else, Stat = {}; end
    
    [Data(n).name, Data(n).fnames, Data(n).data, Data(n).xfield, Data(n).xexpr, ...
            Data(n).yfield, Data(n).yexpr, Data(n).idxexpr, Data(n).statement, Data(n).idxinfofields] = ...
        deal(SName, FNames, CData, Xfield, Xexpr, Yfield, Yexpr, Idxexpr, Stat, idxInfoFields);
end

%-----------------------------------------------------------------------------
function Param = CheckParam(Param, NS)

if ~iscellstr(Param.colors) | ~all(ismember(Param.colors, {'r', 'g', 'b', 'c', 'm', 'y', 'k'})), 
    error('Wrong value for property colors.'); 
end
if ~iscellstr(Param.linestyles) | ~all(ismember(Param.linestyles, {'-', '--', ':', '-.', 'none'})), 
    error('Wrong value for property linestyles.'); 
end
[Param.mrksymb, Param.mrksurf] = parsemrksymb(Param.markers);
if ~ischar(Param.dispstats) | ~any(strncmpi(Param.dispstats, {'y', 'n'}, 1)),
    error('Value for property dispstats must be ''yes'' or ''no''.');
end
if ~ischar(Param.fitfnc) | ~any(strncmpi(Param.fitfnc, {'n', 's'}, 1)),
    error('Value for property fitfnc must be ''none'' or ''spline''.');
end
%The properties indexexpr, infofields and execevalfnc are checked for each 
%structure-array independently, but the value of indexexpr and execevalfnc
%must be a character string or cell-array of strings with length the number
%of supplied structure-arrays. If the value is a character-string then this 
%value must be expanded to a cell-array of strings ...
%The value for the property infofields must be a character-array or a cell-
%array of strings. In the former case, conversion to a cell-array of strings
%is necessary ...
if ischar(Param.indexexpr)
    Param.indexexpr = repmat({Param.indexexpr}, NS, 1); 
elseif (iscellstr(Param.indexexpr) & (length(Param.indexexpr) == NS))
    Param.indexepr = reshape(Param.indexexpr, NS, 1);
else
    error('Invalid value for property ''indexexpr''.'); 
end

if ischar(Param.execevalfnc)
    Param.execevalfnc = repmat({Param.execevalfnc}, NS, 1); 
elseif (iscellstr(Param.execevalfnc) & (length(Param.execevalfnc) == NS))
    Param.execevalfnc = reshape(Param.execevalfnc, NS, 1);
else
    error('Invalid value for property ''execevalfnc''.'); 
end

if ischar(Param.infofields)
    Param.infofields = {Param.infofields};
elseif (iscellstr(Param.infofields))
    Param.infofields = Param.infofields(:)';
else, error('Invalid value for property ''infofields''.'); end
if ~isnumeric(Param.fitsampleratio) | (length(Param.fitsampleratio) ~= 1) | ...
        (Param.fitsampleratio <= 0),
    error('Value of property fitsampleratio must be positive integer.');
end
if ischar(Param.animalidfield), Param.animalidfield = repmat({Param.animalidfield}, NS, 1);
elseif (iscellstr(Param.animalidfield) & (length(Param.animalidfield) == NS)),
    Param.animalidfield = reshape(Param.animalidfield, NS, 1);
else, error('Invalid value for property animalidfield.'); end
if iscellstr(Param.cellidfield), Param.cellidfield = repmat({Param.cellidfield}, NS, 1);
elseif ischar(Param.cellidfield), Param.cellidfield = repmat({{Param.cellidfield}}, NS, 1);
elseif (iscell(Param.cellidfield) & (length(Param.cellidfield) == NS)) & ...
        all(cellfun('isclass', Param.cellidfield, 'cell')),
    Param.cellidfield = reshape(Param.cellidfield, NS, 1);
else, error('Invalid value for property cellidfield.'); end
if ~isnumeric(Param.xlim) | ~isequal(sort(size(Param.xlim)), [1, 2]) | ...
        (Param.xlim(1) >= Param.xlim(2)), 
    error('Wrong value for property xlim.'); 
end
if ~isnumeric(Param.ylim) | ~isequal(sort(size(Param.ylim)), [1, 2]) | ...
        (Param.ylim(1) >= Param.ylim(2)), 
    error('Wrong value for property ylim.'); 
end

%-----------------------------------------------------------------------------
function [Stats, Data, Param] = ExtractPlotData(Data, Param)

%Add actual abcissa and ordinate values and calculate limits of abcissa and ordinate.
%Also, statistics are collected ...
[Stats.nanimals, Stats.ncells, Stats.npoints] = deal(0);
N = length(Data);
XLim = [+Inf, -Inf]; YLim = [+Inf, -Inf];
for n = 1:N,
    %Calculate plot data ...
    Xval = evalExpr(Data(n).xexpr, Data(n).data);
    if isnumeric(Xval), Xval = num2cell(Xval, 2); end
    Yval = evalExpr(Data(n).yexpr, Data(n).data);
    if isnumeric(Yval), Yval = num2cell(Yval, 2); end
    if ~all(cellfun('isclass', [Xval, Yval], 'double')) | any(cellfun('ndims', [Xval, Yval]) > 2) | ...
            ~all(any([cellfun('size', Xval, 1), cellfun('size', Xval, 2)] == 1, 2)) | ...
            ~all(any([cellfun('size', Yval, 1), cellfun('size', Yval, 2)] == 1, 2)),
        error('The supplied fieldnames/arithmetic expressions do not contain/result in numeric vectors.'); 
    end
    if ~all(cellfun('prodofsize', Xval) == cellfun('prodofsize', Yval)),
        error('Vector supplying abcissa values must have same length as vector supplying the ordinate values.'); 
    else, Len = cellfun('prodofsize', Xval); end
    
    if ~isempty(Data(n).idxexpr),
        Idx = evalExpr(Data(n).idxexpr, Data(n).data);
        if isnumeric(Idx), Idx = num2cell(Idx, 2); end
        if any(cellfun('ndims', Idx) > 2) | ...
                ~all(any([cellfun('size', Idx, 1), cellfun('size', Idx, 2)] == 1, 2)) | ...
                ~all(any([cellfun('size', Idx, 1), cellfun('size', Idx, 2)] == [Len(:), Len(:)], 2))
                %~all(cellfun('isclass', Idx, 'double')))
            error('Indexation expression must result in numerical vector with same size as abcissa and ordinate vectors.');     
        end
    else, Idx = {}; end
        
    %Extract statistics, calculate and sample fit function if necessary ...
    Nrows = size(Data(n).data, 1); IncRowNrs = 1:Nrows;
    for r = 1:Nrows,
        %Spline-fitting requires at least two datapoints. Spline-fitting is done on all datapoints,
        %but sampling is only done on intervals between included datapoints. This is done to avoid
        %extreme curves near the end ...
        if strncmpi(Param.fitfnc, 's', 1) & (sum(~isnan(Xval{r})&~isnan(Yval{r})) >= 2),
            PP = spline(Xval{r}, Yval{r});
        else, PP = struct([]); end
        
        if ~isempty(Idx),
            Idx{r} = reshape(Idx{r}, 1, length(Idx{r}));
            Xval{r} = reshape(Xval{r}(find(Idx{r})), 1, length(find(Idx{r}))); 
            Yval{r} = reshape(Yval{r}(find(Idx{r})), 1, length(find(Idx{r}))); 
        else,
            Xval{r} = reshape(Xval{r}, 1, length(Xval{r})); 
            Yval{r} = reshape(Yval{r}, 1, length(Yval{r})); 
        end

        MinX = min(Xval{r}); MaxX = max(Xval{r});
        MinY = min(Yval{r}); MaxY = max(Yval{r});
        XLim = [min([XLim(1), MinX]), max([XLim(2), MaxX])];
        YLim = [min([YLim(1), MinY]), max([YLim(2), MaxY])];

        if isempty(Xval{r}) | all(isnan(Xval{r}) | isnan(Yval{r})), IncRowNrs = setdiff(IncRowNrs, r); end    
        Stats.npoints(n) = sum(~isnan(Xval{r}) & ~isnan(Yval{r}));
        
        %Sampling of spline-fit ...
        if ~isempty(PP) & ~any(length(Xval{r}) == [0, 1]),
            AvgXInc = mean(diff(Xval{r}));
            Xfit{r} = MinX:AvgXInc/Param.fitsampleratio:MaxX;
            if ~isempty(Xfit{r}), Yfit{r} = ppval(PP, Xfit{r});
            else, [Xfit{r}, Yfit{r}] = deal([]); end
        else, [Xfit{r}, Yfit{r}] = deal([]); end
    end
    if ~isempty(Param.animalidfield{n}),
        Stats.nanimals(n) = ...
            AssessNrOfAnimals(construct(Data(n).data, Data(n).fnames), Param.animalidfield{n}, IncRowNrs);
    end
    if ~isempty(Param.cellidfield{n}),
        Stats.ncells(n) = ...
            AssessNrOfCells(construct(Data(n).data, Data(n).fnames), Param.cellidfield{n}, IncRowNrs);
    end    
    
    %Assess which columns are needed for the display of information fields or the evaluation
    %of a statement. The evaluation of a statement takes precedence over takes precedence over
    %diplaying information fields ...
    if ~isempty(Data(n).statement),
        idxNeededFields = cat(1, Data(n).statement{find(cellfun('isclass', Data(n).statement, 'double'))});
    else, idxNeededFields = Data(n).idxinfofields; end

    [Data(n).x, Data(n).y, Data(n).idx] = deal(Xval, Yval, Idx);
    [Data(n).xfit, Data(n).yfit, Data(n).idxfields] = deal(Xfit, Yfit, idxNeededFields);
end

%Adjust abcissa and ordinate limits in parameter structure ...
idx = isinf(Param.xlim); Param.xlim(idx) = XLim(idx);
idx = isinf(Param.ylim); Param.ylim(idx) = YLim(idx);

%-----------------------------------------------------------------------------
function CreatePlot(Data, Stats, Param)

%Create figure and axis object ...
FigHdl = figure('Name', sprintf('%s', upper(mfilename)), ...
             'NumberTitle', 'on', ...
             'PaperType', 'A4', ...
             'PaperPositionMode', 'manual', ...
             'PaperUnits', 'normalized', ...
             'PaperPosition', [0.05 0.05 0.90 0.90], ...
             'PaperOrientation', 'landscape');
if strncmpi(Param.dispstats, 'n', 1)
    AxPos = [0.10 0.10 0.80 0.80]; 
else
    AxPos = [0.08 0.08 0.70 0.84]; 
end

AxHdl  = axes('Units', 'normalized', ...
              'Position', AxPos, ...
              'Box', 'off', ...
              'TickDir', 'out', ...
              'FontSize', 8);

%Create extra menu item ...
NPlots = length(Data); 
CallBackStr = [mfilename '(''callback'', ''menu'');'];
if (NPlots == 1)
    MnHdl = uimenu('Parent', FigHdl, 'Label', 'Restrict View', 'Enable', 'off');
else
    MnHdl = uimenu('Parent', FigHdl, 'Label', 'Restrict View', 'Enable', 'on');
    for n = 1:NPlots
        uimenu(MnHdl, 'Label', Data(n).name, 'Enable', 'on', 'Checked', 'on', 'CallBack', CallBackStr); 
    end
end

%Actual plotting ...          
CallBackStr = [mfilename '(''callback'', ''plot'');'];
NMrk = length(Param.markers); NCol = length(Param.colors); NLin = length(Param.linestyles);
MrkIdx = 0; ColIdx = 0; LinIdx = 0;
LgdHdl = []; HdlPartitions = cell(1, NPlots);
for p = 1:NPlots,
    MrkIdx = mod(MrkIdx, NMrk) + 1;
    ColIdx = mod(ColIdx, NCol) + 1;
    LinIdx = mod(LinIdx, NLin) + 1;
    if strcmpi(Param.mrksurf{MrkIdx}, 'u'),
        MrkECol = Param.colors{ColIdx}; MrkFCol = 'none'; 
    elseif strcmpi(Param.mrksurf{MrkIdx}, 'f'),
        MrkECol = Param.colors{ColIdx}; MrkFCol = Param.colors{ColIdx};
    else, MrkECol = Param.colors{ColIdx}; MrkFCol = 'w'; end;

    [LnHdl, FitHdl] = deal(zeros(1, 0));
    NLines = length(Data(p).x);
    for l = 1:NLines,
        %Plot line or its sampled fit function ...
        if ~strncmpi(Param.fitfnc, 's', 1),
            Hdl = line(Data(p).x{l}, Data(p).y{l}, ...
                'LineStyle', Param.linestyles{LinIdx}, ...
                'Marker', Param.mrksymb{MrkIdx}, ...
                'MarkerEdgeColor', MrkECol, ...
                'MarkerFaceColor', MrkFCol, ...
                'Color', Param.colors{ColIdx}, ...
                'ButtonDownFcn', CallBackStr, ...
                'UserData', [p, l]); %Plot and line number ...
        else,
            Hdl = line(Data(p).xfit{l}, Data(p).yfit{l}, ...
                'LineStyle', Param.linestyles{LinIdx}, ...
                'Marker', 'none', ...
                'Color', Param.colors{ColIdx}, ...
                'ButtonDownFcn', CallBackStr, ...
                'UserData', [p, l]); %Plot and line number ...
        end
        LnHdl = [LnHdl; Hdl];
    end
    LgdHdl = [LgdHdl, LnHdl(1)];
    HdlPartitions{p} = LnHdl;
end
axis([Param.xlim, Param.ylim]);
xlabel(GetAxisLbl({Data.xfield}), 'fontsize', 8); 
ylabel(GetAxisLbl({Data.yfield}), 'fontsize', 8);
Hdl = legend(LgdHdl, cat(1, {Data.name})); 

set(findobj(Hdl, 'type', 'text'), 'fontsize', 8, 'interpreter', 'none');

%Plotting statistical information ...
if strncmpi(Param.dispstats, 'y', 1),
    SetTxt([0.80 0.70 0.15 0.25], {sprintf('\\bfStatistics\\rm'); ...
            ['\it', cellstr2str({Data.name}, ','), '\rm']; ...
            ['\it#Animals:\rm', mat2str(Stats.nanimals)]; ...
            ['\it#Cells:\rm', mat2str(Stats.ncells)]; ...
            ['\it#Dots:\rm', mat2str(Stats.npoints)]; ...
            sprintf(''); ...
            sprintf('\\bfDate:\\rm %s', date)});
end

%Assembling userdata and attaching userdata to figure ...
for n = 1:NPlots,
    UD(n).name   = Data(n).name;
    UD(n).fnames = Data(n).fnames(Data(n).idxfields);
    UD(n).data   = Data(n).data(:, Data(n).idxfields);
    UD(n).stat   = Data(n).statement;
    idx = find(cellfun('isclass', Data(n).statement, 'double'));
    N = length(idx); UD(n).stat(idx) = num2cell(1:N);
    UD(n).hdls   = HdlPartitions{n};
end
set(FigHdl, 'UserData', UD);

%Set current axes to the one containing the actual groupplot ...
axes(AxHdl);

%-----------------------------------------------------------------------------
function Str = GetAxisLbl(Fields)

if (length(Fields) > 1) & isequal(Fields{:}), Fields = unique(Fields); end
NFields = length(Fields);
C = vectorzip(Fields, repmat({' and '}, 1, NFields)); C(end) = [];
Str = cat(2, C{:});

%-----------------------------------------------------------------------------
function AxHdl = SetTxt(Pos, Str)

%Create axis object ... 
AxHdl = axes('Position', Pos, 'Visible', 'off');

%Create yext object ...
TxtHdl = text(0, 0.5, Str, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', ...
             'Color', 'k', 'FontSize', 8, 'Interpreter', 'tex');

%-----------------------------------------------------------------------------
function CallBackFunc(Flag)

UD = get(gcf, 'UserData');
if strcmpi(Flag, 'plot'),
    Nrs = get(gcbo, 'UserData'); 
    [StructNr, PlotNr] = deal(Nrs(1), Nrs(2));

    if isempty(UD(StructNr).data)
        return;
    elseif isempty(UD(StructNr).stat)
        Args = vectorzip(UD(StructNr).fnames, UD(StructNr).data(PlotNr, :));
        %Converting numeric fieldnames to character strings ...
        Nidx = find(cellfun('isclass', Args, 'double'));
        for idx = Nidx(:)'
            Args{idx} = num2str(Args{idx}, '%.2f '); 
        end
        Txt = [ sprintf('\\bf\\fontsize{9}Line from %s has following ID parameters :\\rm\n', UD(StructNr).name), ...
                sprintf('\\it%s\\rm : %s\n', Args{:}) ];
        
        Hdl = msgbox(Txt, upper(mfilename), struct('WindowStyle', 'non-modal', 'Interpreter', 'tex'));
    else
        EvalExpr(UD(StructNr).stat, UD(StructNr).data(PlotNr, :)); 
    end
elseif strcmpi(Flag, 'menu'),
    Checked  = get(gcbo, 'Checked');
    Position = get(gcbo, 'Position');
    
    switch Checked
    case 'on', 
        set(gcbo, 'Checked', 'off');
        set(UD(Position).hdls, 'Visible', 'off');
    case 'off',
        set(gcbo, 'Checked', 'on');
        set(UD(Position).hdls, 'Visible', 'on');
    end
end

%-----------------------------------------------------------------------------