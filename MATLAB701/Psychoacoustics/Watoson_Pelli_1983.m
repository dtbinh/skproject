% QUEST�̃V�~�����[�V����
%
% Watson, A. B. & Pelli, D. G. (1983) "QUEST: A Bayesian adaptive
%     psychometric method". Perception & Psychophysics, 33, 113-120.
% Figure 4 ����B
% 
% ���O���Ƃ��Ă�臒l�̐���l�ƁA���ۂ�臒l�̒l����͂����
% �ݒ肳�ꂽ���s���͈̔͂ŁAQUEST�ɂ��臒l�̐�����s���B
%
% �E��L�_���ł� BASIC �ŏ�����Ă������̂� MATLAB �̃X�N���v�g��
% �@�����������B
% �E���Ƃ̃v���O�����ł͔z��̓Y������ 0 ����n�܂��Ă��邪�AMATLAB
% �@�ł͍ŏ��l�� 1 �Ȃ̂ŁA���̂悤�ɉ��ς��Ă���B
% �E�uMATLAB�I�v�ɏ��������]�n�����X���邪�A���Ƃ̃v���O�����Ƃ�
% �@��r�̂��߂ɁA���̂܂܂ɂ����B

% ���̃X�N���v�g�͎��R�ɉ��ς��Ďg�p���č\���܂���B
% ���͂��̃X�N���v�g�̎g�p�ɂ��A�����Ȃ鑹�Q�ɑ΂��Ă��ӔC�𕉂��܂���B
% 
% ���V���[
% e-mail: harasawa@be.to
% 2001.02.12

clear;
close all;

SUB=['x=-n;for t=-n:n;if (q(n+t+1) > q(n+x+1)) x=t;end;end;'];


n=20;     %���{�\�ȑ���͈̔�
n2=n*2;
S=12;     %���O���z�̕W���΍�
m=32;     %���肷�鎎�s��
d=.01;    %�F�L�[�̉����ԈႢ�Ȃǂ̎��s�v���̐�����m��
g=.5;     %���F�`�����X���x��
b=3.5/20; %��/20�F臒l�ł�psychometric function�̌X��/20
e=1.5;    %�ÁF臒l�����傤�ǂ����Ƃ���ő��邽�߂̐������炵��

for x=(-n2:n2)  % x �͎h�����x (dB)
   p(n2+x+1)=1-(1-g).*exp(-10.^(b.*(x+e)));
   if (p(n2+x+1) > 1-d)
      p(n2+x+1)=1-d;
   end
   s(1,n2-x+1)=log(1-p(n2+x+1));
   s(2,n2-x+1)=log(p(n2+x+1));
end

for t=(-n:n) % t �͑z�肳���臒l�̎��O����(t0)�ɑ΂��Ă̑��ΓI�Ȓl
   q0(n+t+1)=-(t./S).^2;
   q(n+t+1)=q0(n+t+1);
end

t0=input(['Prior estimate (+/-' num2str(S) 'dB)? ']);
t1=input(['Actual threshold? ']);
for k=1:m
   eval(SUB);
   r=floor(p(n2+x+t0-t1+1)+rand);  % x ��t0�ɑ��ΓI��臒l�̃x�C�Y����
   % ���ۂ̎����ł͂��̍s���͎h���̒掦�Ɣ����̎擾�ɒu�������
   disp(['Trial ' num2str(k) ' at ' num2str(x+t0) ' dB has response ' num2str(r) ]);
   for t=-n:n
      q(n+t+1)=q(n+t+1)+s(r+1,n2+t-x+1);
   end
   % QUEST�֐����O���t�ɏo��
   plot(-n:n,q);hold on;
end
for t=-n:n
   q(n+t+1)=q(n+t+1)-q0(n+t+1);
end
eval(SUB);
disp(['Maximum likelihood estimate is ' num2str(x+t0) ' dB']);

