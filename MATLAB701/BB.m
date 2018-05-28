% BB
function Beat=BB(F1,F2)
t=(1:(1/25000):10);
B(:,1)=sin(2*pi*F1*t);
B(:,2)=sin(2*pi*F2*t);
assignin('base','B',B);
h1=figure('Position',[150 150 300 300]);
h2=uicontrol(...
    'Parent',h1,...
    'Style','Pushbutton',...
    'Position',[100 20 40 40],...
    'String','Start',...
    'Callback',['BBsub(''start'')']...
    );
h3=uicontrol(...
    'Parent',h1,...
    'Style','text',...
    'Position',[60 100 40 16],...
    'String',num2str(F1)...
    );
h4=uicontrol(...
    'Parent',h1,...
    'Style','text',...
    'Position',[140 100 40 16],...
    'String',num2str(F2)...
    );
end
