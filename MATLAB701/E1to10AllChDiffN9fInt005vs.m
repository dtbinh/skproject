% E1to10AllChDiffN9fInt005vs
function SigChN=E1to10AllChDiffN9fInt005vs(M1,M2,M3,M4,M5,M6,M7,M8,M9,N1,N2,N3,N4,N5,N6,N7,N8,N9,V)
for c=1:202
    M1S((1:123),c)=M1((15:137),c)/sum(M1((15:137),c))*123;
    M2S((1:123),c)=M2((15:137),c)/sum(M2((15:137),c))*123;
    M3S((1:123),c)=M3((15:137),c)/sum(M3((15:137),c))*123;
    M4S((1:123),c)=M4((15:137),c)/sum(M4((15:137),c))*123;
    M5S((1:123),c)=M5((15:137),c)/sum(M5((15:137),c))*123;
    M6S((1:123),c)=M6((15:137),c)/sum(M6((15:137),c))*123;
    M7S((1:123),c)=M7((15:137),c)/sum(M7((15:137),c))*123;
    M8S((1:123),c)=M8((15:137),c)/sum(M8((15:137),c))*123;
    M9S((1:123),c)=M9((15:137),c)/sum(M9((15:137),c))*123;
    N1S((1:123),c)=N1((15:137),c)/sum(N1((15:137),c))*123;
    N2S((1:123),c)=N2((15:137),c)/sum(N2((15:137),c))*123;
    N3S((1:123),c)=N3((15:137),c)/sum(N3((15:137),c))*123;
    N4S((1:123),c)=N4((15:137),c)/sum(N4((15:137),c))*123;
    N5S((1:123),c)=N5((15:137),c)/sum(N5((15:137),c))*123;
    N6S((1:123),c)=N6((15:137),c)/sum(N6((15:137),c))*123;
    N7S((1:123),c)=N7((15:137),c)/sum(N7((15:137),c))*123;
    N8S((1:123),c)=N8((15:137),c)/sum(N8((15:137),c))*123;
    N9S((1:123),c)=N9((15:137),c)/sum(N9((15:137),c))*123;
end;    
D1S=[(M1S(:,(1:202))-N1S(:,(1:202))),M1((15:137),203)];
D2S=[(M2S(:,(1:202))-N2S(:,(1:202))),M2((15:137),203)];
D3S=[(M3S(:,(1:202))-N3S(:,(1:202))),M3((15:137),203)];
D4S=[(M4S(:,(1:202))-N4S(:,(1:202))),M4((15:137),203)];
D5S=[(M5S(:,(1:202))-N5S(:,(1:202))),M5((15:137),203)];
D6S=[(M6S(:,(1:202))-N6S(:,(1:202))),M6((15:137),203)];
D7S=[(M7S(:,(1:202))-N7S(:,(1:202))),M7((15:137),203)];
D8S=[(M8S(:,(1:202))-N8S(:,(1:202))),M8((15:137),203)];
D9S=[(M9S(:,(1:202))-N9S(:,(1:202))),M9((15:137),203)];
P((1:123),203)=M1((15:137),203)/1000;
P((1:7),(1:202))=ones(7,202);
P((117:123),(1:202))=ones(7,202);
for C=1:202
    for fp=8:116
        if mean([(sum(M1S(((fp-7):(fp+7)),C))-sum(N1S(((fp-7):(fp+7)),C))) (sum(M2S(((fp-7):(fp+7)),C))-sum(N2S(((fp-7):(fp+7)),C))) (sum(M3S(((fp-7):(fp+7)),C))-sum(N3S(((fp-7):(fp+7)),C))) (sum(M4S(((fp-7):(fp+7)),C))-sum(N4S(((fp-7):(fp+7)),C))) (sum(M5S(((fp-7):(fp+7)),C))-sum(N5S(((fp-7):(fp+7)),C))) (sum(M6S(((fp-7):(fp+7)),C))-sum(N6S(((fp-7):(fp+7)),C))) (sum(M7S(((fp-7):(fp+7)),C))-sum(N7S(((fp-7):(fp+7)),C))) (sum(M8S(((fp-7):(fp+7)),C))-sum(N8S(((fp-7):(fp+7)),C))) (sum(M9S(((fp-7):(fp+7)),C))-sum(N9S(((fp-7):(fp+7)),C)))])<0
            P(fp,C)=1;
        else
            [H,P(fp,C),ci]=ttest([(sum(M1S(((fp-7):(fp+7)),C))-sum(N1S(((fp-7):(fp+7)),C))) (sum(M2S(((fp-7):(fp+7)),C))-sum(N2S(((fp-7):(fp+7)),C))) (sum(M3S(((fp-7):(fp+7)),C))-sum(N3S(((fp-7):(fp+7)),C))) (sum(M4S(((fp-7):(fp+7)),C))-sum(N4S(((fp-7):(fp+7)),C))) (sum(M5S(((fp-7):(fp+7)),C))-sum(N5S(((fp-7):(fp+7)),C))) (sum(M6S(((fp-7):(fp+7)),C))-sum(N6S(((fp-7):(fp+7)),C))) (sum(M7S(((fp-7):(fp+7)),C))-sum(N7S(((fp-7):(fp+7)),C))) (sum(M8S(((fp-7):(fp+7)),C))-sum(N8S(((fp-7):(fp+7)),C))) (sum(M9S(((fp-7):(fp+7)),C))-sum(N9S(((fp-7):(fp+7)),C)))],0,0.05,0);
        end;
    end;
end;
SigChN(1:7)=[0 0 0 0 0 0 0];
SigChN(117:123)=[0 0 0 0 0 0 0];
for Fp=8:116
    SigChN(Fp)=sum(P(Fp,(1:202))<0.05);
end;
PlotP=[[P;V] [SigChN 0 0 0 0]'];
assignin('base','PlotP',PlotP);
[i,j]=find(PlotP((1:123),(1:202))<0.05);
plot3(PlotP(126,j),PlotP(127,j),PlotP(i,203),'b.'),hold on;
plot3(PlotP(126,find(PlotP(125,(1:202))>0)),PlotP(127,find(PlotP(125,(1:202))>0)),ones(nnz(PlotP(125,(1:202))>0)),'ko'),hold on;
plot3(PlotP(126,find(PlotP(125,(1:202))==0)),PlotP(127,find(PlotP(125,(1:202))==0)),ones(nnz(PlotP(125,(1:202))==0)),'k.'),hold on;          
end
