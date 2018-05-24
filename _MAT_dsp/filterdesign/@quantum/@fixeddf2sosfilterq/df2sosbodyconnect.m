function [NL, PrevIPorts, PrevOPorts, NextIPorts, NextOPorts, mainparams]=df2sosbodyconnect(q,NL,H,mainparams)
%DF2SOSBODYCONNECT specifies the connection and quantization parameters in the
%conceptual body stage

%   Author(s): Honglei Chen
%   Copyright 1988-2008 The MathWorks, Inc.

% add quantization blocks
NL.setnode(filtgraph.node('caststage'),16);
set(NL.nodes(16).block,'label','CastStageIn');
set(NL.nodes(16),'position',[0.5 0 0.5 0]);
set(NL.nodes(16).block,'orientation','right');
mainparams(16)=filtgraph.indexparam(16,{});

%replace a(1) with cast since a(1)=1 in fixed point
NL.setnode(filtgraph.node('cast'),5);
set(NL.nodes(5).block,'label','CastState');
set(NL.nodes(5),'position',[4 0 4 0]);
set(NL.nodes(5).block,'orientation','right');
% Store the gain label so that we know that this node is an optimized
% gain. We need this to track and remove the useless gain labels from
% demux when MapCoeffsToPorts is on.
mainparams(5)=filtgraph.indexparam(5,{'0'},mainparams(5).gainlabels);

% specify the qparam

%CastStates
castqparam.outQ=[H.StateWordLength H.StateFracLength];
castqparam.RoundMode=H.RoundMode;
castqparam.OverflowMode=H.OverflowMode;
set(NL.nodes(5),'qparam',castqparam);

%CastStageOutput
caststageoutqparam.outQ=[H.SectionOutputWordLength H.SectionOutputFracLength];
caststageoutqparam.RoundMode=H.RoundMode;
caststageoutqparam.OverflowMode=H.OverflowMode;
set(NL.nodes(16),'qparam',caststageoutqparam);

% gain
%Numerator gain
lgainqparam.qcoeff=[H.CoeffWordLength H.NumFracLength];
lgainqparam.qproduct=[H.ProductWordLength H.NumProdFracLength];
lgainqparam.Signed=H.Signed;
lgainqparam.RoundMode=H.RoundMode;
lgainqparam.OverflowMode=H.OverflowMode;
set(NL.nodes(6),'qparam', lgainqparam);
set(NL.nodes(12),'qparam', lgainqparam);
set(NL.nodes(15),'qparam', lgainqparam);
%Denominator gain
rgainqparam.qcoeff=[H.CoeffWordLength H.DenFracLength];
rgainqparam.qproduct=[H.ProductWordLength H.DenProdFracLength];
rgainqparam.Signed=H.Signed;
rgainqparam.RoundMode=H.RoundMode;
rgainqparam.OverflowMode=H.OverflowMode;
set(NL.nodes(10),'qparam', rgainqparam);
set(NL.nodes(13),'qparam', rgainqparam);
%Scale Gain
% if scale value is 1 and OptimizeScaleValues is true, it will be removed
% by remove_caststage
scalegainqparam.qcoeff=[H.CoeffWordLength H.ScaleValueFracLength];
scalegainqparam.qproduct=[H.SectionInputWordLength H.SectionInputFracLength];
scalegainqparam.Signed=H.Signed;
scalegainqparam.RoundMode=H.RoundMode;
scalegainqparam.OverflowMode=H.OverflowMode;
set(NL.nodes(2),'qparam', scalegainqparam);

if H.CastBeforeSum
    lsumqparam.AccQ = [H.AccumWordLength H.NumAccumFracLength];
    rsumqparam.AccQ = [H.AccumWordLength H.DenAccumFracLength];
else
    s=getbestprecision(H);
    lsumqparam.AccQ = [s.AccumWordLength s.NumAccumFracLength];
    rsumqparam.AccQ = [s.AccumWordLength s.DenAccumFracLength];
end
%Numerator sum
lsumqparam.sumQ = [H.AccumWordLength H.NumAccumFracLength];
lsumqparam.RoundMode = H.RoundMode;
lsumqparam.OverflowMode = H.OverflowMode;
set(NL.nodes(7),'qparam',lsumqparam);
set(NL.nodes(8),'qparam',lsumqparam);
%Denominator sum
rsumqparam.sumQ = [H.AccumWordLength H.DenAccumFracLength];
rsumqparam.RoundMode = H.RoundMode;
rsumqparam.OverflowMode = H.OverflowMode;
set(NL.nodes(3),'qparam',rsumqparam);
set(NL.nodes(4),'qparam',rsumqparam);

%connection
if H.CastBeforeSum
    NL.connect(2,1,3,1);
    NL.connect(6,1,7,1);
else
    %Add a convert block before DenAcc
    NL.setnode(filtgraph.node('convert'),17);
    set(NL.nodes(17).block,'label','ConvertH');
    set(NL.nodes(17),'position',[1.5 0 1.5 0]);
    set(NL.nodes(17).block,'orientation','right');
    mainparams(17) = filtgraph.indexparam(17,{});
    convertqparam.outQ=[H.AccumWordLength H.DenAccumFracLength];
    convertqparam.RoundMode=H.RoundMode;
    convertqparam.OverflowMode=H.OverflowMode;
    set(NL.nodes(17),'qparam',convertqparam);
    %Add a convert block before NumAcc
    NL.setnode(filtgraph.node('convert'),18);
    set(NL.nodes(18).block,'label','ConvertF');
    set(NL.nodes(18),'position',[5.5 0 5.5 0]);
    set(NL.nodes(18).block,'orientation','right');
    mainparams(18) = filtgraph.indexparam(18,{});
    convertqparam.outQ=[H.AccumWordLength H.NumAccumFracLength];
    convertqparam.RoundMode=H.RoundMode;
    convertqparam.OverflowMode=H.OverflowMode;
    set(NL.nodes(18),'qparam',convertqparam);
    %making connections
    NL.connect(2,1,17,1);
    NL.connect(17,1,3,1);
    NL.connect(6,1,18,1);
    NL.connect(18,1,7,1);
end
NL.connect(1,1,16,1);
NL.connect(16,1,2,1);
NL.connect(3,1,4,1);
NL.connect(4,1,5,1);
NL.connect(5,1,6,1);
NL.connect(7,1,8,1);
NL.connect(8,1,9,1);
NL.connect(5,1,11,1);
NL.connect(11,1,10,1);
NL.connect(11,1,12,1);
NL.connect(11,1,14,1);
NL.connect(14,1,13,1);
NL.connect(14,1,15,1);
NL.connect(13,1,4,2);
NL.connect(15,1,8,2);
NL.connect(10,1,3,2);
NL.connect(12,1,7,2);

% setup the interstage connections
% since in the middle, both previous and next input and output needs to be
% specified.  Note that one stage's number of output has to match the
% number of input in adjacent layers.
PrevIPorts = [];
PrevOPorts = [];
NextIPorts = [];
NextOPorts = [];