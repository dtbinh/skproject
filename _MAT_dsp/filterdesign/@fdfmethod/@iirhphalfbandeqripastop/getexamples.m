function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Copyright 2007 The MathWorks, Inc.

examples = {{ ...
    'Design a quasi linear phase highpass halfband IIR filter of 32th order',...
    '% and with a stopband attenuation of 60 dB.',...
    'N = 32; % Must be a multiple of 4',...
    'Ast = 60;',...
    'd = fdesign.halfband(''Type'',''Highpass'',''N,Ast'',N,Ast);',...
    'Hd = design(d,''iirlinphase'');',...
    'fvtool(Hd)'}};

% [EOF]