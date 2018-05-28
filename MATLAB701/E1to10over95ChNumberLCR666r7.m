% E1to10over95ChNumberLCR666r7
function NumberTvsRev=E1to10over95ChNumberLCR666r7(M6,M4,N,V)
% M6:FFTby6.66HzBB; M4:FFTby4HzBB; N:FFTbyNoBB; V:channels202XY 
% In 666HzBB, find channel in which there find 666Hz peak over 95 
C6=((M6(92,(1:202))>mean(M6(([78:90 94:106]),(1:202)),1)+std(M6(([78:90 94:106]),(1:202)),0,1)*1.64)...
    &(M6(91,(1:202))<mean(M6(([78:90 94:106]),(1:202)),1)+std(M6(([78:90 94:106]),(1:202)),0,1)*1.64)...
    &(M6(93,(1:202))<mean(M6(([78:90 94:106]),(1:202)),1)+std(M6(([78:90 94:106]),(1:202)),0,1)*1.64));
C6rev=(C6*(-1))+ones(size(C6));
% In 4HzBB, find channel in which there find no 666Hz peak over 95
C4pre=((M4(92,(1:202))>mean(M4(([78:90 94:106]),(1:202)),1)+std(M4(([78:90 94:106]),(1:202)),0,1)*1.64)...
    &(M4(91,(1:202))<mean(M4(([78:90 94:106]),(1:202)),1)+std(M4(([78:90 94:106]),(1:202)),0,1)*1.64)...
    &(M4(93,(1:202))<mean(M4(([78:90 94:106]),(1:202)),1)+std(M4(([78:90 94:106]),(1:202)),0,1)*1.64));
C4=(C4pre*(-1))+ones(size(C4pre));
% In NoBB, find channel in which there find no 666Hz peak over 95
CNpre=((N(92,(1:202))>mean(N(([78:90 94:106]),(1:202)),1)+std(N(([78:90 94:106]),(1:202)),0,1)*1.64)...
    &(N(91,(1:202))<mean(N(([78:90 94:106]),(1:202)),1)+std(N(([78:90 94:106]),(1:202)),0,1)*1.64)...
    &(N(93,(1:202))<mean(N(([78:90 94:106]),(1:202)),1)+std(N(([78:90 94:106]),(1:202)),0,1)*1.64));
CN=(CNpre*(-1))+ones(size(CNpre));
% find propriate channels
C=(C6.*C4).*CN;
SelectChs=V(:,find(C>0));
Crev=(CNpre.*C4).*C6rev;
SelectChs_rev=V(:,find(Crev>0));
% find number of propriate channels
NumberLCR=[nnz(SelectChs(2,:)==1) nnz(SelectChs(2,:)==0) nnz(SelectChs(2,:)==2)];
assignin('base',[inputname(1) '_SelectChs95_666r7'],SelectChs);
assignin('base',[inputname(1) '_NumberLCR95_666r7'],NumberLCR);
NumberLCR_rev=[nnz(SelectChs_rev(2,:)==1) nnz(SelectChs_rev(2,:)==0) nnz(SelectChs_rev(2,:)==2)];
assignin('base',[inputname(1) '_SelectChs95_666r7rev'],SelectChs_rev);
assignin('base',[inputname(1) '_NumberLCR95_666r7rev'],NumberLCR_rev);
NumberTvsRev=[NumberLCR;NumberLCR_rev];
plot(M6((15:137),203)/1000,M6((15:137),find(C>0)),'b',M4((15:137),203)/1000,M4((15:137),find(C>0)),'r',N((15:137),203)/1000,N((15:137),find(C>0)),'k'),grid on
end
