% V to Theta (from -pi/2 to pi/2)
function Theta=VtoTheta(V)
FFT=fft(V);
FFT(1)=[];
Power=abs(FFT(1:length(FFT)/2)).^2;
nyquist=1/2/0.001;
FreqAxis=(1:length(FFT)/2)/(length(FFT)/2)*nyquist;
[PowerF1 IndexF1]=max(Power);
F1=FreqAxis(IndexF1);
w=2*pi*F1;
T=[-0.126000002:0.001:0.123000011];
B11=sum((sin(w*T)).^2);
B12=sum((sin(w*T)).*(cos(w*T)));
B21=sum((sin(w*T)).*(cos(w*T)));
B22=sum((cos(w*T)).^2);
B=[B11 B12;B21 B22];
C11=sum((sin(w*T)).*V);
C21=sum((cos(w*T)).*V);
C=[C11;C21];
X=(inv(B))*C;
Theta=angle(X(1)+X(2)*i)