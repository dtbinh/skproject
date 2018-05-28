%Script for K4 (1st control is "attend-attend or ignore-ignore")

%Note that "X444no" function is for no peak channel case, but it can be
%used in normal case.
close all;E1to10over95ChNumberLCRnewX444no(K4l240r24444attend_fft,K4l240r248attend_fft,K3l240r240fft,channels202XY)
close all;E1to10over95ChNumberLCRnewX444no(K4l240r24444ignore_fft,K4l240r248ignore_fft,K3l240r240fft,channels202XY)

%Note that 444HzBB is used as 1st control for 5.71HzBB
close all;E1to10over95ChNumberLCRnewX571(K4l240r24571attend_fft,K4l240r24444attend_fft,K3l240r240fft,channels202XY)
close all;E1to10over95ChNumberLCRnewX571(K4l240r24571ignore_fft,K4l240r24444ignore_fft,K3l240r240fft,channels202XY)

close all;E1to10over95ChNumberLCRnewX8(K4l240r248attend_fft,K4l240r24444attend_fft,K3l240r240fft,channels202XY)
close all;E1to10over95ChNumberLCRnewX8(K4l240r248ignore_fft,K4l240r24444ignore_fft,K3l240r240fft,channels202XY)