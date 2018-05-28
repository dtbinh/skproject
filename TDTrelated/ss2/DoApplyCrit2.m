
if 1
    DataCell={...
            'd:\data\G030123\#0','d:\data\G030123\#0';...
            'd:\data\G030123\#1','d:\data\G030123\#1';...
            'd:\data\G030123\#2','d:\data\G030123\#2';...
            'd:\data\G030123\#3','d:\data\G030123\#3';...
            'd:\data\G030123\#4','d:\data\G030123\#3';...
            ...
            'd:\data\G030123\#5','d:\data\G030123\#5';...
            'd:\data\G030123\#6','d:\data\G030123\#6';...
            'd:\data\G030123\#7','d:\data\G030123\#7';...
            ...
            'd:\data\G030123\#9','d:\data\G030123\#9';...
        }
end

NData=size(DataCell,1);
%diary d:\data\diary.txt
for iData=1:NData
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TargetRoot=DataCell{iData,1};
    CriterionRoot=DataCell{iData,2};    
    disp(TargetRoot);
    
    %Set up the data directory
    RootNameIn=TargetRoot;
    RootNameOut=fullfile(TargetRoot,'sort');
    if exist(RootNameOut,'dir')~=7
        mkdir(TargetRoot,'sort')
    end

    %Get stim indeces
    d=dir(fullfile(RootNameIn,'*.raw'));
    n=length(d);
    StimIdx=zeros(1,n);
    for i=1:n
        myname=d(i).name;
        [Path,Name,Ext]=fileparts(myname);
        StimIdx(i)=str2num(Name);
    end
    
 %  ApplyCrit2(fullfile(Root,'peaks'),StimIdx,RootNameOut,fullfile(Root,'Criterion'));
    ApplyCrit2(fullfile(TargetRoot,'peaks'),StimIdx,RootNameOut,fullfile(CriterionRoot,'Criterion'));
end
%diary off
