function P = set(P, varargin)
% SET sets a property of the legendObject to a new value
%
% legendObjects have a set of properties you can retrieve or adjust. The 'get' 
% and 'set' functions are used for this purpose.
%
% P = set(P, propName1, newValue1, propName2, newValue2, propName3, newValue3, ...)
% Sets the value of property propName.
%
%           P: The legendObject instance.
%    propName: The property you want to get, this should be a member of the
%             'params' property of P.
%    newValue: The new value we give to the field.
%
% Properties for legendObject: see 'help legendObject'.
%
% Example:
%  Suppose P is a legendObject instance, with property 
%   Color == 'r',
%  then:
%  >> get(P, 'TextColor')
%  ans = 
%      'r'
%  >> P = set(P, 'TextColor', 'k');
%  >> get(P, 'TextColor')
%  ans = 
%      'k'


%% ---------------- CHANGELOG -----------------------
%  Tue Apr 19 2011  Abel   
%   Initial creation based on code of Kevin Spiritus
P.params = processParams(varargin, P.params);