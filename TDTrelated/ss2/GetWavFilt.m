function [Wav,Fs]=GetWavFilt(RootName,StimIdx,TrialNo)
%GetWavFilt -- Load the recorded waveforms after bandpass filtering
%
%Usage: [Wav,Fs]=GetWavFilt(RootName,StimIdx,TrialNo)
%
%RootName : Name of the root directory for the data (eg, 'c:\data\g020613\#1')
%StimIdx : Index for stimulus (Scalar or a vector)
%TrialNo : Trial number(s) to retrieve
%Wav : Matrix or cell array for the waveforms.
%   If length(StimIdx) is 1, Wav is a matrix with a size of [NPts, NTrials].
%   Otherwise, Wav is a cell array, each cell containing a matrix as above.
%Fs : Sampling rate
%
%By SF, 11/21/02


[Wav,Fs]=GetWav(RootName,StimIdx,TrialNo);

%Filter coefficients for band pass filtering
[b,a]=ellip(3,0.5,20,[500 3000]/(Fs/2));
%[b,a]=ellip(3,0.5,20,[10 500]/(Fs/2));

nWav=length(StimIdx);
if nWav>1, h=waitbar(0,'Filtering ...');, end
for iWav=1:nWav
    if iscell(Wav)
        myWav=Wav{iWav};
        myWav=filtfilt(b,a,myWav);
        Wav{iWav}=myWav;
    else
        Wav=filtfilt(b,a,Wav);
    end
if nWav>1, waitbar(iWav/nWav,h); end
end
if nWav>1, close (h); end