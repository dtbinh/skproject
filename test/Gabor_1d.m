function psi = Gabor_1d(omega,sigma,mtime,dt,shift)

%
% �K�{�[���E�F�[�u���b�g psi �̐���
%  p.38  �� (2.17) (2.18)�Q��
%
%
%  Copyright 2001 Hiroki NAKANO
%


	t = -mtime/2:dt:mtime/2-dt;
   gauss=exp((-(t-shift).^2)/(4*sigma^2))/(2*sqrt(pi*sigma));
   psi=gauss.*exp(i*omega*(t-shift));
   
% end of file
