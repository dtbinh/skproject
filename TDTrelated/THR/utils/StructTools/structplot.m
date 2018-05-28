function structplot(varargin)
%STRUCTPLOT create scatterplot using fields from a structure-array.
%   STRUCTPLOT(S, XField, YField) plots the field given by the character string
%   XField versus the fieldname supplied by the string YField from structure-array
%   S. This can be extended to more than one structure-array by the following 
%   syntax:
%   STRUCTPLOT(S1, XField1, YField1, S2, XField2, YField2, ..., Sn, XFieldn, 
%   YFieldn) and results in a plot of superimposed scatterplots.
%
%   For branched structures fieldnames can be given using the dot as a fieldname
%   separator. Moreover fieldnames my contain arithmetic expressions. Any MATLAB
%   expression that returns a vector with the same number of elements in a field
%   is valid. Fieldnames in these expressions must be enclosed between dollar signs.
%   If a field has numeric rowvectors as elements instead of scalars, the
%   special command GETCOLUMN can be used to extract a single element from
%   these vectors to form a numerical vector. This command has the following
%   syntax:              GETCOLUMN($FieldName$, Nr)
%   and returns a numerical column assembled from the requested element number
%   out of each rowvector of the specified fieldname.
%
%   The figure generated by this program has the following features:
%   1. Datapoints derived from the same cell are connected with lines.
%   2. Clicking on a datapoint reveals information on that datapoint.
%   3. If multiple scatterplots are superimposed, an extra menu item is present for
%      selecting scatterplots to be displayed.
%   Attention! When clicking on a line the information of the closest datapoint is
%   displayed. This is not necessarily a datapoint belonging to that line.
%
%   Optional properties and their values can be given as a comma-separated list.
%   To view a list of all possible properties and their default values, use 'factory'
%   as only input argument.
%
%   See also STRUCTFIELD, STRUCTSORT, STRUCTFILTER, STRUCTMERGE and STRUCTVIEW

%B. Van de Sande 19-07-2005
%Adapt to common functions: PARSEEXPR.M, EVALEXPR.M, FINDGROUPS.M and PARSEMRKSYMB.M ...

%-----------------------------------------------------------------------------
%Default parameters ...
DefParam.cellidfields   = {'ds1.filename', 'ds1.icell'};
DefParam.totalidfields  = {'ds1.filename', 'ds1.seqid'};
DefParam.execevalfnc    = '';
DefParam.info           = 'yes';         %'yes' or 'no' ...
DefParam.fit            = 'none';        %'none' or 'linear' ...
DefParam.contour        = 'no';          %'yes' or 'no' ...   
DefParam.gutter         = 'no';          %'yes' or 'no' ...   
DefParam.hist           = 'no';          %'yes' or 'no' ...
DefParam.histstyle      = 'outline';     %'frames' or 'outline' ...
DefParam.histbarcolor   = 'full';        %'transparent' or 'full' ...
DefParam.histbarwidth   = 1;         
DefParam.histnbin       = 128;
DefParam.histyunit      = '#';           %'#' or '%' ...
DefParam.colors         = {'b', 'g', 'r', 'c', 'm', 'y'};
DefParam.linestyles     = {'-'};
%Marker symbols can be extended with the postfix 'f', 'u' or 'w'. If no postfix is supplied
%then then the surface color is transparent, this corresponds with the postfix 'u'.
%Adding an 'f' to the symbol will set the surface color equal to the color of the edges and
%adding a 'w' will set the surface color to white.
DefParam.markers        = {'o', '^', 'v', '*', '+', 'x', '<', '>', 's', 'd', 'p', 'h'};
DefParam.xlim           = [-Inf +Inf];
DefParam.ylim           = [-Inf +Inf];

%------------------------------main program-----------------------------------
%Parse parameters ...
[T, XFields, YFields, Param] = ParseParam(DefParam, varargin);
if isempty(T), return; end

%Create scatterplot ...
PlotTable(T, XFields, YFields, Param);

%-----------------------------local functions---------------------------------
function [T, XFields, YFields, Param] = ParseParam(DefParam, ParamList)

%Initialisation of output parameters ...
[T, XFields, YFields] = deal(cell(0));
Param = struct([]);

NParam = length(ParamList);

%Exceptions to general syntax ...
if (NParam == 1) & ischar(ParamList{1}) & strcmpi(ParamList{1}, 'factory'), %Display list of properties ...
    disp('List of factory defaults:');
    disp(DefParam); 
    return; 
elseif (NParam == 2) & ischar(ParamList{1}) & strcmpi(ParamList{1}, 'callback'), %Invocation of callback funtion ...
    CallBackFunc(ParamList{2}); 
    return; 
end

%General syntax ...
%STRUCTPLOT(S, XField, YField)
%STRUCTPLOT(S1, XField1, YField1, S2, XField2, YField2, ..., Sn, XFieldn, YFieldn) 
if (NParam < 3), error('Invalid number of input parameters.'); end
Sidx = find(cellfun('isclass', ParamList, 'struct')); 
%Property/value list can always be given as a structure instead of a comma-separated list.
%In order to interpret the parameter list correctly, a terminal structure needs to  be
%evaluated separatly. Moreover a property can never be assigned a structure as value, which
%makes the parsing of the input parameters a bit easier ...
if ismember(NParam, Sidx), Sidx = Sidx(1:end-1); end

NS = length(Sidx); 
ArgList = ParamList(1:NS*3); PropList = ParamList(NS*3+1:end);
if ~ismember(1, Sidx) | ~all(ismember(1:(NS*3), [find(cellfun('isclass', ArgList, 'char')), Sidx])), 
    error('Invalid syntax.'); 
end

for n = 1:NS,
    idx = (3*n) - 2;
    [S, XFields{n}, YFields{n}] = deal(ArgList{idx:idx+2}); 
    SName = evalin('caller', sprintf('inputname(%d);', idx));
    if isempty(SName), SName = sprintf('(Arg #%d)', n); end
    T{n} = Struct2Table(S, SName);
    if ~CheckFieldExpr(XFields{n}, T{n}.FNames), error(sprintf('''%s'' is not a valid expression.', XFields{n})); end
    if ~CheckFieldExpr(YFields{n}, T{n}.FNames), error(sprintf('''%s'' is not a valid expression.', YFields{n})); end
end

%Evaluate additional list of properties and their values ...
Param = CheckPropList(DefParam, PropList{:});
Param = CheckParam(Param);
%The property cellidfields is checked independently ...
if iscellstr(Param.cellidfields),
    Param.cellidfields = repmat({Param.cellidfields}, 1, NS);
elseif ischar(Param.cellidfields),
    Param.cellidfields = repmat({{Param.cellidfields}}, 1, NS);
elseif (iscell(Param.cellidfields) & (length(Param.cellidfields) == NS)) & ...
        all(cellfun('isclass', Param.cellidfields, 'cell')),
    Param.cellidfields = reshape(Param.cellidfields, 1, NS);
else, error('Invalid value for property cellidfields.'); end
%The property execevalfnc is checked independently ...
if isempty(Param.execevalfnc), Param.execevalfnc = repmat({''}, 1, NS);
else,    
    if ischar(Param.execevalfnc), Param.execevalfnc = repmat({Param.execevalfnc}, 1, NS); end
    if ~iscellstr(Param.execevalfnc) | (length(Param.execevalfnc) ~= NS), error('Property execevalfnc must be character string or a cell-array of strings.'); end
end    
%The property markers is checked independently and parsed along the way ...
[Param.mrksymb, Param.mrksurf] = ParseMrkSymb(Param.markers);
%if isempty(Param.mrksymb), error('Wrong value for property markers.'); end

%Checking identification fields ...
%Only cell identification fields need to be checked, because the total identification fields
%are only used for deciding which information gets displayed when clicking on a datapoint ...
for n = 1:NS, if ~all(ismember(Param.cellidfields{n}, T{n}.FNames)), 
        error(sprintf('Cell identification fields not valid for structure %s.', T{n}.Name)); 
end; end
%Mismatch in total identification fields results only in a warning ...
for n = 1:NS, if ~all(ismember(Param.totalidfields, T{n}.FNames)), 
        warning(sprintf(char('Total identification fields not valid for structure %s. This may result\n', ...
                         'in insufficient information being returned when clicking on a datapoint.')', T{n}.Name)); 
end; end

%-----------------------------------------------------------------------------
function Param = CheckParam(Param)

if ~iscellstr(Param.totalidfields), error('Invalid value for property totalidfields.'); end
if ~ischar(Param.info) | ~any(strncmpi(Param.info, {'y', 'n'}, 1)), error('Wrong value for property info.'); end
if ~ischar(Param.fit) | ~any(strncmpi(Param.fit, {'n', 'l'}, 1)), error('Wrong value for property fit.'); end
if ~ischar(Param.contour) | ~any(strncmpi(Param.contour, {'y', 'n'}, 1)), error('Wrong value for property contour.'); end
if ~ischar(Param.gutter) | ~any(strncmpi(Param.gutter, {'y', 'n'}, 1)), error('Wrong value for property gutter.'); end
if ~ischar(Param.hist) | ~any(strncmpi(Param.hist, {'y', 'n'}, 1)), error('Wrong value for property hist.'); end
if ~ischar(Param.histstyle) | ~any(strncmpi(Param.histstyle, {'f', 'o'}, 1)), error('Wrong value for property histstyle.'); end
if ~ischar(Param.histbarcolor) | ~any(strncmpi(Param.histbarcolor, {'t', 'f'}, 1)), error('Wrong value for property histbarcolor.'); end
if ~isnumeric(Param.histbarwidth) | (length(Param.histbarwidth) ~= 1) | (Param.histbarwidth <= 0), error('Wrong value for property histbarwidth.'); end
if ~isnumeric(Param.histnbin) | (length(Param.histnbin) ~= 1) | mod(Param.histnbin, 1), error('Wrong value for property histnbin.'); end
if ~ischar(Param.histyunit) | ~any(strcmpi(Param.histyunit, {'#', '%'})), error('Value for property histyunit must be ''#'' or ''%''.'); end
if ~iscellstr(Param.colors) | ~all(ismember(Param.colors, {'r', 'g', 'b', 'c', 'm', 'y', 'k'})), error('Wrong value for property colors.'); end
if ~iscellstr(Param.linestyles) | ~all(ismember(Param.linestyles, {'-', '--', ':', '-.', 'none'})), error('Wrong value for property linestyles.'); end
if ~isnumeric(Param.xlim) | ~isequal(sort(size(Param.xlim)), [1, 2]) | (Param.xlim(1) >= Param.xlim(2)), error('Wrong value for property xlim.'); end
if ~isnumeric(Param.ylim) | ~isequal(sort(size(Param.ylim)), [1, 2]) | (Param.ylim(1) >= Param.ylim(2)), error('Wrong value for property ylim.'); end

if strncmpi(Param.gutter, 'y', 1) & strncmpi(Param.hist, 'y', 1), error('Property gutter and hist cannot have both the value ''yes''.'); end

%-----------------------------------------------------------------------------
%function [Sm, Srf] = ParseMarkerSymbols(Mrk)
%
%L = cellfun('length', Mrk);
%if ~iscellstr(Mrk) | ~all(ismember(L, [1, 2])), [Sm, Srf] = deal(cell(0)); return; end
%Sidx = find(L == 1); 
%if ~isempty(Sidx), Sm(Sidx) = Mrk(Sidx); Srf(Sidx) = {'u'}; end
%Didx = find(L == 2); 
%if ~isempty(Didx), Ch = char(Mrk(Didx)); Sm(Didx) = cellstr(Ch(:, 1)); Srf(Didx) = cellstr(Ch(:, 2)); end
%if ~all(ismember(Sm, {'.', 'o', 'x', '+', '-', '*', '^', 'v', '<', '>', 'p', 'h', 'd', 's'})), 
%    [Sm, Srf] = deal(cell(0)); return; 
%end
%if ~all(ismember(Srf, {'u', 'f'})), 
%    [Sm, Srf] = deal(cell(0)); return; 
%end
%
%-----------------------------------------------------------------------------
function T = Struct2Table(S, SName)

T.Name = SName;
[T.Data, T.FNames] = destruct(S);

%-----------------------------------------------------------------------------
function [boolean, FN] = CheckFieldExpr(Expr, FNames)

boolean = logical(0); %Pessimistic approach ...

DolSidx = find(Expr == '$');  
if ~isempty(DolSidx),
    if rem(length(DolSidx), 2) ~= 0, return; end
    DolSidx = reshape(DolSidx, 2, length(DolSidx)/2)';
    
    NFields = size(DolSidx, 1); FN = cell(1, NFields);
    for n = 1:NFields, FN{n} = Expr(DolSidx(n, 1)+1:DolSidx(n, 2)-1); end 
else, FN = {Expr}; end
    
if ~all(ismember(FN, FNames)), return; 
else, boolean = logical(1); end;

%-----------------------------------------------------------------------------
function PlotTable(T, XFields, YFields, Param)

NTables = length(T);

%Reorganize data ...
for n = 1:NTables, P(n) = AssemblePlotData(T{n}, XFields{n}, YFields{n}, Param.cellidfields{n}, Param.execevalfnc{n}, Param); end
LegNames = ExtractLegNames(P, XFields, YFields); [P.LegendName] = deal(LegNames{:});
    
%Plotting data ...
FigHdl = figure('Name', sprintf('%s', upper(mfilename)), 'NumberTitle', 'on', 'PaperType', 'A4', 'PaperPositionMode', 'manual', ...
        'PaperUnits', 'normalized', 'PaperPosition', [0.05 0.05 0.90 0.90], 'PaperOrientation', 'landscape');
if strncmpi(Param.info, 'n', 1) & strncmpi(Param.hist, 'n', 1) & strncmpi(Param.gutter, 'n', 1), 
    AxPos = [0.10 0.10 0.80 0.80]; 
    [XHistPos, YHistPos] = deal([]);
elseif strncmpi(Param.info, 'y', 1) & strncmpi(Param.hist, 'n', 1) & strncmpi(Param.gutter, 'n', 1), 
    AxPos = [0.08 0.08 0.70 0.84]; 
    [XHistPos, YHistPos] = deal([]);
elseif strncmpi(Param.info, 'y', 1) & strncmpi(Param.gutter, 'y', 1),
    AxPos    = [0.08 0.15 0.70 0.75];
    XHistPos = [0.08 0.05 0.70 0.05];
    YHistPos = [0.08 0.90 0.70 0.05];
elseif strncmpi(Param.info, 'n', 1) & strncmpi(Param.gutter, 'y', 1), 
    AxPos    = [0.10 0.15 0.80 0.75];
    XHistPos = [0.10 0.05 0.80 0.05];
    YHistPos = [0.10 0.90 0.80 0.05];
elseif strncmpi(Param.info, 'y', 1) & strncmpi(Param.hist, 'y', 1), 
    AxPos    = [0.22 0.10 0.53 0.66];
    XHistPos = [0.22 0.81 0.53 0.14];
    YHistPos = [0.05 0.10 0.07 0.66];
elseif strncmpi(Param.info, 'n', 1) & strncmpi(Param.hist, 'y', 1), 
    AxPos    = [0.22 0.10 0.73 0.66];
    XHistPos = [0.22 0.81 0.73 0.14];
    YHistPos = [0.05 0.10 0.07 0.66];
end
AxHdl  = axes('Units', 'normalized', 'Position', AxPos, 'Box', 'off', 'TickDir', 'out', 'FontSize', 8);
if strncmpi(Param.hist, 'y', 1),
    XHistHdl = axes('Units', 'normalized', 'Position', XHistPos, 'Box', 'off', 'TickDir', 'out', 'FontSize', 8);
    YHistHdl = axes('Units', 'normalized', 'Position', YHistPos, 'Box', 'off', 'TickDir', 'out', ...
        'FontSize', 8, 'XDir', 'reverse', 'YAxisLocation', 'right', 'YTickLabel', '');
elseif strncmpi(Param.gutter, 'y', 1),
    XHistHdl = axes('Units', 'normalized', 'Position', XHistPos, 'Visible', 'off');
    YHistHdl = axes('Units', 'normalized', 'Position', YHistPos, 'Visible', 'off');
else, [XHistHdl, YHistHdl] = deal([]); end    

NPlots = length(P); CallBackStr = sprintf('%s(''callback'', ''menu'');', mfilename);
if (NPlots == 1), MnHdl = uimenu('Parent', FigHdl, 'Label', 'Restrict View', 'Enable', 'off');
else,
    MnHdl = uimenu('Parent', FigHdl, 'Label', 'Restrict View', 'Enable', 'on');
    for n = 1:NPlots, uimenu(MnHdl, 'Label', P(n).Name, 'Enable', 'on', 'Checked', 'on', 'CallBack', CallBackStr); end
end

CallBackStr = sprintf('%s(''callback'', ''datapoint'');', mfilename);
NMrk = length(Param.markers); NCol = length(Param.colors); NLin = length(Param.linestyles);
MrkIdx = 0; ColIdx = 0; LinIdx = 0;
LgdHdl = []; [MaxX, MinX, MaxY, MinY] = deal([]);
for n = 1:NPlots,
    MrkIdx = mod(MrkIdx, NMrk) + 1;
    ColIdx = mod(ColIdx, NCol) + 1;
    LinIdx = mod(LinIdx, NLin) + 1;
    if strcmpi(Param.mrksurf{MrkIdx}, 'u'),
        MrkECol = Param.colors{ColIdx}; MrkFCol = 'none'; 
    elseif strcmpi(Param.mrksurf{MrkIdx}, 'f'),
        MrkECol = Param.colors{ColIdx}; MrkFCol = Param.colors{ColIdx};
    else, MrkECol = Param.colors{ColIdx}; MrkFCol = 'w'; end;
    %Plotting scatterdata ...
    LnHdls = line(P(n).Xplot, P(n).Yplot, 'LineStyle', Param.linestyles{LinIdx}, 'Color', Param.colors{ColIdx}, ...
        'Marker', Param.mrksymb{MrkIdx}, 'MarkerEdgeColor', MrkECol, 'MarkerFaceColor', MrkFCol, ...
        'ButtonDownFcn', CallBackStr, 'Parent', AxHdl, 'Tag', P(n).Name);
    %Plotting contour if requested ...
    if strncmpi(Param.contour, 'y', 1) & ~isempty(P(n).Xcontour) & ~isempty(P(n).Ycontour),
        LnHdls = [LnHdls; line(P(n).Xcontour, P(n).Ycontour, 'LineStyle', Param.linestyles{LinIdx}, 'Marker', 'none', ...
            'Color', Param.colors{ColIdx}, 'ButtonDownFcn', CallBackStr, 'Parent', AxHdl, 'Tag', P(n).Name)];
    end
    LgdHdl = [LgdHdl, min(LnHdls)]; PHdls{n} = LnHdls;
    MaxX = max([MaxX; max(P(n).Xplot(:))]); MinX = min([MinX; min(P(n).Xplot(:))]);
    MaxY = max([MaxY; max(P(n).Yplot(:))]); MinY = min([MinY; min(P(n).Yplot(:))]);
end

AxLim = GetAxisLimits(Param, [MinX, MaxX, MinY, MaxY]);

ColIdx = 0; X = AxLim(1:2);
for n = 1:NPlots,
    ColIdx = mod(ColIdx, NCol) + 1;
    if ~isempty(P(n).Fit), 
        Y = feval(P(n).Fit.Func, P(n).Fit.C, X);
        FitHdl = line(X, Y, 'LineStyle', ':', 'Marker', 'none', 'Color', Param.colors{ColIdx}, 'Parent', AxHdl, 'Tag', [P(n).Name '_Fit']);
        PHdls{n} = [PHdls{n}; FitHdl];
    end
end

%Making and plotting histograms or gutter if requested ...
if strncmpi(Param.hist, 'y', 1),
    ColIdx = 0;
    for n = 1:NPlots,
        ColIdx = mod(ColIdx, NCol) + 1;
        idx = find(~isnan(P(n).Xorig) & ~isnan(P(n).Yorig));
        
        [XEdges, XN, XFrac] = MakeHist(P(n).Xorig(idx), AxLim(1:2), Param.histnbin);
        [YEdges, YN, YFrac] = MakeHist(P(n).Yorig(idx), AxLim(3:4), Param.histnbin);
        if strcmpi(Param.histyunit, '#'),
            XBarsHdl = PlotHist(XHistHdl, XEdges, XN, Param.colors{ColIdx}, 'normal', Param);
            YBarsHdl = PlotHist(YHistHdl, YEdges, YN, Param.colors{ColIdx}, 'rotated', Param);
        elseif strcmpi(Param.histyunit, '%'),
            XBarsHdl = PlotHist(XHistHdl, XEdges, XFrac, Param.colors{ColIdx}, 'normal', Param);
            YBarsHdl = PlotHist(YHistHdl, YEdges, YFrac, Param.colors{ColIdx}, 'rotated', Param);
        end
        
        PHdls{n} = [PHdls{n}; XBarsHdl(:); YBarsHdl(:)];
    end
elseif strncmpi(Param.gutter, 'y', 1),    
    set(XHistHdl, 'xlim', AxLim(1:2), 'ylim', [-1, +1]);
    set(YHistHdl, 'xlim', AxLim(1:2), 'ylim', [-1, +1]);
    
    axes(XHistHdl); line(AxLim(1:2), [0 0], 'LineStyle', '-', 'Color', 'k', 'Marker', 'none');
    axes(YHistHdl); line(AxLim(1:2), [0 0], 'LineStyle', '-', 'Color', 'k', 'Marker', 'none');
    
    MrkIdx = 0; ColIdx = 0;
    for n = 1:NPlots,
        ColIdx = mod(ColIdx, NCol) + 1;
        MrkIdx = mod(MrkIdx, NMrk) + 1;
        if strcmpi(Param.mrksurf{MrkIdx}, 'u'),
            MrkECol = Param.colors{ColIdx}; MrkFCol = 'none'; 
        elseif strcmpi(Param.mrksurf{MrkIdx}, 'f'),
            MrkECol = Param.colors{ColIdx}; MrkFCol = Param.colors{ColIdx};
        else, MrkECol = Param.colors{ColIdx}; MrkFCol = 'w'; end;
        
        idx = find((P(n).Yorig < AxLim(3)) & ~isnan(P(n).Xorig));
        if ~isempty(idx),
            LnHdls = line(P(n).Xorig(idx), 0, 'LineStyle', 'none', 'Color', Param.colors{ColIdx}, ...
                'Marker', Param.mrksymb{MrkIdx}, 'MarkerEdgeColor', MrkECol, 'MarkerFaceColor', MrkFCol, ...
                'ButtonDownFcn', CallBackStr, 'Parent', XHistHdl, 'Tag', P(n).Name);
            PHdls{n} = [PHdls{n}; LnHdls(:)];
        end
        
        idx = find((P(n).Yorig > AxLim(4)) & ~isnan(P(n).Xorig));
        if ~isempty(idx),
            axes(YHistHdl);
            LnHdls = line(P(n).Xorig(idx), 0, 'LineStyle', 'none', 'Color', Param.colors{ColIdx}, ...
                'Marker', Param.mrksymb{MrkIdx}, 'MarkerEdgeColor', MrkECol, 'MarkerFaceColor', MrkFCol, ...
                'ButtonDownFcn', CallBackStr, 'Parent', YHistHdl, 'Tag', P(n).Name);
            PHdls{n} = [PHdls{n}; LnHdls(:)];
        end
    end
end

%Calculating and collecting extra information ...
Info.NAnimals = EstimateNAnimals(P, AxLim);
[Info.NPoints, Info.NCells] = deal(0); Data = [];
for n = 1:NPlots,
    idx = find(~isnan(P(n).Xorig) & ~isnan(P(n).Yorig) & (P(n).Xorig >= AxLim(1)) & ...
        (P(n).Xorig <= AxLim(2)) & (P(n).Yorig >= AxLim(3)) & (P(n).Yorig <= AxLim(4)));
    Info.NPoints = Info.NPoints + length(idx);
    Data = [Data; P(n).Xorig(idx), P(n).Yorig(idx)];
    
    idx = find(any((~isnan(P(n).Xplot) & ~isnan(P(n).Yplot) & (P(n).Xplot >= AxLim(1)) & ...
        (P(n).Xplot <= AxLim(2)) & (P(n).Yplot >= AxLim(3)) & (P(n).Yplot <= AxLim(4))), 1));
    Info.NCells  = Info.NCells + length(idx);
end
Info.DateStr = date;
if ~isempty(Data),
    Info.Avg     = mean(Data, 1);
    Info.Std     = std(Data, 0, 1);
    Info.Prctl   = prctile(Data, [50 25 75]); % 50% percentile is the median ...
    [Info.pCorr, Info.Corr] = SignCorr(Data(:, 1), Data(:, 2));
else,
    [Info.Avg, Info.Std] = deal([NaN, NaN]);
    Info.Prctl = repmat(NaN, 3, 2);
    [Info.pCorr, Info.Corr] = deal(NaN);
end

%Plotting additional information ...
if strncmpi(Param.info, 'y', 1),
    SetTxt([0.80 0.70 0.15 0.25], {sprintf('\\bfStatistics\\rm'); ...
            sprintf('\\it#Animals:\\rm %d', Info.NAnimals); ...
            sprintf('\\it#Dots:\\rm %d', Info.NPoints); ...
            sprintf('\\it#Cells:\\rm %d', Info.NCells); ...
            sprintf('\\itAvg(X/Y):\\rm %0.4g/%0.4g', Info.Avg); ...
            sprintf('\\itStd(X/Y):\\rm %0.4g/%0.4g', Info.Std); ...
            sprintf('\\itPrctl(X/Y 50,25,75):\\rm'); ...
            sprintf('%0.4g,%0.4g,%0.4g', Info.Prctl(:, 1)); ...
            sprintf('%0.4g,%0.4g,%0.4g', Info.Prctl(:, 2)); ...
            sprintf('\\itCorr:\\rm %0.2f (p=%0.2g)', Info.Corr, Info.pCorr); ...
            sprintf(''); ...
            sprintf('\\bfDate:\\rm %s', Info.DateStr)});
    F = descstruct(P, 'Fit');
    if ~isempty(F), 
        Con = cat(1, F.C); Slope = Con(:, 1); Yintercept = Con(:, 2);
        AcF = cat(1, F.AcF)*100; Names = upper({P.Name});
        Str = {sprintf('\\bfLinear Regression\\rm')};
        for n = 1:NPlots, 
            Str = [Str; {sprintf(''); sprintf('\\bf%s\\rm', Names{n}); ...
                        sprintf('\\itSlope:\\rm %0.4g', Slope(n)); ...
                        sprintf('\\itYintrcpt:\\rm %0.4g', Yintercept(n)); ...
                        sprintf('\\itAccFrac:\\rm %.0f%%', AcF(n))}];
        end
        SetTxt([0.80 0.05 0.15 0.60], Str); 
    end
end

if strncmpi(Param.hist, 'y', 1),
    axes(XHistHdl); xlim(AxLim(1:2)); xlabel(''); ylabel(Param.histyunit, 'fontsize', 8);
    axes(YHistHdl); ylim(AxLim(3:4)); xlabel(Param.histyunit, 'fontsize', 8); ylabel('');
end
Hdl = legend(LgdHdl, cat(1, {P.LegendName})); set(findobj(Hdl, 'type', 'text'), 'fontsize', 8);
axes(AxHdl); %Setting the axis object containing the scatterplot as the current axis ...    
axis(AxLim); xlabel(GetAxisLbl(XFields), 'fontsize', 8); ylabel(GetAxisLbl(YFields), 'fontsize', 8);

%Assembling UserData ...
UD.F = Param.totalidfields;
UD.P = P;
UD.H = PHdls;
set(FigHdl, 'UserData', UD);

%-----------------------------------------------------------------------------
function P = AssemblePlotData(T, XField, YField, GroupFields, ExecStat, Param)

P = struct([]);

Name  = T.Name;
Xorig = ParseFieldExpr(T, XField); 
Yorig = ParseFieldExpr(T, YField);
if ~isnumeric(Xorig) | ~isnumeric(Yorig) | ~isequal(size(Xorig), size(Yorig)),
    error('One of the expressions results in an invalid value.'); 
end

%Conversion to strings doesn't give any problems when comparing entries, cause
%comparisons are only made within the same table ... There could be a problem
%when comparing multiple tables, cause then the alignment of columns could give 
%rise to restricted matchings ...
%A real problem is the reduced accuracy with which floating points are compared!
Col = GetTableColumn(T, GroupFields{:}); if isnumeric(Col), Col = num2cell(Col); end
List = upper(cv2str(Col));
%List = upper(cv2str(GetTableColumn(T, GroupFields{:})));
if isempty(List), return; end

[List, sidx] = sortrows(List); 
[Xorig, Yorig] = deal(Xorig(sidx), Yorig(sidx));

[dummy, idx] = unique(List, 'rows'); N = [idx(1); diff(idx)];
%If all the entries belong to different cells, the Xplot and Yplot vectors would be
%columnvectors, which are interpreted by LINE in a total different way as matrices.
%For this reason an extra column of all NaN's is added to Xplot and Yplot ...
Nmax = max([2; N]);
[Xplot, Yplot] = deal(repmat(NaN, Nmax, length(idx)));
for n = 1:length(idx),
    exidx = idx(n)-N(n)+1:idx(n);
    XVec = Xorig(exidx); YVec = Yorig(exidx);
    
    exidx = find(~isnan(XVec) & ~isnan(YVec));
    XVec = XVec(exidx); YVec = YVec(exidx);
    
    NElem = length(exidx);
    Xplot(1:NElem, n) = XVec; Yplot(1:NElem, n) = YVec;
end

if isempty(ExecStat),
    idx = find(ismember(Param.totalidfields, T.FNames));
    if ~isempty(idx), 
        IDFNames = Param.totalidfields(idx);
        IDs = GetTableColumn(T, IDFNames{:});
        IDs = IDs(sidx, :);
    else, [IDFNames, IDs] = deal(cell(0)); end
else,
    [isOK, FNames] = CheckFieldExpr(ExecStat, T.FNames);
    if ~isOK, error(sprintf('''%s'' is not a valid statement.', Param.execevalfnc{n})); end
    idx = find(ismember(FNames, T.FNames));
    if ~isempty(idx), 
        IDFNames = FNames(idx);
        IDs = GetTableColumn(T, IDFNames{:});
        IDs = IDs(sidx, :);
    else, [IDFNames, IDs] = deal(cell(0)); end
end

%Assessing contour if requested ... 
if strncmpi(Param.contour, 'y', 1),
    incidx = find(all(~isnan([Xorig, Yorig]), 2)); Ninc = length(incidx);
    if (Ninc >= 3),
        [XorigC, YorigC] = deal(Xorig(incidx), Yorig(incidx));
        idx = convhull(XorigC, YorigC);
        [Xcontour, Ycontour] = deal(XorigC(idx), YorigC(idx));
    else, [Xcontour, Ycontour] = deal([]); end    
else, [Xcontour, Ycontour] = deal([]); end

%Fitting of curves if requested ... 
if strncmpi(Param.fit, 'l', 1), %Linear fit ...
    Func = 'polyval';
    idx = find(~isnan(Xorig) & ~isnan(Yorig));
    C = polyfit(Xorig(idx), Yorig(idx), 1);
    AcF = getaccfrac(Func, C, Xorig(idx), Yorig(idx));
    Fit = CollectInStruct(Func, C, AcF);
else, Fit = struct([]); end

P = CollectInStruct(Name, Xorig, Yorig, IDFNames, IDs, Xplot, Yplot, Xcontour, Ycontour, Fit, ExecStat); 

%-----------------------------------------------------------------------------
function NewLegendNames = ExtractLegNames(P, XFields, YFields)

[LegendNames, NewLegendNames] = deal({P.Name}); N = length(LegendNames);
for n = 1:N,
    idx = find(ismember(LegendNames, LegendNames{n}));
    if (length(idx) > 1), NewLegendNames{n} = [LegendNames{n}, ' (', XFields{n}, ',', YFields{n}, ')']; end
end

%-----------------------------------------------------------------------------
function [Edges, N, Frac] = MakeHist(Data, Range, NBin)

Edges      = linspace(Range(1), Range(2), NBin+1);
BinWidth   = Edges(2)-Edges(1);
BinCenters = (Range(1)+BinWidth/2):BinWidth:(Range(2)-BinWidth/2);
if isempty(Data), Data = Inf; end; %To avoid crash dump but still use histc ...
N = histc(Data, Edges)'; N(end) = []; %Remove last garbage bin ...
%The last bin doesn't include the final edge, but these datapoints are plotted
%on the scatterplot. In order to fix this inconsistency the datapoints that are
%equal to the final edge are manually added to the final bin ...
N(end) = N(end)+ sum(Data == Edges(end));
NTotal = sum(N); if (NTotal ~= 0), Frac = 100*N/NTotal; else, Frac = N; end

%-----------------------------------------------------------------------------
function Hdl = PlotHist(AxHdl, Edges, N, EdgeColor, Mode, Param);

if strncmpi(Param.histbarcolor, 'f', 1), FaceColor = EdgeColor; else, FaceColor = 'none'; end   

if strncmpi(Param.histstyle, 'f', 1),
    NBars = length(Edges)-1;
    for n = 1:NBars,
        BarWidth = diff(Edges([n, n+1]));
        Frac = (BarWidth*(1-Param.histbarwidth)/2);
        X = [Edges([n n])+Frac, Edges([n n]+1)-Frac];
        Y = [0, N([n n]), 0];
        if strcmpi(Mode, 'rotated'), [X, Y] = swap(X, Y); end
        Hdl(n) = patch('parent', AxHdl, 'xdata', X, 'ydata', Y, 'facecolor', FaceColor, 'edgecolor', EdgeColor);
    end    
else, 
    X = mmrepeat(Edges, 2);
    Y = [0, mmrepeat(N, 2), 0];
    if strcmpi(Mode, 'rotated'), [X, Y] = swap(X, Y); end
    Hdl = patch('parent', AxHdl, 'xdata', X, 'ydata', Y, 'facecolor',  FaceColor, 'edgecolor', EdgeColor);
end

%-----------------------------------------------------------------------------
function V = ParseFieldExpr(T, Expr) 

DolSidx = find(Expr == '$'); 
if isempty(DolSidx), V = GetTableColumn(T, Expr);
else,
    DolSidx = reshape(DolSidx, 2, length(DolSidx)/2)';
    
    NFields = size(DolSidx, 1); FNames = cell(1, NFields);
    for n = 1:NFields, FNames{n} = Expr(DolSidx(n, 1)+1:DolSidx(n, 2)-1); end 
    for n = 1:NFields, Expr = strrep(Expr, ['$' FNames{n} '$'], '%s'); end
    
    %NElem = size(T.Data, 1);
    %D = zeros(NElem, NFields); VNames = cell(1, NFields);
    %for n = 1:NFields,
    %    D(:, n) = GetTableColumn(T, FNames{n});
    %    VNames{n} = sprintf('D(:, %d)', n);
    %end
    %Expr = sprintf(Expr, VNames{:});
    D = []; ColNr = 1; VNames = cell(1, NFields);
    for n = 1:NFields,
        Col = GetTableColumn(T, FNames{n}); 
        if ~isnumeric(Col), error(sprintf('Field ''%s'' cannot be used in expressions.', FNames{n})); end
        NCols = size(Col, 2); idx = ColNr:(ColNr+NCols-1);
        D(:, idx) = Col; VNames{n} = ['D(:,' mat2str(idx) ')'];
        ColNr = ColNr+NCols;
    end
    %Expression can be safely transformed to lowercase, because fieldnames are removed
    %from expression and these were the only case sensitive tokens in the expression ...
    Expr = sprintf(lower(Expr), VNames{:});
    
    V = eval(Expr);
end

%-----------------------------------------------------------------------------
function C = getcol(M, ColNr)
%This local function can be used in arithmetic expressions on the data
%to be plotted ...

%Redirect to GETCOLUMN ...
C = getcolumn(M, ColNr);

%-----------------------------------------------------------------------------
function C = getcolumn(M, ColNr)
%This local function can be used in arithmetic expressions on the data
%to be plotted ...

if ~isnumeric(M) | ~isnumeric(ColNr) | (length(ColNr) ~= 1), error('Wrong syntax for GETCOLUMN.'); end
if (ColNr < 1) | (ColNr > size(M, 2)), error('Requested column number doesn''t exist.');
else, C = M(:, ColNr); end

%-----------------------------------------------------------------------------
function Col = GetTableColumn(T, varargin)

%idx = find(ismember(T.FNames, varargin));
%Col = T.Data(:, idx);
N = length(varargin); Col = cell(size(T.Data, 1), N);
for n = 1:N,
    idx = find(ismember(T.FNames, varargin{n}));
    Col(:, n) = T.Data(:, idx);
end
%if (size(Col, 2) == 1) & all(cellfun('isclass', Col, 'double')), Col = cat(1, Col{:}); end
if all(cellfun('isclass', Col, 'double') & (cellfun('size', Col, 1) == 1)) & ...
    (length(unique(cellfun('size', Col, 2))) == 1),
    Col = cat(1, Col{:}); 
end

%-----------------------------------------------------------------------------
function N = EstimateNAnimals(P, AxLim)

NTables = length(P); FileNames = cell(0);
for n = 1:NTables,
    %Search for first fieldname in requested ID fields with the
    %pattern 'fieldname' ...
    fidx = min(strfindcell(lower(P(n).IDFNames), 'filename'));
    if isempty(fidx), 
        warning(sprintf('Could not estimate number of animals because total identification fields\ndon''t contain information on filenames.'));
        N = NaN; return; 
    end
    
    %Only those points are taken into account that are displayed
    %on the plot ...
    ridx = find(~isnan(P(n).Xorig) & ~isnan(P(n).Yorig) & (P(n).Xorig >= AxLim(1)) & ...
        (P(n).Xorig <= AxLim(2)) & (P(n).Yorig >= AxLim(3)) & (P(n).Yorig <= AxLim(4)));
    
    FileNames = [FileNames; P(n).IDs(ridx, fidx)];
end

%The number of animals is estimated by the number of middle numbers in the filenames.
%E.g. C0214 and A0214B are collected from the same animal ...
FileNames = char(FileNames);
FileNames = unique(char2num(FileNames(:, [2:end]), 1), 'rows');
if (length(FileNames) == 1) & isnan(FileNames), N = 0;
else, N = length(FileNames); end

%-----------------------------------------------------------------------------
function LimVec = GetAxisLimits(Param, LimVec)

idx = find(~isinf(Param.xlim)); LimVec(idx)   = Param.xlim(idx);
idx = find(~isinf(Param.ylim)); LimVec(idx+2) = Param.ylim(idx);

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

if strcmpi(Flag, 'datapoint'),
    Position    = get(gca, 'CurrentPoint');
    AspectRatio = get(gca, 'DataAspectRatio');
    Xpos = Position(1,1);  Ypos = Position(1,2);
    Xar  = AspectRatio(1); Yar  = AspectRatio(2);
    
    NPlots = length(UD.P); [Dst, Idx] = deal(repmat(NaN, 1, NPlots));
    for n = 1:NPlots, 
        [TmpDst, TmpIdx] = min(((Xpos - UD.P(n).Xorig)/Xar).^2 + ((Ypos - UD.P(n).Yorig)/Yar).^2);
        if ~isempty(TmpDst), [Dst(n), Idx(n)] = deal(TmpDst, TmpIdx); end
    end
    if all(isnan(Dst)), return; end
    [dummy, Pidx] = min(Dst); RowIdx = Idx(Pidx);
    
    
    if isempty(UD.P(Pidx).ExecStat),
        if ~isempty(UD.P(Pidx).IDFNames),
            Args = vectorzip(UD.P(Pidx).IDFNames, UD.P(Pidx).IDs(RowIdx, :));
            %Converting numeric fieldnames to character strings ...
            Nidx = find(cellfun('isclass', Args, 'double'));
            for idx = Nidx(:)', Args{idx} = num2str(Args{idx}, '%.2f '); end
            Txt = [ sprintf('\\bf\\fontsize{9}Datapoint from %s has following ID parameters :\\rm\n', UD.P(Pidx).Name), sprintf('\\it%s\\rm : %s\n', Args{:}) ];
        else, Txt = sprintf('\\bf\\fontsize{9}Not a single valid fieldname in the ''totalIDfields''-\nproperty for the table to which the datapoint belongs!'); end
        
        Hdl = msgbox(Txt, upper(mfilename), struct('WindowStyle', 'non-modal', 'Interpreter', 'tex'));
    else, ExecStat(UD.P(Pidx).ExecStat, UD.P(Pidx).IDs(RowIdx, :)); end
elseif strcmpi(Flag, 'menu'),
    Checked  = get(gcbo, 'Checked');
    Position = get(gcbo, 'Position');
    
    switch Checked
    case 'on', 
        set(gcbo, 'Checked', 'off');
        set(UD.H{Position}, 'Visible', 'off');
    case 'off',
        set(gcbo, 'Checked', 'on');
        set(UD.H{Position}, 'Visible', 'on');
    end
end

%-----------------------------------------------------------------------------
function ExecStat(Stat, Args) 

DolSidx = find(Stat == '$');
if ~isempty(DolSidx),
    DolSidx = reshape(DolSidx, 2, length(DolSidx)/2)';
    
    NFields = size(DolSidx, 1); FNames = cell(1, NFields);
    for n = 1:NFields, FNames{n} = Stat(DolSidx(n, 1)+1:DolSidx(n, 2)-1); end 
    for n = 1:NFields, 
        if ischar(Args{n}), Stat = strrep(Stat, ['$' FNames{n} '$'], ['''', Args{n}, '''']);
        else, Stat = strrep(Stat, ['$' FNames{n} '$'], mat2str(Args{n})); end
    end
end

eval(Stat);

%-----------------------------------------------------------------------------