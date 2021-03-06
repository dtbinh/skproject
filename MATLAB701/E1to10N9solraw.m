% E1to10N9solraw
function frequency=E1to10N9solraw(M1,M2,M3,M4,M5,M6,M7,M8,M9)
for c=1:202
    M((1:123),c,1)=M1((15:137),c);
    M((1:123),c,2)=M2((15:137),c);
    M((1:123),c,3)=M3((15:137),c);
    M((1:123),c,4)=M4((15:137),c);
    M((1:123),c,5)=M5((15:137),c);
    M((1:123),c,6)=M6((15:137),c);
    M((1:123),c,7)=M7((15:137),c);
    M((1:123),c,8)=M8((15:137),c);
    M((1:123),c,9)=M9((15:137),c);
end;    
for n=1:9
    M((1:123),203,n)=M1((15:137),203)/1000;
end;
assignin('base','Msol',M);
frequency=M(:,203,1);
end
