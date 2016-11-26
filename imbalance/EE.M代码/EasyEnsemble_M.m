function ensemble=EasyEnsemble_M(trainset,traintarget,si,T,Y,catidx)
% Input:
%   trainset: n-by-d training set
%   traintarget: n-by-1 training target
%   catidx: indicates which attributes are discrete ones (Note: start from 1)
%   si: use $si$ iterations to train each AdaBoost classifier
%   T: sample $T$ subsets of negtive examples
%   Y:  the labels; for example [5;4;3;6;1;2]

tr=cell(size(Y,1),1);index=ones(1,size(Y,1));
for i=1:size(Y,1)
    for j=1:size(trainset,1)
        if(traintarget(j)==Y(i))
            tr{i}(index(i),:)=trainset(j,:);
            index(i)=index(i)+1;
        end;
    end;
end;
count=zeros(size(Y,1),1);
for i=1:size(Y,1)
    count(i)=size(tr{i},1);
end;
negset=cell(size(Y,1)-1,1);
for i=2:size(Y,1)
    negset{i-1}(:,:) = tr{i}(randperm(count(i)),:);
end;

% ensemble = struct('tree',{},'beta',[]);
nset=cell(size(Y,1)-1,1);
for no=1:T
    curtrainset=[];curtarget=[];
    curtrainset=tr{1};curtarget(1:count(1),1)=Y(1);
    for i=1:size(Y,1)-1
        nset{i}(:,:)=negset{i}(1:count(1),:);
        tar(1:count(1),1)=Y(i+1);
        curtrainset=[curtrainset;nset{i}];
        curtarget=[curtarget;tar];
    end;
    ens=AdaboostM1(curtrainset,curtarget,Y,catidx,si);


    ensemble(no)=ens;
    for i=1:size(Y,1)-1
        negset{i}(:,:) = negset{i}(randperm(count(i+1)),:);
    end;
end;
depth = length(ensemble);
ens= struct('trees',{},'beta',[]);
for i=1:depth
   ens(1).trees = [ens.trees; ensemble(i).trees];
   ens(1).beta = [ens.beta; ensemble(i).beta];
end;
ensemble = ens;
    
    
    
    
