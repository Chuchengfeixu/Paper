function ORTHOGONAL=orth(sw,sb,num)
%������������þ��ǽ�inv��sw��*sb�õ�����������������
%����sw��������Э�������sb�������Э�������num��ʾҪ�õ����ٸ�����������������
%���ORTHOGONAL����һ����������������

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