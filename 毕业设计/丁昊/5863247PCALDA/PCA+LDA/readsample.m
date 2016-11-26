function sample=readsample(address,classnum,num)
%这个函数用来读取样本。
%输入：address就是要读取的样本的地址,classnum代表要读入样本的类别数,num是每类的个数；
%输出为样本矩阵
%出自波波之手。
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