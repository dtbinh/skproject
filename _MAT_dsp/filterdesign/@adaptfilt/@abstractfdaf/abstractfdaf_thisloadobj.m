function abstractfdaf_thisloadobj(this, s)
%ABSTRACTFDAF_THISLOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.

adapt_thisloadobj(this, s);

set(this, ...
    'BlockLength',     s.BlockLength, ...
    'StepSize',        s.StepSize, ...
    'Leakage',         s.Leakage, ...
    'Power',           s.Power, ...
    'AvgFactor',       s.AvgFactor, ...
    'Offset',          s.Offset, ...
    'FFTCoefficients', s.FFTCoefficients);

% [EOF]