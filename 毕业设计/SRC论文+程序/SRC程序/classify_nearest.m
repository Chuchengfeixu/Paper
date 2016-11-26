%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> classify_nearest: Classifies test and train
% weights based on the nearest neighbor as determined by Euclidean
% distance. We split this functionality off from the rest of the individual
% recognition methods since it is is a common operation for subspace
% algorithms (PCA, CCIPCA, ICA, LDA, etc). The Euclidean distance is
% calculated using some nifty Matlab vectorization magic.
%
% This script has been since extended to do some other cool stuff. First,
% you can set fbgCountTopX in fbInit and get not just the top match, but
% the top X number of matches. If the correct identity is found within
% these top X matches, we consider the match a success and count the face
% as being recognized. This might be useful in an interactive tagging
% system where the top X choices are presented to the user.
%
% Anpother cool thing this script can do is generate an HTML page with all
% the matches shown in tables. See genHTMLResults.m for more detail
%
% This sets the fbgAccuracy variable.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%������ŵ�X��ƥ��
topX = fbgCountTopX;

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
% 
% %ͳ��ʶ����
% if topX > 1
%     resultMatrix = (resultIds == repmat(fbgTestIds, 1, topX));
%     results = max(resultMatrix, [], 2);
% else
%     resultMatrix = (resultIds == fbgTestIds);%ʶ����ȷ��Ϊ1,�����Ϊ0
%     results = max(resultMatrix, [], 2);
% end
% 
% correct = find(results == 1);                               %���ʶ����ȷ�Ĳ���ͼ������
% fbgAccuracy = 100* length(correct) / size(fbgTestIds,1);    %������ȷʶ����

% % Only do this if we are not also 
% if fbgMakeAccuracy > 0 && topX == 1
% 	t = fminsearch(@(t) testThreshold(t, correct, resultDist, fbgMakeAccuracy, results), mean(resultDist));
% 	[accuracy, left, keepIndex] = testThreshold(t, correct, resultDist, 0, results);
% 	[accuracy, left, t / 1e4];
% 	fbgAccuracy = accuracy*100;
% 	fprintf('By thresholding, we have eliminated %0.1f%% of the faces.\n', 100*(1-left));
% 	% Should remove the ignored faces here so HTML output is correct
% 	resultIds = resultIds(keepIndex, :);
% 	index = index(keepIndex, :);
% 	resultDist = resultDist(keepIndex, :);
% 	resultMatrix = resultMatrix(keepIndex, :);
% 	testFiles = fbgTestFiles(keepIndex);
% else
% 	testFiles = fbgTestFiles;
% end
