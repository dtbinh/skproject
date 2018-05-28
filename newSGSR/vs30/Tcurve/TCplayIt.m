function y=TCplay(INSTR);

% synched play with adaptive loop for tuning curves

global SGSR PD1;

PrepareHardware4DA(INSTR.Hardware); % reset PD1, routing, fsam, nsam, etc; SS1 pre-synch switching
% load playlist(s) to dama and call APOS seqplay

loadPlayList(INSTR);

s232('seqplay', INSTR.chanDBN);
% set PA4s according to instructions generated by PA4settings
setPA4s(INSTR.StartAtt);

%-------------------
% some bookkeeping before triggering the hardware
ch = INSTR.synchChan;
Iplayed = 0;
DBNsil = INSTR.DBNsil(ch); % silence buffer
DBNtone = INSTR.DBNtone; % tones in synch channel
NSpike = zeros(1,100);
% timing of recording
RT = INSTR.RecTiming;
Nrep = RT.Nrep;
SWdur = RT.Nswitch*RT.SamP;
Bdur = RT.Nburst*RT.SamP;
SilDur = RT.Nsil*RT.SamP;
Onset = SWdur + (0:Nrep-1)*(Bdur+SilDur);
Offset = Onset + Bdur;
MaxCount = round(RT.MaxSpikeRate*Bdur*1e-6), % spike counts above this value will ignored by TCspikeCount
maxSPL = 90;
maxAtt = 90; minAtt = 10; Thr = 60;
Spont = Bdur*1e-6*inputOutput(-1000),
Crit = Spont+2*sqrt(Spont)
tctrack('init',1,[1 1 2 2], [INSTR.StartAtt(1) minAtt maxAtt], ...
   [-2 -1; 1 100], Nrep);
resp = (rand(1,Nrep)>0.3);

s232('PD1arm',1); 
ET1clear;
SecureET1go; % must be started before D/A or else will miss click
% read 0 from ET1, both as a test and for speed of consecuive calls to et1read
if et1read32~=0, 
   completeStop2;
   error('ET1 does not return zero after GO'); 
end;


%try
   s232('PD1go',1);
   % ----swift rewiring for proper sound output and spike input
   % connect ET1 to spike trigger device, etc.
   % already figured out in function ss1switching called by playINSTR.
   for icomm=INSTR.Hardware.postGo.', % column-wise assignment (see help for)
      s232('SS1select', icomm(1), icomm(2), icomm(3));
   end;
   newAtt = INSTR.StartAtt;
   setpa4s(newAtt);
   
   SilWait = nan+zeros(1,Nrep);
   BurstWait = nan+zeros(1,Nrep);
   TsilWait = nan+zeros(1,Nrep);
   TburstWait = nan+zeros(1,Nrep);
   Tspike = nan+zeros(1,Nrep);
   Over = 0;
   tic;
   for ilpendam=1:inf,
      % wait for the silence buffer to be played (or end-of-D/A)
      endOfDA = localWaitForSil(DBNsil, ch);
      % sil buffer is played now - act swiftly
      Iplayed=Iplayed+1;
      Nspike(Iplayed) = TCspikeCount([Onset(Iplayed) Offset(Iplayed)], MaxCount);
      meanNspike = Bdur*1e-6*inputOutput(maxSPL-newAtt(1))
      Nspike(Iplayed) = gpoisson(meanNspike);
      resp = Nspike(Iplayed)>Crit;
      newAtt = tctrack(resp);
      if isnan(newAtt), break; end; % track ready
      setpa4s(newAtt); 
      if endOfDA, break; end;
      for iii=0:inf, if (s232('playseg',ch)~=DBNsil), break; end; ;end;
   end
   % wait for silence buffer and unterrupt
   localWaitForSil(DBNsil, ch);
   setpa4s(99);
   completeStop2;
   Track = Tctrack('result');
   y = collectInStruct(Track, Nspike);
%catch, 
%   completeStop2;
%   disp(lasterr)
%   keyboard
%end % try/catch

%-----LOCALS-----------------------
function endOfDA = localWaitForSil(DBNsil, ch);
% waits until DA is from DBNsil DAMA buffer or D/A is stopped
% optimized for speed (playseg is much faster than PD1status; also
% no hurry when D/A is stopped)
endOfDA = 0;
for jjj=0:inf,
   for iii=0:1000, 
      if (s232('playseg',ch)==DBNsil), 
         break; 
      end; 
   end;
   if (s232('playseg',ch)==DBNsil), break; end;
   if (s232('PD1status',1)==0), endOfDA = 1; break; end;
end
