topX = 1;

reconImg = zeros(fbgRows*fbgCols,1);
matchDist = zeros(length(fbgIds),1);
index = zeros(length(fbgIds),topX);
for i = 1:length(fbgTestIds)
	for j = 1:length(fbgIds)
		testImg = fbgTestImgs(:,i) - avgFace{j};
		testWeight = v{j}'*testImg;
		reconImg = v{j}*testWeight;
		diff = testImg - reconImg;
		matchDist(j) = sum(diff .* diff, 1);
    end
    d = matchDist;
    for j = 1:topX
    	[best, index(i, j)] = min(d);
        d(index(i, j)) = Inf; % Remove best
    end
end

resultIds = fbgIds(index)';
if topX > 1
    resultMatrix = (resultIds == repmat(fbgTestIds, 1, topX)');
    results = max(resultMatrix, [], 1);
else
    resultMatrix = (resultIds == fbgTestIds);
    results = max(resultMatrix, [], 2);
end

correct = find(results == 1);
fbgAccuracy = 100* length(correct) / size(fbgTestIds,1);

if resetEigWeights, clear eigWeights; end