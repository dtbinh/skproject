function help_initden(~)
%HELP_INITDEN  

%   Copyright 2010 The MathWorks, Inc.

init_str = sprintf('%s\n%s\n%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''InitDen'', INITDEN) specifies an initial estimate', ...
    '    of the filter denominator coefficients in vector INITDEN. This may be', ...
    '    useful for difficult optimization problems. INITDEN is empty by default.',...     
    '    Since the designed filter is an allpass filter, its denominator is the',...
    '    reversed version of its numerator. For this reason, it is irrelevant to',...
    '    specify an initial numerator as a design option.');
disp(init_str);
disp(' ');

% [EOF]