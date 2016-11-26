function main()
classnum=[1:1:40];
num=[1:1:5];
address='E:\s\s';
allsamples=readsample(address,classnum,num);
[newsample base]=pca(allsamples,0.9);
[sw sb]=computswb(newsample,40,5);
%vsort1=orth(sw,sb,39);
%如果将sw/sb的向量正交化，可以达到89%。不加,达到81.5%。
vsort1=projectto(sw,sb,39);
num1=[6:1:10];
testsample=readsample(address,classnum,num1);
tstsample=testsample*base*vsort1;
trainsample=newsample*vsort1;
accuracy=computaccu(tstsample,5,trainsample,5)