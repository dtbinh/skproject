function [RAPStat, LineNr, ErrTxt] = RAPCmdCLO(RAPStat, LineNr, OptArg)
%RAPCmdXXX  actual code for interpretation of RAP commandos
%   [RAPStat, LineNr, ErrTxt] = RAPCmdXXX(RAPStat, LineNr, Arg1, Arg2, ..., ArgN)
%
%   Attention! This function is an internal function belonging to the RAP 
%   project and should not be invoked from the MATLAB command prompt.

%B. Van de Sande 13-11-2003

%-------------------------------------RAP Syntax------------------------------------
%   CLO [CUR]               Closes the current RAP figure
%   CLO ALL                 Closes all figures generated by RAP
%-----------------------------------------------------------------------------------

ErrTxt = '';

if (nargin == 2), OptArg = 'cur'; end

switch OptArg
case 'all',
    FigHdls = findobj(0, 'Tag', 'RAP');
    close(FigHdls);
case 'cur',
    if ishandle(RAPStat.PlotParam.Figure.Hdl), close(RAPStat.PlotParam.Figure.Hdl);
    elseif ~isempty(findobj('Type', 'figure')) & strcmp(get(gcf, 'Tag'), 'RAP'), close(gcf);
    else, ErrTxt = 'No active RAP figure'; return; end    
end    

LineNr = LineNr + 1;