% V to dt1ms250PlotDFTSinPlot4Hz1248
function MaxPhase1248=Vtodt1ms250PlotDFTSinPlot4Hz1248(V)
FFT=fft(V);
RFFT=[FFT(2:(length(FFT)/2))];
Amp=abs(RFFT/(length(FFT)/2));
nyquist=1/2/0.001;
FreqAxis=(1:length(RFFT)/2)/(length(FFT)/2)*nyquist;
CosPhase=angle(RFFT(1:length(RFFT)/2))/pi;
T1=[-0.125:0.0001:0.125];
T2=[-0.0625:0.0001:0.0625];
T4=[-0.03125:0.0001:0.03125];
T8=[-0.015625:0.0001:0.015625];
y1=(real(RFFT(1))*cos(2*pi*FreqAxis(1)*T1)-imag(RFFT(1))*sin(2*pi*FreqAxis(1)*T1))/125;
y2=(real(RFFT(2))*cos(2*pi*FreqAxis(2)*T2)-imag(RFFT(2))*sin(2*pi*FreqAxis(2)*T2))/125;
y4=(real(RFFT(4))*cos(2*pi*FreqAxis(4)*T4)-imag(RFFT(4))*sin(2*pi*FreqAxis(4)*T4))/125;
y8=(real(RFFT(8))*cos(2*pi*FreqAxis(8)*T8)-imag(RFFT(8))*sin(2*pi*FreqAxis(8)*T8))/125;
[Max1,MaxPhaseI1]=max(y1);
[Max2,MaxPhaseI2]=max(y2);
[Max4,MaxPhaseI4]=max(y4);
[Max8,MaxPhaseI8]=max(y8);
MaxPhase1248=[T1(MaxPhaseI1);T2(MaxPhaseI2);T4(MaxPhaseI4);T8(MaxPhaseI8)]
