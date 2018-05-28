function [Nspikes, Onset, Offset] =testPTC(dur, freq, Nbuf, GNOEPS);
% testPTC - test multi-buffer D/A for PTCs 
if nargin<4, GNOEPS = 0; end;

global SGSR

dur = dur*1e-3; % ms->s
if length(dur)==1, dur = [dur dur]; end;
Int = dur(2); % interval etween pips
dur = dur(1); % pip duration
[Fsam iFilt] = safeSampleFreq(freq);
Ntone = round(dur*Fsam);
tt = linspace(0,dur,Ntone); 

tone = SGSR.TTLamplitude*sin(2*pi*freq*tt);
tone(find(tone<0)) = 0;
%plot(1e3*tt, tone);
%pause

%train = zeros(1,Ntone);
%Npulse = round(dur*freq);
%pulseIndex = round(((1:Npulse)-0.5)*(Npulse/Ntone))
%return
% train()

cleanAP2;
pd1clear
DBN = zeros(1,Nbuf);
for ibuf=1:Nbuf, DBN(ibuf) = ML2dama(tone); end 
DBNtone1 = DBN(1);
DBN; Nsil = round(Int*Fsam); DBNsil = ML2dama(zeros(1,Nsil));
% interleave and add sync buff
global GLBsync SGSR
DBNsync = GLBsync.DBN;
Nsync = GLBsync.Nsync;
Nswitch = round(1e-3*SGSR.switchDur*Fsam);
[DBNswitch NRepSw] = silenceList(Nswitch);

% pip-sil-pip-..
DBN = vectorzip(DBN,DBNsil+DBN*0);
REPs = 1+0*DBN; 
% preceding sync&switch
DBN = [DBNsync DBNswitch(:)' DBN];
REPs = [1  NRepSw(:)' REPs];


DBNlist = [vectorzip(DBN, REPs) 0];
PLAY_DBN = ML2dama(DBNlist);
CHAN_DBN = ML2dama([PLAY_DBN 0]);

Nplay = Nsync + Nswitch+Nbuf*(Ntone+Nsil);
SamP = 1e6/Fsam; % sample period in us
HWI = HardwareInstr4DA('L', iFilt, Nplay, SamP);

% compute burst on- and offsets, expressed in (ET1)us from synch pulse
Onset = (Nswitch + (0:Nbuf-1)*(Ntone+Nsil))*SamP;
Offset = Onset+Ntone*SamP;
% spike count buffer
Nspikes = nan+zeros(1,Nbuf);


%-----------D/A-------------

prepareHardware4DA(HWI);
% load playlist(s) to dama and call APOS seqplay

s232('seqplay', CHAN_DBN);

% set PA4s according to instructions generated by PA4settings
%for icomm=INSTR.PA4.', % column-wise assignment (see help for)
%   PA4atten(icomm(1), icomm(2));
%end;
% -------CLICK DEBUG-------
s232('PD1arm',1); 
disp('Hit return to go');
pause;
ET1clear;
SecureET1go; % must be started before D/A or else will miss click
% -------CLICK DEBUG-------
% tic;
% while toc<1, end;
% disp('POST SWITCHING')
Att = 10+rand(1,Nbuf+1)*40;
z3('PA5setatt', 1, Att(Nbuf+1));
s232('PD1go',1);
if GNOEPS, return; end
% ----swift rewiring for proper sound output and spike input
% connect ET1 to spike trigger device, etc.
% already figured out in function ss1switching called by playInstr.
for icomm=HWI.postGo.', % column-wise assignment (see help for)
   s232('SS1select', icomm(1), icomm(2), icomm(3));
end;


%oldps = nan; II=0; PS = nan+zeros(1,100);
%while (s232('PD1status',1)~=0),
%   ps = s232('playseg',1);
%   if ps~=oldps,
%      II = II+1;
%      PS(II) = ps;
%      oldps=ps;
%   end
%end
%PS = PS(1:II)
%tup = DBNlist(1:end-1);
%tup = reshape(tup,round(size(tup).*[2 0.5]))
%return

% read synch pulse
if et1read32~=0, error('no zero in ET1'); end;
synch = et1read32

% Now the fun starts
stopch = 3; % strange TDT bug
ii =1;
%try
   while (s232('PD1status',1)~=0) & (s232('playseg',1)~=DBNtone1), end;
   while (s232('PD1status',1)~=0),
      while 1,
         ps = s232('playseg',1);
         if (ps==DBNsil) | (ps==stopch), break; end;
      end
      if ps==stopch, break; end;
      z3('PA5setatt', 1, Att(ii));
      Nspikes(ii) = TCspikeCount(synch+[Onset(ii) Offset(ii)]);
      ii=ii+1;
      if DBNsil~=s232('playseg',1),
         warning(['too late! ' num2str(ii) ' ' num2str(s232('playseg',1))])
      end;
      while DBNsil==s232('playseg',1); end;
   end
%catch
   disp(['stopped at chan ' num2str(s232('playseg',1))]);
%end





