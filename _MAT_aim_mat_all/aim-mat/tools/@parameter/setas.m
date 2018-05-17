% method of class @parameter
%
% (c) 2011, University of Southampton
% Maintained by Stefan Bleeck (bleeck@gmail.com)
% download of current version is on the soundsoftware site: 
% http://code.soundsoftware.ac.uk/projects/aimmat
% documentation and everything is on http://www.acousticscale.org
function param=setas(param,text,value,unit,inbox)
%% sets the parameter value in the parameter "text" in the panel "inbox" to
%% the value "value".
% param must be of type float or slider

if nargin<5
    inbox='all';
end

% cont=param.entries;
nr=getentrynumberbytext(param,text,inbox);
if nr>0
    if isequal(value,'auto');
        param.entries{nr}.rawvalue=value;
        param.entries{nr}.stringvalue=value;    % set the string value
    else
        if ~ischar(value)
            unittype=param.entries{nr}.unittype;
            if ~isa(unittype,'unit_none')
                rawval=fromunits(unittype,value,unit);
            else
                rawval=value;
            end
            param.entries{nr}.rawvalue=rawval;    % set the value in the class structure with the raw value
            param.entries{nr}.stringvalue=num2str(rawval);    % set the string value
        else
            param.entries{nr}.stringvalue=value;    % set the string value
            param.entries{nr}.rawvalue=str2num(value);
        end
    end
    if isfield(param.entries{nr},'handle') && ishandle(param.entries{nr}.handle{1}) % and set in the gui as well
        if strcmp(param.entries{nr}.type,'float')
            hand=param.entries{nr}.handle{1};
            if isequal(value,'auto');
                set(hand,'String',value);   % set the string as given
            else
                if ~ischar(value)
                    if length(value)==1
                        set(hand,'String',num2str(value));   % translate to string
                    else
                        set(hand,'String',param.entries{nr}.stringvalue);   % set the string as given
                    end
                    if ~isa(unittype,'unit_none')
                        unitnr=findunit(unittype,unit);
                        set(param.entries{nr}.handle{2},'value',unitnr);  % set the unit to the given one
                    end
                else % its a string format
                    set(hand,'String',value);   % set the string as given
                end
            end
        else  % it must be a slider
            secombi=param.entries{nr}.slidereditcombi;
            if ~isa(unittype,'unit_none')
                unitnr=findunit(unittype,unit);
                set(param.entries{nr}.handle{2},'value',unitnr);  % set the unit to the given one
                editscaler=tounits(unittype,1,unit);
                secombi.editscaler=editscaler;
            end
            secombi=slidereditcontrol_set_raweditvalue(secombi,value);
            param.entries{nr}.slidereditcontrol=secombi;
        end
        return
    end
    else
        error('setvalue::error, the entry does not exist');
    end
