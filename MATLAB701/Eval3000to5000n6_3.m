% Eval3000to5000n6_3
function Eval=Eval3000to5000n6_3(M)
for n=1:202
    for f=1:28
        if M(f,n)<0.001
            Eval(f,n)=1;
        else
            Eval(f,n)=0;
        end
    end
end
Eval((1:28),203)=M((1:28),203);
assignin('base','Eval',Eval);    
end



