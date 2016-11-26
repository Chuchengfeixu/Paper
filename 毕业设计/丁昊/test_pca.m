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
