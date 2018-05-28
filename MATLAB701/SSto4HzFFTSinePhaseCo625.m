% SS to 4HzFFTSinePhaseCo 625points
function T1=SSto4HzFFTSinePhaseCo625(V)
% FFT of SS
FFT=fft(V);
A0=FFT(1);
FFT(1)=[];
RFFT=[FFT(1:(length(FFT)/2))];
Amp=abs(RFFT/(length(FFT)/2));
nyquist=1/2/0.0016;
FreqAxis=(1:length(RFFT))/(length(FFT)/2)*nyquist;
% DFT amplitude at 4Hz
DFT4=Amp(4);
% SS wave and 4Hz sine wave
T=[-0.5:0.0016:(-0.5+(624*0.0016))];
Y=(A0+real(RFFT(4))*cos(2*pi*FreqAxis(4)*T)-imag(RFFT(4))*sin(2*pi*FreqAxis(4)*T))/(625/2);
% Phase analysis by radian
T1=[-0.125:0.0016:(-0.125+(156*0.0016))];
y=(A0+real(RFFT(4))*cos(2*pi*FreqAxis(4)*T1)-imag(RFFT(4))*sin(2*pi*FreqAxis(4)*T1))/(625/2);
[Max,MaxPhaseI]=max(y);
MaxPhase=((T1(MaxPhaseI))/0.125)*pi;
SineAmp=Max;
if MaxPhase-(pi/2)<-pi
    ZeroPhase=MaxPhase-(pi/2)+(2*pi);
else
    ZeroPhase=MaxPhase-(pi/2);
end;
% Polar graph Zerophase vs SinAmp
subplot(2,1,1);
h=polar([-pi pi],[0 10]);delete(h);hold on;
polar(ZeroPhase,SineAmp,'bo'),hold on;
polar(MaxPhase,SineAmp,'ro'),hold on;
% Coherence
[Co,F]=mscohere(V,Y,[],[],624,(1/0.0016));
% Polar graph Zerophase vs Coherence
subplot(2,1,2);
h2=polar([-pi pi],[0 1]);delete(h2);hold on;
polar(ZeroPhase,Co(5),'bx'),hold on;
polar(MaxPhase,Co(5),'rx'),hold on;
% Summary of data
RESULTS=[DFT4;ZeroPhase;MaxPhase;SineAmp;Co(5)];
assignin('base',[inputname(1) '_RESULTS'],RESULTS); 
end


