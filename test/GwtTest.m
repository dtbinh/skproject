%
% �K�{�[���E�F�[�u���b�g�ϊ��@�T���v���v���O����
%    p.45 �}2.26 �Q��
%
%  Copyright 2001 Hiroki NAKANO
%

%
% ���͐M�� S0 �̐���
%

dt=.005;  % delta_t = 0.05 [sec]
mtime=10;  % 10 [sec]
mtdat = mtime/dt;

t = 0:dt:mtime-dt;

period=.5; % T=.5 [sec]

s0=cos(2*pi*t/period);


%
% �K�{�[���E�F�[�u���b�g psi �̐���
%

mtime2=4;
mtdat2 = mtime2/dt;

k=5;  % k=sigma*omega;

N=5;
YY=zeros(mtdat+mtdat2-1,N);

for J = 1:N,
   
   omega = 4*pi*J
   sigma=k/omega;
   
   psi = Gabor_1d(omega,sigma,mtime2,dt,0);

   Y=abs(conv(s0,psi));  % filtering
	YY(:,J)=Y';
end;

figure(1); % Gabor wavelet

t2 = -mtime2/2:dt:mtime2/2-dt;
plot(t2,real(psi))
xlabel('[sec]');

figure(2);  % Output

t3 = 0:dt:mtime+mtime2-2*dt;
plot(t3,log(YY));  % ���ʂ����₷�����邽�߁A�ΐ��\���ɂ��Ă���
xlabel('[sec]');


