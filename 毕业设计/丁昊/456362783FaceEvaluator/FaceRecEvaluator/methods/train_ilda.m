len = size(fbgTrainImgs,2);
batch = 250;

eigenThreshold = 0;
DeigenThreshold = 0;
dimScatterMatrix = 250;%length(unique(fbgTrainIds));

maxBatch = len / batch;

avgFace = zeros(size(fbgTrainImgs(:,1)));
for i = 1:maxBatch+1
	if i < maxBatch
		batchImgs = fbgTrainImgs(:,(i-1)*batch+1:i*batch);
		batchIds = fbgTrainIds((i-1)*batch+1:i*batch);
	else
		batchImgs = fbgTrainImgs(:,(i-1)*batch+1:end);
		batchIds = fbgTrainIds((i-1)*batch+1:end);
	end

	me = mean(batchImgs, 2);
	co = size(batchImgs, 2) / batch;
	if i == 1
		co = 1;
	end
	avgFace = (i-1)/i*avgFace*(1-co) + 1/i*me*co;
	for j = 1:size(batchImgs,2)
		batchImgs(:,j) = batchImgs(:,j) - avgFace;
	end
	m = reshape(avgFace, fbgCols, fbgRows)';
	imshow(m / max(m(:)));
	drawnow;
	
	if i == 1
		%[m_1, M_1, TeigenVect_1, TeigenVal_1] = fGetStModel(fbgTrainImgs, eigenThreshold);
		[m_1, M_1] = size(batchImgs);
		[TeigenVect_1, TeigenVal_1] = svd(batchImgs, 'econ');
		label_1 = batchIds'; 

		[m_1, M_1, BeigenVect_1, BeigenVal_1, samplePerClass_1, meanPerClass_1] = fGetSbModel(batchImgs, label_1, eigenThreshold);
		[DiscriminativeComponents, D] = fGetDiscriminativeComponents(TeigenVect_1, TeigenVal_1, BeigenVect_1, BeigenVal_1, M_1, DeigenThreshold, dimScatterMatrix);
	else
		% for new data
		dataset_2 = batchImgs; label_2 = batchIds'; 
		%[m_2, M_2, TeigenVect_2, TeigenVal_2] = fGetStModel(dataset_2, eigenThreshold);
		[m_2, M_2] = size(batchImgs);
		[TeigenVect_2, TeigenVal_2] = svd(batchImgs, 'econ');		
		[m_2, M_2, BeigenVect_2, BeigenVal_2, samplePerClass_2, meanPerClass_2] = fGetSbModel(dataset_2, label_2, eigenThreshold);

		% update
		[outMean, outNSample, outEVect_t, outEVal_t] = fMergeSt(m_1, M_1, TeigenVect_1, TeigenVal_1, m_2, M_2, TeigenVect_2, TeigenVal_2, eigenThreshold);
		[outMean, outNSample, outEVect_b, outEVal_b, outSamplePerClass, outMeanPerClass] = fMergeSb(m_1, M_1, BeigenVect_1, BeigenVal_1, samplePerClass_1, meanPerClass_1, label_1, m_2, M_2, BeigenVect_2, BeigenVal_2, samplePerClass_2, meanPerClass_2, label_2, eigenThreshold);
		[DiscriminativeComponents, D] = fGetDiscriminativeComponents(outEVect_t, outEVal_t, outEVect_b, outEVal_b, outNSample,DeigenThreshold, dimScatterMatrix);

		% update variables
		m_1 = outMean; M_1 = outNSample; TeigenVect_1=outEVect_t; TeigenVal_1=outEVal_t;
		BeigenVect_1=outEVect_b; BeigenVal_1=outEVal_b; 
		samplePerClass_1=outSamplePerClass; meanPerClass_1=outMeanPerClass;
		label_1 = horzcat(label_1,label_2);
	end
	fprintf('%d ', i);
end

for i = 1:size(fbgTrainImgs,2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - avgFace;
end

v = DiscriminativeComponents;
trainWeights = v'*fbgTrainImgs;
vi = v;

% This is the data we need to perform recognition (during testing phase)
% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
fbgTrainMem{2} = fbgTrainIds;
fbgTrainMem{3} = trainWeights;
fbgTrainMem{4} = avgFace;