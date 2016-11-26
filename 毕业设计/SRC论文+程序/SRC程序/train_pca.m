                                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_pca.m: Trains the original
% 'eigenface' 本征脸method using Principle Component Analysis (PCA)主成分分
% 析. PCA usually involves calculating the covariance matrix协方差矩阵, which is 
% extremely large if training on a lot of images, so we get around that by 
% using SVD (singular value decomposition)奇异值分解 instead. 100 eigenfaces 
% (eigenvectors) are used,and the top 10 are set to zero (ignored). It is 
% often good to discard(ignore) the top eigenfaces because they encode 
% illumination variations. This is often not true for small or consistently 
% illuminated datasets.These parameters (numVectors  and eigWeights) can be 
% varied for different recognition accuracy rates. For instance, try 
% commenting out line 48.

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

%默认使用 100 eigenvectors (eigenfaces)
if isempty(numVectors)
	numVectors = 100;
end

%忽略前10个eigenfaces (eigenvectors)→因他们多数包含亮度信息
if isempty(eigWeights)
	eigWeights(1:numVectors) = 1;
	eigWeights(1:10) = 0; % Ignore first 10 eigenfaces by setting to zero
end

%减去均值
for i = 1:size(fbgTrainImgs, 2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

%采用SVD进行PCA
[U,SV] = svd(fbgTrainImgs,'econ');
v = U(:,1:numVectors); %取前numVectors个eigenvectors作为eigenfaces

%忽略前10个eigenfaces (eigenvectors)→因他们多数包含亮度信息
for i = 1:numVectors
    v(:,i) = v(:,i)*eigWeights(i);
end

%获得每个图片的训练权重
%在eigenspace空间中采用eigenface线性表示每个脸的权重
trainWeights = v'*fbgTrainImgs;
