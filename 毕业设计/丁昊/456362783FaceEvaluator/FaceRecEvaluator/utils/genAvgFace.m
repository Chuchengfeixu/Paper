% Test script only, disregard
% The test was to see if we could calculate an average face for all
% datasets except one and then use that for the excepted database.
% This attempted worked, but did not provide good performance. For CCIPCA,
% the true mean must be used.

fbInit

fbgDatasets = {'acr', 'bcb', 'jbk', 'rga', 'liz', 'ssb'};


for runD = 1:length(fbgDatasets)
	fbgDataset = fbgDatasets{runD};
	fbgCurPath = [fbgBasePath '/' fbgDataset '/' fbgImgFolder];
	fprintf('Separating train/test (%d/%d%%) set images in %s, run %d...\n', fbgTrainPercent, 100 - fbgTrainPercent, fbgCurPath, 0);
	[fbgTrainFiles, fbgTestFiles, fbgIds] = getTrainTestSet(fbgCurPath, fbgTrainPercent, fbgImgExt, 0, fbgMinImgsPerUser);
	
	[fbgTrainImgs,fbgTrainIds,fbgAvgFace] = batchPictures(fbgCurPath, fbgTrainFiles, fbgImgSide, 0);
	tmpImg = getImageN(fbgCurPath, fbgTrainFiles(1), fbgImgSide);
	[fbgRows, fbgCols] = size(tmpImg);
	if runD == 1
		avg = fbgAvgFace;
		ctr = length(fbgTrainIds);
	else
		newctr = ctr + length(fbgTrainIds);
		avg = ctr / newctr * avg + (1 - ctr / newctr) * fbgAvgFace;
		ctr = newctr;
	end
	[fbgTestImgs,fbgTestIds,fbgAvgFace] = batchPictures(fbgCurPath, fbgTestFiles, fbgImgSide, 0);
	
	newctr = ctr + length(fbgTestIds);
	avg = ctr / newctr * avg + (1 - ctr / newctr) * fbgAvgFace;
	ctr = newctr;
	
	save(sprintf('genavgface_%s.mat', fbgDataset), 'fbgAvgFace');
	imwrite(reshape(fbgAvgFace / max(fbgAvgFace(:)), fbgCols, fbgRows)', sprintf('pretty-genavgface_%s.png', fbgDataset));
end

save('genavgface.mat', 'fbgAvgFace');
imwrite(reshape(fbgAvgFace / max(fbgAvgFace(:)), fbgCols, fbgRows)', 'pretty-genavgface.png');
