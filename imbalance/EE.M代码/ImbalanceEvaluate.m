function [fmeasure,gmean]=ImbalanceEvaluate(target,result,Y)

% F-measure and G-mean
    auc=zeros(size(Y,1),1);
    recall=zeros(size(Y,1),1);
    precision=zeros(size(Y,1),1);
    Fmeasure=zeros(size(Y,1),1); gmean=1;
    for l=1:size(Y,1)
        for i=1:size(target,1)
            if(result(i)==target(i)&&result(i)==Y(l))
                auc(l)=auc(l)+1;
            end;
        end;
    end;
    true=zeros(size(Y,1),1);%每个类别的样本数
    for j=1:size(Y,1)
        for i=1:size(target,1)
            if(target(i)==Y(j))
                true(j)=true(j)+1;
            end;
        end;
    end;
    pre=zeros(size(Y,1),1);%被预测为各个类别的样本数
    for j=1:size(Y,1)
        for i=1:size(target,1)
            if(result(i)==Y(j))
                pre(j)=pre(j)+1;
            end;
        end;
    end;
    for i=1:size(Y,1)
        if(auc(i)==0)
            Fmeasure(i)=0;
            recall(i)=0;
        else
            recall(i)=auc(i)/true(i);
            precision(i)=auc(i)/pre(i);
            Fmeasure(i)=(2*recall(i)*precision(i))/(recall(i)+precision(i));
        end;
    end;
    fmeasure=sum(Fmeasure)/size(Y,1);
    for i=1:size(Y,1)
        gmean=gmean*recall(i);
    end;
    gmean=gmean^(1/size(Y,1)); 




