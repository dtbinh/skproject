%
%     Demonstrations for introducting auditory filters 
%     Irino, T. 
%     Created:   9 Mar 2010
%     Modified:  9 Mar 2010
%     Modified: 20 Mar 2010
%     Modified: 31 Mar 2010
%     Modified:  7 Apr 2010
%     Modified: 11 Apr 2010 (Unicode for MATLAB 2010a)
%     Modified: 11 Jun 2010 (Figure number�AstrDemo)
%     Modified: 27 Jul 2010 (SwSound, DemoAF_PrintFig)
%     Modified:  3 Sep 2010 (SwEnglish, Note)
%     Modified: 10 Sep 2010 (sound(PlaySnd(:),fs))
%
%     Note: 
%     ���̃f���́A�ȉ��̕����p�ɏ����ꂽ���̂ł��B
%     ����,"�͂��߂Ă̒��o�t�B���^",���{�����w�, 66��10��, pp.506-512, 2010.
%     �f���̏ڍׂ́A�{�����Q�Ƃ��������B
%�@�@�@* MATLAB_R2010a�p�ł��B
%     * Octave����sound�֐���plot�֌W�̊֐��̕ύX���K�v���Ǝv���܂��B
%      �f��4�̒��́Afminsearch()���ύX���K�v�炵���ł��B�ŏ��Q��@�ŉ����Ă��������B
%
%%
clear

DirWork = '~/tmp/'; % working directory: you may change this.
                    % ��Ɨp��directory�ł��B
                    % Unix�̌`���ŏ����Ă��܂��B
                    % Windows�̏ꍇ�͓K�X�ύX���������B
                    % DirWork = "c:\tmp\" 
                    % �ł��傤���H
%DirWork = [pwd '/']; % ���̂悤�ɂ���΁A�����炭���Ȃ������悤�ɂȂ�܂����A
                    % �}��f�[�^�����̂܂܌����_��directory�Ɏc��܂��B
                    %
                    %
if exist(DirWork) == 0
  disp('You need to specify the working directory.');
  disp('Example commands in matlab:  >> cd ~; mkdir tmp; ');
  error(['Please look into this file : ' mfilename '.m']);
  % ����error�������ŏo��悤�ł�����A��Ɨp��directory��ݒ肵�Ă��������B
  % ���Ƃ���Unix�̏ꍇ�Acd ~; mkdir tmp; �Ƃ���΁A�����悤�ɂȂ�܂��B
end;
NameRsltNN = [DirWork 'DemoAF_RsltNN.mat']; 

SwEnglish = 0;  % Japanese    ���{�� (default)
%SwEnglish = 1; % English     �p��

%SwSound = 0;   % No sound playback for�@lecture demonstration�@�����f���p
SwSound = 1;  % playback sound (default)

if SwEnglish == 0,
  strDemo0 = '�f��:';
  strDemo(1) = {'  1) ���o�t�B���^�̊�b'};
  strDemo(2) = {'  2) �ՊE�ш敝'};
  strDemo(3) = {'  3) �m�b�`�G���}�X�L���O�@'};
  strDemo(4) = {'  4) ���o�t�B���^�`�󐄒�'};
  strDemoQ = '�f���ԍ��̑I�� >>';

else    
  strDemo0 ='Demo:';
  strDemo(1) = {'  1) Auditory filter basics'};
  strDemo(2) = {'  2) Critical band'};
  strDemo(3) = {'  3) Notched noise masking'};
  strDemo(4) = {'  4) Estimation of filter shape'};
  strDemoQ ='Select demo number >> ';
end;

disp(strDemo0);
for nd =1:4,
    disp(char(strDemo(nd)));
end;
SwDemo = input(strDemoQ);
if length(SwDemo) == 0, SwDemo = 1; end;
 
disp(' ');
disp(['===  ' strDemo0  char(strDemo(SwDemo)) '  ===']);

%%
switch SwDemo
  case 1,
    close all
    DemoAF_Basics
 
  case 2,
    DemoAF_CriticalBand
   % Responses for ASJ review Fig.4 : 12 8 8 8 9 10 

  case 3,
    DemoAF_NotchedNoise
    % Responses for ASJ review Fig. 6 : 13 5 6 8 10 11 12 
    %%% save the result for filer-shape estimation in case 4
    str = ['save ' NameRsltNN ' ProbeLevel ParamNN ' ];
    eval(str);
 
 case 4,
    %%% load the result of exp. notched noise in case 3
    str = ['load ' NameRsltNN ];
    eval(str);
    DemoAF_ShapeEstimation
           
end;

disp(' ');

