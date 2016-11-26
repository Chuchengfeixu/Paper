%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_pca.m: Tests/recognizes the original
% 'eigenface' method using Principal Component Analysis (PCA). Test images
% are projected into the eigenspace created by the training process and are
% then matched to their nearest neighbor in the trained face weights. The
% nearest trained face provides the classification for the test face.
%
% This is usually called during a fbRun, you will need to set fgbAccuracy
% in order for the fbRun script to calculate the accuracy. A number of
% variables are  already loaded and ready:
%  - fbgAccuracy: You must set this with the accuracy of the method
%  - fbgTestImgs: The testing images, arranged in columns.
%  - fbgTestIds: The IDs of the testing images (identity of faces)
%  - fbgAverageFace: The mean face of all the training images
%  - fbgRows/fbgCols: The size of images trained on
%  - fbgTrainMem: Store any training memory necessary to do recognition
%    here in cell arrays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [resultIds]=test_pca(fbgTestImgs,fbgAvgFace,CountTopX,v,trainWeights,fbgTrainIds)

%对测试图像归一化(减去均值)
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

%将测试图像投影到eigenspace得到对应每个测试图像的eigenfaces线性组合系数
testWeights = v'*fbgTestImgs;

%现已得到训练图像和测试图像对应的eigenfaces线性组合系数
%识别可用简单的最近邻方法获得；对于每个测试图像，其识别结果为最接近的训练图像ID
% classify_nearest;
%获得最优的X个匹配
topX = CountTopX;

%用最近邻方法寻找最优X个匹配
testlen = size(testWeights,2);
trainlen = size(trainWeights,2);
index = zeros(testlen,topX);
resultIds = zeros(testlen,topX);
resultDist = zeros(testlen,topX);

%依次计算每个测试图像投影系数同所有训练图像系数的欧氏距离
x2 = sum(testWeights.^2)';
y2 = sum(trainWeights.^2);
for i = 1:testlen
    z = testWeights(:,i)'*trainWeights;
    z = repmat(x2(i),1,trainlen) + y2 - 2*z; %测试图像系数同所有训练图像系数欧氏距离
    %[C, index(i)] = min(z);
    
    %获得最相似的X个解
    for j = 1:topX
		[best, index(i, j)] = min(z);
		resultIds(i, j) = fbgTrainIds(index(i, j));
		resultDist(i, j) = best;
		z(index(i, j)) = Inf; %移除该次找到的最优解,一遍下次迭代寻找次优解

        %由于前最优的几个解可能都对应训练库中同一个人,为获得次优解需要继续寻找,直至出现不同的人
		if j > 1 %跳过j=1,因为j=1不会为次优解
			while sum(resultIds(i, 1:j-1) == resultIds(i, j)) > 0
				[best, index(i, j)] = min(z);
				resultIds(i, j) = fbgTrainIds(index(i, j));
				resultDist(i, j) = best;
				z(index(i, j)) = Inf; %移除该次找到的最优解,一遍下次迭代寻找次优解
			end
		end
    end	
end
