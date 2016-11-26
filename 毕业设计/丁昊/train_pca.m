%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_pca.m: Trains the original
% 'eigenface' method using Principle Component Analysis (PCA). PCA usually
% involves calculating the covariance matrix, which is extremely large if
% training on a lot of images, so we get around that by using SVD (singular
% value decomposition) instead. 100 eigenfaces (eigenvectors) are used,
% and the top 10 are set to zero (ignored). It is often good to discard
% (ignore) the top eigenfaces because they encode illumination variations.
% This is often not true for small or consistently illuminated datasets.
% These parameters (numVectors  and eigWeights) can be varied for different
% recognition accuracy rates. For instance, try commenting out line 48.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready:
%  - fbgTrainImgs: The training images, arranged in columns.
%  - fbgTrainIds: The IDs of the training images (identity of faces)
%  - fbgAverageFace: The mean face of all the training images
%  - fbgRows/fbgCols: The size of images trained on
%  - fbgTrainMem: Store any training memory necessary to do recognition
%    here in cell arrays
%
% M. A. Turk and A. P. Pentland, "Face Recognition Using Eigenfaces," in
% IEEE CVPR), 1991, pp. 586-591.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [v,trainWeights]=train_pca(fbgTrainImgs,fbgTrainIds,fbgAvgFace,numVectors,eigWeights)

if isempty(numVectors)              %默认使用 100 eigenvectors (eigenfaces)
	numVectors = 100;
end

if isempty(eigWeights)              %忽略前10个eigenfaces （因他们多数包含亮度信息）
	eigWeights(1:numVectors) = 1;
	eigWeights(1:10) = 0; 
end

for i = 1:size(fbgTrainImgs, 2)     %减去均值
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

[U,SV] = svd(fbgTrainImgs,'econ');  %采用SVD进行PCA
v = U(:,1:numVectors);              %取前numVectors个eigenvectors作为eigenfaces

for i = 1:numVectors                %忽略前10个eigenfaces
    v(:,i) = v(:,i)*eigWeights(i);
end

%获得每个图片的训练权重
%在eigenspace空间中采用eigenface线性表示每个脸的权重
trainWeights = v'*fbgTrainImgs;
