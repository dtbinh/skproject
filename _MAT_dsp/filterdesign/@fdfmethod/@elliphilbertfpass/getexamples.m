function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.


examples = {{ ...
    'Design an elliptic IIR Hilbert transformer of 25th order ',...
    '% and a transition width of 0.06.',...
    'N = 25; % Must be an odd number',...
    'TW = 0.06;',...
    'd = fdesign.hilbert(''N,TW'',N,TW);',...
    'Hd = design(d,''ellip'');',...
    'fvtool(Hd)'}};

% [EOF]
