% WN for VEMP
Duration=3.5;Fs=10000;
L=Duration*Fs/2;PassBand=[1 1000];%Sampling rate=10kHz, Duration=3.5s.

%FiltCoef=fc;

%%% No need until speaker charactersitic becomes clear
%%%FiltCoef=ones(1,256);

%Make a band of white noise
Freq=(1:L)/L*Fs/2; %Frequency vector (Real part only)
Iout_lo=find(Freq<min(PassBand));%Indeces to the outside of the passband
Iout_hi=find(Freq>max(PassBand));

Amp=ones(size(Freq)); %Amplitude spectrum
Amp(Iout_lo)=linspace(0,1,length(Iout_lo));
Amp(Iout_hi)=linspace(1,0,length(Iout_hi));

%Amp(Iout)=0; %Set the gain 0 for the outside of the passband
Phase=(rand(size(Amp))*2-1)*pi; %Phase spectrum -- random
x=Amp.*exp(sqrt(-1)*Phase); %Complex representation of the signal
Noise1=RealIFFT(x); %Get the time representation
Noise2=Cos2RampMs(Noise1,100,Fs); %Apply 100ms ramps
%OrigSPL=20*log10(sqrt(mean(Noise.^2))); %SPL of the original noise 
%Noise3=[Noise2 zeros(size(Noise2))]; %Double the # of points by padding with zeros
OrigSPL=20*log10(sqrt(mean(Noise2.^2))); %SPL of the original noise 

%%% No need until speaker charactersitic becomes clear
%FiltNoise1=filter(FiltCoef,1,Noise2); %FIR filtering

%Scale the signal so that the maximum unsigned amplitude is no greater than maxv V %%%SK
maxv=0.5;
%RMS=sqrt(mean(FiltNoise(1:2*L).^2)); 
%RMS=sqrt(mean(FiltNoise.^2)); 
%Scale=10/max(abs(FiltNoise(:))); %%%SK
%%%Scale=maxv/max(abs(FiltNoise1(:)));
Scale=maxv/max(abs(Noise2(:)));

GainByScale=20*log10(Scale); %Gain in dB
FiltNoise=Noise2*Scale; %Scale the signal

RMS1=sqrt(mean(FiltNoise(1:2*L).^2))
RMS2=sqrt(mean(FiltNoise.^2))

FiltNoiseT=(FiltNoise)';
rms = norm(FiltNoiseT)/sqrt(length(FiltNoiseT))


p1=zeros(1,0.5*Fs);
p2=ones(1,0.5*Fs)*(-5);
p3=ones(1,10)*5;
p4=ones(1,4.5*Fs-10)*(-5);
p5=ones(1,10)*5;
p6=ones(1,3*Fs-10)*(-5);
p7=zeros(1,1.5*Fs+1);
tr=([p1 p2 p3 p4 p5 p6 p7])';

Len=10;
time=(0:1/Fs:Len);

q=zeros(1,Len*Fs+1);
q(1,(0.5*Fs+1):((0.5+Duration)*Fs))=FiltNoise;
q(1,(5*Fs+1):((5+Duration)*Fs))=FiltNoise*(-1);
bn=q';

subplot(2,1,1)
semilogx(Freq,Amp,'ro')
grid;
subplot(2,1,2)
plot(time,bn,'b',time,tr,'r')
grid;