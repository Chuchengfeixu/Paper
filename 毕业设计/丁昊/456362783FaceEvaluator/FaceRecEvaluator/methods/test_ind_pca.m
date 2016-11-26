for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

for i = 1:length(fbgIds)
    testWeights{i} = v{i}'*fbgTestImgs;
end

reconImg = zeros(fbgRows*fbgCols,1);
matchDist = zeros(length(fbgIds),1);
resultIds = zeros(length(fbgTestIds),1);
matchDist = zeros(length(fbgIds),1);
index = zeros(length(fbgIds),1);
for i = 1:length(fbgTestIds)
	for j = 1:length(fbgIds)
		reconImg = v{j}*testWeights{j}(:,i);
		diff = fbgTestImgs(:,i) - reconImg;
		matchDist(j) = sum(diff .* diff, 1);
	end
	[best, index(i)] = min(matchDist);
end

resultIds = fbgIds(index)';

correct = find(resultIds - fbgTestIds == 0);
fbgAccuracy = 100* size(correct,1) / size(fbgTestIds,1);

if resetEigWeights, clear eigWeights; end