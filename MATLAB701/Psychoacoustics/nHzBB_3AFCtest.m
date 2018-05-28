% nHzBB_3AFCtest
function RESULT=nHzBB_3AFCtest(s,Z,c)
t=(1:(1/8192):5);
RESULT((1:6),1)=[0;0;0;0;0;1];
RESULT((1:6),2)=[0;0;0;0;0;2];
RESULT(1,3)=s;
NoBB=[(sin(2*pi*t*250))' (sin(2*pi*t*250))'];
ISI2s=zeros([(8192*2),2]);
for m=3:Z
    BB=[(sin(2*pi*t*250))' (sin(2*pi*t*(250+RESULT(1,m))))'];
    RESULT(2,m)=unidrnd(3);
    if RESULT(2,m)==1
        Trial=[BB;ISI2s;NoBB;ISI2s;NoBB];
    elseif RESULT(2,m)==2
        Trial=[NoBB;ISI2s;BB;ISI2s;NoBB];
    else
        Trial=[NoBB;ISI2s;NoBB;ISI2s;BB];
    end;
    sound(Trial)
    RESULT(3,m)=input('Which is BB? 1,2or3?');
    if RESULT(3,m)==RESULT(2,m)
        RESULT(4,m)=1;
    else
        RESULT(4,m)=0;
    end;
    if RESULT(5,(m-2))*RESULT(5,(m-1))==0
        x=RESULT(4,m);
    else
        x=(RESULT(4,(m-2))+RESULT(4,(m-1))+RESULT(4,m))*RESULT(4,m);
    end;
    if x==0
        RESULT(1,(m+1))=RESULT(1,m)+c;
        RESULT(5,m)=0;
    elseif x==3
        RESULT(1,(m+1))=RESULT(1,m)-c;
        RESULT(5,m)=0;
    else
        RESULT(1,(m+1))=RESULT(1,m);
        RESULT(5,m)=1;
    end;
    RESULT(6,m)=m;
end;
assignin('base','RESULT',RESULT);
Tnumber=(1:1:10);
plot(RESULT(6,(RESULT(4,:)==1)),RESULT(1,(RESULT(4,:)==1)),'ok'),hold on
plot(RESULT(6,(RESULT(4,:)==0)),RESULT(1,(RESULT(4,:)==0)),'xk'),hold on
end
