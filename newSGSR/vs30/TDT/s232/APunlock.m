function APunlock(Fend)

% function a=APunlock(Fend)
% releases the AP2 lock
% if Fend=0, lock counter is decremented
% if Fend=1, lock counter is reset
% Fend defaults to 0.

if nargin<1, Fend=0; end;

s232('APunlock',Fend);
