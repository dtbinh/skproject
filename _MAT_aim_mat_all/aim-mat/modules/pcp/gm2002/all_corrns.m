%%%%%%%% Table data file, from BRG May 2001

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  This is the current file as of at least September 3rd 2001      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Killion JASA 63 1501-1509  (1978)

Hz = [ 0.,...
      20.,    25.,   31.5,   40.,    50.,    63.,   80.,  100.,  125.,   160.,  200.,   250.,   315.,   400.,  500.,  630.,...
     750.,   800., 1000.,  1250.,  1500.,  1600., 2000., 2500., 3000.,  3150., 4000.,  5000.,  6000.,  6300., 8000., 9000.,...
     10000., 11200.,12500., 14000., 15000., 16000.,20000.];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% This is the AES paper midear correction with slight increases in the corrections of 80 Hz & below  
%% USED TO CALC FILES ff.32k and df.32k

Midear=[ 55.0,...
      43.6,   34.9,  27.9,   22.4,   19.0,  16.6,  14.5,  12.5,  11.13,   9.71,  8.42,   7.2,    6.1,   4.7,   3.7,   3.0,...
       2.7,    2.6,   2.6,    2.7,    3.7,   4.6,   8.5,  10.8,   7.3,    6.7,   5.7,    5.7,    7.6,   8.4,  11.3,  10.6,...
       9.9,   11.9,  13.9,   16.0,   17.3,  17.8,  20.0];

%% This is the truer AES paper midear correction, no low-freq 
MidearAES=[ 42,... %% apart from 0 Hz which was 50
     39.15,  31.4,  25.4,   20.9,   18.0,  16.1,  14.2,  12.5,  11.13,   9.71,  8.42,   7.2,    6.1,   4.7,   3.7,   3.0,...
       2.7,    2.6,   2.6,    2.7,    3.7,   4.6,   8.5,  10.8,   7.3,    6.7,   5.7,    5.7,    7.6,   8.4,  11.3,  10.6,...
       9.9,   11.9,  13.9,   16.0,   17.3,  17.8,  20.0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FF_ED correction for threshold  (was ISO std Table 1 - 4.2 dB)
% i.e. relative to  0.0 dB at 1000 Hz, Shaw 1974

Ff_ed= [0.0,...
        0.0,    0.0,   0.0,    0.0,    0.0,    0.0,   0.0,   0.0,   0.1,    0.3,   0.5,    0.9,    1.4,    1.6,   1.7,   2.5,...
        2.7,    2.6,   2.6,    3.2,    5.2,    6.6,  12.0,  16.8,  15.3,   15.2,  14.2,   10.7,    7.1,    6.4,   1.8,  -0.9,...
       -1.6,    1.9,   4.9,    2.0,   -2.0,    2.5,   2.5];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% diffuse field correction
%% DIFFUSE correction ( relative to 0.0 dB at 1000Hz)
Diffuse= [0.0,...
        0.0,    0.0,   0.0,    0.0,    0.0,    0.0,   0.0,   0.0,   0.1,    0.3,   0.4,    0.5,    1.0,    1.6,   1.7,   2.2,...
        2.7,    2.9,   3.8,    5.3,    6.8,    7.2,  10.2,  14.9,  14.5,   14.4,  12.7,   10.8,    8.9,    8.7,   8.5,   6.2,...
        5.0,    4.5,   4.0,    3.3,    2.6,    2.0,   2.0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ITU Rec P 58 08/96 Head and Torso Simulator transfer fns.
%% from Peter Hugher BTRL , 4-June-2001

ITU_Hz = [0 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000];

%% ERP-DRP transfer fn, Table 14A/P.58, sect 6.2.  NB negative of table since defined other way round.
%% Ear Reference Point to Drum Reference Point

ITU_erp_drp = [0. 0. 0. 0. 0. .3 .2 .5 .6 .7 1.1 1.7 2.6 4.2 6.5 9.4 10.3 6.6 3.2 3.3 16 14.4];

