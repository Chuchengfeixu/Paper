function fbgTrainImgs=train_SRC(fbgTrainImgs)
for i = 1 : size(fbgTrainImgs,2)    %i从1到fbg...的列方向的维数（大小）
    fbgTrainImgs(:,i) = fbgTrainImgs(:,i) / norm(fbgTrainImgs(:,i));
end
%定义了一个函数train_SRC()
%作用为将矩阵的每一列i 都变成  i/(i的范数L2)