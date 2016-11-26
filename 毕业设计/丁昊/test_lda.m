%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_lda.m: Trains using the Fisherfaces
% algorithm (Linear Discriminant Analysis => LDA). This method does quite
% well, although is more computationally expensive. The trick to this
% method is to reduce the dimensionality of the images first using PCA and
% then do LDA on the PCA weights.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See train_pca.m for more details.
%
% P. N. Belhumeur, J. P. Hespanha, and D. J. Kriegman, "Eigenfaces vs.
% Fisherfaces: Recognition Using Class Specific Linear Projection," in IEEE
% TPAMI. vol. 19, 1997, pp. 711-720 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Authors:                           Brian C. Becker @ www.BrianCBecker.com
% Copyright (c) 2007-2008          Enrique G. Ortiz @ www.EnriqueGOrtiz.com
%
% License: You are free to use this code for academic and non-commercial
% use, provided you reference the following paper in your work.
%
% Becker, B.C., Ortiz, E.G., "Evaluation of Face Recognition Techniques for 
% Application to Facebook," in Proceedings of the 8th IEEE International
% Automatic Face and Gesture Recognition Conference, 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [resultIds]=test_lda(fbgTestImgs,fbgAvgFace,CountTopX,v,trainWeights,fbgTrainIds)

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