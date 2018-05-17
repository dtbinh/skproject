% method of class @signal
% function sig=genfm(sig,fc,f_mod,modindex,amplitude)
%
%   INPUT VALUES:
%       sig: original @signal with length and samplerate 
%       fc: carrier frequency (Hz)
%       fmod: modulation frequency (Hz)
%       modindex: modulation index b =
%           maximum carrier frequency deviation / modulation frequency
%
% modulation depth = modulation index * modulation_frequency / carrier frequency
% modulation index = modulation_frequency *  carrier frequency/100/modulation_depth;
        
% 
%   RETURN VALUE:
%       sig:  @signal 
%
% This external file is included as part of the 'aim-mat' distribution package
% (c) 2011, University of Southampton
% Maintained by Stefan Bleeck (bleeck@gmail.com)
% download of current version is on the soundsoftware site: 
% http://code.soundsoftware.ac.uk/projects/aimmat
% documentation and everything is on http://www.acousticscale.org


function sig=genfm(sig,fc,f_mod,modindex,amplitude)

if nargin<5
    amplitude=1;
end
if nargin<4
    modindex=0.1;
end
if nargin<3
    f_mod=100;
end
if nargin<2
    fc=1000;
end



sr=getsr(sig);
len=getlength(sig);

d=getvalues(sig);
d=zeros(size(d));

t=0:1/sr:len-1/sr;

fm=amplitude*cos(2*pi*fc.*t + modindex*sin(2*pi*f_mod.*t));

sig=setvalues(sig,fm);


% f1=fc-f_mod;
% f2=fc;
% f3=fc+f_mod;
% sin1=sinus(len,sr,f1,modgrad/2,0);
% sin2=sinus(len,sr,f2,1,0);
% sin3=sinus(len,sr,f3,modgrad/2,0);
% sig=sin1;
% sig=sig+sin2;
% sig=sig+sin3;

name=sprintf('FM: modulation: %3.1f Hz, carrier: %4.1f kHz, mod index: %2.1f',f_mod,fc/1000,modindex);
sig=setname(sig,name);
% sig=scaletomaxvalue(sig,1);
% sig=RampAmplitude(sig,0.01); % baue eine Rampe

