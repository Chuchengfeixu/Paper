function fbgTrainImgs=train_SRC(fbgTrainImgs)
for i = 1 : size(fbgTrainImgs,2)    %i��1��fbg...���з����ά������С��
    fbgTrainImgs(:,i) = fbgTrainImgs(:,i) / norm(fbgTrainImgs(:,i));
end
%������һ������train_SRC()
%����Ϊ�������ÿһ��i �����  i/(i�ķ���L2)