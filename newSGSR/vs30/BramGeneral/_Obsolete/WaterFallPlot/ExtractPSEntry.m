function Entry = ExtractPSEntry(varargin)
%EXTRACTPSENTRY
%   Entry = EXTRACTPSENTRY(S, XFieldName, YFieldName) extract a row for a
%   popscript generated structure-array from the structure-array S generated
%   by GENWFPLOT. The values of the fields with names XFieldName and 
%   YFieldName are concatenated to vectors for all correlograms in the
%   waterfall plot that have the same reference fiber/cell. These vectors
%   can be plotted by GROUPPLOT.
%   
%
%   E.g.
%       List = GenWFList(struct([]), 'A0307', [368; 666; 486; 748], [+1, -1]);
%       S = GenWFPlot(List, 2, 'plot', 'no');
%       groupplot(ExtractPSENtry(S, 'ds2.discernvalue', 'primpeak.delay'), ...
%           'xval', 'yval');
%
%   Optional properties and their values can be given as a comma-separated
%   list. To view list of all possible properties and their default value, 
%   use 'factory' as only input argument. See relevant code-section for an
%   explanation on the meaning of the different properties.
%
%   See also GENWFLIST, GENWFPLOT or COMPARESCCXCC.

%B. Van de Sande 11-08-2005

%--------------------properties and their default values---------------------
%The name of the fields for the abcissa and ordinate vectors in the resulting
%structure ...
DefProps.xfieldname = 'xval';
DefProps.yfieldname = 'yval';
%The name of the fields that are needed to identify the popscript entry in the
%structure array generated by the popscript. This can be a character string or
%a cell-array of strings.
DefProps.idfields = {'ds1.filename', 'ds1.iseqp', 'ds1.isubseqp', ...
        'ds1.iseqn', 'ds1.isubseqn'};

%--------------------------------main program--------------------------------
%Evaluate input arguments ...
if (nargin == 1) & ischar(varargin{1}) & strcmpi(varargin{1}, 'factory'),
    disp('Properties and their factory defaults:'); 
    disp(DefProps);
    return;
else, [S, XFieldName, YFieldName, Props] = ParseArgs(DefProps, varargin{:}); end

%Using STRUCTAGGREGATE.M ...
AggrFncs = {sprintf('cat(1, $%s$)', XFieldName), sprintf('cat(1, $%s$)', YFieldName)};
AggrFNames = {Props.xfieldname, Props.yfieldname};
if isempty(Props.idfields),
    Entry = structaggregate(S, AggrFncs, 'aggrfnames', AggrFNames);
else,
    GroupFNames = Props.idfields;
    Entry = structaggregate(S, AggrFncs, GroupFNames, 'aggrfnames', AggrFNames);
end

%-------------------------------local functions------------------------------
function [S, XFieldName, YFieldName, Props] = ParseArgs(DefProps, varargin)

%Checking mandatory input arguments ...
NArgs = length(varargin);
if (NArgs < 3), error('Wrong number of input arguments.'); end
if ~isstruct(varargin{1}), error('First argument should be structure-array.'); end
if ~ischar(varargin{2}) | (size(varargin{2}, 1) ~= 1),
    error('Second argument must be character string.');
end    
if ~ischar(varargin{3}) | (size(varargin{3}, 1) ~= 1),
    error('Third argument must be character string.');
end
[S, XFieldName, YFieldName] = deal(varargin{:});
try, [dummy, FieldNames] = destruct(S);
catch, error('Given structure-array is invalid.'); end
if ~all(ismember({XFieldName, YFieldName}, FieldNames)),
    error('One of the supplied fieldnames doesn''t exist for the structure-array.'); 
end

%Check properties and their values ...
Props = CheckPropList(DefProps, varargin{4:end});
Props = CheckAndTransformProps(Props, FieldNames);

%----------------------------------------------------------------------------
function Props = CheckAndTransformProps(Props, FieldNames)

if ~ischar(Props.xfieldname) | (size(Props.xfieldname, 1) ~= 1), 
    error('Property ''xfieldname'' must be a non-empty character string.'); 
end
if ~ischar(Props.yfieldname) | (size(Props.yfieldname, 1) ~= 1), 
    error('Property ''yfieldname'' must be a non-empty character string.'); 
end
if ~ischar(Props.idfields) & ~iscellstr(Props.idfields) & ~isempty(Props.idfields),
    error('Property ''idfields'' must be a character string or a cell-array of strings.');
end
if isempty(Props.idfields), Props.idfields = {};
else, 
    Props.idfields = cellstr(Props.idfields);
    if ~all(ismember(Props.idfields, FieldNames)),
        error('One of the supplied fieldnames for identification of an entry does not exist.');
    end
end

%----------------------------------------------------------------------------