fbgTestImgs = fbgTestImgs';

batch = 100;
totalAccuracy = 0;
totalImgs = 0;
maxBatch = length(fbgTestIds) / batch;
for i = 1:maxBatch+1
	if i < maxBatch
		batchImgs = fbgTestImgs((i-1)*batch+1:i*batch, :);
		batchIds = fbgTestIds((i-1)*batch+1:i*batch);
	else
		batchImgs = fbgTestImgs((i-1)*batch+1:end,:);
		batchIds = fbgTestIds((i-1)*batch+1:end);
	end
	[predict_label, accuracy, dec_values] = libsvm(OPT_PREDICT, batchIds, batchImgs);
	numImgs = length(batchIds);
	totalAccuracy = totalAccuracy + accuracy(1) * numImgs;
	totalImgs = totalImgs + numImgs;
end
fbgAccuracy = totalAccuracy / totalImgs;
libsvm(OPT_CLEAR);