function ensemble=AdaboostM1(trainset, traintarget, classY,catidx, rounds)
% Input:
%   trainset: n-by-d training set
%   traintarget: n-by-1 training target
%   catidx: indicates which attributes are discrete ones (Note: start from 1)
%   rounds: use $rounds$ iterations to train each AdaBoost classifier
% Output:
%   ensemble: AdaBoost classifier, a structure variable
% Note: this method uses 'treefit' decision tree method in statistics toolbox to 
%   generate base classifiers 

% Copyright: Xu-Ying Liu, Jianxin Wu, and Zhi-Hua Zhou, 2009
% Contact: Xu-Ying Liu (liuxy@lamda.nju.edu.cn)

% Version 2. 2012-5-12 handling the case that training error is 0
epsilon = 1e-8;

ensemble.trees = cell(rounds,1);
ensemble.alpha = zeros(rounds,1);
% ensemble.thresh = 0;

weight = zeros(size(traintarget));
for i=1:size(classY,1)
    weight(traintarget==classY(i)) = 1/sum(traintarget==classY(i));
end;
weight = weight / sum(weight);

 err0flag = false;
% result = zeros(size(traintarget));
beta=zeros(rounds,1);
for i=1:rounds
    [boostset boosttarget] = boost_data(trainset,traintarget,weight);
    tree = treefit(boostset,boosttarget,'method','classification','categorical',catidx);%base weak learner
    ensemble.trees{i} = tree;
    [yfit,node,trainresult] = treeval(tree,trainset);
    trainresult=cellfun(@str2num,trainresult);
    %trainresult=str2num(cell2mat(trainresult));
    trainerror = sum(weight.*(trainresult~=traintarget));
    if(trainerror<epsilon) 
        err0flag = true;        
        break;
    end;
    beta(i) = trainerror/(1-trainerror);
    ensemble.alpha(i)=log(1/beta(i));
%     weight = weight .* exp(-ensemble.alpha(i)*(trainresult-0.5).*(traintarget-0.5)*4);
    for j=1:size(trainset,1)
        if(traintarget(j)==trainresult(j))
            tempweight(j)=beta(i);
        else
            tempweight(j)=1;
        end;
    end;
    for k=1:size(weight,1)
        weight(k)=weight(k)*tempweight(k);
    end;
    weight = weight / sum(weight);
end


if(err0flag)
% if training error gets 0 in the first round, then keep the weak learner
% and alpha = 1, stop learning
% else, ingor this weak learner, using the previous ones to ensemble
     if(i==1)
         ensemble.trees=ensemble.trees(1);
         ensemble.alpha(1) = 1;
         ensemble.alpha=ensemble.beta(1);
     else
         ensemble.trees=ensemble.trees(1:i-1);
         ensemble.alpha=ensemble.alpha(1:i-1);
     end
 end

% ensemble.thresh = sum(ensemble.alpha)/2;