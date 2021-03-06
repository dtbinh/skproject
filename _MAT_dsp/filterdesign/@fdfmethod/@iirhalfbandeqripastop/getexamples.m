function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.

examples = {{ ...
    'Design a quasi linear phase lowpass halfband IIR filter of 32th order',...
    '% and with a stopband attenuation of 60 dB.',...
    'N = 32; % Must be a multiple of 4',...
    'Ast = 60;',...
    'd = fdesign.halfband(''Type'',''Lowpass'',''N,Ast'',N,Ast);',...
    'Hd = design(d,''iirlinphase'');',...
    'fvtool(Hd)'}};

% [EOF]
