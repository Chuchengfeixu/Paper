function accuracy=computaccu(testsample,num1,trainsample,num2)
%����׼ȷ�ʵĺ���
%����testsample��ʾ����ͶӰ��Ĳ�������,num1��ʾÿһ����������ĸ���,
%trainsample������ͶӰ���ѵ������,num2����ÿһ��ѵ�������ĸ���
%���Ϊ��ȷ��
%�������ǲ���д��
accu=0;
testsampnum=size(testsample,1);
%classnum1=testsampnum/num1;
trainsampnum=size(trainsample,1);
%classnum2=trainsampnum/num2;
for i=1:testsampnum
for j=1:trainsampnum
juli(j)=norm(testsample(i,:)-trainsample(j,:));
end
[temp index]=sort(juli);
if ceil(i/num1)==ceil(index(1)/num2)
accu=accu+1;
end
end
accuracy=accu/testsampnum;
