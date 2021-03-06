function help_isincparams(~,type)
%HELP_ISINCPARAMS

%   Copyright 2011 The MathWorks, Inc.

if strcmpi(type,'highpass')
  force_str = sprintf('%s\n%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''SincFrequencyFactor'', C, ''SincPower'', P) designs an', ...
    '    inverse sinc highpass filter with the passband magnitude response equal to', ...
    '    H(w) = sinc(C*(1-w))^(-P). The value of C must satisfy C < 1/(1-wo), where', ...
    '    wo is the normalized cutoff frequency of the filter. The default value of',...
    '    ''SincFrequencyFactor'' is 0.5. The default value of ''SincPower'' is 1.');
elseif strcmpi(type,'lowpass')
  force_str = sprintf('%s\n%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''SincFrequencyFactor'', C, ''SincPower'', P) designs an', ...
    '    inverse sinc lowpass filter with a passband magnitude response equal to', ...
    '    H(w) = sinc(C*w)^(-P). The value of C must satisfy C < 1/wo, where', ...
    '    wo is the normalized cutoff frequency of the filter. The default value of',...
    '    ''SincFrequencyFactor'' is 0.5. The default value of ''SincPower'' is 1.');
end
disp(force_str);
disp(' ');

% [EOF]
