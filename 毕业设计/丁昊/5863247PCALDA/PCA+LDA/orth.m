function ORTHOGONAL=orth(sw,sb,num)
%这个函数的作用就是将inv（sw）*sb得到的特征向量正交化
%输入sw代表类内协方差矩阵，sb代表类间协方差矩阵，num表示要得到多少个正交化的特征向量
%输出ORTHOGONAL就是一组正交的特征向量

invsw=inv(sw);
newspace=invsw*sb;
[x y]=eig(newspace);
d3=diag(y);
[d4 index1]=dsort(d3);
w1=x(:,index1(1));
V=[w1];
for i=1:num-1
U=V'*invsw*V;
temp1=invsw*V*inv(U)*V';
[u v]=size(temp1);
temp2=eye(u,v);
Q=(temp2-temp1)*newspace;
[q1 q2]=eig(Q);
wi=q1(:,1);
V=[V wi];
end
ORTHOGONAL=V;