function sample=readsample(address,classnum,num)
%�������������ȡ������
%���룺address����Ҫ��ȡ�������ĵ�ַ,classnum����Ҫ���������������,num��ÿ��ĸ�����
%���Ϊ��������
%���Բ���֮�֡�
allsamples=[];
sizeclassnum=size(classnum,2);
sizenum=size(num,2);
for i=1:sizeclassnum
for j=1:sizenum
a=imread(strcat(address,num2str(classnum(i)),'\',num2str(num(j)),'.BMP'));
b=a(1:92*112);
b=double(b);
allsamples=[allsamples;b];
end
end
sample=allsamples;