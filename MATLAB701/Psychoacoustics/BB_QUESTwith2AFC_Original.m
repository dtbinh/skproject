% BB_QUESTwith2AFC_Original

time=(1:(1/8192):3);
NoBB=[(sin(2*pi*time*250))' (sin(2*pi*time*250))'];
ISI2s=zeros([(8192*2),2]);

x=(0.001:0.001:0.040);
gamma=0.5;
b=3.5/20;

S(1,1)=0.035;
F(1,1)=250*(10^(S(1,1)/20));
BB=[(sin(2*pi*time*250))' (sin(2*pi*time*F(1,1)))'];
BBinterval=unidrnd(2);
if BBinterval==1
    Trial=[BB;ISI2s;NoBB];
else
    Trial=[NoBB;ISI2s;BB];
end;
sound(Trial)
Ans=input('Which is BB? the former (1) or latter (2) ?');
if Ans==BBinterval
   r(1,1)=1;
   for m=1:30
       P(m,1)=1-(1-gamma).*exp(-10.^(b.*(S(1,1)-m*0.001)));
   end;
else
   r(1,1)=0;
   for m=1:30
       P(m,1)=1-(1-(1-gamma).*exp(-10.^(b.*(S(1,1)-m*0.001))));
   end;
end;
[Pmax(1,1),MaxIndex(1,1)]=max(P(:,1),[],1);
Th(1,1)=MaxIndex(1,1)*0.001+(1/b)*log10(log((1-gamma)/(1-0.9)));
disp(['Trial 1 at ' num2str(S(1,1)) 'dB (' num2str(F(1,1)) ' Hz) has response ' num2str(r(1,1)) ]);
for k=2:10
    S(1,k)=Th(1,(k-1));
    F(1,k)=250*(10^(S(1,k)/20));
    BB=[(sin(2*pi*time*250))' (sin(2*pi*time*F(1,k)))'];
    BBinterval=unidrnd(2);
    if BBinterval==1
        Trial=[BB;ISI2s;NoBB];
    else
        Trial=[NoBB;ISI2s;BB];
    end;
    sound(Trial)
    Ans=input('Which is BB? the former (1) or latter (2) ?');
    if Ans==BBinterval
        r(1,k)=1;
        for m=1:30
            P(m,k)=(1-(1-(1-gamma).*exp(-10.^(b.*(S(1,k)-m*0.001))))).*P(m,(k-1));
        end;
    else
        r(1,k)=0;
        for m=1:30
            P(m,k)=(1-(1-(1-gamma).*exp(-10.^(b.*(S(1,k)-m*0.001))))).*P(m,(k-1));
        end;
    end;
    [Pmax(1,k),MaxIndex(1,k)]=max(P(:,k),[],1);
    Th(1,k)=MaxIndex(1,k)*0.001+(1/b)*log10(log((1-gamma)/(1-0.9)));
    disp(['Trial ' num2str(k) ' at ' num2str(S(1,k)) 'dB (' num2str(F(1,k)) ' Hz) has response ' num2str(r(1,1)) ]);
end;
    

