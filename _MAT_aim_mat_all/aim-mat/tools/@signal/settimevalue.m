% method of class @signal
% 
%   INPUT VALUES:
%  
%   RETURN VALUE:
%
% 
% This external file is included as part of the 'aim-mat' distribution package
% (c) 2011, University of Southampton
% Maintained by Stefan Bleeck (bleeck@gmail.com)
% download of current version is on the soundsoftware site: 
% http://code.soundsoftware.ac.uk/projects/aimmat
% documentation and everything is on http://www.acousticscale.org


function sig=settimevalue(sig,time,val)
%usage: sig=setvalue(sig,time,val)
% sets the double time value "time" to "val"

nr=time2bin(sig,time);
sig.werte(nr)=val;