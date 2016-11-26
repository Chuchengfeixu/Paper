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

%�Բ���ͼ���һ��(��ȥ��ֵ)
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

%������ͼ��ͶӰ��eigenspace�õ���Ӧÿ������ͼ���eigenfaces�������ϵ��
testWeights = v'*fbgTestImgs;

%���ѵõ�ѵ��ͼ��Ͳ���ͼ���Ӧ��eigenfaces�������ϵ��
%ʶ����ü򵥵�����ڷ�����ã�����ÿ������ͼ����ʶ����Ϊ��ӽ���ѵ��ͼ��ID
% classify_nearest;
%������ŵ�X��ƥ��
topX = CountTopX;

%������ڷ���Ѱ������X��ƥ��
testlen = size(testWeights,2);
trainlen = size(trainWeights,2);
index = zeros(testlen,topX);
resultIds = zeros(testlen,topX);
resultDist = zeros(testlen,topX);

%���μ���ÿ������ͼ��ͶӰϵ��ͬ����ѵ��ͼ��ϵ����ŷ�Ͼ���
x2 = sum(testWeights.^2)';
y2 = sum(trainWeights.^2);
for i = 1:testlen
    z = testWeights(:,i)'*trainWeights;
    z = repmat(x2(i),1,trainlen) + y2 - 2*z; %����ͼ��ϵ��ͬ����ѵ��ͼ��ϵ��ŷ�Ͼ���
    %[C, index(i)] = min(z);
    
    %��������Ƶ�X����
    for j = 1:topX
		[best, index(i, j)] = min(z);
		resultIds(i, j) = fbgTrainIds(index(i, j));
		resultDist(i, j) = best;
		z(index(i, j)) = Inf; %�Ƴ��ô��ҵ������Ž�,һ���´ε���Ѱ�Ҵ��Ž�

        %����ǰ���ŵļ�������ܶ���Ӧѵ������ͬһ����,Ϊ��ô��Ž���Ҫ����Ѱ��,ֱ�����ֲ�ͬ����
		if j > 1 %����j=1,��Ϊj=1����Ϊ���Ž�
			while sum(resultIds(i, 1:j-1) == resultIds(i, j)) > 0
				[best, index(i, j)] = min(z);
				resultIds(i, j) = fbgTrainIds(index(i, j));
				resultDist(i, j) = best;
				z(index(i, j)) = Inf; %�Ƴ��ô��ҵ������Ž�,һ���´ε���Ѱ�Ҵ��Ž�
			end
		end
    end	
end