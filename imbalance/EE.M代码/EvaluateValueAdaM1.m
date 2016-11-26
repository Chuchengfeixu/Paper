function result = EvaluateValueAdaM1(dataset,classY,ensemble)
% To predict real values for a set of examples using 
% AdaBoost/EasyEnsemble/BalanceCascade classifer
% Input:
%   dataset: n-by-d test set
%   ensemble: AdaBoost/EasyEnsemble/BalanceCascade classifer
% Output:
%   values: predicted real values of test examples

% Copyright: Xu-Ying Liu, Jianxin Wu, and Zhi-Hua Zhou, 2009
% Contact: Xu-Ying Liu (liuxy@lamda.nju.edu.cn)
result=zeros(size(dataset,1),1);
value = zeros(size(dataset,1),size(classY,1));
for i=1:size(dataset,1)
    for k=1:size(classY,1)
        for j=1:length(ensemble.trees)
            [yfit,node,re]=treeval(ensemble.trees{j},dataset(i,:));
            re=cellfun(@str2num,re);
            if(re==classY(k))
                value(i,k) = value(i,k) + ensemble.alpha(j);
            end;
        end;
    end;
    [temp,index]=max(value(i,:));
    result(i)=classY(index);
end;
