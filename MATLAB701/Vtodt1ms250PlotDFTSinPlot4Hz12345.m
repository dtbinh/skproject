% V to dt1ms250PlotDFTSinPlot4Hz12345
function Vtodt1ms250PlotDFTSinPlot4Hz12345(V)
FFT=fft(V);
RFFT=[FFT(2:(length(FFT)/2))];
Amp=abs(RFFT(1:length(RFFT)/2))/(length(FFT)/2);
nyquist=1/2/0.001;
FreqAxis=(1:length(RFFT)/2)/(length(FFT)/2)*nyquist;
CosPhase=angle(RFFT(1:length(RFFT)/2))/pi;
T=[-0.126000002:0.001:0.123000011];
y1=(real(RFFT(1))*cos(2*pi*FreqAxis(1)*T)-imag(RFFT(1))*sin(2*pi*FreqAxis(1)*T))/125;
y2=(real(RFFT(2))*cos(2*pi*FreqAxis(2)*T)-imag(RFFT(2))*sin(2*pi*FreqAxis(2)*T))/125;
y3=(real(RFFT(3))*cos(2*pi*FreqAxis(3)*T)-imag(RFFT(3))*sin(2*pi*FreqAxis(3)*T))/125;
y4=(real(RFFT(4))*cos(2*pi*FreqAxis(4)*T)-imag(RFFT(4))*sin(2*pi*FreqAxis(4)*T))/125;
y5=(real(RFFT(5))*cos(2*pi*FreqAxis(5)*T)-imag(RFFT(5))*sin(2*pi*FreqAxis(5)*T))/125;
y12345=y1+y2+y3+y4+y5;
plot(T,V,'k-',T,y1,'r-',T,y2,'y-',T,y3,'g-',T,y4,'c-',T,y5,'b-',T,y12345,'k:'),grid;
axis([-0.125 0.125 -4 4])
