function syncprops(this, hq)
%SYNCPROPS   Sync the common properties from one quantizer to another.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.

set(this, ...
    'InputWordLength',       hq.InputWordLength, ...
    'FilterInternals',       hq.FilterInternals);

if strcmpi(this.FilterInternals,'MinWordLengths'),
    set(this,'OutputWordLength',hq.OutputWordLength);
elseif strcmpi(this.FilterInternals,'SpecifyWordLengths')
    set(this, ...
        'OutputWordLength',hq.OutputWordLength,...
        'SectionWordLengths', hq.SectionWordLengths);
elseif strcmpi(this.FilterInternals,'SpecifyPrecision'),
    set(this, ...
        'OutputWordLength',hq.OutputWordLength,...
        'SectionWordLengths', hq.SectionWordLengths,...
        'SectionFracLengths', hq.SectionFracLengths,...
        'OutputFracLength',hq.OutputFracLength);
end

% [EOF]
