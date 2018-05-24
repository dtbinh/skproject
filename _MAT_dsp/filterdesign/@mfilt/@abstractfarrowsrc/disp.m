function disp(this)
%DISP   Display this object.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.

if length(this) > 1
    vectordisp(this);
    return;
end

fn = fieldnames(this);
N = length(fn);
% Reorder the fields. NumSamplesProcessed, ResetStates and States in
% the end.
nidx = [3, 5, 6, 7, 1];
if N>7, 
    nidx = [3, 5, 6, 7, 8, 1];
end

if this.PersistentMemory,
    % display states
    nidx = [nidx, 4];
end
fn = fn(nidx);

siguddutils('dispstr', this, fn, 25);

disp(this.filterquantizer, 25);

% [EOF]
